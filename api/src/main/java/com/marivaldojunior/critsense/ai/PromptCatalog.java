package com.marivaldojunior.critsense.ai;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

/**
 * Carrega os prompts versionados de {@code src/main/resources/prompts/<nome>/v<versão>/}. Cada
 * prompt tem um {@code system.st} (regras fixas) e um {@code user.st} (o pedido, com variáveis no
 * formato {@code {variavel}} do StringTemplate).
 *
 * <p>Para mudar um prompt, crie uma versão nova em vez de editar a antiga: assim o histórico mostra
 * qual texto gerou cada resultado, e a troca de versão fica num único lugar ({@link PromptId}).
 */
@Component
public class PromptCatalog {

    /** Prompts conhecidos e a versão em uso de cada um. */
    public enum PromptId {
        NPC_GENERATOR("npc-generator", 1);

        private final String name;
        private final int version;

        PromptId(String name, int version) {
            this.name = name;
            this.version = version;
        }

        public String path(String file) {
            return "prompts/%s/v%d/%s".formatted(name, version, file);
        }

        /** Identificador legível da versão, ex: {@code npc-generator@v1}. */
        public String label() {
            return name + "@v" + version;
        }
    }

    private final Map<String, String> cache = new ConcurrentHashMap<>();

    /** Texto fixo do prompt de sistema. */
    public String system(PromptId id) {
        return load(id.path("system.st"));
    }

    /** Prompt do usuário com as variáveis substituídas por {@code variables}. */
    public String user(PromptId id, Map<String, Object> variables) {
        return new PromptTemplate(load(id.path("user.st"))).render(variables);
    }

    private String load(String path) {
        return cache.computeIfAbsent(path, p -> {
            try {
                return new ClassPathResource(p).getContentAsString(StandardCharsets.UTF_8);
            } catch (IOException e) {
                throw new UncheckedIOException("Prompt não encontrado: " + p, e);
            }
        });
    }
}
