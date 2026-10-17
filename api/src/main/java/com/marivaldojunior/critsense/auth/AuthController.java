package com.marivaldojunior.critsense.auth;

import com.marivaldojunior.critsense.auth.JwtTokenService.IssuedToken;
import com.marivaldojunior.critsense.auth.dto.AuthDtos.LoginRequest;
import com.marivaldojunior.critsense.auth.dto.AuthDtos.MeResponse;
import com.marivaldojunior.critsense.auth.dto.AuthDtos.RegisterRequest;
import com.marivaldojunior.critsense.auth.dto.AuthDtos.TokenResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
@Tag(name = "Autenticação")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/auth/register")
    @ResponseStatus(HttpStatus.CREATED)
    @SecurityRequirements
    @Operation(operationId = "register", summary = "Cria uma conta e devolve um token de acesso")
    public TokenResponse register(@Valid @RequestBody RegisterRequest request) {
        return toResponse(authService.register(request.username(), request.password()));
    }

    @PostMapping("/auth/login")
    @SecurityRequirements
    @Operation(operationId = "login", summary = "Troca usuário e senha por um token de acesso")
    public TokenResponse login(@Valid @RequestBody LoginRequest request) {
        return toResponse(authService.login(request.username(), request.password()));
    }

    @GetMapping("/me")
    @Operation(operationId = "getMe", summary = "Devolve o usuário do token")
    public MeResponse me(@AuthenticationPrincipal Jwt jwt) {
        return new MeResponse(UUID.fromString(jwt.getSubject()), jwt.getClaimAsString(JwtTokenService.USERNAME_CLAIM));
    }

    private static TokenResponse toResponse(IssuedToken token) {
        return TokenResponse.bearer(token.value(), token.expiresInSeconds());
    }
}
