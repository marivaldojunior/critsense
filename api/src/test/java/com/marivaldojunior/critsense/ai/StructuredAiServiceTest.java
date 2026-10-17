package com.marivaldojunior.critsense.ai;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.marivaldojunior.critsense.ai.PromptCatalog.PromptId;
import com.marivaldojunior.critsense.common.error.ApiException;
import com.marivaldojunior.critsense.common.error.ErrorCode;
import com.marivaldojunior.critsense.npc.NpcFixtures;
import com.marivaldojunior.critsense.npc.SrdRace;
import com.marivaldojunior.critsense.npc.dto.NpcDtos.Npc;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import java.time.Duration;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.MessageType;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.beans.factory.support.StaticListableBeanFactory;

/** Testa a geração estruturada: schema no prompt, validação, nova tentativa e erros. */
class StructuredAiServiceTest {

    private static final Map<String, Object> VARIABLES =
            Map.of("race", "livre", "role", "livre", "alignment", "livre", "context", "livre");

    private final Validator validator = Validation.buildDefaultValidatorFactory().getValidator();
    private final AiGateway gateway = new AiGateway(Duration.ofSeconds(5));
    private FakeChatModel model;
    private StructuredAiService service;

    @BeforeEach
    void setUp() {
        model = new FakeChatModel();
        service = serviceWith(model);
    }

    @AfterEach
    void tearDown() {
        gateway.destroy();
    }

    @Test
    void respostaValidaNaPrimeiraTentativa() {
        model.reply(NpcFixtures.validNpcJson());

        Npc npc = generate();

        assertThat(npc.name()).isEqualTo("Brunna Martelo-Fundo");
        assertThat(npc.race()).isEqualTo(SrdRace.DWARF);
        assertThat(model.prompts()).hasSize(1);
    }

    @Test
    void oPromptLevaASRegrasDeSistemaEOJsonSchema() {
        model.reply(NpcFixtures.validNpcJson());

        generate();

        List<Message> messages = model.prompts().getFirst().getInstructions();
        assertThat(messages.getFirst().getMessageType()).isEqualTo(MessageType.SYSTEM);
        assertThat(messages.getFirst().getText()).contains("SRD 5.1");
        assertThat(messages.get(1).getText())
                .contains("\"$schema\"")
                .contains("personalityTraits")
                .contains("HALF_ELF");
    }

    @Test
    void jsonInvalidoGanhaUmaNovaTentativaComOsErros() {
        model.reply("Claro! Aqui está o NPC: Brunna, uma anã ferreira.")
                .reply(NpcFixtures.validNpcJson());

        Npc npc = generate();

        assertThat(npc.race()).isEqualTo(SrdRace.DWARF);
        assertThat(model.prompts()).hasSize(2);
        List<Message> retry = model.prompts().get(1).getInstructions();
        assertThat(retry.get(retry.size() - 2)).isInstanceOf(AssistantMessage.class);
        assertThat(retry.getLast().getText()).contains("não é um JSON válido");
    }

    @Test
    void violacaoDoBeanValidationTambemGanhaNovaTentativa() {
        model.reply(NpcFixtures.npcWithOneTrait()).reply(NpcFixtures.validNpcJson());

        Npc npc = generate();

        assertThat(npc.personalityTraits()).hasSize(2);
        assertThat(model.prompts().get(1).getInstructions().getLast().getText())
                .contains("personalityTraits");
    }

    @Test
    void asRegrasExtrasDeQuemChamaSaoAplicadas() {
        model.reply(NpcFixtures.validNpcJson("ELF", "LAWFUL_GOOD"))
                .reply(NpcFixtures.validNpcJson("DWARF", "LAWFUL_GOOD"));

        Npc npc =
                service.generate(
                        PromptId.NPC_GENERATOR,
                        VARIABLES,
                        Npc.class,
                        n -> n.race() == SrdRace.DWARF ? List.of() : List.of("race: precisa ser DWARF"));

        assertThat(npc.race()).isEqualTo(SrdRace.DWARF);
        assertThat(model.prompts()).hasSize(2);
    }

    @Test
    void duasRespostasInvalidasDevolvemAiInvalidOutput() {
        model.reply("{}").reply("não sei");

        assertThatThrownBy(this::generate)
                .isInstanceOfSatisfying(
                        ApiException.class,
                        e -> assertThat(e.code()).isEqualTo(ErrorCode.AI_INVALID_OUTPUT));
        assertThat(model.prompts()).hasSize(StructuredAiService.MAX_ATTEMPTS);
    }

    @Test
    void recusaDoModeloDevolveAiRefusedSemNovaTentativa() {
        model.refuse();

        assertThatThrownBy(this::generate)
                .isInstanceOfSatisfying(
                        ApiException.class, e -> assertThat(e.code()).isEqualTo(ErrorCode.AI_REFUSED));
        assertThat(model.prompts()).hasSize(1);
    }

    @Test
    void semProvedorConfiguradoDevolveAiUnavailable() {
        StructuredAiService withoutModel = serviceWith(null);

        assertThatThrownBy(
                        () ->
                                withoutModel.generate(
                                        PromptId.NPC_GENERATOR, VARIABLES, Npc.class, n -> List.of()))
                .isInstanceOfSatisfying(
                        ApiException.class,
                        e -> assertThat(e.code()).isEqualTo(ErrorCode.AI_UNAVAILABLE));
    }

    private Npc generate() {
        return service.generate(PromptId.NPC_GENERATOR, VARIABLES, Npc.class, n -> List.of());
    }

    private StructuredAiService serviceWith(ChatModel chatModel) {
        StaticListableBeanFactory beans = new StaticListableBeanFactory();
        if (chatModel != null) {
            beans.addBean("chatModel", chatModel);
        }
        return new StructuredAiService(
                beans.getBeanProvider(ChatModel.class), new PromptCatalog(), gateway, validator);
    }
}
