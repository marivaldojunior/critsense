import 'package:crit_sense/features/dice_roller/domain/entities/dice_notation.dart';

import '../entities/voice_command.dart';
import 'spoken_text.dart';

/// Converte frases simples em [VoiceCommand] com regras fixas, sem IA.
///
/// Funciona em qualquer aparelho e sem internet. Uma frase que não casa com
/// nenhuma regra devolve `null`; o app então tenta o modelo no aparelho
/// (quando existe) ou pede para o jogador falar de novo.
class RuleBasedParser {
  const RuleBasedParser();

  VoiceCommand? parse(String transcript) {
    final original = transcript.trim();
    if (original.isEmpty) return null;
    final text = replaceNumberWords(normalizeSpoken(original));

    return _note(original) ??
        _concentration(original, text) ??
        _turn(text) ??
        _rest(text) ??
        _initiative(text) ??
        _tempHp(text) ??
        _roll(text) ??
        _heal(text) ??
        _damage(text);
  }

  // ── Notas ──────────────────────────────────────────────────────────────

  static final _notePattern = RegExp(
    r'^(?:anotar|anota|anote|nota|registrar|registra|registre|lore)\b[\s:,.\-]*(.+)$',
    caseSensitive: false,
    dotAll: true,
  );

  NoteCommand? _note(String original) {
    final match = _notePattern.firstMatch(original);
    final body = match?.group(1)?.trim();
    if (body == null || body.isEmpty) return null;
    return NoteCommand('${body[0].toUpperCase()}${body.substring(1)}');
  }

  // ── Concentração ───────────────────────────────────────────────────────

  static final _endConcentration = RegExp(
    r'\b(?:encerr\w*|termin\w*|perd\w*|sem|parar? de|quebr\w*)\b.*\bconcentra',
  );
  static final _startConcentration = RegExp(
    r'^(?:concentr\S*|mantenho|manter)\s+(?:(?:a )?concentra\S*\s+)?(?:em|na|no|nas|nos)?\s*(.+)$',
    caseSensitive: false,
  );

  ConcentrationCommand? _concentration(String original, String text) {
    if (!text.contains('concentr')) return null;
    if (_endConcentration.hasMatch(text)) {
      return const ConcentrationCommand(null);
    }
    final spell = _startConcentration.firstMatch(original.trim())?.group(1);
    if (spell == null || spell.trim().isEmpty) return null;
    return ConcentrationCommand(_titleCase(spell.trim()));
  }

  // ── Turnos e descansos ─────────────────────────────────────────────────

  VoiceCommand? _turn(String text) {
    if (RegExp(
      r'\bturno anterior\b|\bvolt\w* (?:o |um )?turno\b',
    ).hasMatch(text)) {
      return const PreviousTurnCommand();
    }
    if (RegExp(
      r'\bproximo turno\b|\bpass\w* (?:o |a )?(?:turno|vez)\b|\bproximo\b$',
    ).hasMatch(text)) {
      return const NextTurnCommand();
    }
    return null;
  }

  VoiceCommand? _rest(String text) {
    if (!RegExp(r'\bdescans|\bdormir\b').hasMatch(text)) return null;
    if (RegExp(r'\bcurto\b|\bpequeno\b|\brapido\b').hasMatch(text)) {
      return const ShortRestCommand();
    }
    if (RegExp(r'\blongo\b|\bdormir\b|\bnoite\b').hasMatch(text)) {
      return const LongRestCommand();
    }
    return null;
  }

  VoiceCommand? _initiative(String text) =>
      RegExp(r'\biniciativa\b').hasMatch(text)
      ? const InitiativeRollCommand()
      : null;

  // ── Dados ──────────────────────────────────────────────────────────────

  static final _rollVerb = RegExp(r'\b(?:rol\w*|jog\w*|lanc\w*|dados?)\b');
  static final _dice = RegExp(r'\b(\d*)\s*(?:d|de)\s*(\d+)\b');
  static final _modifier = RegExp(r'(\bmais\b|\+|\bmenos\b|-)\s*(\d+)');

