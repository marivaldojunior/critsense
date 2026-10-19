import 'package:equatable/equatable.dart';

/// Um comando entendido a partir da fala do jogador.
///
/// O comando só descreve a ação. Quem aplica é a tela que abriu a escuta,
/// com os eventos e as regras do SRD que o app já tem.
sealed class VoiceCommand extends Equatable {
  const VoiceCommand();

  /// Frase curta para a confirmação (ex: "Dano: 8 no lobo").
  String get description;

  @override
  List<Object?> get props => [];
}

/// Dano no personagem ou, com [target], numa criatura do combate.
final class DamageCommand extends VoiceCommand {
  final int amount;
  final String? target;

  const DamageCommand(this.amount, {this.target});

  @override
  String get description =>
      target == null ? 'Dano: $amount' : 'Dano: $amount em $target';

  @override
  List<Object?> get props => [amount, target];
}

/// Cura no personagem ou, com [target], numa criatura do combate.
final class HealCommand extends VoiceCommand {
  final int amount;
  final String? target;

  const HealCommand(this.amount, {this.target});

  @override
  String get description =>
      target == null ? 'Cura: $amount' : 'Cura: $amount em $target';

  @override
  List<Object?> get props => [amount, target];
}

/// PV temporários no personagem.
final class TempHpCommand extends VoiceCommand {
  final int amount;

  const TempHpCommand(this.amount);

  @override
  String get description => 'PV temporários: $amount';

  @override
  List<Object?> get props => [amount];
}

/// Rolagem de dados na notação do app (ex: `2d6+3`).
final class RollCommand extends VoiceCommand {
  final String notation;

  const RollCommand(this.notation);

  @override
  String get description => 'Rolar $notation';

  @override
  List<Object?> get props => [notation];
}

/// Rolagem de iniciativa do personagem.
final class InitiativeRollCommand extends VoiceCommand {
  const InitiativeRollCommand();

  @override
  String get description => 'Rolar iniciativa';
}

final class ShortRestCommand extends VoiceCommand {
  const ShortRestCommand();

  @override
  String get description => 'Descanso Curto';
}

final class LongRestCommand extends VoiceCommand {
  const LongRestCommand();

  @override
  String get description => 'Descanso Longo';
}

/// Nota para o Diário de Campanha.
final class NoteCommand extends VoiceCommand {
  final String text;

  const NoteCommand(this.text);

  @override
  String get description => 'Anotar: $text';

  @override
  List<Object?> get props => [text];
}

/// Começa a concentração em [spell], ou termina quando [spell] é `null`.
final class ConcentrationCommand extends VoiceCommand {
  final String? spell;

  const ConcentrationCommand(this.spell);

  @override
  String get description =>
      spell == null ? 'Encerrar a concentração' : 'Concentrar em $spell';

  @override
  List<Object?> get props => [spell];
}

/// Passa o turno no rastreador de iniciativa.
final class NextTurnCommand extends VoiceCommand {
  const NextTurnCommand();

  @override
  String get description => 'Próximo turno';
}

/// Volta o turno no rastreador de iniciativa.
final class PreviousTurnCommand extends VoiceCommand {
  const PreviousTurnCommand();

  @override
  String get description => 'Turno anterior';
}
