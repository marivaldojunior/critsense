package com.marivaldojunior.critsense.npc;

import com.marivaldojunior.critsense.npc.dto.NpcDtos.NpcRequest;
import com.marivaldojunior.critsense.npc.dto.NpcDtos.NpcResponse;
import com.marivaldojunior.critsense.ratelimit.AiRateLimited;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/npcs")
@Tag(name = "NPCs")
public class NpcController {

    private final NpcService npcService;

    public NpcController(NpcService npcService) {
        this.npcService = npcService;
    }

    @PostMapping("/generate")
    @AiRateLimited
    @Operation(
            operationId = "generateNpc",
            summary = "Gera um NPC com a IA",
            description =
                    "Conta no limite de chamadas de IA do usuário (cabeçalho X-RateLimit-Remaining)."
                            + " Erros: 429 RATE_LIMITED, 422 AI_REFUSED, 502 AI_INVALID_OUTPUT ou"
                            + " AI_PROVIDER_ERROR, 503 AI_UNAVAILABLE, 504 AI_TIMEOUT.")
    public NpcResponse generate(@Valid @RequestBody NpcRequest request) {
        return npcService.generate(request);
    }
}
