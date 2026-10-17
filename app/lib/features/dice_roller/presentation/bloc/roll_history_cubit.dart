import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/dice_result.dart';
import '../../domain/entities/dice_type.dart';

/// Uma rolagem guardada no histórico.
class RollHistoryEntry extends Equatable {
  /// O que foi rolado (ex: "Atletismo", "Espada longa — dano", "2d6 + 1").
  final String label;

  /// Os dados e o modificador (ex: "d20: 14 (6 descartado) + 3").
  final String detail;

  final int total;

  /// Um d20 natural 20 (`true`), natural 1 (`false`) ou nenhum (`null`).
  final bool? critical;

  final DateTime rolledAt;

  const RollHistoryEntry({
    required this.label,
    required this.detail,
    required this.total,
    required this.rolledAt,
    this.critical,
  });

  Map<String, dynamic> toJson() => {
    'label': label,
    'detail': detail,
    'total': total,
    'critical': critical,
    'rolledAt': rolledAt.toIso8601String(),
  };

  factory RollHistoryEntry.fromJson(Map<String, dynamic> json) =>
      RollHistoryEntry(
        label: json['label'] as String,
        detail: json['detail'] as String,
        total: (json['total'] as num).toInt(),
        critical: json['critical'] as bool?,
        rolledAt: DateTime.parse(json['rolledAt'] as String),
      );

  @override
  List<Object?> get props => [label, detail, total, critical, rolledAt];
}

/// Texto dos dados de [result], ex: `d20: 14 (6 descartado) + 3` ou
/// `d6: 2, d6: 5 - 1`.
String describeRoll(DiceRollResult result) {
  final dice = [
    for (final die in result.rolls)
      die.discardedValue != null
          ? '${die.type.label}: ${die.value} (${die.discardedValue} descartado)'
          : '${die.type.label}: ${die.value}',
  ].join(', ');
  final modifier = result.modifier;
  if (dice.isEmpty) return '$modifier';
  if (modifier == 0) return dice;
  return modifier > 0 ? '$dice + $modifier' : '$dice - ${modifier.abs()}';
}

/// Nome de uma rolagem do rolador, ex: `2d6 + 1d20 + 3`.
String poolLabel(Map<DiceType, int> pool, int modifier) {
  final dice = [
    for (final type in DiceType.values)
      if ((pool[type] ?? 0) > 0) '${pool[type]}${type.label}',
  ].join(' + ');
  if (modifier == 0) return dice;
  return modifier > 0 ? '$dice + $modifier' : '$dice - ${modifier.abs()}';
}

/// As últimas [maxEntries] rolagens do rolador e da ficha, da mais nova
/// para a mais antiga. Fica salvo no [SharedPreferences].
class RollHistoryCubit extends Cubit<List<RollHistoryEntry>> {
  RollHistoryCubit(this._preferences, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      super(_load(_preferences));

  static const storageKey = 'roll_history';
  static const maxEntries = 50;

  final SharedPreferences _preferences;
  final DateTime Function() _clock;

  static List<RollHistoryEntry> _load(SharedPreferences preferences) {
    final raw = preferences.getString(storageKey);
    if (raw == null) return const [];
    try {
      return [
        for (final e in jsonDecode(raw) as List<dynamic>)
          RollHistoryEntry.fromJson(e as Map<String, dynamic>),
      ];
    } catch (_) {
      return const [];
    }
  }

  void record(String label, DiceRollResult result) {
    final hasD20 = result.rolls.any((r) => r.type.sides == 20);
    final entry = RollHistoryEntry(
      label: label,
      detail: describeRoll(result),
      total: result.total,
      critical: !hasD20
          ? null
          : result.hasCriticalSuccess
          ? true
          : result.hasCriticalFailure
          ? false
          : null,
      rolledAt: _clock(),
    );
    _save([entry, ...state].take(maxEntries).toList());
  }

  void clear() => _save(const []);

  void _save(List<RollHistoryEntry> entries) {
    emit(entries);
    _preferences.setString(
      storageKey,
      jsonEncode([for (final e in entries) e.toJson()]),
    );
  }
}
