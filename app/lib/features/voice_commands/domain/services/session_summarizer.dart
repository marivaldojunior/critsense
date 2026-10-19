import 'package:crit_sense/features/character_sheet/domain/entities/session_note.dart';

import 'on_device_ai.dart';

/// Resume as notas de uma sessão com o modelo no aparelho. O texto das
/// notas não sai do celular.
class SessionSummarizer {
  const SessionSummarizer(this._ai);

  final OnDeviceAi _ai;

  /// O modelo aceita menos de 4.000 tokens. Este limite de caracteres deixa
  /// espaço para as instruções e para a resposta.
  static const maxNotesChars = 8000;

  /// Notas do dia da nota mais nova, da mais antiga para a mais nova. Uma
  /// sessão de jogo costuma caber num dia.
  static List<SessionNote> notesOfLastSession(List<SessionNote> notes) {
    if (notes.isEmpty) return const [];
    final newest = notes
        .map((n) => n.createdAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    bool sameDay(DateTime d) =>
        d.year == newest.year && d.month == newest.month && d.day == newest.day;
    return notes.where((n) => sameDay(n.createdAt)).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  String buildPrompt(List<SessionNote> notes) {
    final buffer = StringBuffer();
    for (final note in notes) {
      final entry = '- ${note.title}: ${note.content}\n';
      if (buffer.length + entry.length > maxNotesChars) break;
      buffer.write(entry);
    }
    return '''
Você resume as anotações de uma sessão de D&D 5e para o jogador.
Escreva em português do Brasil, em até 5 tópicos curtos que começam com "- ".
Fale só do que está nas anotações: não invente nomes, lugares nem fatos.
Destaque os ganchos, as pistas e as pendências para a próxima sessão.

Anotações:
$buffer
Resumo:''';
  }

  /// Devolve o resumo, ou `null` se o modelo não respondeu.
  Future<String?> summarize(List<SessionNote> notes) async {
    if (notes.isEmpty) return null;
    final text = await _ai.generate(
      buildPrompt(notes),
      temperature: 0.2,
      maxOutputTokens: 400,
    );
    final summary = text?.trim();
    return summary == null || summary.isEmpty ? null : summary;
  }
}
