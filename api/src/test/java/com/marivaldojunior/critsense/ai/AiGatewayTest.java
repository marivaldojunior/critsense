package com.marivaldojunior.critsense.ai;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.marivaldojunior.critsense.common.error.ApiException;
import com.marivaldojunior.critsense.common.error.ErrorCode;
import java.io.UncheckedIOException;
import java.net.SocketTimeoutException;
import java.time.Duration;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;

/** Testa o tempo máximo e a tradução de erros do {@link AiGateway}. */
class AiGatewayTest {

    private final AiGateway gateway = new AiGateway(Duration.ofMillis(200));

    @AfterEach
    void tearDown() {
        gateway.destroy();
    }

    @Test
    void devolveOResultadoDaChamada() {
        assertThat(gateway.call("teste", () -> "ok")).isEqualTo("ok");
    }

    @Test
    void chamadaLentaDevolveAiTimeout() {
        assertThatThrownBy(
                        () ->
                                gateway.call(
                                        "teste",
                                        () -> {
                                            sleep(Duration.ofSeconds(5));
                                            return "tarde demais";
                                        }))
                .isInstanceOfSatisfying(
                        ApiException.class, e -> assertThat(e.code()).isEqualTo(ErrorCode.AI_TIMEOUT));
    }

    @Test
    void timeoutDoClienteHttpDoProvedorTambemViraAiTimeout() {
        assertThatThrownBy(
                        () ->
                                gateway.call(
                                        "teste",
                                        () -> {
                                            throw new UncheckedIOException(
                                                    new SocketTimeoutException("read timed out"));
                                        }))
                .isInstanceOfSatisfying(
                        ApiException.class, e -> assertThat(e.code()).isEqualTo(ErrorCode.AI_TIMEOUT));
    }

    @Test
    void outraFalhaDoProvedorViraAiProviderError() {
        assertThatThrownBy(
                        () ->
                                gateway.call(
                                        "teste",
                                        () -> {
                                            throw new IllegalStateException("401 invalid x-api-key");
                                        }))
                .isInstanceOfSatisfying(
                        ApiException.class,
                        e -> {
                            assertThat(e.code()).isEqualTo(ErrorCode.AI_PROVIDER_ERROR);
                            // O detalhe do provedor não vai para o cliente.
                            assertThat(e.getMessage()).doesNotContain("x-api-key");
                        });
    }

    @Test
    void apiExceptionLancadaNaChamadaPassaSemMudanca() {
        ApiException refused = new ApiException(ErrorCode.AI_REFUSED, "recusado");

        assertThatThrownBy(
                        () ->
                                gateway.call(
                                        "teste",
                                        () -> {
                                            throw refused;
                                        }))
                .isSameAs(refused);
    }

    private static void sleep(Duration duration) {
        try {
            Thread.sleep(duration);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
