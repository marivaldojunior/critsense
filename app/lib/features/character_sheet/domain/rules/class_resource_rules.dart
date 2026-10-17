import 'dart:math';

import '../entities/attribute_type.dart';
import '../entities/character.dart';
import '../srd/srd_class.dart';

/// Quando um recurso de classe volta.
enum ResourceRecharge {
  shortRest('Descanso Curto'),
  longRest('Descanso Longo');

  const ResourceRecharge(this.label);

  final String label;
}

/// Um recurso de classe com usos contados (ex: Fúria, Pontos de Ki).
class ClassResource {
  /// Chave guardada em [Character.resourcesUsed].
  final String key;

  /// Nome na ficha.
  final String name;

  /// Usos no nível atual. Não vale quando [unlimited] é `true`.
  final int max;

  final ResourceRecharge recharge;

  /// O recurso não tem limite de usos (ex: Fúria no 20º nível).
  final bool unlimited;

  const ClassResource({
    required this.key,
    required this.name,
    required this.max,
    required this.recharge,
    this.unlimited = false,
  });
}

/// Primeiro valor da tabela [byLevel] cujo nível é menor ou igual a [level].
/// Devolve 0 antes do primeiro nível da tabela.
int _fromTable(int level, Map<int, int> byLevel) {
  var value = 0;
  for (final entry in byLevel.entries) {
    if (level >= entry.key) value = entry.value;
  }
  return value;
}

/// Recursos de classe do SRD 5.1 e os usos de cada um.
///
/// Os métodos `with...` são transformações puras, como em `HitPointRules`:
/// eles devolvem o personagem novo, ou `null` quando nada muda.
extension ClassResourceRules on Character {
  /// Recursos da classe no nível atual. Uma classe fora do SRD não tem
  /// recursos.
  List<ClassResource> get classResources {
    final cha = max(1, modifierOf(AttributeType.charisma));
    const short = ResourceRecharge.shortRest;
    const long = ResourceRecharge.longRest;

    final resources = <ClassResource>[
      ...switch (srdClass) {
        SrdClass.barbarian => [
          ClassResource(
            key: 'rage',
            name: 'Fúria',
            max: _fromTable(level, {1: 2, 3: 3, 6: 4, 12: 5, 17: 6}),
            recharge: long,
            unlimited: level >= 20,
          ),
        ],
        SrdClass.bard => [
          ClassResource(
            key: 'bardic-inspiration',
            name: 'Inspiração de Bardo',
            max: cha,
            // Fonte de Inspiração (5º nível).
            recharge: level >= 5 ? short : long,
          ),
        ],
        SrdClass.cleric => [
          ClassResource(
            key: 'channel-divinity',
            name: 'Canalizar Divindade',
            max: _fromTable(level, {2: 1, 6: 2, 18: 3}),
            recharge: short,
          ),
        ],
        SrdClass.druid => [
          ClassResource(
            key: 'wild-shape',
            name: 'Forma Selvagem',
            max: _fromTable(level, {2: 2}),
            recharge: short,
          ),
        ],
        SrdClass.fighter => [
          const ClassResource(
            key: 'second-wind',
            name: 'Retomar o Fôlego',
            max: 1,
            recharge: short,
          ),
          ClassResource(
            key: 'action-surge',
            name: 'Surto de Ação',
            max: _fromTable(level, {2: 1, 17: 2}),
            recharge: short,
          ),
          ClassResource(
            key: 'indomitable',
            name: 'Indomável',
            max: _fromTable(level, {9: 1, 13: 2, 17: 3}),
            recharge: long,
          ),
        ],
        SrdClass.monk => [
          ClassResource(
            key: 'ki',
            name: 'Pontos de Ki',
            max: level >= 2 ? level : 0,
            recharge: short,
          ),
        ],
        SrdClass.paladin => [
          ClassResource(
            key: 'divine-sense',
            name: 'Sentido Divino',
            max: 1 + max(0, modifierOf(AttributeType.charisma)),
            recharge: long,
          ),
          ClassResource(
            key: 'lay-on-hands',
            name: 'Cura pelas Mãos (PV)',
            max: 5 * level,
            recharge: long,
          ),
          ClassResource(
            key: 'channel-divinity',
            name: 'Canalizar Divindade',
            max: _fromTable(level, {3: 1}),
            recharge: short,
          ),
          ClassResource(
            key: 'cleansing-touch',
            name: 'Toque Purificador',
            max: level >= 14 ? cha : 0,
            recharge: long,
          ),
        ],
        SrdClass.rogue => [
          ClassResource(
            key: 'stroke-of-luck',
            name: 'Golpe de Sorte',
            max: _fromTable(level, {20: 1}),
            recharge: short,
          ),
        ],
        SrdClass.sorcerer => [
          ClassResource(
            key: 'sorcery-points',
            name: 'Pontos de Feitiçaria',
            max: level >= 2 ? level : 0,
            recharge: long,
          ),
        ],
        SrdClass.warlock => [
          for (final (minLevel, spellLevel) in const [
            (11, 6),
            (13, 7),
            (15, 8),
            (17, 9),
          ])
            ClassResource(
              key: 'mystic-arcanum-$spellLevel',
              name: 'Arcana Mística ($spellLevelº nível)',
              max: level >= minLevel ? 1 : 0,
              recharge: long,
            ),
        ],
        SrdClass.wizard => [
          const ClassResource(
            key: 'arcane-recovery',
            name: 'Recuperação Arcana',
            max: 1,
            recharge: long,
          ),
        ],
        SrdClass.ranger || null => const <ClassResource>[],
      },
    ];
    return [
      for (final r in resources)
        if (r.max > 0 || r.unlimited) r,
    ];
  }

