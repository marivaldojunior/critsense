package com.marivaldojunior.critsense.ai;

import com.marivaldojunior.critsense.common.error.ApiException;
import com.marivaldojunior.critsense.common.error.ErrorCode;
import com.marivaldojunior.critsense.config.CritsenseProperties;
import java.io.InterruptedIOException;
import java.net.SocketTimeoutException;
import java.net.http.HttpTimeoutException;
import java.time.Duration;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeoutException;
import java.util.function.Supplier;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.DisposableBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * Ponto único por onde passa toda chamada ao provedor de IA. Aplica o tempo máximo de {@code
 * critsense.ai.timeout} e troca as exceções do provedor pelos erros da API:
 *
 * <ul>
 *   <li>tempo esgotado (do lado da API ou do cliente HTTP do provedor): {@link
 *       ErrorCode#AI_TIMEOUT} (504);
 *   <li>qualquer outra falha do provedor: {@link ErrorCode#AI_PROVIDER_ERROR} (502).
 * </ul>
 *
 * <p>Uma {@link ApiException} lançada dentro da chamada passa sem mudança.
 */
@Component
public class AiGateway implements DisposableBean {

    private static final Logger log = LoggerFactory.getLogger(AiGateway.class);

    private final Duration timeout;
    private final ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();

    @Autowired
    public AiGateway(CritsenseProperties properties) {
        this(properties.ai().timeout());
    }

    AiGateway(Duration timeout) {
        this.timeout = timeout;
    }

    public <T> T call(String operation, Supplier<T> call) {
        Future<T> future = executor.submit(call::get);
        try {
            return future.get(timeout.toMillis(), java.util.concurrent.TimeUnit.MILLISECONDS);
        } catch (TimeoutException e) {
            future.cancel(true);
            throw timeoutError(operation, e);
        } catch (InterruptedException e) {
            future.cancel(true);
            Thread.currentThread().interrupt();
            throw new ApiException(ErrorCode.AI_PROVIDER_ERROR, "A chamada de IA foi interrompida.", e);
        } catch (ExecutionException e) {
            throw translate(operation, e.getCause());
        }
    }

    private ApiException translate(String operation, Throwable failure) {
        if (failure instanceof ApiException apiException) {
            return apiException;
        }
        if (isTimeout(failure)) {
            return timeoutError(operation, failure);
        }
        log.warn("Falha do provedor de IA em {}", operation, failure);
        return new ApiException(
                ErrorCode.AI_PROVIDER_ERROR,
                "O provedor de IA falhou. Tente de novo em alguns instantes.",
                failure);
    }

    private ApiException timeoutError(String operation, Throwable cause) {
        log.warn("Tempo esgotado em {} (limite de {})", operation, timeout);
        return new ApiException(
                ErrorCode.AI_TIMEOUT,
                "A IA demorou mais que %d s para responder.".formatted(timeout.toSeconds()),
                cause);
    }

    /** Procura na cadeia de causas um timeout de rede de qualquer cliente HTTP. */
    static boolean isTimeout(Throwable failure) {
        for (Throwable t = failure; t != null; t = t.getCause()) {
            if (t instanceof TimeoutException
                    || t instanceof SocketTimeoutException
                    || t instanceof HttpTimeoutException
                    || t instanceof InterruptedIOException) {
                return true;
            }
            if (t.getCause() == t) {
                break;
            }
        }
        return false;
    }

    @Override
    public void destroy() {
        executor.shutdownNow();
    }
}
