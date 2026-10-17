import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

import '../../domain/entities/attribute_type.dart';
import '../../domain/entities/character.dart';
import '../../domain/rules/level_rules.dart';
import '../../domain/rules/srd_rules.dart';
import '../../domain/srd/spell_slots.dart';
import '../bloc/character_bloc.dart';
import 'number_edit_dialog.dart';

String _signed(int value) => value >= 0 ? '+$value' : '$value';

/// Nível, XP e o botão de subir de nível.
class LevelProgressCard extends StatelessWidget {
  const LevelProgressCard({super.key, required this.character});

  final Character character;

  Future<void> _addExperience(BuildContext context) async {
    final bloc = context.read<CharacterBloc>();
    final amount = await showNumberEditDialog(
      context,
      title: 'Adicionar XP',
      initialValue: 0,
      allowNegative: true,
      helperText: 'Use um valor negativo para corrigir.',
    );
    if (amount != null && amount != 0) {
      bloc.add(AddExperienceEvent(character.id, amount));
    }
  }

  void _openLevelUp(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<CharacterBloc>(),
        child: LevelUpSheet(character: character),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final next = experienceForNextLevel(character.level);
    final current = experienceThresholds[character.level - 1];
    final progress = next == null
        ? 1.0
        : ((character.experiencePoints - current) / (next - current)).clamp(
            0.0,
            1.0,
          );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const DnDIcon(
                  assetPath: 'assets/icons/util/star.svg',
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Nível ${character.level}',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Text(
                  next == null
                      ? '${character.experiencePoints} XP'
                      : '${character.experiencePoints} / $next XP',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _addExperience(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar XP'),
                ),
                if (character.canLevelUp)
                  (character.isReadyToLevelUp
                      ? FilledButton.icon(
                          onPressed: () => _openLevelUp(context),
                          icon: const Icon(Icons.arrow_upward),
                          label: const Text('Subir de nível'),
                        )
                      : OutlinedButton.icon(
                          onPressed: () => _openLevelUp(context),
                          icon: const Icon(Icons.arrow_upward),
                          label: const Text('Subir de nível'),
                        )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _HitPointMethod { average, roll }

enum _ImprovementMode { plusTwo, plusOneEach }

/// Painel de subida de nível: ganho de PV (média ou rolagem), Aumento de
/// Valor de Atributo quando o nível tem um, e o resumo do nível novo.
class LevelUpSheet extends StatefulWidget {
  const LevelUpSheet({super.key, required this.character, this.random});

  final Character character;

  /// Gerador do dado de vida; os testes passam um com semente fixa.
  final Random? random;

  @override
  State<LevelUpSheet> createState() => _LevelUpSheetState();
}

class _LevelUpSheetState extends State<LevelUpSheet> {
  late final Random _random = widget.random ?? Random();
  _HitPointMethod _method = _HitPointMethod.average;
  int? _rolled;
  _ImprovementMode _mode = _ImprovementMode.plusTwo;
  AttributeType? _first;
  AttributeType? _second;

  Character get _character => widget.character;

  int get _hitDieResult => _method == _HitPointMethod.average
      ? _character.averageHitDieGain
      : (_rolled ?? 0);

  Map<AttributeType, int> get _increases {
    if (!_character.nextLevelHasAbilityScoreImprovement) return const {};
    if (_mode == _ImprovementMode.plusTwo) {
      return _first == null ? const {} : {_first!: 2};
    }
    if (_first == null || _second == null || _first == _second) return const {};
    return {_first!: 1, _second!: 1};
  }

  bool get _isValid {
    if (_method == _HitPointMethod.roll && _rolled == null) return false;
    if (!_character.nextLevelHasAbilityScoreImprovement) return true;
    return isValidAbilityScoreImprovement(_character.attributes, _increases);
  }

  void _confirm() {
    context.read<CharacterBloc>().add(
      LevelUpEvent(
        _character.id,
        hitDieResult: _hitDieResult,
        abilityIncreases: _increases,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = _isValid
        ? _character.withLevelUp(
            hitDieResult: _hitDieResult,
            abilityIncreases: _increases,
          )
        : null;
    final newLevel = _character.level + 1;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nível ${_character.level} → $newLevel',
                style: theme.textTheme.titleLarge,
              ),
              if (!_character.isReadyToLevelUp)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'O XP ainda não chega ao próximo nível. Suba assim mesmo '
                    'se a mesa usa marcos de história.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: 16),
              Text('Pontos de vida', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<_HitPointMethod>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: _HitPointMethod.average,
                    label: Text('Média (${_character.averageHitDieGain})'),
                  ),
                  ButtonSegment(
                    value: _HitPointMethod.roll,
                    label: Text('Rolar d${_character.hitDie}'),
                  ),
                ],
                selected: {_method},
                onSelectionChanged: (s) => setState(() => _method = s.single),
              ),
              if (_method == _HitPointMethod.roll)
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(
                        () => _rolled = _random.nextInt(_character.hitDie) + 1,
                      ),
                      icon: const Icon(Icons.casino_outlined),
                      label: Text(_rolled == null ? 'Rolar' : 'Rolar de novo'),
                    ),
                    if (_rolled != null) Text('Resultado: $_rolled'),
                  ],
                ),
              if (_character.nextLevelHasAbilityScoreImprovement) ...[
                const SizedBox(height: 16),
                Text(
                  'Aumento de Valor de Atributo',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SegmentedButton<_ImprovementMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: _ImprovementMode.plusTwo,
                      label: Text('+2 em um'),
                    ),
                    ButtonSegment(
                      value: _ImprovementMode.plusOneEach,
                      label: Text('+1 em dois'),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() {
                    _mode = s.single;
                    _second = null;
                  }),
                ),
                const SizedBox(height: 8),
                _AttributePicker(
                  label: _mode == _ImprovementMode.plusTwo
                      ? 'Atributo (+2)'
                      : 'Primeiro atributo (+1)',
                  value: _first,
                  character: _character,
                  onChanged: (a) => setState(() => _first = a),
                ),
                if (_mode == _ImprovementMode.plusOneEach)
                  _AttributePicker(
                    label: 'Segundo atributo (+1)',
                    value: _second,
                    character: _character,
                    onChanged: (a) => setState(() => _second = a),
                  ),
                Text(
                  'Nenhum atributo passa de 20. Se a mesa usa talentos, escolha '
                  'o talento fora do app e não aumente atributos aqui.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 16),
              if (preview != null) _Summary(before: _character, after: preview),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isValid ? _confirm : null,
                child: Text('Subir para o nível $newLevel'),
              ),
              if (_character.nextLevelHasAbilityScoreImprovement)
                TextButton(
                  onPressed: _method == _HitPointMethod.roll && _rolled == null
                      ? null
                      : () {
                          context.read<CharacterBloc>().add(
                            LevelUpEvent(
                              _character.id,
                              hitDieResult: _hitDieResult,
                            ),
                          );
                          Navigator.pop(context);
                        },
                  child: const Text('Subir sem aumentar atributos (talento)'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttributePicker extends StatelessWidget {
  const _AttributePicker({
    required this.label,
    required this.value,
    required this.character,
    required this.onChanged,
  });

  final String label;
  final AttributeType? value;
  final Character character;
  final ValueChanged<AttributeType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DropdownButtonFormField<AttributeType>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: [
          for (final attribute in AttributeType.values)
            DropdownMenuItem(
              value: attribute,
              child: Text(
                '${attribute.label} (${character.attributes.valueOf(attribute)})',
              ),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

/// O que muda no nível novo: PV, proficiência, atributos e espaços de magia.
class _Summary extends StatelessWidget {
  const _Summary({required this.before, required this.after});

  final Character before;
  final Character after;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lines = <String>[
      'PV máximo: ${before.maxHitPoints} → ${after.maxHitPoints}',
      if (after.proficiencyBonus != before.proficiencyBonus)
        'Bônus de proficiência: ${_signed(before.proficiencyBonus)} → '
            '${_signed(after.proficiencyBonus)}',
      for (final attribute in AttributeType.values)
        if (after.attributes.valueOf(attribute) !=
            before.attributes.valueOf(attribute))
          '${attribute.label}: ${before.attributes.valueOf(attribute)} → '
              '${after.attributes.valueOf(attribute)}',
      for (var level = 1; level <= spellSlotLevels; level++)
        if (after.maxSpellSlots[level - 1] != before.maxSpellSlots[level - 1])
          'Espaços de $levelº nível: ${before.maxSpellSlots[level - 1]} → '
              '${after.maxSpellSlots[level - 1]}',
      if (after.pactMagic != before.pactMagic && after.pactMagic != null)
        'Magia de Pacto: ${after.pactMagic!.slots} espaços de '
            '${after.pactMagic!.slotLevel}º nível',
    ];
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumo', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            for (final line in lines)
              Text(line, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
