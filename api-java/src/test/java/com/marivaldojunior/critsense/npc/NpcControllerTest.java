package com.marivaldojunior.critsense.npc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.marivaldojunior.critsense.auth.JwtTokenService;
import com.marivaldojunior.critsense.common.error.ApiException;
import com.marivaldojunior.critsense.common.error.ErrorCode;
import com.marivaldojunior.critsense.config.CritsenseProperties;
import com.marivaldojunior.critsense.config.SecurityConfig;
import com.marivaldojunior.critsense.npc.dto.NpcDtos.Npc;
import com.marivaldojunior.critsense.npc.dto.NpcDtos.NpcResponse;
import com.marivaldojunior.critsense.ratelimit.AiRateLimiter;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;

/** Camada web do gerador de NPCs: autenticação, validação, rate limit e erros da IA. */
@WebMvcTest(controllers = NpcController.class, properties = "critsense.ai.rate-limit.requests-per-minute=2")
@Import({SecurityConfig.class, JwtTokenService.class, AiRateLimiter.class})
@EnableConfigurationProperties(CritsenseProperties.class)
class NpcControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private NpcService npcService;

    private final NpcResponse response = new NpcResponse(
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
                    List.of("Recuperar a chave.")),
            "npc-generator@v1");

    @Test
    void semTokenDevolve401() throws Exception {
        mockMvc.perform(generate("{}"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHORIZED"));
    }

    @Test
    void comTokenDevolveONpcEAsChamadasRestantes() throws Exception {
        when(npcService.generate(any())).thenReturn(response);

        mockMvc.perform(generate("{\"race\": \"DWARF\"}").with(jwt().jwt(j -> j.subject("user-ok"))))
                .andExpect(status().isOk())
                .andExpect(header().string("X-RateLimit-Remaining", "1"))
                .andExpect(jsonPath("$.npc.name").value("Brunna"))
                .andExpect(jsonPath("$.npc.race").value("DWARF"))
                .andExpect(jsonPath("$.promptVersion").value("npc-generator@v1"));
    }

    @Test
    void acimaDoLimiteDevolve429ComRetryAfter() throws Exception {
        when(npcService.generate(any())).thenReturn(response);
        var user = jwt().jwt(j -> j.subject("user-limit"));

        mockMvc.perform(generate("{}").with(user)).andExpect(status().isOk());
        mockMvc.perform(generate("{}").with(user)).andExpect(status().isOk());
        mockMvc.perform(generate("{}").with(user))
                .andExpect(status().isTooManyRequests())
                .andExpect(header().exists("Retry-After"))
                .andExpect(jsonPath("$.code").value("RATE_LIMITED"));
    }

    @Test
    void racaForaDoSrdDevolve400() throws Exception {
        mockMvc.perform(generate("{\"race\": \"WARFORGED\"}").with(jwt().jwt(j -> j.subject("user-race"))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("MALFORMED_REQUEST"));
    }

    @Test
    void contextoLongoDemaisDevolveValidationFailed() throws Exception {
        String context = "a".repeat(1001);

        mockMvc.perform(generate("{\"context\": \"" + context + "\"}").with(jwt().jwt(j -> j.subject("user-context"))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_FAILED"))
                .andExpect(jsonPath("$.errors[0].field").value("context"));
    }

    @Test
    void erroDaIaVemNoFormatoProblemDetail() throws Exception {
        when(npcService.generate(any())).thenThrow(new ApiException(ErrorCode.AI_TIMEOUT, "A IA demorou demais."));

        mockMvc.perform(generate("{}").with(jwt().jwt(j -> j.subject("user-timeout"))))
                .andExpect(status().isGatewayTimeout())
                .andExpect(jsonPath("$.code").value("AI_TIMEOUT"));
    }

    private static MockHttpServletRequestBuilder generate(String body) {
        return post("/api/v1/npcs/generate")
                .contentType(MediaType.APPLICATION_JSON)
                .content(body);
    }
}
