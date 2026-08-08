import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

import '../../../../di/injection_container.dart';
import '../../domain/entities/spell_detail.dart';
import '../bloc/spell_detail_bloc.dart';

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
              ),
            ),
            body: switch (state) {
              SpellDetailInitial() => const SizedBox.shrink(),
              SpellDetailLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              SpellDetailLoaded(:final spell) => _SpellDetailBody(spell: spell),
              SpellDetailError(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            },
          );
        },
      ),
    );
  }
}

/// Corpo da tela com todos os detalhes da magia.
class _SpellDetailBody extends StatelessWidget {
  final SpellDetail spell;

  const _SpellDetailBody({required this.spell});

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
                color: colorScheme.secondary,
              ),
              _InfoChip(
                iconAsset: 'assets/icons/attribute/range.svg',
                label: spell.range,
                color: colorScheme.tertiary,
              ),
              _InfoChip(
                iconAsset: 'assets/icons/combat/round.svg',
                label: spell.duration,
                color: colorScheme.secondary,
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
