package com.marivaldojunior.critsense.ratelimit;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import com.marivaldojunior.critsense.common.error.ApiException;
import com.marivaldojunior.critsense.common.error.ErrorCode;
import com.marivaldojunior.critsense.config.CritsenseProperties;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.ConsumptionProbe;
import io.github.bucket4j.TimeMeter;
import java.time.Duration;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * Limita as chamadas de IA por usuário com um token bucket (Bucket4j): cada usuário tem {@code
 * requestsPerMinute} fichas, repostas aos poucos ao longo de um minuto.
 *
 * <p>Os buckets ficam em memória (Caffeine) e somem depois de 10 minutos sem uso. Com mais de uma
 * instância da API, o limite passa a valer por instância; um Bucket4j distribuído (ex: com Redis)
 * resolve isso quando for preciso.
 */
@Component
public class AiRateLimiter {

    private final long requestsPerMinute;
    private final TimeMeter timeMeter;
    private final Cache<String, Bucket> buckets =
            Caffeine.newBuilder().expireAfterAccess(Duration.ofMinutes(10)).build();

    @Autowired
    public AiRateLimiter(CritsenseProperties properties) {
        this(properties.ai().rateLimit().requestsPerMinute(), TimeMeter.SYSTEM_MILLISECONDS);
    }

    AiRateLimiter(long requestsPerMinute, TimeMeter timeMeter) {
        this.requestsPerMinute = requestsPerMinute;
        this.timeMeter = timeMeter;
    }

    /**
     * Gasta uma ficha de {@code userId}.
     *
     * @return quantas fichas ainda restam.
     * @throws ApiException com {@link ErrorCode#RATE_LIMITED} e o cabeçalho {@code Retry-After}
     *     quando o usuário não tem mais fichas.
     */
    public long consume(String userId) {
        ConsumptionProbe probe = buckets.get(userId, key -> newBucket()).tryConsumeAndReturnRemaining(1);
        if (probe.isConsumed()) {
            return probe.getRemainingTokens();
        }
        long retryAfterSeconds =
                Math.max(1, TimeUnit.NANOSECONDS.toSeconds(probe.getNanosToWaitForRefill() + 999_999_999));
        throw new ApiException(
                ErrorCode.RATE_LIMITED,
                "Limite de %d chamadas de IA por minuto atingido. Tente de novo em %d s."
                        .formatted(requestsPerMinute, retryAfterSeconds),
                Map.of("Retry-After", String.valueOf(retryAfterSeconds)),
                null);
    }

    private Bucket newBucket() {
        return Bucket.builder()
                .addLimit(
                        limit ->
                                limit.capacity(requestsPerMinute)
                                        .refillGreedy(requestsPerMinute, Duration.ofMinutes(1)))
                .withCustomTimePrecision(timeMeter)
                .build();
    }
}
