import 'package:equatable/equatable.dart';

/// Um participante do combate: um personagem da lista, um monstro do
/// bestiário ou uma criatura avulsa.
class Combatant extends Equatable {
  final String id;
  final String name;

  /// Modificador de iniciativa (DES), somado ao d20.
  final int initiativeBonus;

  /// Resultado da iniciativa, ou `null` enquanto não foi rolada.
  final int? initiative;

  final int? armorClass;
  final int? maxHitPoints;
  final int? hitPoints;

  /// Id do personagem da lista, quando o participante é um personagem.
  final String? characterId;

  const Combatant({
    required this.id,
    required this.name,
    this.initiativeBonus = 0,
    this.initiative,
    this.armorClass,
    this.maxHitPoints,
    this.hitPoints,
    this.characterId,
  });

  bool get isCharacter => characterId != null;

  /// Um monstro ou uma criatura com 0 PV está fora do combate.
  bool get isDown => hitPoints != null && hitPoints! <= 0;

  Combatant copyWith({int? initiative, int? hitPoints}) => Combatant(
    id: id,
    name: name,
    initiativeBonus: initiativeBonus,
    initiative: initiative ?? this.initiative,
    armorClass: armorClass,
    maxHitPoints: maxHitPoints,
    hitPoints: hitPoints ?? this.hitPoints,
    characterId: characterId,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'initiativeBonus': initiativeBonus,
    'initiative': initiative,
    'armorClass': armorClass,
    'maxHitPoints': maxHitPoints,
    'hitPoints': hitPoints,
    'characterId': characterId,
  };

  factory Combatant.fromJson(Map<String, dynamic> json) => Combatant(
    id: json['id'] as String,
    name: json['name'] as String,
    initiativeBonus: (json['initiativeBonus'] as num?)?.toInt() ?? 0,
    initiative: (json['initiative'] as num?)?.toInt(),
    armorClass: (json['armorClass'] as num?)?.toInt(),
    maxHitPoints: (json['maxHitPoints'] as num?)?.toInt(),
    hitPoints: (json['hitPoints'] as num?)?.toInt(),
    characterId: json['characterId'] as String?,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    initiativeBonus,
    initiative,
    armorClass,
    maxHitPoints,
    hitPoints,
    characterId,
  ];
}

/// Ordem de iniciativa: maior resultado primeiro; no empate, o maior
/// modificador. Quem ainda não rolou fica no fim.
int compareInitiative(Combatant a, Combatant b) {
  final byResult = (b.initiative ?? -999).compareTo(a.initiative ?? -999);
  if (byResult != 0) return byResult;
  return b.initiativeBonus.compareTo(a.initiativeBonus);
}
