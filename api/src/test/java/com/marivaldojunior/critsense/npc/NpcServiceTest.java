package com.marivaldojunior.critsense.npc;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.marivaldojunior.critsense.ai.PromptCatalog.PromptId;
import com.marivaldojunior.critsense.ai.StructuredAiService;
import com.marivaldojunior.critsense.npc.dto.NpcDtos.Npc;
import com.marivaldojunior.critsense.npc.dto.NpcDtos.NpcRequest;
import com.marivaldojunior.critsense.npc.dto.NpcDtos.NpcResponse;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

/** Testa como o {@link NpcService} monta o pedido e confere a resposta. */
class NpcServiceTest {

    private final Npc dwarf =
            new Npc(
                    "Brunna",
                    SrdRace.DWARF,
                    "ferreira",
                    Alignment.LAWFUL_GOOD,
                    "Anã forte.",
                    List.of("teimosa", "generosa"),
                    "Reabrir a mina.",
                    "Vendeu a chave.",
                    "Bate o martelo.",
                    List.of("Recuperar a chave."));

    @Test
    @SuppressWarnings("unchecked")
    void camposVaziosViramEscolhaLivreEARespostaLevaAVersaoDoPrompt() {
        StructuredAiService ai = mock(StructuredAiService.class);
        when(ai.generate(eq(PromptId.NPC_GENERATOR), any(), eq(Npc.class), any())).thenReturn(dwarf);

        NpcResponse response = new NpcService(ai).generate(new NpcRequest(null, " ", null, null));

        ArgumentCaptor<Map<String, Object>> variables = ArgumentCaptor.forClass(Map.class);
        verify(ai).generate(eq(PromptId.NPC_GENERATOR), variables.capture(), eq(Npc.class), any());
        assertThat(variables.getValue())
                .containsEntry("race", "livre")
                .containsEntry("role", "livre")
                .containsEntry("alignment", "livre")
                .containsEntry("context", "livre");
        assertThat(response.npc()).isSameAs(dwarf);
        assertThat(response.promptVersion()).isEqualTo("npc-generator@v1");
    }

    @Test
    void raçaETendenciaPedidasSaoObrigatoriasNaResposta() {
        NpcRequest request =
                new NpcRequest(SrdRace.ELF, null, Alignment.CHAOTIC_GOOD, "floresta antiga");

        assertThat(NpcService.matchesRequest(request, dwarf))
                .containsExactly(
                        "race: o pedido exige ELF", "alignment: o pedido exige CHAOTIC_GOOD");
    }

    @Test
    void semPreferenciasQualquerRaçaETendenciaServem() {
        assertThat(NpcService.matchesRequest(new NpcRequest(null, null, null, null), dwarf))
                .isEmpty();
    }
}
