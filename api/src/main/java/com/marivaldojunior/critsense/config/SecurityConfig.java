package com.marivaldojunior.critsense.config;

import com.marivaldojunior.critsense.common.error.ErrorCode;
import com.marivaldojunior.critsense.common.error.ProblemDetails;
import com.nimbusds.jose.jwk.source.ImmutableSecret;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.Clock;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.MediaType;
import org.springframework.http.ProblemDetail;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.factory.PasswordEncoderFactories;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.core.DelegatingOAuth2TokenValidator;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtIssuerValidator;
import org.springframework.security.oauth2.jwt.JwtValidators;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder;
import org.springframework.security.web.SecurityFilterChain;
import tools.jackson.databind.json.JsonMapper;

/**
 * API sem sessão: cada requisição autentica pelo token JWT do cabeçalho {@code Authorization}. Só o
 * cadastro, o login, o health check e a documentação OpenAPI são públicos.
 */
@Configuration
public class SecurityConfig {

    private static final String[] PUBLIC_PATHS = {
        "/api/v1/auth/**",
        "/actuator/health/**",
        "/v3/api-docs/**",
        "/v3/api-docs.yaml",
        "/swagger-ui/**",
        "/swagger-ui.html",
        "/error"
    };

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http, JsonMapper jsonMapper) {
        http.csrf(csrf -> csrf.disable())
                .sessionManagement(
                        session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(
                        auth ->
                                auth.requestMatchers(PUBLIC_PATHS)
                                        .permitAll()
                                        .anyRequest()
                                        .authenticated())
                .oauth2ResourceServer(
                        oauth2 ->
                                oauth2.jwt(jwt -> {})
                                        .authenticationEntryPoint(
                                                (request, response, ex) ->
                                                        writeProblem(
                                                                response,
                                                                jsonMapper,
                                                                ErrorCode.UNAUTHORIZED,
                                                                "Envie um token válido no cabeçalho"
                                                                        + " Authorization."))
                                        .accessDeniedHandler(
                                                (request, response, ex) ->
                                                        writeProblem(
                                                                response,
                                                                jsonMapper,
                                                                ErrorCode.FORBIDDEN,
                                                                "Sem permissão para este recurso.")))
                .exceptionHandling(
                        exceptions ->
                                exceptions.authenticationEntryPoint(
                                        (request, response, ex) ->
                                                writeProblem(
                                                        response,
                                                        jsonMapper,
                                                        ErrorCode.UNAUTHORIZED,
                                                        "Envie um token válido no cabeçalho"
                                                                + " Authorization.")));
        return http.build();
    }

    @Bean
    SecretKey jwtSecretKey(CritsenseProperties properties) {
        byte[] secret = properties.security().jwt().secret().getBytes(StandardCharsets.UTF_8);
        return new SecretKeySpec(secret, "HmacSHA256");
    }

    @Bean
    JwtEncoder jwtEncoder(SecretKey jwtSecretKey) {
        return new NimbusJwtEncoder(new ImmutableSecret<>(jwtSecretKey));
    }

    @Bean
    JwtDecoder jwtDecoder(SecretKey jwtSecretKey, CritsenseProperties properties) {
        NimbusJwtDecoder decoder =
                NimbusJwtDecoder.withSecretKey(jwtSecretKey).macAlgorithm(MacAlgorithm.HS256).build();
        // Valida expiração (com a folga padrão) e o emissor.
        decoder.setJwtValidator(
                new DelegatingOAuth2TokenValidator<>(
                        JwtValidators.createDefault(),
                        new JwtIssuerValidator(properties.security().jwt().issuer())));
        return decoder;
    }

    @Bean
    PasswordEncoder passwordEncoder() {
        return PasswordEncoderFactories.createDelegatingPasswordEncoder();
    }

    @Bean
    Clock clock() {
        return Clock.systemUTC();
    }

    private static void writeProblem(
            HttpServletResponse response, JsonMapper jsonMapper, ErrorCode code, String detail)
            throws IOException {
        ProblemDetail problem = ProblemDetails.of(code, detail);
        response.setStatus(code.status().value());
        response.setContentType(MediaType.APPLICATION_PROBLEM_JSON_VALUE);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        jsonMapper.writeValue(response.getOutputStream(), problem);
    }
}
