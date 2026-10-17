package com.marivaldojunior.critsense.ai;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.List;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.metadata.ChatGenerationMetadata;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.chat.model.Generation;
import org.springframework.ai.chat.prompt.Prompt;

/**
 * {@link ChatModel} falso para os testes: devolve as respostas da fila, em ordem, e guarda os
 * prompts recebidos. Nenhum teste chama um provedor real.
 */
public class FakeChatModel implements ChatModel {

    private final Deque<Generation> responses = new ArrayDeque<>();
    private final List<Prompt> prompts = new ArrayList<>();

    /** Enfileira uma resposta normal com [text]. */
    public FakeChatModel reply(String text) {
        responses.add(generation(text, "end_turn"));
        return this;
    }

    /** Enfileira uma recusa do modelo ({@code stop_reason: refusal}). */
    public FakeChatModel refuse() {
        responses.add(generation("", "refusal"));
        return this;
    }

    public List<Prompt> prompts() {
        return prompts;
    }

    public void reset() {
        responses.clear();
        prompts.clear();
    }

    @Override
    public synchronized ChatResponse call(Prompt prompt) {
        prompts.add(prompt);
        Generation next = responses.poll();
        if (next == null) {
            throw new IllegalStateException("FakeChatModel sem respostas na fila");
        }
        return new ChatResponse(List.of(next));
    }

    private static Generation generation(String text, String finishReason) {
        return new Generation(
                new AssistantMessage(text),
                ChatGenerationMetadata.builder().finishReason(finishReason).build());
    }
}
