# Build em duas etapas: o uv só existe na etapa de build; a imagem final tem só o Python, o
# ambiente virtual com a API e as migrações.
FROM python:3.15-slim AS build
COPY --from=ghcr.io/astral-sh/uv:0.13 /uv /bin/uv

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_DOWNLOADS=0
WORKDIR /app

# Instala as dependências antes de copiar o código, para o Docker reaproveitar esta camada quando
# só o código mudar.
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-dev --no-install-project

COPY . .
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-dev --no-editable

FROM python:3.15-slim
WORKDIR /app

RUN groupadd --system critsense && useradd --system --gid critsense critsense

COPY --from=build /app/.venv /app/.venv
COPY alembic.ini ./
COPY migrations migrations

ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONUNBUFFERED=1
USER critsense

EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=5 \
    CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')"]

# Aplica as migrações e sobe a API. O exec troca o shell pelo uvicorn, que recebe os sinais do
# Docker e encerra a API com calma.
CMD ["sh", "-c", "alembic upgrade head && exec uvicorn --factory critsense.main:create_app --host 0.0.0.0 --port 8080 --proxy-headers"]
