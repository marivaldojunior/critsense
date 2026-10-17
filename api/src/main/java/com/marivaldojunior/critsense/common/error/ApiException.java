package com.marivaldojunior.critsense.common.error;

import java.util.Map;

/**
 * Erro de negócio que vira um {@code ProblemDetail} com o status e o {@code code} de {@link
 * ErrorCode}. {@code headers} vai na resposta (ex: {@code Retry-After} no 429).
 */
public class ApiException extends RuntimeException {

    private final ErrorCode code;
    private final transient Map<String, String> headers;

    public ApiException(ErrorCode code, String detail) {
        this(code, detail, Map.of(), null);
    }

    public ApiException(ErrorCode code, String detail, Throwable cause) {
        this(code, detail, Map.of(), cause);
    }

    public ApiException(ErrorCode code, String detail, Map<String, String> headers, Throwable cause) {
        super(detail, cause);
        this.code = code;
        this.headers = Map.copyOf(headers);
    }

    public ErrorCode code() {
        return code;
    }

    public Map<String, String> headers() {
        return headers;
    }
}
