import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/di/injection_container.dart';

import '../../domain/entities/d20_roll_mode.dart';
import '../../domain/entities/dice_result.dart';
import '../bloc/sheet_roll_cubit.dart';

String _signed(int value) => value >= 0 ? '+$value' : '$value';

/// Abre o painel de rolagem da ficha: d20 + [modifier], com vantagem ou
/// desvantagem. Em ataques, [damage] (e [versatileDamage]) permitem rolar o
/// dano; um 20 natural dobra os dados de dano.
///
/// [note] aparece acima do botão (ex: "Envenenado: desvantagem").
Future<void> showSheetRoll(
  BuildContext context, {
  required String title,
  required int modifier,
  String? damage,
  String? versatileDamage,
  String? note,
  D20RollMode initialMode = D20RollMode.normal,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlocProvider<SheetRollCubit>(
      create: (_) => sl<SheetRollCubit>(param1: initialMode),
      child: _SheetRollBody(
        title: title,
        modifier: modifier,
        damage: damage,
        versatileDamage: versatileDamage,
        note: note,
      ),
    ),
  );
}

class _SheetRollBody extends StatelessWidget {
  const _SheetRollBody({
    required this.title,
    required this.modifier,
    this.damage,
    this.versatileDamage,
    this.note,
  });

  final String title;
  final int modifier;
  final String? damage;
  final String? versatileDamage;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<SheetRollCubit, SheetRollState>(
      builder: (context, state) {
        final cubit = context.read<SheetRollCubit>();
        final d20 = state.d20Result;
        final critical = d20?.hasCriticalSuccess ?? false;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '$title (${_signed(modifier)})',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<D20RollMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: D20RollMode.disadvantage,
                        label: Text('Desvantagem'),
                      ),
                      ButtonSegment(
                        value: D20RollMode.normal,
                        label: Text('Normal'),
                      ),
                      ButtonSegment(
                        value: D20RollMode.advantage,
                        label: Text('Vantagem'),
                      ),
                    ],
                    selected: {state.mode},
                    onSelectionChanged: (s) => cubit.setMode(s.single),
                  ),
                  if (note != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(note!, style: theme.textTheme.bodySmall),
                    ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => cubit.rollD20(modifier),
                    icon: const DnDIcon(
                      assetPath: 'assets/icons/dice/d20.svg',
                      size: 22,
                    ),
                    label: const Text('Rolar d20'),
                  ),
                  if (d20 != null) _D20Result(result: d20),
                  if (damage != null && d20 != null) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () =>
                              cubit.rollDamage(damage!, critical: critical),
                          child: Text(
                            critical
                                ? 'Dano crítico ($damage, dados dobrados)'
                                : 'Rolar dano ($damage)',
                          ),
                        ),
                        if (versatileDamage != null)
                          OutlinedButton(
                            onPressed: () => cubit.rollDamage(
                              versatileDamage!,
                              critical: critical,
                            ),
                            child: Text('Duas mãos ($versatileDamage)'),
                          ),
                      ],
                    ),
                  ],
                  if (state.damageResult != null)
                    _DamageResult(result: state.damageResult!),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _D20Result extends StatelessWidget {
  const _D20Result({required this.result});

  final DiceRollResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final die = result.rolls.single;
    final color = result.hasCriticalSuccess
        ? Colors.green.shade700
        : result.hasCriticalFailure
        ? theme.colorScheme.error
        : null;
    final detail = StringBuffer('d20: ${die.value}');
    if (die.discardedValue != null) {
      detail.write(' (descartado: ${die.discardedValue})');
    }
    detail.write(' ${_signed(result.modifier)}');

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Text(
            '${result.total}',
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(detail.toString(), style: theme.textTheme.bodyMedium),
          if (result.hasCriticalSuccess)
            Text(
              '20 natural! Acerto crítico.',
              style: theme.textTheme.labelLarge?.copyWith(color: color),
            ),
          if (result.hasCriticalFailure)
            Text(
              '1 natural: falha crítica.',
              style: theme.textTheme.labelLarge?.copyWith(color: color),
            ),
        ],
      ),
    );
  }
}

class _DamageResult extends StatelessWidget {
  const _DamageResult({required this.result});

  final DiceRollResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dice = result.rolls.map((r) => '${r.value}').join(' + ');
    final detail = [
      if (dice.isNotEmpty) dice,
      if (result.modifier != 0) _signed(result.modifier),
    ].join(' ');

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Text(
            'Dano: ${result.total < 0 ? 0 : result.total}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (detail.isNotEmpty) Text(detail, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
