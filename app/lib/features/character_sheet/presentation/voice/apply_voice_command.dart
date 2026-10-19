import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:crit_sense/di/injection_container.dart';
import 'package:crit_sense/features/dice_roller/presentation/widgets/quick_roll_dialog.dart';
import 'package:crit_sense/features/dice_roller/presentation/widgets/sheet_roll_sheet.dart';
import 'package:crit_sense/features/voice_commands/domain/entities/voice_command.dart';
import 'package:crit_sense/features/voice_commands/presentation/cubit/voice_command_cubit.dart';
import 'package:crit_sense/features/voice_commands/presentation/widgets/voice_command_sheet.dart';

import '../../domain/entities/attribute_type.dart';
import '../../domain/entities/character.dart';
import '../../domain/entities/session_note.dart';
import '../../domain/rules/concentration_rules.dart';
import '../../domain/rules/hit_point_rules.dart';
import '../../domain/rules/roll_rules.dart';
import '../../domain/usecases/add_session_note_usecase.dart';
import '../bloc/character_bloc.dart';
import '../widgets/concentration_card.dart';
import '../widgets/short_rest_sheet.dart';

/// Abre a escuta na ficha de [characterId] e aplica o comando confirmado.
Future<void> listenForCharacterCommand(
  BuildContext context,
  String characterId,
) async {
  final command = await showVoiceCommandSheet(
    context,
    scope: VoiceScope.character,
  );
  if (command == null || !context.mounted) return;
  final character = context.read<CharacterBloc>().state.findCharacter(
    characterId,
  );
  if (character == null) return;
  await applyVoiceCommand(context, character, command);
}

/// Aplica [command] em [character] com os eventos que a ficha já usa.
///
/// As regras do SRD continuam no domínio: o comando só escolhe o evento. Um
/// alvo falado (ex: "o lobo") é ignorado aqui; ele só vale no rastreador.
Future<void> applyVoiceCommand(
  BuildContext context,
  Character character,
  VoiceCommand command,
) async {
  final bloc = context.read<CharacterBloc>();
  final messenger = ScaffoldMessenger.of(context);
  void tell(String text) =>
      messenger.showSnackBar(SnackBar(content: Text(text)));

  switch (command) {
    case DamageCommand(:final amount):
      bloc.add(ApplyDamageEvent(character.id, amount));
      tell('Dano de $amount aplicado.');
      // O resultado do dano é conhecido sem esperar o BLoC: as regras são
      // puras.
      await showConcentrationCheck(
        context,
        after: character.withDamage(amount).withConcentrationChecked(),
        damage: amount,
        constitutionSave: bloc.savingThrowModifier(
          character,
          AttributeType.constitution,
        ),
      );
    case HealCommand(:final amount):
      bloc.add(HealHpEvent(character.id, amount));
      tell('Cura de $amount aplicada.');
    case TempHpCommand(:final amount):
      bloc.add(AddTempHpEvent(character.id, amount));
      tell('$amount PV temporários aplicados.');
    case RollCommand(:final notation):
      await showQuickRoll(context, notation);
    case InitiativeRollCommand():
      final suggestion = suggestedRollMode(
        character,
        RollKind.abilityCheck,
        attribute: AttributeType.dexterity,
      );
      await showSheetRoll(
        context,
        title: 'Iniciativa',
        modifier: character.initiative,
        initialMode: suggestion.mode,
        note: rollSuggestionNote(suggestion),
      );
    case ShortRestCommand():
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: ShortRestSheet(characterId: character.id),
        ),
      );
    case LongRestCommand():
      bloc.add(TakeLongRestEvent(character.id));
      tell('Descanso Longo concluído.');
    case NoteCommand(:final text):
      try {
        await sl<AddSessionNoteUseCase>()(
          SessionNote(
            id: const Uuid().v4(),
            characterId: character.id,
            title: noteTitleFrom(text),
            content: text,
            createdAt: DateTime.now(),
          ),
        );
        tell('Nota salva no Diário de Campanha.');
      } catch (_) {
        tell('Não foi possível salvar a nota.');
      }
    case ConcentrationCommand(:final spell):
      bloc.add(SetConcentrationEvent(character.id, spell));
      tell(spell == null ? 'Concentração encerrada.' : 'Concentração: $spell.');
    case NextTurnCommand() || PreviousTurnCommand():
      // Só valem no rastreador de iniciativa.
      break;
  }
}
