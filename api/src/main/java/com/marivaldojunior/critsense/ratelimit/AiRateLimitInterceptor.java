package com.marivaldojunior.critsense.ratelimit;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.core.annotation.AnnotatedElementUtils;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * Aplica o {@link AiRateLimiter} nos handlers marcados com {@link AiRateLimited}. A chave é o
 * {@code sub} do token (id do usuário), então o limite segue o usuário, não o IP.
 */
@Component
public class AiRateLimitInterceptor implements HandlerInterceptor {

    /** Cabeçalho com as chamadas de IA que ainda restam no minuto. */
    public static final String REMAINING_HEADER = "X-RateLimit-Remaining";

    private final AiRateLimiter rateLimiter;

    public AiRateLimitInterceptor(AiRateLimiter rateLimiter) {
        this.rateLimiter = rateLimiter;
    }

    @Override
    public boolean preHandle(
            HttpServletRequest request, HttpServletResponse response, Object handler) {
        if (!(handler instanceof HandlerMethod method) || !isRateLimited(method)) {
            return true;
        }
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        // Os endpoints de IA exigem autenticação; sem ela o Spring Security já respondeu 401.
        if (authentication == null) {
            return true;
        }
        long remaining = rateLimiter.consume(authentication.getName());
        response.setHeader(REMAINING_HEADER, String.valueOf(remaining));
        return true;
    }

    private static boolean isRateLimited(HandlerMethod method) {
        return method.hasMethodAnnotation(AiRateLimited.class)
                || AnnotatedElementUtils.hasAnnotation(method.getBeanType(), AiRateLimited.class);
    }
}
