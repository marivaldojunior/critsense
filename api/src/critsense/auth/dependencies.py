from typing import Annotated

from fastapi import Depends, Request
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from critsense.auth.repository import SqlUserRepository, UserRepository
from critsense.auth.service import AuthService
from critsense.auth.tokens import TokenClaims, TokenService
from critsense.db import SessionDep
from critsense.errors import ApiError, ErrorCode

# auto_error=False: a falta do token vira o nosso problem+json, não o erro padrão do FastAPI.
# O nome "bearerAuth" é o do esquema de segurança no contrato OpenAPI.
_bearer = HTTPBearer(scheme_name="bearerAuth", bearerFormat="JWT", auto_error=False)


def get_token_service(request: Request) -> TokenService:
    service: TokenService = request.app.state.token_service
    return service


def get_user_repository(session: SessionDep) -> UserRepository:
    return SqlUserRepository(session)


def get_auth_service(
    request: Request,
    users: Annotated[UserRepository, Depends(get_user_repository)],
    tokens: Annotated[TokenService, Depends(get_token_service)],
) -> AuthService:
    return AuthService(users, request.app.state.password_hasher, tokens)


def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(_bearer)],
    tokens: Annotated[TokenService, Depends(get_token_service)],
) -> TokenClaims:
    """Autentica pelo token do cabeçalho ``Authorization``, sem consultar o banco."""
    if credentials is None:
        raise ApiError(ErrorCode.UNAUTHORIZED, "Envie um token válido no cabeçalho Authorization.")
    return tokens.decode(credentials.credentials)


AuthServiceDep = Annotated[AuthService, Depends(get_auth_service)]
CurrentUser = Annotated[TokenClaims, Depends(get_current_user)]
