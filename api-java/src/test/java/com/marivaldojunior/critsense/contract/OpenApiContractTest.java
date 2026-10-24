package com.marivaldojunior.critsense.contract;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.marivaldojunior.critsense.auth.UserRepository;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

/**
 * Garante que {@code api-java/openapi.yaml} é igual ao contrato que o código gera. Se um endpoint
 * mudar sem o contrato ser atualizado, o teste falha (e o CI também).
 *
 * <p>Para atualizar o arquivo depois de mudar a API:
 *
 * <pre>./mvnw test -Dtest=OpenApiContractTest -Dopenapi.update=true</pre>
 *
 * <p>O teste sobe a API sem banco (o contrato não depende dele), então roda sem Docker.
 */
@SpringBootTest(
        properties = "spring.autoconfigure.exclude="
                + "org.springframework.boot.jdbc.autoconfigure.DataSourceAutoConfiguration,"
                + "org.springframework.boot.hibernate.autoconfigure.HibernateJpaAutoConfiguration,"
                + "org.springframework.boot.flyway.autoconfigure.FlywayAutoConfiguration,"
                + "org.springframework.boot.data.jpa.autoconfigure.DataJpaRepositoriesAutoConfiguration")
@AutoConfigureMockMvc
class OpenApiContractTest {

    /**
     * Contrato próprio do projeto Java de estudo. O {@code contracts/openapi.yaml} da raiz vem da API
     * Python; caminho a partir de {@code api-java/}, onde o Maven roda os testes.
     */
    private static final Path CONTRACT = Path.of("openapi.yaml");

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private UserRepository users;

    @Test
    void contratoVersionadoEstaAtualizado() throws Exception {
        String generated = mockMvc.perform(get("/v3/api-docs.yaml"))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString(StandardCharsets.UTF_8)
                .replace("\r\n", "\n");

        if (Boolean.getBoolean("openapi.update")) {
            Files.createDirectories(CONTRACT.getParent());
            Files.writeString(CONTRACT, generated, StandardCharsets.UTF_8);
        }

        assertThat(CONTRACT)
                .as("api-java/openapi.yaml não existe; gere com -Dopenapi.update=true")
                .exists();
        String committed = Files.readString(CONTRACT, StandardCharsets.UTF_8).replace("\r\n", "\n");
        assertThat(committed)
                .as("api-java/openapi.yaml está desatualizado. Rode: ./mvnw test"
                        + " -Dtest=OpenApiContractTest -Dopenapi.update=true")
                .isEqualTo(generated);
    }
}
