package com.marivaldojunior.critsense.ratelimit;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Marca um endpoint que chama o provedor de IA: cada chamada gasta uma ficha do limite do usuário
 * (ver {@link AiRateLimiter}).
 */
@Documented
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
public @interface AiRateLimited {}
