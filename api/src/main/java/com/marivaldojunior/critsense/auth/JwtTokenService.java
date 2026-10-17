package com.marivaldojunior.critsense.auth;

import com.marivaldojunior.critsense.config.CritsenseProperties;
import java.time.Clock;
import java.time.Instant;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.stereotype.Service;

/**
 * Emite os tokens de acesso (JWT HS256). A validação fica com o resource server do Spring
 * Security (ver {@code SecurityConfig}).
 */
@Service
public class JwtTokenService {

    /** Claim com o nome de usuário; a claim {@code sub} tem o id. */
    public static final String USERNAME_CLAIM = "username";

    private final JwtEncoder encoder;
    private final CritsenseProperties.Jwt properties;
    private final Clock clock;

    public JwtTokenService(JwtEncoder encoder, CritsenseProperties properties, Clock clock) {
        this.encoder = encoder;
        this.properties = properties.security().jwt();
        this.clock = clock;
    }

    public IssuedToken issue(User user) {
        Instant now = clock.instant();
        JwtClaimsSet claims =
                JwtClaimsSet.builder()
                        .issuer(properties.issuer())
                        .subject(user.getId().toString())
                        .claim(USERNAME_CLAIM, user.getUsername())
                        .issuedAt(now)
                        .expiresAt(now.plus(properties.ttl()))
                        .build();
        JwsHeader header = JwsHeader.with(MacAlgorithm.HS256).build();
        String token = encoder.encode(JwtEncoderParameters.from(header, claims)).getTokenValue();
        return new IssuedToken(token, properties.ttl().toSeconds());
    }

    public record IssuedToken(String value, long expiresInSeconds) {}
}
