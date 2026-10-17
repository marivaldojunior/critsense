package com.marivaldojunior.critsense.npc;

/** Respostas JSON de exemplo do modelo para os testes do gerador de NPCs. */
public final class NpcFixtures {

    private NpcFixtures() {}

    public static String validNpcJson(String race, String alignment) {
        return """
                {
                  "name": "Brunna Martelo-Fundo",
                  "race": "%s",
                  "role": "ferreira da vila",
                  "alignment": "%s",
                  "appearance": "Anã de braços largos, com fuligem até os cotovelos.",
                  "personalityTraits": ["teimosa", "generosa com estranhos"],
                  "motivation": "Reabrir a mina antiga da família.",
                  "secret": "Ela vendeu a chave da mina para um culto.",
                  "mannerism": "Bate o martelo na bigorna antes de responder.",
                  "storyHooks": ["Pede ao grupo que recupere a chave da mina."]
                }
                """
                .formatted(race, alignment);
    }

    public static String validNpcJson() {
        return validNpcJson("DWARF", "LAWFUL_GOOD");
    }

    /** JSON válido, mas que quebra o Bean Validation: só um traço de personalidade. */
    public static String npcWithOneTrait() {
        return validNpcJson().replace("\"teimosa\", \"generosa com estranhos\"", "\"teimosa\"");
    }
}
