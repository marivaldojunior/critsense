import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/character_picker_bottom_sheet.dart';
import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/core/presentation/widgets/skeleton_bones.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/character_bloc.dart';

import '../../../../di/injection_container.dart';
import '../../domain/entities/spell_detail.dart';
import '../bloc/spell_detail_bloc.dart';
import '../widgets/compendium_feedback_state.dart';

/// Tela de detalhes de uma magia do compêndio.
///
/// Recebe [spellIndex] via construtor — equivalente ao parâmetro de rota
/// `[HttpGet("{index}")]` em um controller MVC do .NET ou a uma query string
/// `?index=acid-arrow`. No Flutter não há um roteador centralizado tipado por
/// padrão; o parâmetro é passado diretamente ao widget, garantindo type-safety
/// em tempo de compilação sem precisar extrair e converter strings de URL.
class SpellDetailScreen extends StatelessWidget {
  /// Índice da magia na API (ex: "acid-arrow").
  final String spellIndex;

  const SpellDetailScreen({super.key, required this.spellIndex});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<SpellDetailBloc>()..add(LoadSpellDetailEvent(spellIndex)),
      child: BlocBuilder<SpellDetailBloc, SpellDetailState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              // Exibe o nome da magia assim que o estado Loaded for emitido.
              title: Text(
                state is SpellDetailLoaded ? state.spell.name : 'Detalhes',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: switch (state) {
                SpellDetailInitial() => const SizedBox.shrink(
                  key: ValueKey('initial'),
                ),
                SpellDetailLoading() => const _SpellDetailSkeleton(
                  key: ValueKey('loading'),
                ),
                SpellDetailLoaded(:final spell) => _SpellDetailBody(
                  key: const ValueKey('loaded'),
                  spell: spell,
                ),
                SpellDetailError(:final message) =>
                  CompendiumFeedbackState.error(
                    key: const ValueKey('error'),
                    message: message,
                  ),
              },
            ),
            // Só existe com a magia já carregada — precisa do nome dela
            // para vincular ao personagem escolhido.
            floatingActionButton: state is SpellDetailLoaded
                ? FloatingActionButton(
                    onPressed: () => _addSpellToCharacter(context, state.spell),
                    tooltip: 'Adicionar a um personagem',
                    child: const Icon(Icons.add),
                  )
                : null,
          );
        },
      ),
    );
  }
}

/// Abre o [CharacterPickerBottomSheet] e, se um personagem for escolhido,
/// vincula [spell] a ele via [AddSpellToCharacterEvent].
Future<void> _addSpellToCharacter(
  BuildContext context,
  SpellDetail spell,
) async {
  final character = await CharacterPickerBottomSheet.show(context);
  if (character == null) return;
  if (!context.mounted) return;

  context.read<CharacterBloc>().add(
    AddSpellToCharacterEvent(character.id, spell.name),
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('${spell.name} adicionada a ${character.name}.')),
  );
}

/// Corpo da tela com todos os detalhes da magia.
class _SpellDetailBody extends StatelessWidget {
  final SpellDetail spell;

  const _SpellDetailBody({super.key, required this.spell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Chips de atributos rápidos ─────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                iconAsset: 'assets/icons/game/spell.svg',
                label: 'Nível ${spell.level == 0 ? "Truque" : spell.level}',
                color: colorScheme.primary,
              ),
              _InfoChip(
                iconAsset: 'assets/icons/entity/time.svg',
                label: spell.castingTime,
                color: colorScheme.primary,
              ),
              _InfoChip(
                iconAsset: 'assets/icons/attribute/range.svg',
                label: spell.range,
                color: colorScheme.primary,
              ),
              _InfoChip(
                iconAsset: 'assets/icons/combat/round.svg',
                label: spell.duration,
                color: colorScheme.primary,
              ),
              _InfoChip(
                iconAsset: 'assets/icons/entity/wand.svg',
                label: spell.components.join(', '),
                color: colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Descrição ─────────────────────────────────────────────────
          Text('Descrição', style: theme.textTheme.titleMedium),
          const Divider(),
          const SizedBox(height: 4),
          ...spell.desc.map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(paragraph, style: theme.textTheme.bodyMedium),
            ),
          ),

          // ── Em níveis superiores (condicional) ────────────────────────
          if (spell.higherLevel != null && spell.higherLevel!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Em Níveis Superiores', style: theme.textTheme.titleMedium),
            const Divider(),
            const SizedBox(height: 4),
            ...spell.higherLevel!.map(
              (paragraph) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(paragraph, style: theme.textTheme.bodyMedium),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Esqueleto de carregamento que imita o layout de detalhes da magia: chips
/// de atributos rápidos seguidos de linhas de texto da descrição.
class _SpellDetailSkeleton extends StatelessWidget {
  const _SpellDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                SkeletonBones.rect(width: 90, height: 28, borderRadius: 16),
                SkeletonBones.rect(width: 110, height: 28, borderRadius: 16),
                SkeletonBones.rect(width: 80, height: 28, borderRadius: 16),
                SkeletonBones.rect(width: 100, height: 28, borderRadius: 16),
                SkeletonBones.rect(width: 70, height: 28, borderRadius: 16),
              ],
            ),
            const SizedBox(height: 24),
            const SkeletonBones.rect(width: 100, height: 16),
            const SizedBox(height: 12),
            ...List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SkeletonBones.rect(
                  width: index == 4 ? 180 : double.infinity,
                  height: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip compacto para exibir um atributo com ícone e cor personalizados.
class _InfoChip extends StatelessWidget {
  final String iconAsset;
  final String label;
  final Color color;

  const _InfoChip({
    required this.iconAsset,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: DnDIcon(assetPath: iconAsset, size: 16, color: color),
      label: Text(label),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      visualDensity: VisualDensity.compact,
    );
  }
}
