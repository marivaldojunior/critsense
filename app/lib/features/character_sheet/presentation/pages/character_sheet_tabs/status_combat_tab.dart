import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/features/dice_roller/presentation/widgets/sheet_roll_sheet.dart';

import '../../../domain/entities/attribute_type.dart';
import '../../../domain/entities/character.dart';
import '../../../domain/entities/proficiency.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/rules/class_resource_rules.dart';
import '../../../domain/rules/concentration_rules.dart';
import '../../../domain/rules/equipment_rules.dart';
import '../../../domain/rules/hit_point_rules.dart';
import '../../../domain/rules/roll_rules.dart';
import '../../bloc/character_bloc.dart';
import '../../bloc/inventory_bloc.dart';
import '../../widgets/animated_hp_bar.dart';
import '../../widgets/attacks_card.dart';
import '../../widgets/class_resources_card.dart';
import '../../widgets/concentration_card.dart';
import '../../widgets/conditions_card.dart';
import '../../widgets/death_saves_card.dart';
import '../../widgets/hp_management_sheet.dart';
import '../../widgets/level_up_sheet.dart';
import '../../widgets/number_edit_dialog.dart';
import '../../widgets/short_rest_sheet.dart';

/// Aba "Status & Combate" da ficha: os blocos centrais da primeira página
/// da ficha oficial — CA/Iniciativa/Deslocamento, PV, dados de vida,
/// salvaguardas contra a morte, condições e as duas listas de proficiência
/// (Testes de Resistência e Perícias).
///
/// A aba inteira lê o personagem ao vivo do [CharacterBloc]: qualquer
/// mudança (dano, condição, proficiência) aparece na hora.
class StatusCombatTab extends StatelessWidget {
  const StatusCombatTab({super.key, required this.character});

  /// Personagem da abertura da tela; usado só até o BLoC ter a versão atual.
  final Character character;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharacterBloc, CharacterState>(
      buildWhen: (previous, current) => !identical(
        previous.findCharacter(character.id),
        current.findCharacter(character.id),
      ),
      builder: (context, state) {
        final live = state.findCharacter(character.id) ?? character;
        // A CA e os ataques dependem dos itens equipados (InventoryBloc).
        final items = context.watch<InventoryBloc>().state.items;
        final combat = <Widget>[
          _TopStats(
            character: live,
            armorClass: armorClassWithEquipment(live, items),
          ),
          const SizedBox(height: 10),
          _HpCard(character: live),
          const SizedBox(height: 10),
          ConcentrationCard(character: live),
          // Com 0 PV, as salvaguardas vêm logo abaixo do PV: é o que o
          // jogador precisa ver primeiro.
          if (live.currentHitPoints == 0 && live.maxHitPoints > 0) ...[
            const SizedBox(height: 10),
            DeathSavesCard(character: live),
          ],
          const SizedBox(height: 10),
          AttacksCard(
            attacks: weaponAttacks(live, items),
            onAttackTap: (attack) => _roll(
              context,
              live,
              title: attack.name,
              modifier: attack.attackBonus,
              kind: RollKind.attack,
              damage: attack.damage,
              versatileDamage: attack.versatileDamage,
            ),
          ),
          if (live.classResources.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClassResourcesCard(character: live),
          ],
          const SizedBox(height: 10),
          ConditionsCard(character: live),
          const SizedBox(height: 10),
          LevelProgressCard(character: live),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 600) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: combat,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                      children: [_ProficienciesPanel(character: live)],
                    ),
                  ),
                ],
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...combat,
                const SizedBox(height: 16),
                _ProficienciesPanel(character: live),
              ],
            );
          },
        );
      },
    );
  }
}

String _signed(int value) => value >= 0 ? '+$value' : '$value';

/// Abre a rolagem da ficha com o modo sugerido pelas condições.
void _roll(
  BuildContext context,
  Character character, {
  required String title,
  required int modifier,
  required RollKind kind,
  AttributeType? attribute,
  String? damage,
  String? versatileDamage,
}) {
  final suggestion = suggestedRollMode(character, kind, attribute: attribute);
  showSheetRoll(
    context,
    title: title,
    modifier: modifier,
    damage: damage,
    versatileDamage: versatileDamage,
    initialMode: suggestion.mode,
    note: rollSuggestionNote(suggestion),
  );
}

