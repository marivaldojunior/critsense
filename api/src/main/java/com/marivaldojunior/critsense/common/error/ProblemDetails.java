package com.marivaldojunior.critsense.common.error;

import java.net.URI;
import org.springframework.http.ProblemDetail;

/** Monta os {@link ProblemDetail} da API sempre no mesmo formato. */
public final class ProblemDetails {

    /** Nome da propriedade extra com o {@link ErrorCode}. */
    public static final String CODE_PROPERTY = "code";

    private ProblemDetails() {}

    public static ProblemDetail of(ErrorCode code, String detail) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(code.status(), detail);
        return withCode(problem, code);
    }

    /** Completa um {@link ProblemDetail} já criado (ex: pelo Spring MVC) com o {@code code}. */
    public static ProblemDetail withCode(ProblemDetail problem, ErrorCode code) {
        problem.setType(typeOf(code));
        problem.setTitle(code.title());
        problem.setProperty(CODE_PROPERTY, code.name());
        return problem;
    }

    public static URI typeOf(ErrorCode code) {
        return URI.create("urn:critsense:problem:" + code.name().toLowerCase().replace('_', '-'));
    }
}
