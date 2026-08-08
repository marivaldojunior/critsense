import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/attribute_type.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/point_buy_rules.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/point_buy_cubit.dart';
import 'attribute_row.dart';

/// Seção de Compra de Pontos do formulário: contador de pontos restantes
/// no topo e uma [AttributeRow] por atributo abaixo.
///
/// Espera um [PointBuyCubit] já disponível via [BlocProvider] ancestral.
class PointBuySection extends StatelessWidget {
  const PointBuySection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<PointBuyCubit, PointBuyState>(
      builder: (context, state) {
        final cubit = context.read<PointBuyCubit>();
        final remaining = state.pointsRemaining;
        // 0 restante é o desfecho normal de um Point Buy bem alocado, não um
        // erro — por isso cinza neutro, não vermelho, quando chega a zero.
        final remainingColor = remaining > 0
            ? Colors.green.shade600
            : theme.colorScheme.onSurface.withValues(alpha: 0.5);

        return Column(
          children: [
            Text(
              'Pontos Restantes: $remaining / ${PointBuyRules.totalPoints}',
              style: theme.textTheme.titleLarge?.copyWith(
                color: remainingColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            for (final type in AttributeType.values)
              AttributeRow(
                type: type,
                value: state.attributes.valueOf(type),
                canIncrement: state.canIncrement(type),
                canDecrement: state.canDecrement(type),
                onIncrement: () => cubit.increment(type),
                onDecrement: () => cubit.decrement(type),
              ),
          ],
        );
      },
    );
  }
}
