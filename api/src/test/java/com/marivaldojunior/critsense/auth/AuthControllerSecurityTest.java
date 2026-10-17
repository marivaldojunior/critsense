package com.marivaldojunior.critsense.auth;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.marivaldojunior.critsense.auth.JwtTokenService.IssuedToken;
import com.marivaldojunior.critsense.common.error.ApiException;
import com.marivaldojunior.critsense.common.error.ErrorCode;
import com.marivaldojunior.critsense.config.CritsenseProperties;
import com.marivaldojunior.critsense.config.SecurityConfig;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

/**
 * Testa a camada web da autenticação com a configuração de segurança real: rotas públicas, token
 * válido, token ausente ou vencido e o formato dos erros 401.
 */
@WebMvcTest(AuthController.class)
@Import({SecurityConfig.class, JwtTokenService.class})
@EnableConfigurationProperties(CritsenseProperties.class)
class AuthControllerSecurityTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private JwtTokenService tokens;
    @Autowired private JwtEncoder jwtEncoder;
    @Autowired private CritsenseProperties properties;

    @MockitoBean private AuthService authService;

    private final User user = new User("thorin", "{noop}x", Instant.now());

    @Test
    void cadastroEPublicoEDevolve201ComOToken() throws Exception {
        when(authService.register("thorin", "uma-senha-longa"))
                .thenReturn(new IssuedToken("abc", 86400));

        mockMvc.perform(
                        post("/api/v1/auth/register")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(
                                        """
                                        {"username": "thorin", "password": "uma-senha-longa"}
                                        """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.accessToken").value("abc"))
                .andExpect(jsonPath("$.tokenType").value("Bearer"))
                .andExpect(jsonPath("$.expiresIn").value(86400));
    }

    @Test
    void cadastroComDadosInvalidosDevolveValidationFailed() throws Exception {
        mockMvc.perform(
                        post("/api/v1/auth/register")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(
                                        """
                                        {"username": "a b", "password": "curta"}
                                        """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_FAILED"))
                .andExpect(jsonPath("$.errors.length()").value(2));
    }

    @Test
    void loginComCredenciaisErradasDevolve401ComCode() throws Exception {
        when(authService.login(anyString(), anyString()))
                .thenThrow(new ApiException(ErrorCode.INVALID_CREDENTIALS, "Usuário ou senha incorretos."));

        mockMvc.perform(
                        post("/api/v1/auth/login")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(
                                        """
                                        {"username": "thorin", "password": "errada"}
                                        """))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("INVALID_CREDENTIALS"));
    }

    @Test
    void meSemTokenDevolve401NoFormatoProblemDetail() throws Exception {
        mockMvc.perform(get("/api/v1/me"))
                .andExpect(status().isUnauthorized())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_PROBLEM_JSON))
                .andExpect(jsonPath("$.code").value("UNAUTHORIZED"))
                .andExpect(jsonPath("$.status").value(401));
    }

    @Test
    void meComTokenValidoDevolveOUsuario() throws Exception {
        String token = tokens.issue(user).value();

        mockMvc.perform(get("/api/v1/me").header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(user.getId().toString()))
                .andExpect(jsonPath("$.username").value("thorin"));
    }

    @Test
    void meComTokenVencidoDevolve401() throws Exception {
        Clock past =
                Clock.fixed(
                        Instant.now().minus(properties.security().jwt().ttl()).minus(Duration.ofHours(1)),
                        ZoneOffset.UTC);
        String expired = new JwtTokenService(jwtEncoder, properties, past).issue(user).value();

        mockMvc.perform(get("/api/v1/me").header("Authorization", "Bearer " + expired))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHORIZED"));
    }

    @Test
    void meComTokenAdulteradoDevolve401() throws Exception {
        String token = tokens.issue(user).value();
        String tampered = token.substring(0, token.length() - 2) + "xx";

        mockMvc.perform(get("/api/v1/me").header("Authorization", "Bearer " + tampered))
                .andExpect(status().isUnauthorized());
    }
}
