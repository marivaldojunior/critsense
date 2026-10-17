package com.marivaldojunior.critsense.npc;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.jayway.jsonpath.JsonPath;
import com.marivaldojunior.critsense.TestcontainersConfiguration;
import com.marivaldojunior.critsense.ai.FakeChatModel;
import com.marivaldojunior.critsense.auth.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.testcontainers.junit.jupiter.Testcontainers;

/**
 * Fluxo completo do gerador de NPCs: cadastro, token e geração, com PostgreSQL real e um {@link
 * FakeChatModel} no lugar do provedor. Sem Docker na máquina, o teste é pulado.
 */
@Testcontainers(disabledWithoutDocker = true)
@Import({TestcontainersConfiguration.class, NpcIntegrationTest.FakeModelConfig.class})
@SpringBootTest
@AutoConfigureMockMvc
class NpcIntegrationTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private FakeChatModel model;
    @Autowired private UserRepository users;

    @BeforeEach
    void setUp() {
        users.deleteAll();
        model.reset();
    }

    @Test
    void usuarioCadastradoGeraUmNpc() throws Exception {
        model.reply("resposta sem JSON").reply(NpcFixtures.validNpcJson("DWARF", "LAWFUL_GOOD"));

        mockMvc.perform(
                        post("/api/v1/npcs/generate")
                                .header("Authorization", "Bearer " + registerAndGetToken())
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("{\"race\": \"DWARF\", \"role\": \"ferreira\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.npc.race").value("DWARF"))
                .andExpect(jsonPath("$.npc.storyHooks.length()").value(1))
                .andExpect(jsonPath("$.promptVersion").value("npc-generator@v1"));

        // A primeira resposta era inválida: o serviço pediu de novo, com a lista de erros.
        assertThat(model.prompts()).hasSize(2);
        assertThat(model.prompts().getFirst().getUserMessage().getText())
                .contains("Raça: DWARF")
                .contains("Papel: ferreira");
    }

    private String registerAndGetToken() throws Exception {
        String body =
                mockMvc.perform(
                                post("/api/v1/auth/register")
                                        .contentType(MediaType.APPLICATION_JSON)
                                        .content(
                                                """
                                                {"username": "mestre", "password": "uma-senha-longa"}
                                                """))
                        .andExpect(status().isCreated())
                        .andReturn()
                        .getResponse()
                        .getContentAsString();
        return JsonPath.read(body, "$.accessToken");
    }

    @TestConfiguration(proxyBeanMethods = false)
    static class FakeModelConfig {
        @Bean
        FakeChatModel fakeChatModel() {
            return new FakeChatModel();
        }
    }
}
