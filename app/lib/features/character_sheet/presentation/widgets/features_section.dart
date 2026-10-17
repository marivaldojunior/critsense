import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/di/injection_container.dart';
import 'package:crit_sense/features/compendium/domain/entities/api_reference.dart';
import 'package:crit_sense/features/compendium/domain/entities/rule_feature.dart';

import '../../domain/entities/character.dart';
import '../../domain/srd/srd_race.dart';
import '../bloc/features_bloc.dart';

/// Características de classe (até o nível atual) e traços raciais do SRD.
/// Tocar numa característica mostra o texto dela.
///
/// Recarrega quando o nível muda (a chave do [BlocProvider] inclui o nível).
class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final classIndex = character.srdClass?.apiIndex;
    final raceIndex = SrdRace.fromName(character.race)?.apiIndex;

    return BlocProvider<FeaturesBloc>(
      key: ValueKey('features-${character.level}'),
      create: (_) => sl<FeaturesBloc>()
        ..add(
          LoadFeaturesEvent(
            classIndex: classIndex,
            raceIndex: raceIndex,
            level: character.level,
          ),
        ),
      child: _FeaturesBody(
        character: character,
        hasSrdData: classIndex != null || raceIndex != null,
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
