package com.marivaldojunior.critsense.common.error;

import org.springframework.http.HttpStatus;

/**
 * Códigos de erro estáveis da API. O cliente decide o que mostrar pelo campo {@code code} do
 * {@code ProblemDetail}, nunca pelo texto de {@code detail}, que pode mudar.
 */
public enum ErrorCode {
    VALIDATION_FAILED(HttpStatus.BAD_REQUEST, "Dados inválidos"),
    MALFORMED_REQUEST(HttpStatus.BAD_REQUEST, "Requisição malformada"),
    UNAUTHORIZED(HttpStatus.UNAUTHORIZED, "Autenticação necessária"),
    FORBIDDEN(HttpStatus.FORBIDDEN, "Acesso negado"),
    NOT_FOUND(HttpStatus.NOT_FOUND, "Recurso não encontrado"),
    METHOD_NOT_ALLOWED(HttpStatus.METHOD_NOT_ALLOWED, "Método não permitido"),
    UNSUPPORTED_MEDIA_TYPE(HttpStatus.UNSUPPORTED_MEDIA_TYPE, "Tipo de conteúdo não suportado"),
    USERNAME_TAKEN(HttpStatus.CONFLICT, "Nome de usuário em uso"),
    INVALID_CREDENTIALS(HttpStatus.UNAUTHORIZED, "Credenciais inválidas"),
    RATE_LIMITED(HttpStatus.TOO_MANY_REQUESTS, "Limite de requisições atingido"),
    AI_REFUSED(HttpStatus.UNPROCESSABLE_CONTENT, "Pedido recusado pela IA"),
    AI_INVALID_OUTPUT(HttpStatus.BAD_GATEWAY, "Resposta inválida da IA"),
    AI_PROVIDER_ERROR(HttpStatus.BAD_GATEWAY, "Falha no provedor de IA"),
    AI_TIMEOUT(HttpStatus.GATEWAY_TIMEOUT, "Tempo limite da IA esgotado"),
    AI_UNAVAILABLE(HttpStatus.SERVICE_UNAVAILABLE, "IA não configurada"),
    INTERNAL_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "Erro interno");

    private final HttpStatus status;
    private final String title;

    ErrorCode(HttpStatus status, String title) {
        this.status = status;
        this.title = title;
    }

    public HttpStatus status() {
        return status;
    }

    public String title() {
        return title;
    }
}