  ClassResource? _resource(String key) {
    for (final r in classResources) {
      if (r.key == key) return r;
    }
    return null;
  }

  /// Usos que ainda restam de [resource].
  int resourceRemaining(ClassResource resource) =>
      max(0, resource.max - (resourcesUsed[resource.key] ?? 0));

  /// Gasta um uso do recurso [key].
  Character? withResourceUsed(String key) {
    final resource = _resource(key);
    if (resource == null || resource.unlimited) return null;
    if (resourceRemaining(resource) == 0) return null;
    return _withUsed(key, (resourcesUsed[key] ?? 0) + 1);
  }

  /// Devolve um uso do recurso [key].
  Character? withResourceRestored(String key) {
    final used = resourcesUsed[key] ?? 0;
    if (used == 0) return null;
    return _withUsed(key, used - 1);
  }

  /// Define quantos usos restam do recurso [key] (ex: os PV da Cura pelas
  /// Mãos). O valor fica entre 0 e o máximo.
  Character? withResourceRemaining(String key, int remaining) {
    final resource = _resource(key);
    if (resource == null || resource.unlimited) return null;
    final used = resource.max - remaining.clamp(0, resource.max);
    if (used == (resourcesUsed[key] ?? 0)) return null;
    return _withUsed(key, used);
  }

  /// Os recursos que voltam no Descanso Curto ficam cheios de novo. Devolve
  /// `null` se nenhum estava gasto.
  Character? withShortRestResourcesRestored() {
    final shortKeys = {
      for (final r in classResources)
        if (r.recharge == ResourceRecharge.shortRest) r.key,
    };
    final remaining = {
      for (final entry in resourcesUsed.entries)
        if (!shortKeys.contains(entry.key) && entry.value > 0)
          entry.key: entry.value,
    };
    if (remaining.length == _spentCount) return null;
    return copyWith(resourcesUsed: remaining);
  }

  /// Todos os recursos cheios de novo. Usado no Descanso Longo.
  Character withAllResourcesRestored() => copyWith(resourcesUsed: const {});

  int get _spentCount => resourcesUsed.values.where((v) => v > 0).length;

  Character _withUsed(String key, int used) {
    final next = Map<String, int>.of(resourcesUsed);
    if (used <= 0) {
      next.remove(key);
    } else {
      next[key] = used;
    }
    return copyWith(resourcesUsed: next);
  }
}
