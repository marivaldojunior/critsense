package com.marivaldojunior.critsense.ai;

import com.marivaldojunior.critsense.ai.PromptCatalog.PromptId;
import com.marivaldojunior.critsense.common.error.ApiException;
import com.marivaldojunior.critsense.common.error.ErrorCode;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validator;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.chat.model.Generation;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.converter.BeanOutputConverter;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Service;

/**
 * Gera um objeto Java a partir de um prompt versionado, com saída sempre estruturada e validada:
 *
 * <ol>
 *   <li>o prompt recebe o JSON Schema do tipo pedido (via {@link BeanOutputConverter});
 *   <li>a resposta é convertida para o tipo e validada com Bean Validation e com as regras extras
 *       de quem chama;
 *   <li>se a resposta for inválida, o modelo recebe a lista de erros e tem mais uma tentativa;
 *   <li>se ainda for inválida, a API devolve {@link ErrorCode#AI_INVALID_OUTPUT} (502), nunca um
 *       JSON inválido para o cliente.
 * </ol>
 *
 * <p>O {@link ChatModel} vem do provedor escolhido em {@code AI_PROVIDER}. Sem provedor
 * configurado, os endpoints de IA devolvem {@link ErrorCode#AI_UNAVAILABLE} (503) e o resto da API
 * continua funcionando.
 */
@Service
public class StructuredAiService {

    private static final Logger log = LoggerFactory.getLogger(StructuredAiService.class);

    /** Uma chamada e uma nova tentativa com a lista de erros. */
    static final int MAX_ATTEMPTS = 2;

    private final ObjectProvider<ChatModel> chatModel;
    private final PromptCatalog prompts;
    private final AiGateway gateway;
    private final Validator validator;

    public StructuredAiService(
            ObjectProvider<ChatModel> chatModel, PromptCatalog prompts, AiGateway gateway, Validator validator) {
        this.chatModel = chatModel;
        this.prompts = prompts;
        this.gateway = gateway;
        this.validator = validator;
    }

    /**
     * @param promptId prompt versionado a usar.
     * @param variables variáveis do {@code user.st}; a variável {@code format} é preenchida aqui.
     * @param type tipo da resposta, que define o JSON Schema.
     * @param extraChecks regras de negócio além do Bean Validation; devolve a lista de erros (vazia
     *     quando a resposta é válida).
     */
    public <T> T generate(
            PromptId promptId, Map<String, Object> variables, Class<T> type, Function<T, List<String>> extraChecks) {
        ChatModel model = chatModel.getIfAvailable();
        if (model == null) {
            throw new ApiException(ErrorCode.AI_UNAVAILABLE, "Nenhum provedor de IA está configurado na API.");
        }

        BeanOutputConverter<T> converter = new BeanOutputConverter<>(type);
        Map<String, Object> allVariables = new HashMap<>(variables);
        allVariables.put("format", converter.getFormat());

        List<Message> messages = new ArrayList<>();
        messages.add(new SystemMessage(prompts.system(promptId)));
        messages.add(new UserMessage(prompts.user(promptId, allVariables)));

        List<String> errors = List.of();
        for (int attempt = 1; attempt <= MAX_ATTEMPTS; attempt++) {
            Prompt prompt = new Prompt(List.copyOf(messages));
            ChatResponse response = gateway.call(promptId.label(), () -> model.call(prompt));
            String text = textOf(response, promptId);

            Parsed<T> parsed = parse(converter, text, extraChecks);
            if (parsed.errors().isEmpty()) {
                log.info("{} gerado na tentativa {}", promptId.label(), attempt);
                return parsed.value();
            }

            errors = parsed.errors();
            log.warn("{}: resposta inválida na tentativa {}: {}", promptId.label(), attempt, errors);
            messages.add(new AssistantMessage(text));
            messages.add(new UserMessage(retryInstruction(errors)));
        }

        throw new ApiException(
                ErrorCode.AI_INVALID_OUTPUT,
                "A IA não devolveu uma resposta válida depois de %d tentativas.".formatted(MAX_ATTEMPTS));
    }

    private static String textOf(ChatResponse response, PromptId promptId) {
        Generation generation = response == null ? null : response.getResult();
        if (generation == null) {
            return "";
        }
        String finishReason = generation.getMetadata() == null
                ? null
                : generation.getMetadata().getFinishReason();
        if (finishReason != null && finishReason.equalsIgnoreCase("refusal")) {
            log.info("{}: pedido recusado pelo modelo", promptId.label());
            throw new ApiException(
                    ErrorCode.AI_REFUSED, "A IA recusou este pedido. Mude o texto do pedido e tente de novo.");
        }
        String text =
                generation.getOutput() == null ? null : generation.getOutput().getText();
        return text == null ? "" : text;
    }

    private <T> Parsed<T> parse(BeanOutputConverter<T> converter, String text, Function<T, List<String>> extraChecks) {
        if (text.isBlank()) {
            return Parsed.invalid(List.of("a resposta veio vazia"));
        }
        T value;
        try {
            value = converter.convert(text);
        } catch (RuntimeException e) {
            return Parsed.invalid(List.of("a resposta não é um JSON válido para o schema pedido"));
        }
        if (value == null) {
            return Parsed.invalid(List.of("a resposta veio vazia"));
        }
        List<String> errors = new ArrayList<>();
        for (ConstraintViolation<T> violation : validator.validate(value)) {
            errors.add(violation.getPropertyPath() + ": " + violation.getMessage());
        }
        errors.addAll(extraChecks.apply(value));
        return errors.isEmpty() ? Parsed.valid(value) : Parsed.invalid(List.copyOf(errors));
    }

    private static String retryInstruction(List<String> errors) {
        return "A resposta anterior tem estes problemas:\n- "
                + String.join("\n- ", errors)
                + "\nResponda de novo só com o JSON corrigido, seguindo o mesmo schema.";
    }

    private record Parsed<T>(T value, List<String> errors) {
        static <T> Parsed<T> valid(T value) {
            return new Parsed<>(value, List.of());
        }

        static <T> Parsed<T> invalid(List<String> errors) {
            return new Parsed<>(null, errors);
        }
    }
}
