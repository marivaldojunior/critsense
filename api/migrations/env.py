"""Ambiente do Alembic: roda as migrações com o mesmo driver async da API."""

import asyncio
import os
from logging.config import fileConfig

from alembic import context
from sqlalchemy import Connection
from sqlalchemy.ext.asyncio import create_async_engine

# Importa os modelos para registrar as tabelas no Base.metadata.
from critsense.auth import models as _auth_models  # noqa: F401
from critsense.config import DEFAULT_DATABASE_URL
from critsense.db import Base
from critsense.encounters import models as _encounter_models  # noqa: F401

config = context.config
if config.config_file_name is not None and config.attributes.get("configure_logger", True):
    fileConfig(config.config_file_name)

# Ordem: URL passada por quem chama (ex: os testes), depois DATABASE_URL, depois o padrão local.
url = config.get_main_option("sqlalchemy.url") or os.environ.get(
    "DATABASE_URL", DEFAULT_DATABASE_URL
)


def run_migrations(connection: Connection) -> None:
    context.configure(connection=connection, target_metadata=Base.metadata)
    with context.begin_transaction():
        context.run_migrations()


async def run_online() -> None:
    engine = create_async_engine(url)
    async with engine.connect() as connection:
        await connection.run_sync(run_migrations)
    await engine.dispose()


if context.is_offline_mode():
    context.configure(url=url, target_metadata=Base.metadata, literal_binds=True)
    with context.begin_transaction():
        context.run_migrations()
else:
    asyncio.run(run_online())
