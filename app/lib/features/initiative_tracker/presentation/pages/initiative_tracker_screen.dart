import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/app_drawer.dart';
import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/di/injection_container.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/attribute.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/character.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/character_bloc.dart';
import 'package:crit_sense/features/compendium/domain/entities/monster_summary.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_monster_detail_usecase.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_monsters_usecase.dart';
import 'package:crit_sense/features/voice_commands/domain/entities/voice_command.dart';
import 'package:crit_sense/features/voice_commands/presentation/cubit/voice_command_cubit.dart';
import 'package:crit_sense/features/voice_commands/presentation/widgets/voice_command_sheet.dart';

import '../../domain/entities/combatant.dart';
import '../cubit/initiative_cubit.dart';

/// Rastreador de iniciativa: lista o combate na ordem de iniciativa, com o
/// turno atual e a rodada.
class InitiativeTrackerScreen extends StatelessWidget {
  const InitiativeTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InitiativeCubit>.value(
      value: sl<InitiativeCubit>(),
      child: const _TrackerView(),
    );
  }
}

String _signed(int value) => value >= 0 ? '+$value' : '$value';

class _TrackerView extends StatelessWidget {
  const _TrackerView();

  Future<void> _addCharacters(BuildContext context) async {
    final cubit = context.read<InitiativeCubit>();
    final state = context.read<CharacterBloc>().state;
    final characters = state is CharacterLoaded
        ? state.characters
        : const <Character>[];
    final inCombat = {
      for (final c in cubit.state.combatants)
        if (c.characterId != null) c.characterId,
    };
    final available = characters.where((c) => !inCombat.contains(c.id));
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum personagem para adicionar.')),
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(
                'Adicionar personagem',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            for (final character in available)
              ListTile(
                leading: const DnDIcon(
                  assetPath: 'assets/icons/game/character.svg',
                  size: 24,
                ),
                title: Text(character.name),
                subtitle: Text('Iniciativa ${_signed(character.initiative)}'),
                onTap: () {
                  cubit.add(
                    name: character.name,
                    initiativeBonus: character.initiative,
                    characterId: character.id,
                  );
                  Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _addMonster(BuildContext context) async {
    final cubit = context.read<InitiativeCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MonsterPicker(onPicked: cubit.add),
    );
  }

  Future<void> _addCustom(BuildContext context) async {
    final cubit = context.read<InitiativeCubit>();
    await showDialog<void>(
      context: context,
      builder: (_) => _CustomCombatantDialog(onSave: cubit.add),
    );
  }

  Future<void> _editInitiative(BuildContext context, Combatant c) async {
    final cubit = context.read<InitiativeCubit>();
    final value = await showDialog<int>(
      context: context,
      builder: (_) => _NumberDialog(
        title: 'Iniciativa de ${c.name}',
        initialValue: c.initiative,
        allowNegative: true,
      ),
    );
    if (value != null) cubit.setInitiative(c.id, value);
  }

  Future<void> _changeHp(BuildContext context, Combatant c) async {
    final cubit = context.read<InitiativeCubit>();
    final result = await showDialog<int>(
      context: context,
      builder: (_) => _HpDialog(combatant: c),
    );
    if (result != null) cubit.changeHitPoints(c.id, result);
  }

  /// Abre a escuta e aplica o comando confirmado no combate.
  Future<void> _listen(BuildContext context) async {
    final cubit = context.read<InitiativeCubit>();
    final messenger = ScaffoldMessenger.of(context);
    void tell(String text) =>
        messenger.showSnackBar(SnackBar(content: Text(text)));

    final command = await showVoiceCommandSheet(
      context,
      scope: VoiceScope.combat,
    );
    switch (command) {
      case NextTurnCommand():
        cubit.nextTurn();
      case PreviousTurnCommand():
        cubit.previousTurn();
      case DamageCommand(:final amount, :final target) ||
          HealCommand(:final amount, :final target):
        final combatant = target == null
            ? cubit.state.current
            : cubit.findByName(target);
        if (combatant == null) {
          tell(
            target == null
                ? 'Diga o nome da criatura ou comece o combate.'
                : 'Não achei uma só criatura com o nome "$target".',
          );
          return;
        }
        if (combatant.hitPoints == null) {
          tell('${combatant.name} não tem PV no rastreador. Use a ficha.');
          return;
        }
        final delta = command is DamageCommand ? -amount : amount;
        cubit.changeHitPoints(combatant.id, delta);
        tell(
          command is DamageCommand
              ? '${combatant.name}: $amount de dano.'
              : '${combatant.name}: $amount de cura.',
        );
      default:
        break;
    }
  }

  Future<void> _confirmClear(BuildContext context) async {
    final cubit = context.read<InitiativeCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Encerrar combate'),
        content: const Text('Todos os participantes saem da lista.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Encerrar'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) cubit.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<InitiativeCubit, InitiativeState>(
      builder: (context, state) {
        final cubit = context.read<InitiativeCubit>();
        return Scaffold(
          drawer: const AppDrawer(),
          appBar: AppBar(
            title: Text(
              state.started
                  ? 'Iniciativa — rodada ${state.round}'
                  : 'Iniciativa',
            ),
            actions: [
              if (state.combatants.isNotEmpty)
                VoiceCommandButton(onPressed: () => _listen(context)),
              PopupMenuButton<String>(
                tooltip: 'Adicionar',
                icon: const Icon(Icons.person_add_alt_1_outlined),
                onSelected: (value) => switch (value) {
                  'character' => _addCharacters(context),
                  'monster' => _addMonster(context),
                  _ => _addCustom(context),
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'character', child: Text('Personagem')),
                  PopupMenuItem(value: 'monster', child: Text('Monstro')),
                  PopupMenuItem(value: 'custom', child: Text('Outra criatura')),
                ],
              ),
              if (state.combatants.isNotEmpty)
                IconButton(
                  tooltip: 'Encerrar combate',
                  icon: const Icon(Icons.stop_circle_outlined),
                  onPressed: () => _confirmClear(context),
                ),
            ],
          ),
          body: state.combatants.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Toque no botão de adicionar para colocar personagens, '
                      'monstros ou outras criaturas no combate.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                  itemCount: state.combatants.length,
                  itemBuilder: (context, index) {
                    final c = state.combatants[index];
                    return _CombatantTile(
                      combatant: c,
                      isCurrent: state.current?.id == c.id,
                      onInitiativeTap: () => _editInitiative(context, c),
                      onHpTap: c.hitPoints != null
                          ? () => _changeHp(context, c)
                          : null,
                      onRemove: () => cubit.remove(c.id),
                    );
                  },
                ),
          bottomNavigationBar: state.combatants.isEmpty
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: state.started
                        ? Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: cubit.previousTurn,
                                  icon: const Icon(Icons.chevron_left),
                                  label: const Text('Anterior'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: cubit.nextTurn,
                                  icon: const Icon(Icons.chevron_right),
                                  label: const Text('Próximo turno'),
                                ),
                              ),
                            ],
                          )
                        : FilledButton.icon(
                            onPressed: cubit.start,
                            icon: const DnDIcon(
                              assetPath: 'assets/icons/game/combat.svg',
                              size: 20,
                            ),
                            label: const Text('Começar combate'),
                          ),
                  ),
                ),
        );
      },
    );
  }
}

