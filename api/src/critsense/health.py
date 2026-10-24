"""Health checks para o Docker e para orquestradores. Ficam fora do contrato OpenAPI."""

import logging

from fastapi import APIRouter, Request
from fastapi.responses import JSONResponse
from sqlalchemy import text

log = logging.getLogger(__name__)

router = APIRouter(prefix="/health", include_in_schema=False)


@router.get("")
async def liveness() -> dict[str, str]:
    """O processo está de pé."""
    return {"status": "UP"}


@router.get("/ready")
async def readiness(request: Request) -> JSONResponse:
    """A API consegue falar com o banco."""
    try:
        async with request.app.state.engine.connect() as connection:
            await connection.execute(text("SELECT 1"))
    except Exception as e:
        log.warning("Banco indisponível", exc_info=e)
        return JSONResponse({"status": "DOWN"}, status_code=503)
    return JSONResponse({"status": "UP"})
