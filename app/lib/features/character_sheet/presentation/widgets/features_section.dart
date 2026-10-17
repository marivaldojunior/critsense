import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/di/injection_container.dart';
import 'package:crit_sense/features/compendium/domain/entities/api_reference.dart';
import 'package:crit_sense/features/compendium/domain/entities/rule_feature.dart';

import '../../domain/entities/character.dart';
import '../../domain/srd/srd_race.dart';
import '../bloc/character_bloc.dart';
import '../bloc/features_bloc.dart';

/// Características de classe (até o nível atual) e traços raciais do SRD.
/// Tocar numa característica mostra o texto dela.
///
/// Recarrega quando o nível ou a subclasse mudam (a chave do [BlocProvider]
/// inclui os dois).
class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final classIndex = character.srdClass?.apiIndex;
    final raceIndex = SrdRace.fromName(character.race)?.apiIndex;

    return BlocProvider<FeaturesBloc>(
      key: ValueKey('features-${character.level}-${character.subclass}'),
      create: (_) => sl<FeaturesBloc>()
        ..add(
          LoadFeaturesEvent(
            classIndex: classIndex,
            raceIndex: raceIndex,
            level: character.level,
            subclassIndex: character.srdSubclassIndex,
          ),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SubclassTile(character: character),
          _FeaturesBody(
            character: character,
            hasSrdData: classIndex != null || raceIndex != null,
          ),
        ],
      ),
    );
  }
}

class _FeaturesBody extends StatelessWidget {
  const _FeaturesBody({required this.character, required this.hasSrdData});

  final Character character;
  final bool hasSrdData;

  void _showDetail(
    BuildContext context,
    ApiReference ref,
    RuleFeatureKind kind,
  ) {
    final bloc = context.read<FeaturesBloc>()
      ..add(LoadFeatureDetailEvent(ref.index, kind));
    showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: BlocBuilder<FeaturesBloc, FeaturesState>(
          builder: (context, state) {
            final detail = state.details[ref.index];
            final failed = state.failedDetails.contains(ref.index);
            return AlertDialog(
              title: Text(ref.name),
              content: SingleChildScrollView(
                child: detail != null
                    ? Text(detail.desc.join('\n\n'))
                    : failed
                    ? const Text(
                        'Não foi possível carregar o texto. Confira a internet.',
                      )
                    : const SizedBox(
                        height: 48,
                        child: Center(child: CircularProgressIndicator()),
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!hasSrdData) {
      return Text(
        'A classe e a raça deste personagem não são do SRD, então a ficha '
        'não tem as características delas.',
        style: theme.textTheme.bodySmall,
      );
    }

    return BlocBuilder<FeaturesBloc, FeaturesState>(
      builder: (context, state) {
        switch (state.status) {
          case FeaturesStatus.initial:
          case FeaturesStatus.loading:
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          case FeaturesStatus.failure:
            return Row(
              children: [
                const Expanded(
                  child: Text(
                    'Não foi possível carregar as características. Confira a '
                    'internet.',
                  ),
                ),
                TextButton(
                  onPressed: () => context.read<FeaturesBloc>().add(
                    LoadFeaturesEvent(
                      classIndex: character.srdClass?.apiIndex,
                      raceIndex: SrdRace.fromName(character.race)?.apiIndex,
                      level: character.level,
                      subclassIndex: character.srdSubclassIndex,
                    ),
                  ),
                  child: const Text('Tentar novamente'),
                ),
              ],
            );
          case FeaturesStatus.success:
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final level in state.classFeatures)
                  if (level.features.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Text(
                        '${character.characterClass} — nível ${level.level}',
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final feature in level.features)
                          ActionChip(
                            label: Text(feature.name),
                            onPressed: () => _showDetail(
                              context,
                              feature,
                              RuleFeatureKind.classFeature,
                            ),
                          ),
                      ],
                    ),
                  ],
                for (final level in state.subclassFeatures)
                  if (level.features.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Text(
                        '${character.subclassName} — nível ${level.level}',
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final feature in level.features)
                          ActionChip(
                            label: Text(feature.name),
                            onPressed: () => _showDetail(
                              context,
                              feature,
                              RuleFeatureKind.classFeature,
                            ),
                          ),
                      ],
                    ),
                  ],
                if (state.racialTraits.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Text(
                      'Traços de ${character.race}',
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final trait in state.racialTraits)
                        ActionChip(
                          label: Text(trait.name),
                          onPressed: () => _showDetail(
                            context,
                            trait,
                            RuleFeatureKind.racialTrait,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            );
        }
      },
    );
  }
}

/// Subclasse do personagem, com o botão para escolher ou trocar. Antes do
/// nível da subclasse, mostra em que nível ela vem.
class SubclassTile extends StatelessWidget {
  const SubclassTile({super.key, required this.character});

  final Character character;

  Future<void> _choose(BuildContext context) async {
    final bloc = context.read<CharacterBloc>();
    final choice = await showDialog<String>(
      context: context,
      builder: (_) => _SubclassDialog(character: character),
    );
    if (choice != null) bloc.add(SetSubclassEvent(character.id, choice));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = character.subclassName;
    final subclassLevel = character.srdClass?.subclassLevel ?? 3;

    final String subtitle;
    if (name != null) {
      subtitle = name;
    } else if (character.canChooseSubclass) {
      subtitle = 'Escolha a subclasse.';
    } else {
      subtitle = 'A subclasse vem no nível $subclassLevel.';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Subclasse', style: theme.textTheme.labelLarge),
                Text(
                  subtitle,
                  style: name == null && character.canChooseSubclass
                      ? theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        )
                      : theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (character.canChooseSubclass || name != null)
            TextButton(
              onPressed: () => _choose(context),
              child: Text(name == null ? 'Escolher' : 'Trocar'),
            ),
        ],
      ),
    );
  }
}

/// Devolve o índice da subclasse do SRD, um nome livre ou `''` para
/// remover a subclasse.
class _SubclassDialog extends StatefulWidget {
  const _SubclassDialog({required this.character});

  final Character character;

  @override
  State<_SubclassDialog> createState() => _SubclassDialogState();
}

class _SubclassDialogState extends State<_SubclassDialog> {
  late final TextEditingController _custom = TextEditingController(
    text: widget.character.srdSubclassIndex == null
        ? widget.character.subclass ?? ''
        : '',
  );

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final srd = widget.character.srdClass?.srdSubclass;
    return AlertDialog(
      title: const Text('Subclasse'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (srd != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  widget.character.srdSubclassIndex == srd.apiIndex
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(srd.name),
                subtitle: const Text('Do SRD, com as características.'),
                onTap: () => Navigator.pop(context, srd.apiIndex),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: _custom,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Outra subclasse (nome)',
                helperText: 'Fora do SRD: a ficha guarda só o nome.',
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.character.subclass != null)
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('Remover'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final name = _custom.text.trim();
            if (name.isNotEmpty) Navigator.pop(context, name);
          },
          child: const Text('Usar o nome'),
        ),
      ],
    );
  }
}
