"""Corpos de requisição e de resposta da autenticação.

A docstring de cada classe vira a descrição do schema no contrato OpenAPI.
"""

import uuid
from typing import Annotated, Literal

from pydantic import Field

from critsense.schemas import CamelModel


class RegisterRequest(CamelModel):
    """Dados para criar uma conta."""

    username: Annotated[
        str,
        Field(
            min_length=3,
            max_length=30,
            pattern=r"^[A-Za-z0-9._-]+$",
            description="Letras, números, ponto, hífen ou sublinhado.",
            examples=["thorin"],
        ),
    ]
    password: Annotated[str, Field(min_length=8, max_length=128, examples=["uma-senha-longa"])]


class LoginRequest(CamelModel):
    """Credenciais de uma conta existente."""

    username: Annotated[str, Field(min_length=1, examples=["thorin"])]
    password: Annotated[str, Field(min_length=1, examples=["uma-senha-longa"])]


class TokenResponse(CamelModel):
    """Token de acesso. Envie no cabeçalho Authorization: Bearer <accessToken>."""

    access_token: str
    token_type: Literal["Bearer"]
    expires_in: Annotated[int, Field(description="Validade do token, em segundos.")]


class MeResponse(CamelModel):
    """Usuário autenticado."""

    id: uuid.UUID
    username: str
