package com.marivaldojunior.critsense.config;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import java.time.Duration;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

/** Configurações próprias da API, no prefixo {@code critsense} do {@code application.yml}. */
@Validated
@ConfigurationProperties("critsense")
public record CritsenseProperties(@Valid @NotNull Ai ai) {

    /**
     * @param timeout tempo máximo de uma chamada de IA antes de a API devolver 504.
     * @param rateLimit limite de chamadas de IA por usuário.
     */
    public record Ai(@NotNull Duration timeout, @Valid @NotNull RateLimit rateLimit) {}

    /** @param requestsPerMinute chamadas de IA permitidas por usuário a cada minuto. */
    public record RateLimit(@Min(1) int requestsPerMinute) {}
}
