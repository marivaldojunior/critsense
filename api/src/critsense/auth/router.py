from fastapi import APIRouter, status

from critsense.auth.dependencies import AuthServiceDep, CurrentUser
from critsense.auth.schemas import LoginRequest, MeResponse, RegisterRequest, TokenResponse
from critsense.auth.tokens import IssuedToken

router = APIRouter(prefix="/api/v1", tags=["Autenticação"])


@router.post(
    "/auth/register",
    status_code=status.HTTP_201_CREATED,
    operation_id="register",
    summary="Cria uma conta e devolve um token de acesso",
)
async def register(request: RegisterRequest, auth: AuthServiceDep) -> TokenResponse:
    return _to_response(await auth.register(request.username, request.password))


@router.post(
    "/auth/login",
    operation_id="login",
    summary="Troca usuário e senha por um token de acesso",
)
async def login(request: LoginRequest, auth: AuthServiceDep) -> TokenResponse:
    return _to_response(await auth.login(request.username, request.password))


@router.get("/me", operation_id="getMe", summary="Devolve o usuário do token")
async def me(user: CurrentUser) -> MeResponse:
    return MeResponse(id=user.user_id, username=user.username)


def _to_response(token: IssuedToken) -> TokenResponse:
    return TokenResponse(
        access_token=token.value,
        token_type="Bearer",  # noqa: S106  # tipo do token, não uma senha
        expires_in=token.expires_in_seconds,
    )
