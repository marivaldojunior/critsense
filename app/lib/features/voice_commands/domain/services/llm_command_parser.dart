import 'dart:convert';

import 'package:crit_sense/features/dice_roller/domain/entities/dice_notation.dart';

import '../entities/voice_command.dart';

/// Monta o prompt para o modelo no aparelho e valida a resposta em JSON.
///
/// O modelo só escolhe a ação e os valores. Uma resposta fora do formato,
/// com uma ação desconhecida ou com valores impossíveis vira `null`.
class LlmCommandParser {
  const LlmCommandParser();

  static const _maxAmount = 999;
  static const _maxText = 2000;

  String buildPrompt(String transcript) {
    final phrase = transcript.replaceAll('"', "'").trim();
    return '''
Você converte a fala de um jogador de D&D 5e num comando JSON.
Responda só com um objeto JSON, sem texto antes ou depois.

Ações possíveis:
{"action":"damage","amount":8,"target":null}
{"action":"heal","amount":5,"target":null}
{"action":"temp_hp","amount":5}
{"action":"roll","notation":"2d6+3"}
{"action":"initiative"}
{"action":"short_rest"}
{"action":"long_rest"}
{"action":"note","text":"texto da nota"}
{"action":"concentration","spell":"Bless"}
{"action":"concentration","spell":null}
{"action":"next_turn"}
{"action":"previous_turn"}
{"action":"none"}

Regras:
- "amount" é um número inteiro de pontos de vida.
- Use "target" só quando a frase cita outra criatura (ex: "o lobo"). Sem outra criatura, use null.
- "notation" usa o formato NdM+K com os dados d4, d6, d8, d10, d12, d20 ou d100.
- "concentration" com "spell":null encerra a concentração.
- Se a frase não é um comando, use {"action":"none"}.

Exemplos:
Frase: "o orc me acertou com sete de dano cortante"
JSON: {"action":"damage","amount":7,"target":null}
Frase: "o goblin dois perdeu cinco pontos de vida"
JSON: {"action":"damage","amount":5,"target":"goblin 2"}
Frase: "quero jogar três dados de oito somando dois"
JSON: {"action":"roll","notation":"3d8+2"}

Frase: "$phrase"
JSON:''';
  }

  VoiceCommand? parse(String? response) {
    if (response == null) return null;
    final start = response.indexOf('{');
    final end = response.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    final Object? decoded;
    try {
      decoded = jsonDecode(response.substring(start, end + 1));
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, dynamic>) return null;
    final json = decoded;

    int? amount() {
      final value = json['amount'];
      final n = value is num ? value.toInt() : int.tryParse('$value');
      return n != null && n > 0 && n <= _maxAmount ? n : null;
    }

    String? text(String key) {
      final value = json[key];
      if (value is! String) return null;
      final trimmed = value.trim();
      if (trimmed.isEmpty || trimmed == 'null') return null;
      return trimmed.length > _maxText
          ? trimmed.substring(0, _maxText)
          : trimmed;
    }

    switch (json['action']) {
      case 'damage':
        final n = amount();
        return n == null ? null : DamageCommand(n, target: text('target'));
      case 'heal':
        final n = amount();
        return n == null ? null : HealCommand(n, target: text('target'));
      case 'temp_hp':
        final n = amount();
        return n == null ? null : TempHpCommand(n);
      case 'roll':
        final notation = text('notation')?.toLowerCase().replaceAll(' ', '');
        if (notation == null) return null;
        final parsed = DiceNotation.tryParse(notation);
        return parsed == null || !parsed.hasDice ? null : RollCommand(notation);
      case 'initiative':
        return const InitiativeRollCommand();
      case 'short_rest':
        return const ShortRestCommand();
      case 'long_rest':
        return const LongRestCommand();
      case 'note':
        final note = text('text');
        return note == null ? null : NoteCommand(note);
      case 'concentration':
        return ConcentrationCommand(text('spell'));
      case 'next_turn':
        return const NextTurnCommand();
      case 'previous_turn':
        return const PreviousTurnCommand();
      default:
        return null;
    }
  }
}
