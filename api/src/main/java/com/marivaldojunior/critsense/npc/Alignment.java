package com.marivaldojunior.critsense.npc;

import io.swagger.v3.oas.annotations.media.Schema;

/** As nove tendências do SRD 5.1. */
@Schema(enumAsRef = true)
public enum Alignment {
    LAWFUL_GOOD,
    NEUTRAL_GOOD,
    CHAOTIC_GOOD,
    LAWFUL_NEUTRAL,
    TRUE_NEUTRAL,
    CHAOTIC_NEUTRAL,
    LAWFUL_EVIL,
    NEUTRAL_EVIL,
    CHAOTIC_EVIL
}
