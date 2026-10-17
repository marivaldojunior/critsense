package com.marivaldojunior.critsense.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.util.UUID;

/** Corpos de requisição e de resposta da autenticação. */
public final class AuthDtos {

    private AuthDtos() {}

    @Schema(description = "Dados para criar uma conta.")
    public record RegisterRequest(
            @Schema(example = "thorin", description = "Letras, números, ponto, hífen ou sublinhado.")
                    @NotBlank
                    @Size(min = 3, max = 30)
                    @Pattern(regexp = "[A-Za-z0-9._-]+")
                    String username,
            // O BCrypt só usa os primeiros 72 bytes da senha.
            @Schema(example = "uma-senha-longa") @NotBlank @Size(min = 8, max = 72)
                    String password) {}

    @Schema(description = "Credenciais de uma conta existente.")
    public record LoginRequest(
            @Schema(example = "thorin") @NotBlank String username,
            @Schema(example = "uma-senha-longa") @NotBlank String password) {}

    @Schema(description = "Token de acesso. Envie no cabeçalho Authorization: Bearer <accessToken>.")
    public record TokenResponse(String accessToken, String tokenType, long expiresIn) {

        public static TokenResponse bearer(String accessToken, long expiresInSeconds) {
            return new TokenResponse(accessToken, "Bearer", expiresInSeconds);
        }
    }

    @Schema(description = "Usuário autenticado.")
    public record MeResponse(UUID id, String username) {}
}
