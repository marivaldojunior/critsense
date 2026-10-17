package com.marivaldojunior.critsense.npc;

import io.swagger.v3.oas.annotations.media.Schema;

/** Raças jogáveis do SRD 5.1 (CC-BY-4.0). A API só aceita e só devolve estas. */
@Schema(enumAsRef = true)
public enum SrdRace {
    DRAGONBORN,
    DWARF,
    ELF,
    GNOME,
    HALF_ELF,
    HALF_ORC,
    HALFLING,
    HUMAN,
    TIEFLING
}
