package com.marivaldojunior.critsense.config;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Duration;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

/** Configurações próprias da API, no prefixo {@code critsense} do {@code application.yml}. */
@Validated
@ConfigurationProperties("critsense")
public record CritsenseProperties(
        @Valid @NotNull Ai ai, @Valid @NotNull Security security) {

    /**
     * @param timeout tempo máximo de uma chamada de IA antes de a API devolver 504.
     * @param rateLimit limite de chamadas de IA por usuário.
     */
    public record Ai(
            @NotNull Duration timeout, @Valid @NotNull RateLimit rateLimit) {}

    /** @param requestsPerMinute chamadas de IA permitidas por usuário a cada minuto. */
    public record RateLimit(@Min(1) int requestsPerMinute) {}

    public record Security(@Valid @NotNull Jwt jwt) {}

    /**
     * @param secret chave HMAC (HS256) que assina os tokens. Precisa de ao menos 32 caracteres; a
     *     API não sobe sem ela.
     * @param ttl validade de cada token.
     * @param issuer valor da claim {@code iss}.
     */
    public record Jwt(
            @NotBlank @Size(min = 32) String secret,
            @NotNull Duration ttl,
            @NotBlank String issuer) {}
}
