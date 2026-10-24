package com.marivaldojunior.critsense.ratelimit;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.marivaldojunior.critsense.common.error.ApiException;
import com.marivaldojunior.critsense.common.error.ErrorCode;
import io.github.bucket4j.TimeMeter;
import java.time.Duration;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

/** Testa o token bucket por usuário com um relógio controlado pelo teste. */
class AiRateLimiterTest {

    private FakeTimeMeter time;
    private AiRateLimiter limiter;

    @BeforeEach
    void setUp() {
        time = new FakeTimeMeter();
        limiter = new AiRateLimiter(3, time);
    }

    @Test
    void permiteAteOLimiteEDevolveAsFichasRestantes() {
        assertThat(limiter.consume("u1")).isEqualTo(2);
        assertThat(limiter.consume("u1")).isEqualTo(1);
        assertThat(limiter.consume("u1")).isZero();
    }

    @Test
    void acimaDoLimiteDevolveRateLimitedComRetryAfter() {
        consumeAll("u1");

        assertThatThrownBy(() -> limiter.consume("u1")).isInstanceOfSatisfying(ApiException.class, e -> {
            assertThat(e.code()).isEqualTo(ErrorCode.RATE_LIMITED);
            // 3 fichas por minuto: uma ficha volta a cada 20 s.
            assertThat(e.headers()).containsEntry("Retry-After", "20");
        });
    }

    @Test
    void asFichasVoltamComOTempo() {
        consumeAll("u1");

        time.advance(Duration.ofSeconds(20));

        assertThat(limiter.consume("u1")).isZero();
    }

    @Test
    void cadaUsuarioTemOProprioLimite() {
        consumeAll("u1");

        assertThat(limiter.consume("u2")).isEqualTo(2);
    }

    private void consumeAll(String userId) {
        for (int i = 0; i < 3; i++) {
            limiter.consume(userId);
        }
    }

    private static final class FakeTimeMeter implements TimeMeter {
        private long nanos;

        void advance(Duration duration) {
            nanos += duration.toNanos();
        }

        @Override
        public long currentTimeNanos() {
            return nanos;
        }

        @Override
        public boolean isWallClockBased() {
            return false;
        }
    }
}
