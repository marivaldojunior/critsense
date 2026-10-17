import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/features/dice_roller/presentation/widgets/sheet_roll_sheet.dart';

import '../../domain/entities/character.dart';
import '../../domain/rules/concentration_rules.dart';
import '../bloc/character_bloc.dart';

/// Mostra a magia em concentração, com o botão para terminar. Sem
/// concentração, o botão "Marcar" pede o nome da magia.
class ConcentrationCard extends StatelessWidget {
  const ConcentrationCard({super.key, required this.character});

  final Character character;

  Future<void> _start(BuildContext context) async {
    final bloc = context.read<CharacterBloc>();
    final spell = await showDialog<String>(
      context: context,
      builder: (_) => const _SpellNameDialog(),
    );
    if (spell != null && spell.trim().isNotEmpty) {
      bloc.add(SetConcentrationEvent(character.id, spell));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spell = character.concentrationSpell;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          children: [
            DnDIcon(
              assetPath: 'assets/icons/game/concentration.svg',
              size: 24,
              color: spell != null ? theme.colorScheme.primary : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Concentração', style: theme.textTheme.titleSmall),
                  Text(
                    spell ?? 'Nenhuma magia.',
                    style: theme.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (spell != null)
              TextButton(
                onPressed: () => context.read<CharacterBloc>().add(
                  SetConcentrationEvent(character.id, null),
                ),
                child: const Text('Encerrar'),
              )
            else
              TextButton(
                onPressed: () => _start(context),
                child: const Text('Marcar'),
              ),
          ],
        ),
      ),
    );
  }
}

class _SpellNameDialog extends StatefulWidget {
  const _SpellNameDialog();

  @override
  State<_SpellNameDialog> createState() => _SpellNameDialogState();
}

class _SpellNameDialogState extends State<_SpellNameDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Magia em concentração'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(labelText: 'Nome da magia'),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Marcar'),
        ),
      ],
    );
  }
}

/// Depois de [damage] de dano, pergunta se o personagem manteve a
/// concentração. O botão "Rolar" abre a salvaguarda de CON com a CD.
///
/// Não faz nada se [after] (o personagem depois do dano) não está mais
/// concentrado: com 0 PV a concentração já terminou.
Future<void> showConcentrationCheck(
  BuildContext context, {
  required Character after,
  required int damage,
  required int constitutionSave,
}) async {
  if (!after.isConcentrating) return;
  final bloc = context.read<CharacterBloc>();
  final dc = concentrationSaveDc(damage);

  final roll = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const DnDIcon(
        assetPath: 'assets/icons/game/concentration.svg',
        size: 32,
      ),
      title: const Text('Teste de concentração'),
      content: Text(
        'Faça uma salvaguarda de Constituição, CD $dc, para manter '
        '${after.concentrationSpell}.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            bloc.add(SetConcentrationEvent(after.id, null));
            Navigator.pop(dialogContext, false);
          },
          child: const Text('Perdeu'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Manteve'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Rolar'),
        ),
      ],
    ),
  );
  if (roll != true || !context.mounted) return;
  await showSheetRoll(
    context,
    title: 'Concentração (CON)',
    modifier: constitutionSave,
    note:
        'CD $dc. Abaixo disso, a concentração termina: toque em "Encerrar" '
        'no cartão de Concentração.',
  );
}
