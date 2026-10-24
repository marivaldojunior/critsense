"""Contrato OpenAPI da API, versionado em ``contracts/openapi.yaml``.

O app Flutter (e o futuro front React) geram os clientes a partir desse arquivo. Depois de mudar um
endpoint, atualize o arquivo com ``uv run python -m critsense.openapi``. O teste do contrato (e o
CI) falha quando o arquivo está diferente do contrato gerado pelo código.
"""

import argparse
import io
import sys
from pathlib import Path
from typing import Any

from fastapi import FastAPI
from fastapi.openapi.utils import get_openapi
from pydantic import SecretStr
from ruamel.yaml import YAML

DEFAULT_CONTRACT = Path(__file__).resolve().parents[3] / "contracts" / "openapi.yaml"

DESCRIPTION = (
    "API do CritSense: autenticação e ferramentas de IA para mestres de D&D 5e. Conteúdo de"
    " regras restrito ao SRD 5.1 (CC-BY-4.0). Todo erro segue o formato"
    " application/problem+json (RFC 9457), com o campo code."
)

_PROBLEM_REF = "#/components/schemas/Problem"

PROBLEM_SCHEMA: dict[str, Any] = {
    "type": "object",
    "description": "Erro no formato application/problem+json (RFC 9457).",
    "properties": {
        "type": {"type": "string", "examples": ["urn:critsense:problem:rate-limited"]},
        "title": {"type": "string"},
        "status": {"type": "integer"},
        "detail": {"type": "string"},
        "instance": {"type": "string"},
        "code": {
            "type": "string",
            "description": "Código estável do erro (ex: RATE_LIMITED).",
            "examples": ["RATE_LIMITED"],
        },
        "errors": {
            "type": "array",
            "description": "Campos inválidos, só em VALIDATION_FAILED.",
            "items": {
                "type": "object",
                "properties": {"field": {"type": "string"}, "message": {"type": "string"}},
            },
        },
    },
    "required": ["code", "status", "title"],
}


def build_openapi(app: FastAPI) -> dict[str, Any]:
    """Gera o contrato e documenta em toda operação a resposta de erro ``default``."""
    if app.openapi_schema:
        return app.openapi_schema
    schema = get_openapi(
        title=app.title,
        version=app.version,
        description=DESCRIPTION,
        routes=app.routes,
        # Licença do código do CritSense. O conteúdo de regras continua sob a CC-BY-4.0 do SRD 5.1.
        license_info={
            "name": "PolyForm Strict 1.0.0",
            "url": "https://polyformproject.org/licenses/strict/1.0.0",
        },
        # Fixo para o contrato não depender do host de quem gerou o arquivo.
        servers=[{"url": "http://localhost:8080", "description": "Local"}],
    )
    schemas = schema.setdefault("components", {}).setdefault("schemas", {})
    # A API devolve 400 com o Problem, e não o 422 padrão do FastAPI.
    schemas.pop("HTTPValidationError", None)
    schemas.pop("ValidationError", None)
    schemas["Problem"] = PROBLEM_SCHEMA
    for path in schema["paths"].values():
        for operation in path.values():
            responses = operation["responses"]
            responses.pop("422", None)
            responses["default"] = {
                "description": "Erro no formato RFC 9457. Veja o campo code.",
                "content": {"application/problem+json": {"schema": {"$ref": _PROBLEM_REF}}},
            }
    app.openapi_schema = schema
    return schema


def render_yaml(schema: dict[str, Any]) -> str:
    yaml = YAML()
    yaml.width = 4096  # sem quebras de linha no meio das descrições
    yaml.indent(mapping=2, sequence=4, offset=2)
    buffer = io.StringIO()
    yaml.dump(schema, buffer)
    return buffer.getvalue()


def generate_contract() -> str:
    # Import local: o contrato não depende do ambiente, então a API sobe com valores fixos.
    from critsense.config import Settings
    from critsense.main import create_app

    settings = Settings(jwt_secret=SecretStr("x" * 32), ai_provider="none")
    return render_yaml(create_app(settings).openapi())


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Gera o contrato OpenAPI da API.")
    parser.add_argument("--output", type=Path, default=DEFAULT_CONTRACT)
    parser.add_argument(
        "--check", action="store_true", help="só confere se o arquivo está atualizado"
    )
    args = parser.parse_args(argv)

    generated = generate_contract()
    if args.check:
        current = args.output.read_text(encoding="utf-8") if args.output.exists() else ""
        if current.replace("\r\n", "\n") != generated:
            print(f"{args.output} está desatualizado. Rode: uv run python -m critsense.openapi")
            return 1
        print(f"{args.output} está atualizado.")
        return 0
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(generated, encoding="utf-8", newline="\n")
    print(f"Contrato gravado em {args.output}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
