import 'package:flutter/material.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/d20_roll_mode.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_type.dart';

/// Lista horizontal com a composição exata do pool: um ícone por dado
/// individual — `{d20: 2, d4: 1}` renderiza dois ícones de d20 e um de d4
/// lado a lado, na ordem em que os tipos foram adicionados ao pool.
///
/// Tocar em um ícone dispara [onRemove] para aquele dado específico. Rola
/// horizontalmente com uma thumb sempre visível quando o pool excede a
/// largura disponível.
class SelectedDiceRow extends StatefulWidget {
  const SelectedDiceRow({
    super.key,
    required this.pool,
    required this.d20Mode,
    required this.onRemove,
  });

  final Map<DiceType, int> pool;
  final D20RollMode d20Mode;
  final ValueChanged<DiceType> onRemove;

  static const _height = 56.0;

  @override
  State<SelectedDiceRow> createState() => _SelectedDiceRowState();
}

class _SelectedDiceRowState extends State<SelectedDiceRow> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Desdobra o mapa `tipo -> quantidade` em uma lista plana, um item por
  /// unidade de dado.
  List<DiceType> _flatten() => [
    for (final entry in widget.pool.entries)
      for (var i = 0; i < entry.value; i++) entry.key,
  ];

  @override
  Widget build(BuildContext context) {
    final dice = _flatten();

    if (dice.isEmpty) {
      return SizedBox(
        height: SelectedDiceRow._height,
        child: Center(
          child: Text(
            'Nenhum dado no pool ainda.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    return SizedBox(
      height: SelectedDiceRow._height,
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: dice.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) => _SelectedDieIcon(
            type: dice[index],
            d20Mode: widget.d20Mode,
            onRemove: widget.onRemove,
          ),
        ),
      ),
    );
  }
}

class _SelectedDieIcon extends StatelessWidget {
  const _SelectedDieIcon({
    required this.type,
    required this.d20Mode,
    required this.onRemove,
  });

  final DiceType type;
  final D20RollMode d20Mode;
  final ValueChanged<DiceType> onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = DnDIcon(
      assetPath: type.iconAsset,
      size: 32,
      color: colorScheme.primary,
    );

    // Vantagem/desvantagem é regra exclusiva do d20 — só ele recebe o selo.
    final showModeBadge = type == DiceType.d20 && d20Mode != D20RollMode.normal;
    final isAdvantage = d20Mode == D20RollMode.advantage;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => onRemove(type),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: showModeBadge
            ? Badge(
                backgroundColor: isAdvantage
                    ? Colors.green.shade600
                    : Colors.red.shade600,
                label: Icon(
                  isAdvantage ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 10,
                  color: Colors.white,
                ),
                child: icon,
              )
            : icon,
      ),
    );
  }
}
