import 'dart:convert';

import '../../domain/entities/attribute.dart';
import '../../domain/entities/character.dart';
import '../../domain/entities/character_spell.dart';
import '../../domain/entities/coins.dart';
import '../../domain/entities/condition.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/proficiency.dart';
import '../../domain/entities/session_note.dart';
import '../mappers/proficiency_keys.dart';

/// Tudo o que um personagem tem: a ficha, o inventário, o grimório e o
/// diário de campanha.
class CharacterBackup {
  final Character character;
  final List<InventoryItem> inventory;
  final List<CharacterSpell> spells;
  final List<SessionNote> notes;

  const CharacterBackup({
    required this.character,
    this.inventory = const [],
    this.spells = const [],
    this.notes = const [],
  });
}

/// Formato JSON do backup de personagem.
///
/// O arquivo tem `format` e `version` no topo: um app mais novo lê arquivos
/// de versões anteriores, e um arquivo de outro app é recusado com uma
/// [FormatException] clara. Campos que faltam usam o valor padrão da ficha.
///
/// O avatar não vai no arquivo: ele é um caminho de imagem que só existe no
/// aparelho de origem.
class CharacterBackupCodec {
  const CharacterBackupCodec();

  static const format = 'critsense-character';
  static const version = 1;

  String encode(CharacterBackup backup, {DateTime? exportedAt}) {
    final c = backup.character;
    return const JsonEncoder.withIndent('  ').convert({
      'format': format,
      'version': version,
      'exportedAt': (exportedAt ?? DateTime.now()).toUtc().toIso8601String(),
      'character': {
        'name': c.name,
        'race': c.race,
        'characterClass': c.characterClass,
        'level': c.level,
        'experiencePoints': c.experiencePoints,
        'alignment': c.alignment,
        'background': c.background,
        'personalityTraits': c.personalityTraits,
        'ideals': c.ideals,
        'bonds': c.bonds,
        'flaws': c.flaws,
        'attributes': {
          'strength': c.attributes.strength,
          'dexterity': c.attributes.dexterity,
          'constitution': c.attributes.constitution,
          'intelligence': c.attributes.intelligence,
          'wisdom': c.attributes.wisdom,
          'charisma': c.attributes.charisma,
        },
        'speed': c.speed,
        'armorClassBonus': c.armorClassBonus,
        'maxHitPoints': c.maxHitPoints,
        'currentHitPoints': c.currentHitPoints,
        'temporaryHitPoints': c.temporaryHitPoints,
        'hitDiceUsed': c.hitDiceUsed,
        'deathSaveSuccesses': c.deathSaveSuccesses,
        'deathSaveFailures': c.deathSaveFailures,
        'conditions': [for (final condition in c.conditions) condition.name],
        'exhaustionLevel': c.exhaustionLevel,
        'inspiration': c.inspiration,
        'proficiencies': [for (final p in c.proficiencies) proficiencyToKey(p)],
        'otherProficiencies': c.otherProficiencies,
        'languages': c.languages,
        'spellSlotsUsed': c.spellSlotsUsed,
        'pactSlotsUsed': c.pactSlotsUsed,
        'coins': {for (final coin in Coin.values) coin.name: c.coins.of(coin)},
        'defeatedBosses': c.defeatedBosses,
      },
      'inventory': [
        for (final item in backup.inventory)
          {
            'itemIndex': item.itemIndex,
            'name': item.name,
            'equipmentCategory': item.equipmentCategory,
            'quantity': item.quantity,
            'weight': item.weight,
            'equipped': item.equipped,
            'requiresAttunement': item.requiresAttunement,
            'attuned': item.attuned,
            'detailsLoaded': item.detailsLoaded,
            'armorCategory': item.armorCategory,
            'armorBase': item.armorBase,
            'armorDexBonus': item.armorDexBonus,
            'armorMaxDexBonus': item.armorMaxDexBonus,
            'weaponCategory': item.weaponCategory,
            'weaponRange': item.weaponRange,
            'damageDice': item.damageDice,
            'damageType': item.damageType,
            'versatileDamageDice': item.versatileDamageDice,
            'weaponProperties': item.weaponProperties,
          },
      ],
      'spells': [
        for (final spell in backup.spells)
          {
            'spellIndex': spell.spellIndex,
            'name': spell.name,
            'level': spell.level,
            'prepared': spell.prepared,
          },
      ],
      'notes': [
        for (final note in backup.notes)
          {
            'title': note.title,
            'content': note.content,
            'createdAt': note.createdAt.toUtc().toIso8601String(),
          },
      ],
    });
  }