  RollCommand? _roll(String text) {
    final hasVerb = _rollVerb.hasMatch(text);
    // "d20" sem verbo também é rolagem; "8 de dano" não é.
    final compact = RegExp(r'\b\d*d\d+\b').hasMatch(text);
    if (!hasVerb && !compact) return null;

    final dice = _dice.firstMatch(text);
    if (dice == null) return null;
    final count = dice.group(1)!.isEmpty ? '' : dice.group(1)!;
    var notation = '${count}d${dice.group(2)}';

    final rest = text.substring(dice.end);
    var modifier = 0;
    for (final m in _modifier.allMatches(rest)) {
      final value = int.parse(m.group(2)!);
      final sign = m.group(1)!;
      modifier += sign == '+' || sign.trim() == 'mais' ? value : -value;
    }
    if (modifier > 0) notation += '+$modifier';
    if (modifier < 0) notation += '$modifier';
    return DiceNotation.tryParse(notation) == null
        ? null
        : RollCommand(notation);
  }

  // ── PV ─────────────────────────────────────────────────────────────────

  static final _healVerbs = RegExp(
    r'\b(?:cur\w*|recuper\w*|ganh\w*|regener\w*)\b',
  );
  static final _damageVerbs = RegExp(
    r'\b(?:dano|levei|leva|levou|tomei|toma|tomou|sofri|sofre|sofreu|perdi|perde|perdeu|acert\w*|machuc\w*)\b',
  );

  TempHpCommand? _tempHp(String text) {
    if (!text.contains('temporari')) return null;
    final amount = _amount(text);
    return amount == null ? null : TempHpCommand(amount.value);
  }

  HealCommand? _heal(String text) {
    if (!_healVerbs.hasMatch(text)) return null;
    final amount = _amount(text);
    if (amount == null) return null;
    return HealCommand(amount.value, target: _target(text, amount, _healVerbs));
  }

  DamageCommand? _damage(String text) {
    if (!_damageVerbs.hasMatch(text)) return null;
    final amount = _amount(text);
    if (amount == null) return null;
    return DamageCommand(
      amount.value,
      target: _target(text, amount, _damageVerbs),
    );
  }

  /// A quantidade de PV: o número antes de "de dano", "pontos", "PV" ou
  /// "de vida"; senão, o número depois de um verbo; senão, o último número.
  _Amount? _amount(String text) {
    final numbers = RegExp(r'\b\d+\b').allMatches(text).toList();
    if (numbers.isEmpty) return null;
    for (final n in numbers) {
      final after = text.substring(n.end);
      if (RegExp(
        r'^\s*(?:de )?(?:dano|pontos?|pvs?|hp|de vida)\b',
      ).hasMatch(after)) {
        return _Amount(int.parse(n.group(0)!), n.start, n.end);
      }
    }
    final last = numbers.last;
    return _Amount(int.parse(last.group(0)!), last.start, last.end);
  }

  /// Palavras que sobram depois de tirar a quantidade, os verbos e as
  /// palavras de ligação. Elas formam o nome do alvo (ex: "goblin 2"). Sem
  /// palavras, o alvo é o próprio personagem.
  String? _target(String text, _Amount amount, RegExp verbs) {
    final withoutAmount =
        '${text.substring(0, amount.start)} ${text.substring(amount.end)}';
    final words = withoutAmount
        .replaceAll(verbs, ' ')
        .split(' ')
        .where((w) => w.isNotEmpty && !_fillers.contains(w))
        .toList();
    return words.isEmpty ? null : words.join(' ');
  }

  static const _fillers = {
    'o', 'a', 'os', 'as', 'um', 'uma', 'de', 'do', 'da', 'no', 'na', 'em', //
    'ao', 'para', 'pra', 'pro', 'com', 'e', 'que', 'eu', 'me', 'mim', 'meu',
    'minha', 'ele', 'ela', 'dano', 'danos', 'ponto', 'pontos', 'pv', 'pvs',
    'hp', 'vida', 'de vida', 'agora', 'mais', 'menos', 'recebe', 'recebi',
    'recebeu', 'cortante', 'perfurante', 'contundente', 'fogo', 'frio',
    'raio', 'eletrico', 'acido', 'veneno', 'necrotico', 'radiante',
    'psiquico', 'trovao', 'energia', 'forca',
  };

  static String _titleCase(String text) => text
      .split(RegExp(r'\s+'))
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

class _Amount {
  final int value;
  final int start;
  final int end;

  const _Amount(this.value, this.start, this.end);
}
