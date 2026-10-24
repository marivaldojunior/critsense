"""Formato único de erro da API: ``application/problem+json`` (RFC 9457), sempre com ``code``.

O cliente decide o que mostrar pelo campo ``code``, nunca pelo texto de ``detail``, que pode mudar.
"""

import logging
from collections.abc import Mapping
from enum import Enum
from http import HTTPStatus
from typing import Any, cast

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

log = logging.getLogger(__name__)

PROBLEM_MEDIA_TYPE = "application/problem+json"


class ErrorCode(Enum):
    VALIDATION_FAILED = (HTTPStatus.BAD_REQUEST, "Dados inválidos")
    MALFORMED_REQUEST = (HTTPStatus.BAD_REQUEST, "Requisição malformada")
    UNAUTHORIZED = (HTTPStatus.UNAUTHORIZED, "Autenticação necessária")
    FORBIDDEN = (HTTPStatus.FORBIDDEN, "Acesso negado")
    NOT_FOUND = (HTTPStatus.NOT_FOUND, "Recurso não encontrado")
    METHOD_NOT_ALLOWED = (HTTPStatus.METHOD_NOT_ALLOWED, "Método não permitido")
    UNSUPPORTED_MEDIA_TYPE = (HTTPStatus.UNSUPPORTED_MEDIA_TYPE, "Tipo de conteúdo não suportado")
    USERNAME_TAKEN = (HTTPStatus.CONFLICT, "Nome de usuário em uso")
    INVALID_CREDENTIALS = (HTTPStatus.UNAUTHORIZED, "Credenciais inválidas")
    RATE_LIMITED = (HTTPStatus.TOO_MANY_REQUESTS, "Limite de requisições atingido")
    AI_REFUSED = (HTTPStatus.UNPROCESSABLE_CONTENT, "Pedido recusado pela IA")
    AI_INVALID_OUTPUT = (HTTPStatus.BAD_GATEWAY, "Resposta inválida da IA")
    AI_PROVIDER_ERROR = (HTTPStatus.BAD_GATEWAY, "Falha no provedor de IA")
    AI_TIMEOUT = (HTTPStatus.GATEWAY_TIMEOUT, "Tempo limite da IA esgotado")
    AI_UNAVAILABLE = (HTTPStatus.SERVICE_UNAVAILABLE, "IA não configurada")
    INTERNAL_ERROR = (HTTPStatus.INTERNAL_SERVER_ERROR, "Erro interno")

    def __init__(self, status: HTTPStatus, title: str) -> None:
        self.status = status
        self.title = title

    @property
    def type_uri(self) -> str:
        return "urn:critsense:problem:" + self.name.lower().replace("_", "-")


_CODES_BY_STATUS = {
    HTTPStatus.NOT_FOUND: ErrorCode.NOT_FOUND,
    HTTPStatus.METHOD_NOT_ALLOWED: ErrorCode.METHOD_NOT_ALLOWED,
    HTTPStatus.UNSUPPORTED_MEDIA_TYPE: ErrorCode.UNSUPPORTED_MEDIA_TYPE,
    HTTPStatus.UNAUTHORIZED: ErrorCode.UNAUTHORIZED,
    HTTPStatus.FORBIDDEN: ErrorCode.FORBIDDEN,
}


class ApiError(Exception):
    """Erro de negócio que vira um problem+json com o status e o ``code`` de ``ErrorCode``.

    ``headers`` vai na resposta (ex: ``Retry-After`` no 429).
    """

    def __init__(
        self, code: ErrorCode, detail: str, *, headers: dict[str, str] | None = None
    ) -> None:
        super().__init__(detail)
        self.code = code
        self.detail = detail
        self.headers = headers or {}


def problem_response(
    code: ErrorCode,
    detail: str,
    *,
    headers: Mapping[str, str] | None = None,
    **extra: Any,
) -> JSONResponse:
    body = {
        "type": code.type_uri,
        "title": code.title,
        "status": code.status.value,
        "detail": detail,
        "code": code.name,
        **extra,
    }
    return JSONResponse(
        body, status_code=code.status.value, headers=headers, media_type=PROBLEM_MEDIA_TYPE
    )


async def _handle_api_error(_: Request, exc: Exception) -> JSONResponse:
    exc = cast(ApiError, exc)
    if exc.code.status >= HTTPStatus.INTERNAL_SERVER_ERROR:
        log.warning("Erro %s: %s", exc.code.name, exc.detail, exc_info=exc.__cause__)
    return problem_response(exc.code, exc.detail, headers=exc.headers)


async def _handle_validation_error(_: Request, exc: Exception) -> JSONResponse:
    """Erros de validação do corpo: lista cada campo inválido em ``errors``."""
    exc = cast(RequestValidationError, exc)
    errors = exc.errors()
    if any(error["type"] == "json_invalid" for error in errors):
        return problem_response(ErrorCode.MALFORMED_REQUEST, "O corpo não é um JSON válido.")
    fields = [{"field": _field_name(error["loc"]), "message": error["msg"]} for error in errors]
    return problem_response(
        ErrorCode.VALIDATION_FAILED, "Um ou mais campos são inválidos.", errors=fields
    )


def _field_name(loc: tuple[int | str, ...]) -> str:
    # O primeiro item diz onde o valor estava ("body", "query"...); o resto é o caminho.
    path = loc[1:] if loc and loc[0] in {"body", "query", "path", "header"} else loc
    return ".".join(str(part) for part in path) or "body"


async def _handle_http_error(_: Request, exc: Exception) -> JSONResponse:
    """Completa com ``code`` os erros que o próprio Starlette gera (404, 405...)."""
    exc = cast(StarletteHTTPException, exc)
    status = HTTPStatus(exc.status_code)
    default = (
        ErrorCode.INTERNAL_ERROR
        if status >= HTTPStatus.INTERNAL_SERVER_ERROR
        else ErrorCode.MALFORMED_REQUEST
    )
    code = _CODES_BY_STATUS.get(status, default)
    detail = exc.detail if isinstance(exc.detail, str) else status.phrase
    return problem_response(code, detail, headers=exc.headers)


async def _handle_unexpected(_: Request, exc: Exception) -> JSONResponse:
    """Erros inesperados viram 500 sem detalhes internos na resposta."""
    log.error("Erro inesperado", exc_info=exc)
    return problem_response(ErrorCode.INTERNAL_ERROR, "Ocorreu um erro inesperado.")


def register_error_handlers(app: FastAPI) -> None:
    app.add_exception_handler(ApiError, _handle_api_error)
    app.add_exception_handler(RequestValidationError, _handle_validation_error)
    app.add_exception_handler(StarletteHTTPException, _handle_http_error)
    app.add_exception_handler(Exception, _handle_unexpected)
