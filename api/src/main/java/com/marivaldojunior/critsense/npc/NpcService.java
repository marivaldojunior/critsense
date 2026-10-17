package com.marivaldojunior.critsense.npc;

import com.marivaldojunior.critsense.ai.PromptCatalog.PromptId;
import com.marivaldojunior.critsense.ai.StructuredAiService;
import com.marivaldojunior.critsense.npc.dto.NpcDtos.Npc;
import com.marivaldojunior.critsense.npc.dto.NpcDtos.NpcRequest;
import com.marivaldojunior.critsense.npc.dto.NpcDtos.NpcResponse;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;

/** Gera NPCs com a IA, respeitando as preferências do pedido. */
@Service
public class NpcService {

    static final String FREE_CHOICE = "livre";

    private final StructuredAiService ai;

    public NpcService(StructuredAiService ai) {
        this.ai = ai;
    }

    public NpcResponse generate(NpcRequest request) {
        Map<String, Object> variables =
                Map.of(
                        "race", request.race() == null ? FREE_CHOICE : request.race().name(),
                        "role", orFree(request.role()),
                        "alignment",
                                request.alignment() == null
                                        ? FREE_CHOICE
                                        : request.alignment().name(),
                        "context", orFree(request.context()));

        Npc npc =
                ai.generate(
                        PromptId.NPC_GENERATOR,
                        variables,
                        Npc.class,
                        generated -> matchesRequest(request, generated));
        return new NpcResponse(npc, PromptId.NPC_GENERATOR.label());
    }

    /** A raça e a tendência pedidas são obrigatórias na resposta; o resto é sugestão. */
    static List<String> matchesRequest(NpcRequest request, Npc npc) {
        List<String> errors = new ArrayList<>();
        if (request.race() != null && npc.race() != request.race()) {
            errors.add("race: o pedido exige " + request.race());
        }
        if (request.alignment() != null && npc.alignment() != request.alignment()) {
            errors.add("alignment: o pedido exige " + request.alignment());
        }
        return errors;
    }

    private static String orFree(String value) {
        return value == null || value.isBlank() ? FREE_CHOICE : value.trim();
    }
}