class _CombatantTile extends StatelessWidget {
  const _CombatantTile({
    required this.combatant,
    required this.isCurrent,
    required this.onInitiativeTap,
    required this.onHpTap,
    required this.onRemove,
  });

  final Combatant combatant;
  final bool isCurrent;
  final VoidCallback onInitiativeTap;
  final VoidCallback? onHpTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = combatant;
    final details = [
      'Mod. ${_signed(c.initiativeBonus)}',
      if (c.armorClass != null) 'CA ${c.armorClass}',
    ].join(' · ');

    return Card(
      color: isCurrent ? theme.colorScheme.primaryContainer : null,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: InkWell(
          onTap: onInitiativeTap,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 44,
            child: Center(
              child: Text(
                c.initiative?.toString() ?? '—',
                style: theme.textTheme.titleLarge,
              ),
            ),
          ),
        ),
        title: Text(
          c.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: c.isDown
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: Text(details),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (c.hitPoints != null)
              TextButton(
                onPressed: onHpTap,
                child: Text('${c.hitPoints}/${c.maxHitPoints} PV'),
              ),
            IconButton(
              tooltip: 'Tirar ${c.name}',
              icon: const Icon(Icons.close),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

typedef _AddCombatant =
    void Function({
      required String name,
      int initiativeBonus,
      int? armorClass,
      int? hitPoints,
      String? characterId,
    });

/// Busca no bestiário e adiciona o monstro com CA, PV e o modificador de
/// DES.
class _MonsterPicker extends StatefulWidget {
  const _MonsterPicker({required this.onPicked});

  final _AddCombatant onPicked;

  @override
  State<_MonsterPicker> createState() => _MonsterPickerState();
}

class _MonsterPickerState extends State<_MonsterPicker> {
  final _search = TextEditingController();
  List<MonsterSummary> _results = const [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _find();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _find() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await sl<GetMonstersUseCase>()(
        offset: 0,
        limit: 30,
        name: _search.text.trim().isEmpty ? null : _search.text.trim(),
      );
      if (mounted) setState(() => _results = results);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Não foi possível buscar. Confira a internet.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pick(MonsterSummary summary) async {
    setState(() => _loading = true);
    try {
      final monster = await sl<GetMonsterDetailUseCase>()(summary.index);
      widget.onPicked(
        name: monster.name,
        initiativeBonus: attributeModifier(monster.dexterity),
        armorClass: monster.armorClass,
        hitPoints: monster.hitPoints,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Não foi possível abrir o monstro. Confira a internet.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    labelText: 'Buscar monstro',
                    suffixIcon: IconButton(
                      tooltip: 'Buscar',
                      icon: const Icon(Icons.search),
                      onPressed: _find,
                    ),
                  ),
                  onSubmitted: (_) => _find(),
                ),
              ),
              if (_loading) const LinearProgressIndicator(),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_error!),
                ),
              Expanded(
                child: ListView(
                  children: [
                    for (final monster in _results)
                      ListTile(
                        leading: const DnDIcon(
                          assetPath: 'assets/icons/game/monster.svg',
                          size: 24,
                        ),
                        title: Text(monster.name),
                        onTap: _loading ? null : () => _pick(monster),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomCombatantDialog extends StatefulWidget {
  const _CustomCombatantDialog({required this.onSave});

  final _AddCombatant onSave;

  @override
  State<_CustomCombatantDialog> createState() => _CustomCombatantDialogState();
}

class _CustomCombatantDialogState extends State<_CustomCombatantDialog> {
  final _name = TextEditingController();
  final _bonus = TextEditingController(text: '0');
  final _hp = TextEditingController();
  final _ac = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _bonus.dispose();
    _hp.dispose();
    _ac.dispose();
    super.dispose();
  }

  Widget _numberField(
    TextEditingController c,
    String label, {
    bool signed = false,
  }) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.numberWithOptions(signed: signed),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(signed ? r'^-?\d*' : r'\d*')),
      ],
      decoration: InputDecoration(labelText: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Outra criatura'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            _numberField(_bonus, 'Modificador de iniciativa', signed: true),
            _numberField(_hp, 'PV (opcional)'),
            _numberField(_ac, 'CA (opcional)'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final hp = int.tryParse(_hp.text);
            widget.onSave(
              name: _name.text,
              initiativeBonus: int.tryParse(_bonus.text) ?? 0,
              hitPoints: hp != null && hp > 0 ? hp : null,
              armorClass: int.tryParse(_ac.text),
            );
            Navigator.pop(context);
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}

class _NumberDialog extends StatefulWidget {
  const _NumberDialog({
    required this.title,
    required this.initialValue,
    this.allowNegative = false,
  });

  final String title;
  final int? initialValue;
  final bool allowNegative;

  @override
  State<_NumberDialog> createState() => _NumberDialogState();
}

class _NumberDialogState extends State<_NumberDialog> {
  late final _controller = TextEditingController(
    text: widget.initialValue?.toString() ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_controller.text);
    if (value != null) Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.numberWithOptions(
          signed: widget.allowNegative,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(widget.allowNegative ? r'^-?\d*' : r'\d*'),
          ),
        ],
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Salvar')),
      ],
    );
  }
}

/// Devolve a mudança de PV: negativa para dano, positiva para cura.
class _HpDialog extends StatefulWidget {
  const _HpDialog({required this.combatant});

  final Combatant combatant;

  @override
  State<_HpDialog> createState() => _HpDialogState();
}

class _HpDialogState extends State<_HpDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(int sign) {
    final value = int.tryParse(_controller.text);
    if (value != null && value > 0) Navigator.pop(context, sign * value);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.combatant;
    return AlertDialog(
      title: Text('${c.name}: ${c.hitPoints}/${c.maxHitPoints} PV'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(labelText: 'Quantidade'),
      ),
      actions: [
        TextButton(onPressed: () => _submit(1), child: const Text('Cura')),
        FilledButton(onPressed: () => _submit(-1), child: const Text('Dano')),
      ],
    );
  }
}
