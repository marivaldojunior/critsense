import 'dart:convert';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/combatant.dart';

class InitiativeState extends Equatable {
  /// Participantes na ordem de iniciativa.
  final List<Combatant> combatants;

  /// Rodada atual; 0 = o combate ainda não começou.
  final int round;

  /// Posição de quem joga agora em [combatants].
  final int turnIndex;

  const InitiativeState({
    this.combatants = const [],
    this.round = 0,
    this.turnIndex = 0,
  });

  bool get started => round > 0;

  /// Quem joga agora, ou `null` antes do combate.
  Combatant? get current => started && combatants.isNotEmpty
      ? combatants[turnIndex.clamp(0, combatants.length - 1)]
      : null;

  InitiativeState copyWith({
    List<Combatant>? combatants,
    int? round,
    int? turnIndex,
  }) => InitiativeState(
    combatants: combatants ?? this.combatants,
    round: round ?? this.round,
    turnIndex: turnIndex ?? this.turnIndex,
  );

  Map<String, dynamic> toJson() => {
    'round': round,
    'turnIndex': turnIndex,
    'combatants': [for (final c in combatants) c.toJson()],
  };

  factory InitiativeState.fromJson(Map<String, dynamic> json) =>
      InitiativeState(
        round: (json['round'] as num?)?.toInt() ?? 0,
        turnIndex: (json['turnIndex'] as num?)?.toInt() ?? 0,
        combatants: [
          for (final c in (json['combatants'] as List<dynamic>? ?? const []))
            Combatant.fromJson(c as Map<String, dynamic>),
        ],
      );

  @override
  List<Object?> get props => [combatants, round, turnIndex];
}

/// Rastreador de iniciativa: ordem dos participantes, turno e rodada.
///
/// O estado fica salvo no [SharedPreferences]: o combate continua depois de
/// sair da tela ou de fechar o app.
class InitiativeCubit extends Cubit<InitiativeState> {
  InitiativeCubit(this._preferences, {Random? random})
    : _random = random ?? Random(),
      super(_load(_preferences));

  static const storageKey = 'initiative_tracker';

  final SharedPreferences _preferences;
  final Random _random;

  static InitiativeState _load(SharedPreferences preferences) {
    final raw = preferences.getString(storageKey);
    if (raw == null) return const InitiativeState();
    try {
      return InitiativeState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const InitiativeState();
    }
  }

  @override
  void emit(InitiativeState state) {
    super.emit(state);
    _preferences.setString(storageKey, jsonEncode(state.toJson()));
  }

  int _d20() => _random.nextInt(20) + 1;

  /// Adiciona um participante. Um nome repetido ganha um número (ex:
  /// "Goblin 2"). Com o combate já começado, ele rola a iniciativa na hora.
  void add({
    required String name,
    int initiativeBonus = 0,
    int? armorClass,
    int? hitPoints,
    String? characterId,
  }) {
    if (characterId != null &&
        state.combatants.any((c) => c.characterId == characterId)) {
      return;
    }
    final combatant = Combatant(
      id: const Uuid().v4(),
      name: _uniqueName(name.trim().isEmpty ? 'Criatura' : name.trim()),
      initiativeBonus: initiativeBonus,
      initiative: state.started ? _d20() + initiativeBonus : null,
      armorClass: armorClass,
      maxHitPoints: hitPoints,
      hitPoints: hitPoints,
      characterId: characterId,
    );
    _emitSorted([...state.combatants, combatant]);
  }

  String _uniqueName(String name) {
    final names = state.combatants.map((c) => c.name).toSet();
    if (!names.contains(name)) return name;
    var n = 2;
    while (names.contains('$name $n')) {
      n++;
    }
    return '$name $n';
  }

  void remove(String id) {
    final index = state.combatants.indexWhere((c) => c.id == id);
    if (index < 0) return;
    final next = state.combatants.toList()..removeAt(index);
    var turn = state.turnIndex;
    if (index < turn) turn--;
    if (turn >= next.length) turn = 0;
    emit(state.copyWith(combatants: next, turnIndex: turn));
  }

  void setInitiative(String id, int value) {
    _emitSorted([
      for (final c in state.combatants)
        c.id == id ? c.copyWith(initiative: value) : c,
    ]);
  }

  /// Rola d20 + modificador para quem ainda não tem iniciativa.
  void rollMissing() {
    _emitSorted([
      for (final c in state.combatants)
        c.initiative == null
            ? c.copyWith(initiative: _d20() + c.initiativeBonus)
            : c,
    ]);
  }

  /// Muda os PV de um monstro ou criatura por [delta] (negativo = dano),
  /// entre 0 e o máximo.
  void changeHitPoints(String id, int delta) {
    emit(
      state.copyWith(
        combatants: [
          for (final c in state.combatants)
            if (c.id == id && c.hitPoints != null)
              c.copyWith(
                hitPoints: (c.hitPoints! + delta).clamp(0, c.maxHitPoints!),
              )
            else
              c,
        ],
      ),
    );
  }

  /// Começa o combate: rola quem falta e passa o turno ao primeiro.
  void start() {
    if (state.combatants.isEmpty) return;
    rollMissing();
    emit(state.copyWith(round: 1, turnIndex: 0));
  }

  /// Passa o turno. Depois do último, começa a rodada seguinte.
  void nextTurn() {
    if (!state.started || state.combatants.isEmpty) return;
    final next = state.turnIndex + 1;
    if (next >= state.combatants.length) {
      emit(state.copyWith(turnIndex: 0, round: state.round + 1));
    } else {
      emit(state.copyWith(turnIndex: next));
    }
  }

  void previousTurn() {
    if (!state.started || state.combatants.isEmpty) return;
    if (state.turnIndex > 0) {
      emit(state.copyWith(turnIndex: state.turnIndex - 1));
    } else if (state.round > 1) {
      emit(
        state.copyWith(
          turnIndex: state.combatants.length - 1,
          round: state.round - 1,
        ),
      );
    }
  }

  /// Termina o combate e tira todos os participantes.
  void clear() => emit(const InitiativeState());

  /// Reordena e mantém o turno com o mesmo participante.
  void _emitSorted(List<Combatant> combatants) {
    final currentId = state.current?.id;
    final sorted = combatants.toList()..sort(compareInitiative);
    final turn = currentId == null
        ? state.turnIndex
        : sorted.indexWhere((c) => c.id == currentId);
    emit(state.copyWith(combatants: sorted, turnIndex: turn < 0 ? 0 : turn));
  }
}
