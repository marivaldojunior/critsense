import json

VARIABLES = {"race": "DWARF", "role": "ferreira", "alignment": "LAWFUL_GOOD", "context": "livre"}


def npc_json(**overrides: object) -> str:
    """Resposta válida do modelo para o gerador de NPCs; ``overrides`` troca campos."""
    npc: dict[str, object] = {
        "name": "Brunna Martelo-Firme",
        "race": "DWARF",
        "role": "ferreira",
        "alignment": "LAWFUL_GOOD",
        "appearance": "Anã de braços largos, com a barba trançada e cheia de fuligem.",
        "personalityTraits": ["Teimosa", "Generosa com quem trabalha duro"],
        "motivation": "Reabrir a forja do clã, fechada há vinte anos.",
        "secret": "Ela forjou a chave que abriu a mina para os kobolds.",
        "mannerism": "Bate o martelo na bigorna antes de responder.",
        "storyHooks": ["Pede ao grupo que recupere o martelo do avô na mina."],
        **overrides,
    }
    return json.dumps(npc, ensure_ascii=False)
