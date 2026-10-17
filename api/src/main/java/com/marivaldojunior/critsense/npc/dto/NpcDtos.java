package com.marivaldojunior.critsense.npc.dto;

import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.marivaldojunior.critsense.npc.Alignment;
import com.marivaldojunior.critsense.npc.SrdRace;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.util.List;

/** Corpos de requisição e de resposta do gerador de NPCs. */
public final class NpcDtos {

    private NpcDtos() {}

    @Schema(description = "Preferências do NPC. Todo campo é opcional: o que faltar, a IA escolhe.")
    public record NpcRequest(
            @Schema(description = "Raça do NPC (SRD 5.1).") SrdRace race,
            @Schema(example = "ferreiro", description = "Ocupação ou papel no mundo.")
                    @Size(max = 60)
                    String role,
            Alignment alignment,
            @Schema(
                            example = "Uma vila mineira nas montanhas, ameaçada por kobolds.",
                            description = "Descrição livre da campanha ou da cena.")
                    @Size(max = 1000)
                    String context) {}

    /**
     * NPC gerado pela IA. Esta mesma classe define o JSON Schema enviado ao modelo, então as
     * descrições e os limites aqui orientam a geração e são validados antes de a API responder.
     */
    @Schema(description = "NPC gerado.")
    public record Npc(
            @JsonPropertyDescription("Nome do NPC, coerente com a raça.") @NotBlank @Size(max = 80)
                    String name,
            @NotNull SrdRace race,
            @JsonPropertyDescription("Ocupação ou papel no mundo.") @NotBlank @Size(max = 80)
                    String role,
            @NotNull Alignment alignment,
            @JsonPropertyDescription("Aparência em uma ou duas frases.") @NotBlank @Size(max = 400)
                    String appearance,
            @JsonPropertyDescription("De 2 a 4 traços de personalidade curtos.")
                    @NotNull
                    @Size(min = 2, max = 4)
                    List<@NotBlank @Size(max = 120) String> personalityTraits,
            @JsonPropertyDescription("O que o NPC quer.") @NotBlank @Size(max = 300)
                    String motivation,
            @JsonPropertyDescription("Algo que o NPC esconde.") @NotBlank @Size(max = 300)
                    String secret,
            @JsonPropertyDescription("Jeito de falar ou maneirismo para o mestre interpretar.")
                    @NotBlank
                    @Size(max = 200)
                    String mannerism,
            @JsonPropertyDescription("De 1 a 3 ganchos de aventura que envolvem o grupo.")
                    @NotNull
                    @Size(min = 1, max = 3)
                    List<@NotBlank @Size(max = 300) String> storyHooks) {}

    @Schema(description = "NPC gerado e a versão do prompt usada.")
    public record NpcResponse(
            Npc npc,
            @Schema(example = "npc-generator@v1", description = "Prompt que gerou este NPC.")
                    String promptVersion) {}
}
