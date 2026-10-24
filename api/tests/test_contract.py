"""Garante que ``contracts/openapi.yaml`` é igual ao contrato que o código gera.

Se um endpoint mudar sem o contrato ser atualizado, o teste falha (e o CI também). Para atualizar o
arquivo: ``uv run python -m critsense.openapi``.
"""

from critsense.openapi import DEFAULT_CONTRACT, generate_contract


def test_committed_contract_is_up_to_date() -> None:
    assert DEFAULT_CONTRACT.exists(), "contracts/openapi.yaml não existe"
    committed = DEFAULT_CONTRACT.read_text(encoding="utf-8").replace("\r\n", "\n")

    assert committed == generate_contract(), (
        "contracts/openapi.yaml está desatualizado. Rode: uv run python -m critsense.openapi"
    )
