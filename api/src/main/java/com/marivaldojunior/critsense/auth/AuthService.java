package com.marivaldojunior.critsense.auth;

import com.marivaldojunior.critsense.auth.JwtTokenService.IssuedToken;
import com.marivaldojunior.critsense.common.error.ApiException;
import com.marivaldojunior.critsense.common.error.ErrorCode;
import java.time.Clock;
import java.util.Locale;
import java.util.Optional;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Cadastro e login de usuários. */
@Service
public class AuthService {

    private final UserRepository users;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenService tokens;
    private final Clock clock;

    /**
     * Hash usado quando o usuário não existe, para o login levar o mesmo tempo nos dois casos e não
     * revelar quais nomes de usuário estão cadastrados.
     */
    private final String dummyHash;

    public AuthService(
            UserRepository users,
            PasswordEncoder passwordEncoder,
            JwtTokenService tokens,
            Clock clock) {
        this.users = users;
        this.passwordEncoder = passwordEncoder;
        this.tokens = tokens;
        this.clock = clock;
        this.dummyHash = passwordEncoder.encode("dummy-password-for-timing");
    }

    @Transactional
    public IssuedToken register(String username, String password) {
        String normalized = normalize(username);
        if (users.existsByUsername(normalized)) {
            throw usernameTaken();
        }
        User user = new User(normalized, passwordEncoder.encode(password), clock.instant());
        try {
            users.saveAndFlush(user);
        } catch (DataIntegrityViolationException e) {
            // Dois cadastros simultâneos com o mesmo nome: o índice único decide.
            throw usernameTaken();
        }
        return tokens.issue(user);
    }

    @Transactional(readOnly = true)
    public IssuedToken login(String username, String password) {
        Optional<User> user = users.findByUsername(normalize(username));
        String hash = user.map(User::getPasswordHash).orElse(dummyHash);
        boolean matches = passwordEncoder.matches(password, hash);
        if (user.isEmpty() || !matches) {
            throw new ApiException(ErrorCode.INVALID_CREDENTIALS, "Usuário ou senha incorretos.");
        }
        return tokens.issue(user.get());
    }

    static String normalize(String username) {
        return username.trim().toLowerCase(Locale.ROOT);
    }

    private static ApiException usernameTaken() {
        return new ApiException(ErrorCode.USERNAME_TAKEN, "Este nome de usuário já está em uso.");
    }
}
