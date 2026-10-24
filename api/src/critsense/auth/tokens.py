"""Emite e valida os tokens de acesso (JWT HS256)."""

import uuid
from collections.abc import Callable
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta

import jwt

from critsense.auth.models import User
from critsense.errors import ApiError, ErrorCode

ALGORITHM = "HS256"
# Claim com o nome de usuário; a claim "sub" tem o id.
USERNAME_CLAIM = "username"
# Folga para relógios um pouco diferentes entre a API e quem valida o token.
CLOCK_SKEW = timedelta(seconds=60)


@dataclass(frozen=True, slots=True)
class IssuedToken:
    value: str
    expires_in_seconds: int


@dataclass(frozen=True, slots=True)
class TokenClaims:
    user_id: uuid.UUID
    username: str


class TokenService:
    def __init__(
        self,
        secret: str,
        ttl: timedelta,
        issuer: str,
        clock: Callable[[], datetime] = lambda: datetime.now(UTC),
    ) -> None:
        self._secret = secret
        self._ttl = ttl
        self._issuer = issuer
        self._clock = clock

    def issue(self, user: User) -> IssuedToken:
        now = self._clock()
        claims = {
            "iss": self._issuer,
            "sub": str(user.id),
            USERNAME_CLAIM: user.username,
            "iat": now,
            "exp": now + self._ttl,
        }
        token = jwt.encode(claims, self._secret, algorithm=ALGORITHM)
        return IssuedToken(token, int(self._ttl.total_seconds()))

    def decode(self, token: str) -> TokenClaims:
        """Valida assinatura, expiração e emissor. Lança ``ApiError`` (401) se algo falhar."""
        try:
            claims = jwt.decode(
                token,
                self._secret,
                algorithms=[ALGORITHM],
                issuer=self._issuer,
                leeway=CLOCK_SKEW,
                options={"require": ["exp", "iat", "iss", "sub"]},
            )
            return TokenClaims(uuid.UUID(claims["sub"]), str(claims[USERNAME_CLAIM]))
        except (jwt.InvalidTokenError, KeyError, ValueError) as e:
            raise ApiError(ErrorCode.UNAUTHORIZED, "O token é inválido ou expirou.") from e
