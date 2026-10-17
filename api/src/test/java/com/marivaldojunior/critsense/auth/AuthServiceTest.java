package com.marivaldojunior.critsense.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.marivaldojunior.critsense.auth.JwtTokenService.IssuedToken;
import com.marivaldojunior.critsense.common.error.ApiException;
import com.marivaldojunior.critsense.common.error.ErrorCode;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.crypto.factory.PasswordEncoderFactories;
import org.springframework.security.crypto.password.PasswordEncoder;

/** Regras de cadastro e login do {@link AuthService}, sem banco. */
class AuthServiceTest {

    private final Clock clock = Clock.fixed(Instant.parse("2026-10-17T12:00:00Z"), ZoneOffset.UTC);
    private final PasswordEncoder passwordEncoder = PasswordEncoderFactories.createDelegatingPasswordEncoder();

    private UserRepository users;
    private JwtTokenService tokens;
    private AuthService service;

    @BeforeEach
    void setUp() {
        users = mock(UserRepository.class);
        tokens = mock(JwtTokenService.class);
        when(tokens.issue(any())).thenReturn(new IssuedToken("token", 3600));
        service = new AuthService(users, passwordEncoder, tokens, clock);
    }

    @Test
    void registerSalvaONomeEmMinusculasEASenhaComoHash() {
        IssuedToken token = service.register("  Thorin ", "uma-senha-longa");

        ArgumentCaptor<User> saved = ArgumentCaptor.forClass(User.class);
        verify(users).saveAndFlush(saved.capture());
        assertThat(saved.getValue().getUsername()).isEqualTo("thorin");
        assertThat(saved.getValue().getPasswordHash())
                .isNotEqualTo("uma-senha-longa")
                .startsWith("{bcrypt}");
        assertThat(passwordEncoder.matches("uma-senha-longa", saved.getValue().getPasswordHash()))
                .isTrue();
        assertThat(saved.getValue().getCreatedAt()).isEqualTo(clock.instant());
        assertThat(token.value()).isEqualTo("token");
    }

    @Test
    void registerComNomeJaUsadoDevolveUsernameTaken() {
        when(users.existsByUsername("thorin")).thenReturn(true);

        assertThatThrownBy(() -> service.register("THORIN", "uma-senha-longa"))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).code())
                .isEqualTo(ErrorCode.USERNAME_TAKEN);
        verify(users, never()).saveAndFlush(any());
    }

    @Test
    void registerSimultaneoBarradoPeloIndiceUnicoDevolveUsernameTaken() {
        when(users.saveAndFlush(any())).thenThrow(new DataIntegrityViolationException("uq"));

        assertThatThrownBy(() -> service.register("thorin", "uma-senha-longa"))
                .extracting(e -> ((ApiException) e).code())
                .isEqualTo(ErrorCode.USERNAME_TAKEN);
    }

    @Test
    void loginComSenhaCertaEmiteOToken() {
        User user = new User("thorin", passwordEncoder.encode("uma-senha-longa"), clock.instant());
        when(users.findByUsername("thorin")).thenReturn(Optional.of(user));

        IssuedToken token = service.login("Thorin", "uma-senha-longa");

        assertThat(token.value()).isEqualTo("token");
        verify(tokens).issue(user);
    }

    @Test
    void loginComSenhaErradaDevolveInvalidCredentials() {
        User user = new User("thorin", passwordEncoder.encode("uma-senha-longa"), clock.instant());
        when(users.findByUsername("thorin")).thenReturn(Optional.of(user));

        assertThatThrownBy(() -> service.login("thorin", "senha-errada"))
                .extracting(e -> ((ApiException) e).code())
                .isEqualTo(ErrorCode.INVALID_CREDENTIALS);
    }

    @Test
    void loginDeUsuarioInexistenteDevolveOMesmoErro() {
        when(users.findByUsername("ninguem")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.login("ninguem", "qualquer-senha"))
                .extracting(e -> ((ApiException) e).code())
                .isEqualTo(ErrorCode.INVALID_CREDENTIALS);
        verify(tokens, never()).issue(any());
    }
}