  /// Lê um backup e dá ids novos ao personagem e a tudo o que é dele: a
  /// importação nunca sobrescreve um personagem que já existe no aparelho.
  /// [newId] gera cada id.
  CharacterBackup decode(String json, {required String Function() newId}) {
    final Object? root;
    try {
      root = jsonDecode(json);
    } on FormatException {
      throw const FormatException('O arquivo não é um JSON válido.');
    }
    if (root is! Map<String, dynamic> || root['format'] != format) {
      throw const FormatException(
        'O arquivo não é um personagem exportado pelo CritSense.',
      );
    }
    final fileVersion = root['version'];
    if (fileVersion is! int || fileVersion > version) {
      throw const FormatException(
        'O arquivo é de uma versão mais nova do app. Atualize o CritSense.',
      );
    }
    final c = root['character'];
    if (c is! Map<String, dynamic>) {
      throw const FormatException('O arquivo não tem os dados do personagem.');
    }

    final characterId = newId();
    final attributes = (c['attributes'] as Map<String, dynamic>?) ?? const {};
    final coins = (c['coins'] as Map<String, dynamic>?) ?? const {};
    final level = _int(c['level'], 1).clamp(1, 20);

    final character = Character(
      id: characterId,
      name: _string(c['name'], 'Personagem importado'),
      race: _string(c['race'], ''),
      characterClass: _string(c['characterClass'], ''),
      level: level,
      experiencePoints: _int(c['experiencePoints'], 0),
      alignment: _string(c['alignment'], ''),
      background: _string(c['background'], ''),
      personalityTraits: _string(c['personalityTraits'], ''),
      ideals: _string(c['ideals'], ''),
      bonds: _string(c['bonds'], ''),
      flaws: _string(c['flaws'], ''),
      attributes: Attribute(
        strength: _int(attributes['strength'], 10),
        dexterity: _int(attributes['dexterity'], 10),
        constitution: _int(attributes['constitution'], 10),
        intelligence: _int(attributes['intelligence'], 10),
        wisdom: _int(attributes['wisdom'], 10),
        charisma: _int(attributes['charisma'], 10),
      ),
      speed: _int(c['speed'], 30),
      armorClassBonus: _int(c['armorClassBonus'], 0),
      maxHitPoints: _int(c['maxHitPoints'], 1),
      currentHitPoints: _int(c['currentHitPoints'], 1),
      temporaryHitPoints: _int(c['temporaryHitPoints'], 0),
      hitDiceUsed: _int(c['hitDiceUsed'], 0),
      deathSaveSuccesses: _int(c['deathSaveSuccesses'], 0),
      deathSaveFailures: _int(c['deathSaveFailures'], 0),
      conditions: _strings(
        c['conditions'],
      ).map(Condition.fromName).whereType<Condition>().toList(),
      exhaustionLevel: _int(c['exhaustionLevel'], 0),
      inspiration: c['inspiration'] == true,
      proficiencies: _strings(
        c['proficiencies'],
      ).map(proficiencyFromKey).whereType<Proficiency>().toList(),
      otherProficiencies: _strings(c['otherProficiencies']),
      languages: _strings(c['languages']),
      spellSlotsUsed: [
        for (final n in (c['spellSlotsUsed'] as List<dynamic>? ?? const []))
          (n as num).toInt(),
      ],
      pactSlotsUsed: _int(c['pactSlotsUsed'], 0),
      coins: Coins({
        for (final coin in Coin.values) coin: _int(coins[coin.name], 0),
      }),
      defeatedBosses: _strings(c['defeatedBosses']),
    );

    final inventory = <InventoryItem>[
      for (final raw in _maps(root['inventory']))
        () {
          final id = newId();
          final index = _string(raw['itemIndex'], '');
          return InventoryItem(
            id: id,
            characterId: characterId,
            // Itens personalizados levam o próprio id no índice.
            itemIndex:
                index.isEmpty ||
                    index.startsWith(InventoryItem.customIndexPrefix)
                ? '${InventoryItem.customIndexPrefix}$id'
                : index,
            name: _string(raw['name'], 'Item'),
            equipmentCategory: _string(raw['equipmentCategory'], ''),
            quantity: _int(raw['quantity'], 1),
            weight: (raw['weight'] as num?)?.toDouble() ?? 0,
            equipped: raw['equipped'] == true,
            requiresAttunement: raw['requiresAttunement'] == true,
            attuned: raw['attuned'] == true,
            detailsLoaded: raw['detailsLoaded'] != false,
            armorCategory: raw['armorCategory'] as String?,
            armorBase: (raw['armorBase'] as num?)?.toInt(),
            armorDexBonus: raw['armorDexBonus'] == true,
            armorMaxDexBonus: (raw['armorMaxDexBonus'] as num?)?.toInt(),
            weaponCategory: raw['weaponCategory'] as String?,
            weaponRange: raw['weaponRange'] as String?,
            damageDice: raw['damageDice'] as String?,
            damageType: raw['damageType'] as String?,
            versatileDamageDice: raw['versatileDamageDice'] as String?,
            weaponProperties: _strings(raw['weaponProperties']),
          );
        }(),
    ];

    final spells = <CharacterSpell>[
      for (final raw in _maps(root['spells']))
        CharacterSpell(
          id: newId(),
          characterId: characterId,
          spellIndex: _string(raw['spellIndex'], ''),
          name: _string(raw['name'], ''),
          level: (raw['level'] as num?)?.toInt(),
          prepared: raw['prepared'] == true,
        ),
    ];

    final notes = <SessionNote>[
      for (final raw in _maps(root['notes']))
        SessionNote(
          id: newId(),
          characterId: characterId,
          title: _string(raw['title'], ''),
          content: _string(raw['content'], ''),
          createdAt:
              DateTime.tryParse(_string(raw['createdAt'], ''))?.toLocal() ??
              DateTime.now(),
        ),
    ];

    return CharacterBackup(
      character: character,
      inventory: inventory,
      spells: spells,
      notes: notes,
    );
  }

  static int _int(Object? value, int fallback) =>
      value is num ? value.toInt() : fallback;

  static String _string(Object? value, String fallback) =>
      value is String ? value : fallback;

  static List<String> _strings(Object? value) =>
      value is List ? value.whereType<String>().toList() : const [];

  static List<Map<String, dynamic>> _maps(Object? value) => value is List
      ? value.whereType<Map<String, dynamic>>().toList()
      : const [];
}
