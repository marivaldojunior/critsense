import '../entities/voice_command.dart';
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