class _TopStats extends StatelessWidget {
  const _TopStats({required this.character, required this.armorClass});

  final Character character;

  /// CA com a armadura e o escudo equipados.
  final int armorClass;

  Future<void> _editArmorClassBonus(BuildContext context) async {
    final bloc = context.read<CharacterBloc>();
    final bonus = await showNumberEditDialog(
      context,
      title: 'Bônus extra de CA',
      initialValue: character.armorClassBonus,
      allowNegative: true,
      helperText:
          'A CA é calculada pela armadura, pelo escudo, pela DES e pela '
          'classe. Use este bônus para itens mágicos ou magias ativas.',
    );
    if (bonus != null) bloc.add(SetArmorClassBonusEvent(character.id, bonus));
  }

  Future<void> _editSpeed(BuildContext context) async {
    final bloc = context.read<CharacterBloc>();
    final speed = await showNumberEditDialog(
      context,
      title: 'Deslocamento base (pés)',
      initialValue: character.speed,
    );
    if (speed != null) bloc.add(SetSpeedEvent(character.id, speed));
  }

  @override
  Widget build(BuildContext context) {
    final speedLabel = character.effectiveSpeed == character.speed
        ? '${character.speed} pés'
        : '${character.effectiveSpeed} pés (base ${character.speed})';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                iconAsset: 'assets/icons/attribute/ac.svg',
                label: 'CA',
                value: '$armorClass',
                onTap: () => _editArmorClassBonus(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                iconAsset: 'assets/icons/combat/initiative.svg',
                label: 'Iniciativa',
                value: _signed(character.initiative),
                onTap: () => _roll(
                  context,
                  character,
                  title: 'Iniciativa',
                  modifier: character.initiative,
                  kind: RollKind.abilityCheck,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                iconAsset: 'assets/icons/movement/walking.svg',
                label: 'Deslocamento',
                value: speedLabel,
                onTap: () => _editSpeed(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                iconAsset: 'assets/icons/attribute/bonus.svg',
                label: 'Bônus de Proficiência',
                value: _signed(character.proficiencyBonus),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                iconAsset: 'assets/icons/game/inspiration.svg',
                label: character.inspiration
                    ? 'Com inspiração'
                    : 'Sem inspiração',
                value: character.inspiration ? 'Sim' : 'Não',
                highlighted: character.inspiration,
                onTap: () => context.read<CharacterBloc>().add(
                  ToggleInspirationEvent(character.id),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.iconAsset,
    required this.label,
    required this.value,
    this.onTap,
    this.highlighted = false,
  });

  final String iconAsset;
  final String label;
  final String value;

  /// Quando presente, o cartão é editável/alternável ao tocar.
  final VoidCallback? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: highlighted ? theme.colorScheme.primaryContainer : null,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              DnDIcon(assetPath: iconAsset, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _RestType { short, long }

class _HpCard extends StatelessWidget {
  const _HpCard({required this.character});

  final Character character;

  /// Abre o sheet de vida. Depois de dano com concentração ativa, abre o
  /// teste de concentração.
  Future<void> _manageHp(BuildContext context) async {
    final bloc = context.read<CharacterBloc>();
    final damage = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: HpManagementSheet(characterId: character.id),
      ),
    );
    if (damage == null || !context.mounted) return;
    // O resultado do dano é conhecido sem esperar o BLoC: as regras são
    // puras.
    final after = character.withDamage(damage).withConcentrationChecked();
    await showConcentrationCheck(
      context,
      after: after,
      damage: damage,
      constitutionSave: bloc.savingThrowModifier(
        character,
        AttributeType.constitution,
      ),
    );
  }

  Future<void> _editMaxHitPoints(BuildContext context) async {
    final bloc = context.read<CharacterBloc>();
    final value = await showNumberEditDialog(
      context,
      title: 'PV máximo',
      initialValue: character.maxHitPoints,
      helperText:
          'Use para talentos, itens mágicos ou correções. Se o máximo subir, '
          'os PV atuais sobem a mesma quantidade.',
    );
    if (value != null) bloc.add(SetMaxHitPointsEvent(character.id, value));
  }

  Future<void> _confirmLongRest(BuildContext context) async {
    final bloc = context.read<CharacterBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descanso Longo'),
        content: const Text(
          'PV voltam ao máximo, o PV temporário zera, metade dos dados de '
          'vida volta, os espaços de magia e os recursos de classe voltam e '
          'a exaustão diminui 1 nível.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Descansar'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) bloc.add(TakeLongRestEvent(character.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedHpBar(
              currentHitPoints: character.currentHitPoints,
              maxHitPoints: character.maxHitPoints,
              temporaryHitPoints: character.temporaryHitPoints,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Dados de vida: ${character.hitDiceRemaining}/'
                    '${character.level} (d${character.hitDie})',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _editMaxHitPoints(context),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('PV máximo'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => _manageHp(context),
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('Gerenciar Vida'),
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<_RestType>(
                  tooltip: 'Descanso',
                  icon: const DnDIcon(
                    assetPath: 'assets/icons/game/rest.svg',
                    size: 24,
                  ),
                  onSelected: (type) {
                    switch (type) {
                      case _RestType.short:
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => BlocProvider.value(
                            value: context.read<CharacterBloc>(),
                            child: ShortRestSheet(characterId: character.id),
                          ),
                        );
                      case _RestType.long:
                        _confirmLongRest(context);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _RestType.short,
                      child: Text('Descanso Curto'),
                    ),
                    PopupMenuItem(
                      value: _RestType.long,
                      child: Text('Descanso Longo'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProficienciesPanel extends StatelessWidget {
  const _ProficienciesPanel({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CharacterBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PassiveWisdomBadge(value: bloc.passiveWisdom(character)),
        const SizedBox(height: 16),
        Text(
          'Testes de Resistência',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const Divider(),
        for (final attribute in AttributeType.values)
          _ProficiencyRow(
            iconAsset: attribute.iconAsset,
            label: attribute.label,
            modifier: bloc.savingThrowModifier(character, attribute),
            checked: character.proficiencies.contains(
              SavingThrowProficiency(attribute),
            ),
            onRoll: () => _roll(
              context,
              character,
              title: 'Resistência de ${attribute.label}',
              modifier: bloc.savingThrowModifier(character, attribute),
              kind: RollKind.savingThrow,
              attribute: attribute,
            ),
            onChanged: () => bloc.add(
              ToggleProficiencyEvent(
                character.id,
                SavingThrowProficiency(attribute),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text('Perícias', style: Theme.of(context).textTheme.titleSmall),
        const Divider(),
        for (final skill in Skill.values)
          _ProficiencyRow(
            iconAsset: skill.iconAsset,
            label: skill.label,
            sublabel: skill.attribute.label,
            modifier: bloc.skillModifier(character, skill),
            checked: character.proficiencies.contains(SkillProficiency(skill)),
            onRoll: () => _roll(
              context,
              character,
              title: skill.label,
              modifier: bloc.skillModifier(character, skill),
              kind: RollKind.abilityCheck,
            ),
            onChanged: () => bloc.add(
              ToggleProficiencyEvent(character.id, SkillProficiency(skill)),
            ),
          ),
      ],
    );
  }
}

class _PassiveWisdomBadge extends StatelessWidget {
  const _PassiveWisdomBadge({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const DnDIcon(
              assetPath: 'assets/icons/skill/perception.svg',
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Sabedoria Passiva (Percepção)',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Text(
              '$value',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Uma linha de perícia ou teste de resistência: checkbox de proficiência,
/// ícone temático, rótulo e o modificador final já calculado pelo BLoC.
class _ProficiencyRow extends StatelessWidget {
  const _ProficiencyRow({
    required this.iconAsset,
    required this.label,
    this.sublabel,
    required this.modifier,
    required this.checked,
    required this.onChanged,
    required this.onRoll,
  });

  final String iconAsset;
  final String label;
  final String? sublabel;
  final int modifier;
  final bool checked;

  /// Tocar na linha rola o teste; a caixa marca a proficiência.
  final VoidCallback onChanged;
  final VoidCallback onRoll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modifierLabel = modifier >= 0 ? '+$modifier' : '$modifier';

    return InkWell(
      onTap: onRoll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Checkbox(value: checked, onChanged: (_) => onChanged()),
            DnDIcon(
              assetPath: iconAsset,
              size: 20,
              color: checked
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: theme.textTheme.bodyMedium),
                  if (sublabel != null)
                    Text(sublabel!, style: theme.textTheme.labelSmall),
                ],
              ),
            ),
            SizedBox(
              width: 36,
              child: Text(
                modifierLabel,
                textAlign: TextAlign.end,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
