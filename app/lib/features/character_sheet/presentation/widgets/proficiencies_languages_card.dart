import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/character.dart';
import '../../domain/srd/srd_class.dart';
import '../../domain/srd/srd_race.dart';
import '../bloc/character_bloc.dart';

/// Proficiências em armaduras, armas e ferramentas, e idiomas. O jogador
/// adiciona e remove itens; "Preencher pela classe e raça" completa a lista
/// com o que o SRD dá à classe e à raça (útil em personagens antigos).
class ProficienciesLanguagesCard extends StatelessWidget {
  const ProficienciesLanguagesCard({super.key, required this.character});

  final Character character;

  Future<void> _add(
    BuildContext context, {
    required String title,
    required void Function(String value) onAdd,
  }) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => _TextEntryDialog(title: title),
    );
    if (value != null && value.trim().isNotEmpty) onAdd(value.trim());
  }

  void _update(
    BuildContext context, {
    List<String>? otherProficiencies,
    List<String>? languages,
  }) {
    context.read<CharacterBloc>().add(
      UpdateProficienciesEvent(
        character.id,
        otherProficiencies: otherProficiencies,
        languages: languages,
      ),
    );
  }

  void _fillFromSrd(BuildContext context) {
    final equipment = defaultEquipmentProficiencies(character.srdClass);
    final languages =
        SrdRace.fromName(character.race)?.languages ?? const <String>[];
    _update(
      context,
      otherProficiencies: {
        ...character.otherProficiencies,
        ...equipment,
      }.toList(),
      languages: {...character.languages, ...languages}.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget group({
      required String title,
      required List<String> values,
      required String addTitle,
      required ValueChanged<List<String>> onChanged,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: theme.textTheme.labelLarge)),
              IconButton(
                tooltip: addTitle,
                icon: const Icon(Icons.add),
                onPressed: () => _add(
                  context,
                  title: addTitle,
                  onAdd: (value) {
                    if (!values.contains(value)) onChanged([...values, value]);
                  },
                ),
              ),
            ],
          ),
          if (values.isEmpty)
            Text('Nenhum.', style: theme.textTheme.bodySmall)
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final value in values)
                  InputChip(
                    label: Text(value),
                    onDeleted: () =>
                        onChanged(values.where((v) => v != value).toList()),
                  ),
              ],
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        group(
          title: 'Armaduras, armas e ferramentas',
          values: character.otherProficiencies,
          addTitle: 'Adicionar proficiência',
          onChanged: (values) => _update(context, otherProficiencies: values),
        ),
        const SizedBox(height: 12),
        group(
          title: 'Idiomas',
          values: character.languages,
          addTitle: 'Adicionar idioma',
          onChanged: (values) => _update(context, languages: values),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => _fillFromSrd(context),
            icon: const Icon(Icons.auto_fix_high_outlined),
            label: const Text('Preencher pela classe e raça'),
          ),
        ),
      ],
    );
  }
}

class _TextEntryDialog extends StatefulWidget {
  const _TextEntryDialog({required this.title});

  final String title;

  @override
  State<_TextEntryDialog> createState() => _TextEntryDialogState();
}

class _TextEntryDialogState extends State<_TextEntryDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
