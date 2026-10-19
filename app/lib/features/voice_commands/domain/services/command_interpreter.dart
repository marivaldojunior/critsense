import '../entities/voice_command.dart';
import 'llm_command_parser.dart';
import 'on_device_ai.dart';
import 'rule_based_parser.dart';

/// Converte a transcrição num [VoiceCommand], ou `null` se não entende.
abstract interface class CommandInterpreter {
  Future<VoiceCommand?> interpret(String transcript);
}

/// Intérprete só com as regras fixas da [RuleBasedParser].
class RuleBasedInterpreter implements CommandInterpreter {
  const RuleBasedInterpreter([this._parser = const RuleBasedParser()]);

  final RuleBasedParser _parser;

  @override
  Future<VoiceCommand?> interpret(String transcript) async =>
      _parser.parse(transcript);
}

/// Usa as regras fixas primeiro. Só quando elas não entendem a frase, e o
/// modelo no aparelho está pronto, pergunta ao Gemini Nano.
///
/// As regras ficam na frente porque são instantâneas e funcionam em
/// qualquer aparelho; o modelo cobre as frases livres.
class HybridInterpreter implements CommandInterpreter {
  const HybridInterpreter(
    this._ai, {
    this._rules = const RuleBasedParser(),
    this._llm = const LlmCommandParser(),
  });

  final OnDeviceAi _ai;
  final RuleBasedParser _rules;
  final LlmCommandParser _llm;

  @override
  Future<VoiceCommand?> interpret(String transcript) async {
    final byRules = _rules.parse(transcript);
    if (byRules != null) return byRules;
    if (await _ai.status() != OnDeviceAiStatus.available) return null;
    final response = await _ai.generate(_llm.buildPrompt(transcript));
    return _llm.parse(response);
  }
}
