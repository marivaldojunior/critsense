package com.marivaldojunior.critsense.ai;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.marivaldojunior.critsense.ai.PromptCatalog.PromptId;
import java.util.Map;
import org.junit.jupiter.api.Test;

/** Garante que cada prompt versionado existe e renderiza sem sobrar variáveis. */
class PromptCatalogTest {

    private final PromptCatalog catalog = new PromptCatalog();

    @Test
    void npcGeneratorV1ExisteEUsaAsRegrasDoSrd() {
        String system = catalog.system(PromptId.NPC_GENERATOR);

        assertThat(PromptId.NPC_GENERATOR.label()).isEqualTo("npc-generator@v1");
        assertThat(system).contains("SRD 5.1").contains("português do Brasil");
    }

    @Test
    void npcGeneratorV1RenderizaTodasAsVariaveis() {
        String user =
                catalog.user(
                        PromptId.NPC_GENERATOR,
                        Map.of(
                                "race", "dwarf",
                                "role", "ferreiro",
                                "alignment", "livre",
                                "context", "Uma vila mineira nas montanhas.",
                                "format", "<formato>"));

        assertThat(user)
                .contains("Raça: dwarf")
                .contains("Papel: ferreiro")
                .contains("<contexto>Uma vila mineira nas montanhas.</contexto>")
                .contains("<formato>")
                .doesNotContain("{");
    }

    @Test
    void variavelFaltandoFalhaEmVezDeIrParaOModelo() {
        assertThatThrownBy(() -> catalog.user(PromptId.NPC_GENERATOR, Map.of("race", "elf")))
                .isInstanceOf(IllegalStateException.class);
    }
}
