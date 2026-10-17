package com.marivaldojunior.critsense.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.media.ArraySchema;
import io.swagger.v3.oas.models.media.Content;
import io.swagger.v3.oas.models.media.IntegerSchema;
import io.swagger.v3.oas.models.media.MediaType;
import io.swagger.v3.oas.models.media.ObjectSchema;
import io.swagger.v3.oas.models.media.Schema;
import io.swagger.v3.oas.models.media.StringSchema;
import io.swagger.v3.oas.models.responses.ApiResponse;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import java.util.List;
import org.springdoc.core.customizers.OpenApiCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Metadados do contrato OpenAPI. O contrato gerado fica versionado em {@code
 * contracts/openapi.yaml}, e o app Flutter (e o futuro front React) geram os clientes a partir dele.
 */
@Configuration
public class OpenApiConfig {

    static final String BEARER_SCHEME = "bearerAuth";
    static final String PROBLEM_SCHEMA = "Problem";

    @Bean
    OpenAPI critsenseOpenApi() {
        return new OpenAPI()
                .info(
                        new Info()
                                .title("CritSense API")
                                .version("v1")
                                .description(
                                        "API do CritSense: autenticação e ferramentas de IA para"
                                                + " mestres de D&D 5e. Conteúdo de regras restrito"
                                                + " ao SRD 5.1 (CC-BY-4.0). Todo erro segue o"
                                                + " formato application/problem+json (RFC 9457),"
                                                + " com o campo code.")
                                .license(new License().name("SRD 5.1 — CC-BY-4.0")))
                // Fixo para o contrato não depender do host de quem gerou o arquivo.
                .servers(List.of(new Server().url("http://localhost:8080").description("Local")))
                .components(
                        new Components()
                                .addSecuritySchemes(
                                        BEARER_SCHEME,
                                        new SecurityScheme()
                                                .type(SecurityScheme.Type.HTTP)
                                                .scheme("bearer")
                                                .bearerFormat("JWT")))
                .addSecurityItem(new SecurityRequirement().addList(BEARER_SCHEME));
    }

    /**
     * Documenta em toda operação a resposta de erro {@code default}, no formato {@code
     * application/problem+json}. Assim os clientes gerados têm um tipo para os erros.
     */
    @Bean
    OpenApiCustomizer problemResponses() {
        return openApi -> {
            // Registrado aqui, e não no bean OpenAPI: o springdoc monta os schemas dos
            // controllers depois e descartaria um schema adicionado antes.
            openApi.getComponents().addSchemas(PROBLEM_SCHEMA, problemSchema());
            openApi.getPaths()
                        .values()
                        .forEach(
                                path ->
                                        path.readOperations()
                                                .forEach(
                                                        operation ->
                                                                operation
                                                                        .getResponses()
                                                                        .addApiResponse(
                                                                                "default",
                                                                                problemResponse())));
        };
    }

    private static ApiResponse problemResponse() {
        return new ApiResponse()
                .description("Erro no formato RFC 9457. Veja o campo code.")
                .content(
                        new Content()
                                .addMediaType(
                                        "application/problem+json",
                                        new MediaType()
                                                .schema(
                                                        new Schema<>()
                                                                .$ref(
                                                                        "#/components/schemas/"
                                                                                + PROBLEM_SCHEMA))));
    }

    @SuppressWarnings("rawtypes")
    private static Schema problemSchema() {
        Schema<?> fieldError =
                new ObjectSchema()
                        .addProperty("field", new StringSchema())
                        .addProperty("message", new StringSchema());
        return new ObjectSchema()
                .description("Erro no formato application/problem+json (RFC 9457).")
                .addProperty("type", new StringSchema().example("urn:critsense:problem:rate-limited"))
                .addProperty("title", new StringSchema())
                .addProperty("status", new IntegerSchema())
                .addProperty("detail", new StringSchema())
                .addProperty("instance", new StringSchema())
                .addProperty(
                        "code",
                        new StringSchema()
                                .description("Código estável do erro (ex: RATE_LIMITED).")
                                .example("RATE_LIMITED"))
                .addProperty(
                        "errors",
                        new ArraySchema()
                                .items(fieldError)
                                .description("Campos inválidos, só em VALIDATION_FAILED."))
                .required(List.of("code", "status", "title"));
    }
}
