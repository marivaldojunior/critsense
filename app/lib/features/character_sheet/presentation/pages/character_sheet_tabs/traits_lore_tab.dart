import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

import '../../../domain/entities/character.dart';
import '../../bloc/character_bloc.dart';
import '../../widgets/features_section.dart';
import '../../widgets/proficiencies_languages_card.dart';

/// Aba "Características & Lore": os campos de texto longo do bloco lateral
/// esquerdo da ficha oficial (Traços, Ideais, Vínculos, Fraquezas) mais o
/// Antecedente/Histórico do cabeçalho.
///
/// [StatefulWidget] porque junta as edições pendentes dos cinco campos e
/// salva com um único debounce. O salvamento usa [UpdateLoreEvent], que só
/// muda os campos de texto da versão atual do personagem: salvar uma cópia
/// do personagem guardada na abertura da aba desfaria o que mudou nas
/// outras abas (PV, nível, espaços de magia) nesse meio-tempo.
class TraitsLoreTab extends StatefulWidget {
  const TraitsLoreTab({super.key, required this.character});

  final Character character;

  @override
  State<TraitsLoreTab> createState() => _TraitsLoreTabState();
}

enum _LoreKey { personalityTraits, ideals, bonds, flaws, background }

class _TraitsLoreTabState extends State<TraitsLoreTab> {
  final Map<_LoreKey, String> _pending = {};
  Timer? _debounce;
  late final CharacterBloc _bloc = context.read<CharacterBloc>();

  @override
  void dispose() {
    _debounce?.cancel();
    // Salva o que ainda estava no debounce ao sair da aba.
    _flush();
    super.dispose();
  }

  /// Guarda a edição e reagenda o salvamento para 500ms após a última
  /// edição em qualquer campo desta aba.
  void _onFieldChanged(_LoreKey field, String value) {
    _pending[field] = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _flush);
  }

  void _flush() {
    if (_pending.isEmpty) return;
    _bloc.add(
      UpdateLoreEvent(
        widget.character.id,
        personalityTraits: _pending[_LoreKey.personalityTraits],
        ideals: _pending[_LoreKey.ideals],
        bonds: _pending[_LoreKey.bonds],
        flaws: _pending[_LoreKey.flaws],
        background: _pending[_LoreKey.background],
      ),
    );
    _pending.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Características de Classe e Raça',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Divider(),
        // Lê o nível atual do BLoC: subir de nível recarrega a seção.
        BlocBuilder<CharacterBloc, CharacterState>(
          buildWhen: (previous, current) =>
              previous.findCharacter(widget.character.id)?.level !=
              current.findCharacter(widget.character.id)?.level,
          builder: (context, state) => FeaturesSection(
            character:
                state.findCharacter(widget.character.id) ?? widget.character,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Proficiências e Idiomas',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Divider(),
        BlocBuilder<CharacterBloc, CharacterState>(
          buildWhen: (previous, current) => !identical(
            previous.findCharacter(widget.character.id),
            current.findCharacter(widget.character.id),
          ),
          builder: (context, state) => ProficienciesLanguagesCard(
            character:
                state.findCharacter(widget.character.id) ?? widget.character,
          ),
        ),
        const SizedBox(height: 24),
        _LoreField(
          label: 'Traços de Personalidade',
          initialValue: widget.character.personalityTraits,
          onChanged: (v) => _onFieldChanged(_LoreKey.personalityTraits, v),
        ),
        const SizedBox(height: 16),
        _LoreField(
          label: 'Ideais',
          initialValue: widget.character.ideals,
          onChanged: (v) => _onFieldChanged(_LoreKey.ideals, v),
        ),
        const SizedBox(height: 16),
        _LoreField(
          label: 'Vínculos',
          initialValue: widget.character.bonds,
          onChanged: (v) => _onFieldChanged(_LoreKey.bonds, v),
        ),
        const SizedBox(height: 16),
        _LoreField(
          label: 'Fraquezas',
          initialValue: widget.character.flaws,
          onChanged: (v) => _onFieldChanged(_LoreKey.flaws, v),
        ),
        const SizedBox(height: 16),
        _LoreField(
          label: 'Histórico',
          initialValue: widget.character.background,
          minLines: 5,
          onChanged: (v) => _onFieldChanged(_LoreKey.background, v),
        ),
        const SizedBox(height: 24),
        Text(
          'Monstros & Chefes Derrotados',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Divider(),
        _DefeatedBossesSection(characterId: widget.character.id),
      ],
    );
  }
}

/// Seção "Monstros & Chefes Derrotados": lê `character.defeatedBosses` ao
/// vivo do [CharacterBloc] — os abates registrados via Compêndio (ver
/// [MonsterDetailScreen]) aparecem aqui assim que persistidos, sem
/// recarregar a ficha.
class _DefeatedBossesSection extends StatelessWidget {
  const _DefeatedBossesSection({required this.characterId});

  final String characterId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CharacterBloc, CharacterState>(
      buildWhen: (previous, current) => !identical(
        previous.findCharacter(characterId),
        current.findCharacter(characterId),
      ),
      builder: (context, state) {
        final defeatedBosses =
            state.findCharacter(characterId)?.defeatedBosses ?? const [];

        if (defeatedBosses.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Este herói ainda não tem grandes abates registrados.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.outline,
              ),
            ),
          );
        }

        return Column(
          children: [
            for (final boss in defeatedBosses)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: const DnDIcon(
                    assetPath: 'assets/icons/damage/slashing.svg',
                    size: 24,
                  ),
                  title: Text(
                    boss,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Remover registro de abate',
                    onPressed: () => context.read<CharacterBloc>().add(
                      RemoveBossFromCharacterEvent(characterId, boss),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Campo de texto longo padronizado desta aba: rótulo fixo no topo mesmo
/// vazio ([alignLabelWithHint]) e altura mínima maior que um campo comum,
/// já que o conteúdo típico (traços, ideais...) costuma ter várias linhas.
class _LoreField extends StatelessWidget {
  const _LoreField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.minLines = 3,
  });

  final String label;
  final String initialValue;
  final int minLines;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      minLines: minLines,
      maxLines: minLines + 3,
      textCapitalization: TextCapitalization.sentences,
      onChanged: onChanged,
    );
  }
}
