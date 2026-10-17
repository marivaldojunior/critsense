package com.marivaldojunior.critsense.common.error;

import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

/**
 * Converte toda exceção dos controllers em {@code application/problem+json} (RFC 9457), sempre com
 * a propriedade {@code code}. Erros inesperados viram 500 sem detalhes internos na resposta.
 */
@RestControllerAdvice
public class GlobalExceptionHandler extends ResponseEntityExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    private static final Map<HttpStatus, ErrorCode> CODES_BY_STATUS =
            Map.of(
                    HttpStatus.BAD_REQUEST, ErrorCode.MALFORMED_REQUEST,
                    HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND,
                    HttpStatus.METHOD_NOT_ALLOWED, ErrorCode.METHOD_NOT_ALLOWED,
                    HttpStatus.UNSUPPORTED_MEDIA_TYPE, ErrorCode.UNSUPPORTED_MEDIA_TYPE);

    @ExceptionHandler(ApiException.class)
    ResponseEntity<ProblemDetail> handleApiException(ApiException ex) {
        if (ex.code().status().is5xxServerError()) {
            log.warn("Erro {}: {}", ex.code(), ex.getMessage(), ex.getCause());
        }
        HttpHeaders headers = new HttpHeaders();
        ex.headers().forEach(headers::add);
        return ResponseEntity.status(ex.code().status())
                .headers(headers)
                .body(ProblemDetails.of(ex.code(), ex.getMessage()));
    }

    @ExceptionHandler(Exception.class)
    ResponseEntity<ProblemDetail> handleUnexpected(Exception ex) {
        log.error("Erro inesperado", ex);
        return ResponseEntity.internalServerError()
                .body(ProblemDetails.of(ErrorCode.INTERNAL_ERROR, "Ocorreu um erro inesperado."));
    }

    /** Erros de Bean Validation no corpo: lista cada campo inválido em {@code errors}. */
    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(
            MethodArgumentNotValidException ex,
            HttpHeaders headers,
            HttpStatusCode status,
            WebRequest request) {
        List<Map<String, String>> errors =
                ex.getBindingResult().getFieldErrors().stream()
                        .map(
                                error ->
                                        Map.of(
                                                "field", error.getField(),
                                                "message",
                                                        String.valueOf(
                                                                error.getDefaultMessage())))
                        .toList();
        ProblemDetail problem =
                ProblemDetails.of(ErrorCode.VALIDATION_FAILED, "Um ou mais campos são inválidos.");
        problem.setProperty("errors", errors);
        return ResponseEntity.badRequest().headers(headers).body(problem);
    }

    /** Completa com {@code code} os erros que o próprio Spring MVC trata (400, 404, 405, 415...). */
    @Override
    protected ResponseEntity<Object> handleExceptionInternal(
            Exception ex,
            Object body,
            HttpHeaders headers,
            HttpStatusCode statusCode,
            WebRequest request) {
        ResponseEntity<Object> response =
                super.handleExceptionInternal(ex, body, headers, statusCode, request);
        if (response != null && response.getBody() instanceof ProblemDetail problem) {
            if (problem.getProperties() == null
                    || !problem.getProperties().containsKey(ProblemDetails.CODE_PROPERTY)) {
                ErrorCode code =
                        CODES_BY_STATUS.getOrDefault(
                                HttpStatus.resolve(statusCode.value()),
                                statusCode.is5xxServerError()
                                        ? ErrorCode.INTERNAL_ERROR
                                        : ErrorCode.MALFORMED_REQUEST);
                ProblemDetails.withCode(problem, code);
            }
        }
        return response;
    }
}
