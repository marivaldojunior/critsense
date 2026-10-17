package com.marivaldojunior.critsense.config;

import com.marivaldojunior.critsense.ratelimit.AiRateLimitInterceptor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    private final AiRateLimitInterceptor aiRateLimitInterceptor;

    public WebConfig(AiRateLimitInterceptor aiRateLimitInterceptor) {
        this.aiRateLimitInterceptor = aiRateLimitInterceptor;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(aiRateLimitInterceptor).addPathPatterns("/api/**");
    }
}
