import 'package:flutter/material.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/d20_roll_mode.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_type.dart';

/// Grade com a composição exata do pool: um ícone por dado individual —
/// `{d20: 2, d4: 1}` renderiza dois ícones de d20 e um de d4, centralizados
/// em cada linha e quebrando para a linha seguinte conforme a largura
/// disponível.
///
/// Tocar em um ícone dispara [onRemove] para aquele dado específico. Mostra
/// no máximo 2 linhas; a partir da terceira, rola verticalmente com uma
/// thumb sempre visível.
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

  /// Altura de um ícone individual: 32 (tamanho do `DnDIcon`) + 4 de padding
  /// em cada lado — ver [_SelectedDieIcon].
  static const _lineHeight = 40.0;

  /// Altura de 2 linhas + o espaçamento vertical entre elas (`runSpacing`).
  static const _maxHeight = _lineHeight * 2 + 8;

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
        height: SelectedDiceRow._lineHeight,
        child: Center(
          child: Text(
            'Nenhum dado no pool ainda.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: SelectedDiceRow._maxHeight),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in dice)
                _SelectedDieIcon(
                  type: type,
                  d20Mode: widget.d20Mode,
                  onRemove: widget.onRemove,
                ),
            ],
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
