// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CharactersTable extends Characters
    with TableInfo<$CharactersTable, CharacterData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharactersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _racaMeta = const VerificationMeta('raca');
  @override
  late final GeneratedColumn<String> raca = GeneratedColumn<String>(
    'raca',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classeMeta = const VerificationMeta('classe');
  @override
  late final GeneratedColumn<String> classe = GeneratedColumn<String>(
    'classe',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nivelMeta = const VerificationMeta('nivel');
  @override
  late final GeneratedColumn<int> nivel = GeneratedColumn<int>(
    'nivel',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _armorClassMeta = const VerificationMeta(
    'armorClass',
  );
  @override
  late final GeneratedColumn<int> armorClass = GeneratedColumn<int>(
    'armor_class',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _initiativeMeta = const VerificationMeta(
    'initiative',
  );
  @override
  late final GeneratedColumn<int> initiative = GeneratedColumn<int>(
    'initiative',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<int> speed = GeneratedColumn<int>(
    'speed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _maxHitPointsMeta = const VerificationMeta(
    'maxHitPoints',
  );
  @override
  late final GeneratedColumn<int> maxHitPoints = GeneratedColumn<int>(
    'max_hit_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentHitPointsMeta = const VerificationMeta(
    'currentHitPoints',
  );
  @override
  late final GeneratedColumn<int> currentHitPoints = GeneratedColumn<int>(
    'current_hit_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temporaryHitPointsMeta =
      const VerificationMeta('temporaryHitPoints');
  @override
  late final GeneratedColumn<int> temporaryHitPoints = GeneratedColumn<int>(
    'temporary_hit_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alignmentMeta = const VerificationMeta(
    'alignment',
  );
  @override
  late final GeneratedColumn<String> alignment = GeneratedColumn<String>(
    'alignment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _backgroundMeta = const VerificationMeta(
    'background',
  );
  @override
  late final GeneratedColumn<String> background = GeneratedColumn<String>(
    'background',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personalityTraitsMeta = const VerificationMeta(
    'personalityTraits',
  );
  @override
  late final GeneratedColumn<String> personalityTraits =
      GeneratedColumn<String>(
        'personality_traits',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _idealsMeta = const VerificationMeta('ideals');
  @override
  late final GeneratedColumn<String> ideals = GeneratedColumn<String>(
    'ideals',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bondsMeta = const VerificationMeta('bonds');
  @override
  late final GeneratedColumn<String> bonds = GeneratedColumn<String>(
    'bonds',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flawsMeta = const VerificationMeta('flaws');
  @override
  late final GeneratedColumn<String> flaws = GeneratedColumn<String>(
    'flaws',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _experiencePointsMeta = const VerificationMeta(
    'experiencePoints',
  );
  @override
  late final GeneratedColumn<int> experiencePoints = GeneratedColumn<int>(
    'experience_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _proficiencyBonusMeta = const VerificationMeta(
    'proficiencyBonus',
  );
  @override
  late final GeneratedColumn<int> proficiencyBonus = GeneratedColumn<int>(
    'proficiency_bonus',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> spells =
      GeneratedColumn<String>(
        'spells',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($CharactersTable.$converterspells);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  defeatedBosses = GeneratedColumn<String>(
    'defeated_bosses',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($CharactersTable.$converterdefeatedBosses);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  proficiencies = GeneratedColumn<String>(
    'proficiencies',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($CharactersTable.$converterproficiencies);
  static const VerificationMeta _armorClassBonusMeta = const VerificationMeta(
    'armorClassBonus',
  );
  @override
  late final GeneratedColumn<int> armorClassBonus = GeneratedColumn<int>(
    'armor_class_bonus',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hitDiceUsedMeta = const VerificationMeta(
    'hitDiceUsed',
  );
  @override
  late final GeneratedColumn<int> hitDiceUsed = GeneratedColumn<int>(
    'hit_dice_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deathSaveSuccessesMeta =
      const VerificationMeta('deathSaveSuccesses');
  @override
  late final GeneratedColumn<int> deathSaveSuccesses = GeneratedColumn<int>(
    'death_save_successes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deathSaveFailuresMeta = const VerificationMeta(
    'deathSaveFailures',
  );
  @override
  late final GeneratedColumn<int> deathSaveFailures = GeneratedColumn<int>(
    'death_save_failures',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> conditions =
      GeneratedColumn<String>(
        'conditions',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($CharactersTable.$converterconditions);
  static const VerificationMeta _exhaustionLevelMeta = const VerificationMeta(
    'exhaustionLevel',
  );
  @override
  late final GeneratedColumn<int> exhaustionLevel = GeneratedColumn<int>(
    'exhaustion_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _inspirationMeta = const VerificationMeta(
    'inspiration',
  );
  @override
  late final GeneratedColumn<bool> inspiration = GeneratedColumn<bool>(
    'inspiration',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("inspiration" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String>
  spellSlotsUsed = GeneratedColumn<String>(
    'spell_slots_used',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[0,0,0,0,0,0,0,0,0]'),
  ).withConverter<List<int>>($CharactersTable.$converterspellSlotsUsed);
  static const VerificationMeta _pactSlotsUsedMeta = const VerificationMeta(
    'pactSlotsUsed',
  );
  @override
  late final GeneratedColumn<int> pactSlotsUsed = GeneratedColumn<int>(
    'pact_slots_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _copperMeta = const VerificationMeta('copper');
  @override
  late final GeneratedColumn<int> copper = GeneratedColumn<int>(
    'copper',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _silverMeta = const VerificationMeta('silver');
  @override
  late final GeneratedColumn<int> silver = GeneratedColumn<int>(
    'silver',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _electrumMeta = const VerificationMeta(
    'electrum',
  );
  @override
  late final GeneratedColumn<int> electrum = GeneratedColumn<int>(
    'electrum',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _goldMeta = const VerificationMeta('gold');
  @override
  late final GeneratedColumn<int> gold = GeneratedColumn<int>(
    'gold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _platinumMeta = const VerificationMeta(
    'platinum',
  );
  @override
  late final GeneratedColumn<int> platinum = GeneratedColumn<int>(
    'platinum',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  otherProficiencies = GeneratedColumn<String>(
    'other_proficiencies',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($CharactersTable.$converterotherProficiencies);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> languages =
      GeneratedColumn<String>(
        'languages',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($CharactersTable.$converterlanguages);
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, int>, String>
  resourcesUsed = GeneratedColumn<String>(
    'resources_used',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  ).withConverter<Map<String, int>>($CharactersTable.$converterresourcesUsed);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    raca,
    classe,
    nivel,
    armorClass,
    initiative,
    speed,
    maxHitPoints,
    currentHitPoints,
    temporaryHitPoints,
    avatarPath,
    alignment,
    background,
    personalityTraits,
    ideals,
    bonds,
    flaws,
    experiencePoints,
    proficiencyBonus,
    spells,
    defeatedBosses,
    proficiencies,
    armorClassBonus,
    hitDiceUsed,
    deathSaveSuccesses,
    deathSaveFailures,
    conditions,
    exhaustionLevel,
    inspiration,
    spellSlotsUsed,
    pactSlotsUsed,
    copper,
    silver,
    electrum,
    gold,
    platinum,
    otherProficiencies,
    languages,
    resourcesUsed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'characters';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharacterData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('raca')) {
      context.handle(
        _racaMeta,
        raca.isAcceptableOrUnknown(data['raca']!, _racaMeta),
      );
    } else if (isInserting) {
      context.missing(_racaMeta);
    }
    if (data.containsKey('classe')) {
      context.handle(
        _classeMeta,
        classe.isAcceptableOrUnknown(data['classe']!, _classeMeta),
      );
    } else if (isInserting) {
      context.missing(_classeMeta);
    }
    if (data.containsKey('nivel')) {
      context.handle(
        _nivelMeta,
        nivel.isAcceptableOrUnknown(data['nivel']!, _nivelMeta),
      );
    } else if (isInserting) {
      context.missing(_nivelMeta);
    }
    if (data.containsKey('armor_class')) {
      context.handle(
        _armorClassMeta,
        armorClass.isAcceptableOrUnknown(data['armor_class']!, _armorClassMeta),
      );
    }
    if (data.containsKey('initiative')) {
      context.handle(
        _initiativeMeta,
        initiative.isAcceptableOrUnknown(data['initiative']!, _initiativeMeta),
      );
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    }
    if (data.containsKey('max_hit_points')) {
      context.handle(
        _maxHitPointsMeta,
        maxHitPoints.isAcceptableOrUnknown(
          data['max_hit_points']!,
          _maxHitPointsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_maxHitPointsMeta);
    }
    if (data.containsKey('current_hit_points')) {
      context.handle(
        _currentHitPointsMeta,
        currentHitPoints.isAcceptableOrUnknown(
          data['current_hit_points']!,
          _currentHitPointsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentHitPointsMeta);
    }
    if (data.containsKey('temporary_hit_points')) {
      context.handle(
        _temporaryHitPointsMeta,
        temporaryHitPoints.isAcceptableOrUnknown(
          data['temporary_hit_points']!,
          _temporaryHitPointsMeta,
        ),
      );
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    if (data.containsKey('alignment')) {
      context.handle(
        _alignmentMeta,
        alignment.isAcceptableOrUnknown(data['alignment']!, _alignmentMeta),
      );
    }
    if (data.containsKey('background')) {
      context.handle(
        _backgroundMeta,
        background.isAcceptableOrUnknown(data['background']!, _backgroundMeta),
      );
    }
    if (data.containsKey('personality_traits')) {
      context.handle(
        _personalityTraitsMeta,
        personalityTraits.isAcceptableOrUnknown(
          data['personality_traits']!,
          _personalityTraitsMeta,
        ),
      );
    }
    if (data.containsKey('ideals')) {
      context.handle(
        _idealsMeta,
        ideals.isAcceptableOrUnknown(data['ideals']!, _idealsMeta),
      );
    }
    if (data.containsKey('bonds')) {
      context.handle(
        _bondsMeta,
        bonds.isAcceptableOrUnknown(data['bonds']!, _bondsMeta),
      );
    }
    if (data.containsKey('flaws')) {
      context.handle(
        _flawsMeta,
        flaws.isAcceptableOrUnknown(data['flaws']!, _flawsMeta),
      );
    }
    if (data.containsKey('experience_points')) {
      context.handle(
        _experiencePointsMeta,
        experiencePoints.isAcceptableOrUnknown(
          data['experience_points']!,
          _experiencePointsMeta,
        ),
      );
    }
    if (data.containsKey('proficiency_bonus')) {
      context.handle(
        _proficiencyBonusMeta,
        proficiencyBonus.isAcceptableOrUnknown(
          data['proficiency_bonus']!,
          _proficiencyBonusMeta,
        ),
      );
    }
    if (data.containsKey('armor_class_bonus')) {
      context.handle(
        _armorClassBonusMeta,
        armorClassBonus.isAcceptableOrUnknown(
          data['armor_class_bonus']!,
          _armorClassBonusMeta,
        ),
      );
    }
    if (data.containsKey('hit_dice_used')) {
      context.handle(
        _hitDiceUsedMeta,
        hitDiceUsed.isAcceptableOrUnknown(
          data['hit_dice_used']!,
          _hitDiceUsedMeta,
        ),
      );
    }
    if (data.containsKey('death_save_successes')) {
      context.handle(
        _deathSaveSuccessesMeta,
        deathSaveSuccesses.isAcceptableOrUnknown(
          data['death_save_successes']!,
          _deathSaveSuccessesMeta,
        ),
      );
    }
    if (data.containsKey('death_save_failures')) {
      context.handle(
        _deathSaveFailuresMeta,
        deathSaveFailures.isAcceptableOrUnknown(
          data['death_save_failures']!,
          _deathSaveFailuresMeta,
        ),
      );
    }
    if (data.containsKey('exhaustion_level')) {
      context.handle(
        _exhaustionLevelMeta,
        exhaustionLevel.isAcceptableOrUnknown(
          data['exhaustion_level']!,
          _exhaustionLevelMeta,
        ),
      );
    }
    if (data.containsKey('inspiration')) {
      context.handle(
        _inspirationMeta,
        inspiration.isAcceptableOrUnknown(
          data['inspiration']!,
          _inspirationMeta,
        ),
      );
    }
    if (data.containsKey('pact_slots_used')) {
      context.handle(
        _pactSlotsUsedMeta,
        pactSlotsUsed.isAcceptableOrUnknown(
          data['pact_slots_used']!,
          _pactSlotsUsedMeta,
        ),
      );
    }
    if (data.containsKey('copper')) {
      context.handle(
        _copperMeta,
        copper.isAcceptableOrUnknown(data['copper']!, _copperMeta),
      );
    }
    if (data.containsKey('silver')) {
      context.handle(
        _silverMeta,
        silver.isAcceptableOrUnknown(data['silver']!, _silverMeta),
      );
    }
    if (data.containsKey('electrum')) {
      context.handle(
        _electrumMeta,
        electrum.isAcceptableOrUnknown(data['electrum']!, _electrumMeta),
      );
    }
    if (data.containsKey('gold')) {
      context.handle(
        _goldMeta,
        gold.isAcceptableOrUnknown(data['gold']!, _goldMeta),
      );
    }
    if (data.containsKey('platinum')) {
      context.handle(
        _platinumMeta,
        platinum.isAcceptableOrUnknown(data['platinum']!, _platinumMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CharacterData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      raca: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raca'],
      )!,
      classe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}classe'],
      )!,
      nivel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nivel'],
      )!,
      armorClass: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}armor_class'],
      )!,
      initiative: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initiative'],
      )!,
      speed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}speed'],
      )!,
      maxHitPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_hit_points'],
      )!,
      currentHitPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_hit_points'],
      )!,
      temporaryHitPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}temporary_hit_points'],
      )!,
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
      alignment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alignment'],
      ),
      background: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}background'],
      ),
      personalityTraits: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}personality_traits'],
      ),
      ideals: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ideals'],
      ),
      bonds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bonds'],
      ),
      flaws: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flaws'],
      ),
      experiencePoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}experience_points'],
      )!,
      proficiencyBonus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}proficiency_bonus'],
      )!,
      spells: $CharactersTable.$converterspells.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}spells'],
        )!,
      ),
      defeatedBosses: $CharactersTable.$converterdefeatedBosses.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}defeated_bosses'],
        )!,
      ),
      proficiencies: $CharactersTable.$converterproficiencies.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}proficiencies'],
        )!,
      ),
      armorClassBonus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}armor_class_bonus'],
      )!,
      hitDiceUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hit_dice_used'],
      )!,
      deathSaveSuccesses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}death_save_successes'],
      )!,
      deathSaveFailures: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}death_save_failures'],
      )!,
      conditions: $CharactersTable.$converterconditions.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}conditions'],
        )!,
      ),
      exhaustionLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exhaustion_level'],
      )!,
      inspiration: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}inspiration'],
      )!,
      spellSlotsUsed: $CharactersTable.$converterspellSlotsUsed.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}spell_slots_used'],
        )!,
      ),
      pactSlotsUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pact_slots_used'],
      )!,
      copper: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}copper'],
      )!,
      silver: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}silver'],
      )!,
      electrum: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}electrum'],
      )!,
      gold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gold'],
      )!,
      platinum: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}platinum'],
      )!,
      otherProficiencies: $CharactersTable.$converterotherProficiencies.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}other_proficiencies'],
        )!,
      ),
      languages: $CharactersTable.$converterlanguages.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}languages'],
        )!,
      ),
      resourcesUsed: $CharactersTable.$converterresourcesUsed.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}resources_used'],
        )!,
      ),
    );
  }

  @override
  $CharactersTable createAlias(String alias) {
    return $CharactersTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterspells =
      const StringListConverter();
  static TypeConverter<List<String>, String> $converterdefeatedBosses =
      const StringListConverter();
  static TypeConverter<List<String>, String> $converterproficiencies =
      const StringListConverter();
  static TypeConverter<List<String>, String> $converterconditions =
      const StringListConverter();
  static TypeConverter<List<int>, String> $converterspellSlotsUsed =
      const IntListConverter();
  static TypeConverter<List<String>, String> $converterotherProficiencies =
      const StringListConverter();
  static TypeConverter<List<String>, String> $converterlanguages =
      const StringListConverter();
  static TypeConverter<Map<String, int>, String> $converterresourcesUsed =
      const IntMapConverter();
}

class CharacterData extends DataClass implements Insertable<CharacterData> {
  /// Identificador único do personagem (UUID proveniente do domínio).
  final String id;

  /// Nome do personagem.
  final String nome;

  /// Raça do personagem.
  final String raca;

  /// Classe do personagem.
  final String classe;

  /// Nível atual do personagem.
  final int nivel;

  /// Classe de Armadura (CA). Default 10: CA base sem armadura no SRD do
  /// D&D 5e — usado para não quebrar personagens já persistidos antes
  /// desta coluna existir.
  final int armorClass;

  /// Modificador de iniciativa somado à rolagem de d20 no início do combate.
  final int initiative;

  /// Deslocamento em pés por turno. Default 30: valor padrão da maioria das
  /// raças jogáveis no SRD do D&D 5e.
  final int speed;

  /// Pontos de vida máximos. Renomeada de `hpMaximo` para alinhar com a
  /// nomenclatura em inglês do restante do bloco de Status de Combate.
  final int maxHitPoints;

  /// Pontos de vida atuais. Renomeada de `hpAtual`; ver [maxHitPoints].
  final int currentHitPoints;

  /// Pontos de vida temporários — absorvidos antes dos PV atuais, zerados
  /// (não subtraídos) ao sofrer dano restante, conforme a regra do SRD.
  final int temporaryHitPoints;

  /// Caminho local para a imagem de avatar do personagem; pode ser nulo.
  final String? avatarPath;

  /// Tendência (alinhamento), ex: "Leal e Bom". Nullable para não quebrar
  /// personagens já persistidos antes desta coluna existir.
  final String? alignment;

  /// Antecedente (background) do personagem. Mesma justificativa de
  /// nullability de [alignment].
  final String? background;

  /// Traços de personalidade do personagem.
  final String? personalityTraits;

  /// Ideais que guiam as ações do personagem.
  final String? ideals;

  /// Vínculos (pessoas, lugares ou causas importantes) do personagem.
  final String? bonds;

  /// Defeitos ou fraquezas de personalidade do personagem.
  final String? flaws;

  /// Pontos de experiência acumulados. Default 0: início de aventura.
  final int experiencePoints;

  /// Bônus de proficiência aplicado a testes, ataques e resistências.
  /// Default 2: valor do SRD do D&D 5e para personagens de nível 1 a 4.
  final int proficiencyBonus;

  /// Magias conhecidas/vinculadas ao personagem, como JSON de `List<String>`.
  /// Default `'[]'`: nenhum personagem existente antes desta coluna tinha
  /// magias registradas.
  final List<String> spells;

  /// Monstros/chefes derrotados pelo personagem, como JSON de `List<String>`.
  /// Mesma justificativa de default de [spells].
  final List<String> defeatedBosses;
  final List<String> proficiencies;
  final int armorClassBonus;
  final int hitDiceUsed;
  final int deathSaveSuccesses;
  final int deathSaveFailures;
  final List<String> conditions;
  final int exhaustionLevel;
  final bool inspiration;
  final List<int> spellSlotsUsed;
  final int pactSlotsUsed;
  final int copper;
  final int silver;
  final int electrum;
  final int gold;
  final int platinum;
  final List<String> otherProficiencies;
  final List<String> languages;
  final Map<String, int> resourcesUsed;
  const CharacterData({
    required this.id,
    required this.nome,
    required this.raca,
    required this.classe,
    required this.nivel,
    required this.armorClass,
    required this.initiative,
    required this.speed,
    required this.maxHitPoints,
    required this.currentHitPoints,
    required this.temporaryHitPoints,
    this.avatarPath,
    this.alignment,
    this.background,
    this.personalityTraits,
    this.ideals,
    this.bonds,
    this.flaws,
    required this.experiencePoints,
    required this.proficiencyBonus,
    required this.spells,
    required this.defeatedBosses,
    required this.proficiencies,
    required this.armorClassBonus,
    required this.hitDiceUsed,
    required this.deathSaveSuccesses,
    required this.deathSaveFailures,
    required this.conditions,
    required this.exhaustionLevel,
    required this.inspiration,
    required this.spellSlotsUsed,
    required this.pactSlotsUsed,
    required this.copper,
    required this.silver,
    required this.electrum,
    required this.gold,
    required this.platinum,
    required this.otherProficiencies,
    required this.languages,
    required this.resourcesUsed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nome'] = Variable<String>(nome);
    map['raca'] = Variable<String>(raca);
    map['classe'] = Variable<String>(classe);
    map['nivel'] = Variable<int>(nivel);
    map['armor_class'] = Variable<int>(armorClass);
    map['initiative'] = Variable<int>(initiative);
    map['speed'] = Variable<int>(speed);
    map['max_hit_points'] = Variable<int>(maxHitPoints);
    map['current_hit_points'] = Variable<int>(currentHitPoints);
    map['temporary_hit_points'] = Variable<int>(temporaryHitPoints);
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    if (!nullToAbsent || alignment != null) {
      map['alignment'] = Variable<String>(alignment);
    }
    if (!nullToAbsent || background != null) {
      map['background'] = Variable<String>(background);
    }
    if (!nullToAbsent || personalityTraits != null) {
      map['personality_traits'] = Variable<String>(personalityTraits);
    }
    if (!nullToAbsent || ideals != null) {
      map['ideals'] = Variable<String>(ideals);
    }
    if (!nullToAbsent || bonds != null) {
      map['bonds'] = Variable<String>(bonds);
    }
    if (!nullToAbsent || flaws != null) {
      map['flaws'] = Variable<String>(flaws);
    }
    map['experience_points'] = Variable<int>(experiencePoints);
    map['proficiency_bonus'] = Variable<int>(proficiencyBonus);
    {
      map['spells'] = Variable<String>(
        $CharactersTable.$converterspells.toSql(spells),
      );
    }
    {
      map['defeated_bosses'] = Variable<String>(
        $CharactersTable.$converterdefeatedBosses.toSql(defeatedBosses),
      );
    }
    {
      map['proficiencies'] = Variable<String>(
        $CharactersTable.$converterproficiencies.toSql(proficiencies),
      );
    }
    map['armor_class_bonus'] = Variable<int>(armorClassBonus);
    map['hit_dice_used'] = Variable<int>(hitDiceUsed);
    map['death_save_successes'] = Variable<int>(deathSaveSuccesses);
    map['death_save_failures'] = Variable<int>(deathSaveFailures);
    {
      map['conditions'] = Variable<String>(
        $CharactersTable.$converterconditions.toSql(conditions),
      );
    }
    map['exhaustion_level'] = Variable<int>(exhaustionLevel);
    map['inspiration'] = Variable<bool>(inspiration);
    {
      map['spell_slots_used'] = Variable<String>(
        $CharactersTable.$converterspellSlotsUsed.toSql(spellSlotsUsed),
      );
    }
    map['pact_slots_used'] = Variable<int>(pactSlotsUsed);
    map['copper'] = Variable<int>(copper);
    map['silver'] = Variable<int>(silver);
    map['electrum'] = Variable<int>(electrum);
    map['gold'] = Variable<int>(gold);
    map['platinum'] = Variable<int>(platinum);
    {
      map['other_proficiencies'] = Variable<String>(
        $CharactersTable.$converterotherProficiencies.toSql(otherProficiencies),
      );
    }
    {
      map['languages'] = Variable<String>(
        $CharactersTable.$converterlanguages.toSql(languages),
      );
    }
    {
      map['resources_used'] = Variable<String>(
        $CharactersTable.$converterresourcesUsed.toSql(resourcesUsed),
      );
    }
    return map;
  }

  CharactersCompanion toCompanion(bool nullToAbsent) {
    return CharactersCompanion(
      id: Value(id),
      nome: Value(nome),
      raca: Value(raca),
      classe: Value(classe),
      nivel: Value(nivel),
      armorClass: Value(armorClass),
      initiative: Value(initiative),
      speed: Value(speed),
      maxHitPoints: Value(maxHitPoints),
      currentHitPoints: Value(currentHitPoints),
      temporaryHitPoints: Value(temporaryHitPoints),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      alignment: alignment == null && nullToAbsent
          ? const Value.absent()
          : Value(alignment),
      background: background == null && nullToAbsent
          ? const Value.absent()
          : Value(background),
      personalityTraits: personalityTraits == null && nullToAbsent
          ? const Value.absent()
          : Value(personalityTraits),
      ideals: ideals == null && nullToAbsent
          ? const Value.absent()
          : Value(ideals),
      bonds: bonds == null && nullToAbsent
          ? const Value.absent()
          : Value(bonds),
      flaws: flaws == null && nullToAbsent
          ? const Value.absent()
          : Value(flaws),
      experiencePoints: Value(experiencePoints),
      proficiencyBonus: Value(proficiencyBonus),
      spells: Value(spells),
      defeatedBosses: Value(defeatedBosses),
      proficiencies: Value(proficiencies),
      armorClassBonus: Value(armorClassBonus),
      hitDiceUsed: Value(hitDiceUsed),
      deathSaveSuccesses: Value(deathSaveSuccesses),
      deathSaveFailures: Value(deathSaveFailures),
      conditions: Value(conditions),
      exhaustionLevel: Value(exhaustionLevel),
      inspiration: Value(inspiration),
      spellSlotsUsed: Value(spellSlotsUsed),
      pactSlotsUsed: Value(pactSlotsUsed),
      copper: Value(copper),
      silver: Value(silver),
      electrum: Value(electrum),
      gold: Value(gold),
      platinum: Value(platinum),
      otherProficiencies: Value(otherProficiencies),
      languages: Value(languages),
      resourcesUsed: Value(resourcesUsed),
    );
  }

  factory CharacterData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterData(
      id: serializer.fromJson<String>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      raca: serializer.fromJson<String>(json['raca']),
      classe: serializer.fromJson<String>(json['classe']),
      nivel: serializer.fromJson<int>(json['nivel']),
      armorClass: serializer.fromJson<int>(json['armorClass']),
      initiative: serializer.fromJson<int>(json['initiative']),
      speed: serializer.fromJson<int>(json['speed']),
      maxHitPoints: serializer.fromJson<int>(json['maxHitPoints']),
      currentHitPoints: serializer.fromJson<int>(json['currentHitPoints']),
      temporaryHitPoints: serializer.fromJson<int>(json['temporaryHitPoints']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      alignment: serializer.fromJson<String?>(json['alignment']),
      background: serializer.fromJson<String?>(json['background']),
      personalityTraits: serializer.fromJson<String?>(
        json['personalityTraits'],
      ),
      ideals: serializer.fromJson<String?>(json['ideals']),
      bonds: serializer.fromJson<String?>(json['bonds']),
      flaws: serializer.fromJson<String?>(json['flaws']),
      experiencePoints: serializer.fromJson<int>(json['experiencePoints']),
      proficiencyBonus: serializer.fromJson<int>(json['proficiencyBonus']),
      spells: serializer.fromJson<List<String>>(json['spells']),
      defeatedBosses: serializer.fromJson<List<String>>(json['defeatedBosses']),
      proficiencies: serializer.fromJson<List<String>>(json['proficiencies']),
      armorClassBonus: serializer.fromJson<int>(json['armorClassBonus']),
      hitDiceUsed: serializer.fromJson<int>(json['hitDiceUsed']),
      deathSaveSuccesses: serializer.fromJson<int>(json['deathSaveSuccesses']),
      deathSaveFailures: serializer.fromJson<int>(json['deathSaveFailures']),
      conditions: serializer.fromJson<List<String>>(json['conditions']),
      exhaustionLevel: serializer.fromJson<int>(json['exhaustionLevel']),
      inspiration: serializer.fromJson<bool>(json['inspiration']),
      spellSlotsUsed: serializer.fromJson<List<int>>(json['spellSlotsUsed']),
      pactSlotsUsed: serializer.fromJson<int>(json['pactSlotsUsed']),
      copper: serializer.fromJson<int>(json['copper']),
      silver: serializer.fromJson<int>(json['silver']),
      electrum: serializer.fromJson<int>(json['electrum']),
      gold: serializer.fromJson<int>(json['gold']),
      platinum: serializer.fromJson<int>(json['platinum']),
      otherProficiencies: serializer.fromJson<List<String>>(
        json['otherProficiencies'],
      ),
      languages: serializer.fromJson<List<String>>(json['languages']),
      resourcesUsed: serializer.fromJson<Map<String, int>>(
        json['resourcesUsed'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nome': serializer.toJson<String>(nome),
      'raca': serializer.toJson<String>(raca),
      'classe': serializer.toJson<String>(classe),
      'nivel': serializer.toJson<int>(nivel),
      'armorClass': serializer.toJson<int>(armorClass),
      'initiative': serializer.toJson<int>(initiative),
      'speed': serializer.toJson<int>(speed),
      'maxHitPoints': serializer.toJson<int>(maxHitPoints),
      'currentHitPoints': serializer.toJson<int>(currentHitPoints),
      'temporaryHitPoints': serializer.toJson<int>(temporaryHitPoints),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'alignment': serializer.toJson<String?>(alignment),
      'background': serializer.toJson<String?>(background),
      'personalityTraits': serializer.toJson<String?>(personalityTraits),
      'ideals': serializer.toJson<String?>(ideals),
      'bonds': serializer.toJson<String?>(bonds),
      'flaws': serializer.toJson<String?>(flaws),
      'experiencePoints': serializer.toJson<int>(experiencePoints),
      'proficiencyBonus': serializer.toJson<int>(proficiencyBonus),
      'spells': serializer.toJson<List<String>>(spells),
      'defeatedBosses': serializer.toJson<List<String>>(defeatedBosses),
      'proficiencies': serializer.toJson<List<String>>(proficiencies),
      'armorClassBonus': serializer.toJson<int>(armorClassBonus),
      'hitDiceUsed': serializer.toJson<int>(hitDiceUsed),
      'deathSaveSuccesses': serializer.toJson<int>(deathSaveSuccesses),
      'deathSaveFailures': serializer.toJson<int>(deathSaveFailures),
      'conditions': serializer.toJson<List<String>>(conditions),
      'exhaustionLevel': serializer.toJson<int>(exhaustionLevel),
      'inspiration': serializer.toJson<bool>(inspiration),
      'spellSlotsUsed': serializer.toJson<List<int>>(spellSlotsUsed),
      'pactSlotsUsed': serializer.toJson<int>(pactSlotsUsed),
      'copper': serializer.toJson<int>(copper),
      'silver': serializer.toJson<int>(silver),
      'electrum': serializer.toJson<int>(electrum),
      'gold': serializer.toJson<int>(gold),
      'platinum': serializer.toJson<int>(platinum),
      'otherProficiencies': serializer.toJson<List<String>>(otherProficiencies),
      'languages': serializer.toJson<List<String>>(languages),
      'resourcesUsed': serializer.toJson<Map<String, int>>(resourcesUsed),
    };
  }

  CharacterData copyWith({
    String? id,
    String? nome,
    String? raca,
    String? classe,
    int? nivel,
    int? armorClass,
    int? initiative,
    int? speed,
    int? maxHitPoints,
    int? currentHitPoints,
    int? temporaryHitPoints,
    Value<String?> avatarPath = const Value.absent(),
    Value<String?> alignment = const Value.absent(),
    Value<String?> background = const Value.absent(),
    Value<String?> personalityTraits = const Value.absent(),
    Value<String?> ideals = const Value.absent(),
    Value<String?> bonds = const Value.absent(),
    Value<String?> flaws = const Value.absent(),
    int? experiencePoints,
    int? proficiencyBonus,
    List<String>? spells,
    List<String>? defeatedBosses,
    List<String>? proficiencies,
    int? armorClassBonus,
    int? hitDiceUsed,
    int? deathSaveSuccesses,
    int? deathSaveFailures,
    List<String>? conditions,
    int? exhaustionLevel,
    bool? inspiration,
    List<int>? spellSlotsUsed,
    int? pactSlotsUsed,
    int? copper,
    int? silver,
    int? electrum,
    int? gold,
    int? platinum,
    List<String>? otherProficiencies,
    List<String>? languages,
    Map<String, int>? resourcesUsed,
  }) => CharacterData(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    raca: raca ?? this.raca,
    classe: classe ?? this.classe,
    nivel: nivel ?? this.nivel,
    armorClass: armorClass ?? this.armorClass,
    initiative: initiative ?? this.initiative,
    speed: speed ?? this.speed,
    maxHitPoints: maxHitPoints ?? this.maxHitPoints,
    currentHitPoints: currentHitPoints ?? this.currentHitPoints,
    temporaryHitPoints: temporaryHitPoints ?? this.temporaryHitPoints,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
    alignment: alignment.present ? alignment.value : this.alignment,
    background: background.present ? background.value : this.background,
    personalityTraits: personalityTraits.present
        ? personalityTraits.value
        : this.personalityTraits,
    ideals: ideals.present ? ideals.value : this.ideals,
    bonds: bonds.present ? bonds.value : this.bonds,
    flaws: flaws.present ? flaws.value : this.flaws,
    experiencePoints: experiencePoints ?? this.experiencePoints,
    proficiencyBonus: proficiencyBonus ?? this.proficiencyBonus,
    spells: spells ?? this.spells,
    defeatedBosses: defeatedBosses ?? this.defeatedBosses,
    proficiencies: proficiencies ?? this.proficiencies,
    armorClassBonus: armorClassBonus ?? this.armorClassBonus,
    hitDiceUsed: hitDiceUsed ?? this.hitDiceUsed,
    deathSaveSuccesses: deathSaveSuccesses ?? this.deathSaveSuccesses,
    deathSaveFailures: deathSaveFailures ?? this.deathSaveFailures,
    conditions: conditions ?? this.conditions,
    exhaustionLevel: exhaustionLevel ?? this.exhaustionLevel,
    inspiration: inspiration ?? this.inspiration,
    spellSlotsUsed: spellSlotsUsed ?? this.spellSlotsUsed,
    pactSlotsUsed: pactSlotsUsed ?? this.pactSlotsUsed,
    copper: copper ?? this.copper,
    silver: silver ?? this.silver,
    electrum: electrum ?? this.electrum,
    gold: gold ?? this.gold,
    platinum: platinum ?? this.platinum,
    otherProficiencies: otherProficiencies ?? this.otherProficiencies,
    languages: languages ?? this.languages,
    resourcesUsed: resourcesUsed ?? this.resourcesUsed,
  );
  CharacterData copyWithCompanion(CharactersCompanion data) {
    return CharacterData(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      raca: data.raca.present ? data.raca.value : this.raca,
      classe: data.classe.present ? data.classe.value : this.classe,
      nivel: data.nivel.present ? data.nivel.value : this.nivel,
      armorClass: data.armorClass.present
          ? data.armorClass.value
          : this.armorClass,
      initiative: data.initiative.present
          ? data.initiative.value
          : this.initiative,
      speed: data.speed.present ? data.speed.value : this.speed,
      maxHitPoints: data.maxHitPoints.present
          ? data.maxHitPoints.value
          : this.maxHitPoints,
      currentHitPoints: data.currentHitPoints.present
          ? data.currentHitPoints.value
          : this.currentHitPoints,
      temporaryHitPoints: data.temporaryHitPoints.present
          ? data.temporaryHitPoints.value
          : this.temporaryHitPoints,
      avatarPath: data.avatarPath.present
          ? data.avatarPath.value
          : this.avatarPath,
      alignment: data.alignment.present ? data.alignment.value : this.alignment,
      background: data.background.present
          ? data.background.value
          : this.background,
      personalityTraits: data.personalityTraits.present
          ? data.personalityTraits.value
          : this.personalityTraits,
      ideals: data.ideals.present ? data.ideals.value : this.ideals,
      bonds: data.bonds.present ? data.bonds.value : this.bonds,
      flaws: data.flaws.present ? data.flaws.value : this.flaws,
      experiencePoints: data.experiencePoints.present
          ? data.experiencePoints.value
          : this.experiencePoints,
      proficiencyBonus: data.proficiencyBonus.present
          ? data.proficiencyBonus.value
          : this.proficiencyBonus,
      spells: data.spells.present ? data.spells.value : this.spells,
      defeatedBosses: data.defeatedBosses.present
          ? data.defeatedBosses.value
          : this.defeatedBosses,
      proficiencies: data.proficiencies.present
          ? data.proficiencies.value
          : this.proficiencies,
      armorClassBonus: data.armorClassBonus.present
          ? data.armorClassBonus.value
          : this.armorClassBonus,
      hitDiceUsed: data.hitDiceUsed.present
          ? data.hitDiceUsed.value
          : this.hitDiceUsed,
      deathSaveSuccesses: data.deathSaveSuccesses.present
          ? data.deathSaveSuccesses.value
          : this.deathSaveSuccesses,
      deathSaveFailures: data.deathSaveFailures.present
          ? data.deathSaveFailures.value
          : this.deathSaveFailures,
      conditions: data.conditions.present
          ? data.conditions.value
          : this.conditions,
      exhaustionLevel: data.exhaustionLevel.present
          ? data.exhaustionLevel.value
          : this.exhaustionLevel,
      inspiration: data.inspiration.present
          ? data.inspiration.value
          : this.inspiration,
      spellSlotsUsed: data.spellSlotsUsed.present
          ? data.spellSlotsUsed.value
          : this.spellSlotsUsed,
      pactSlotsUsed: data.pactSlotsUsed.present
          ? data.pactSlotsUsed.value
          : this.pactSlotsUsed,
      copper: data.copper.present ? data.copper.value : this.copper,
      silver: data.silver.present ? data.silver.value : this.silver,
      electrum: data.electrum.present ? data.electrum.value : this.electrum,
      gold: data.gold.present ? data.gold.value : this.gold,
      platinum: data.platinum.present ? data.platinum.value : this.platinum,
      otherProficiencies: data.otherProficiencies.present
          ? data.otherProficiencies.value
          : this.otherProficiencies,
      languages: data.languages.present ? data.languages.value : this.languages,
      resourcesUsed: data.resourcesUsed.present
          ? data.resourcesUsed.value
          : this.resourcesUsed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterData(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('raca: $raca, ')
          ..write('classe: $classe, ')
          ..write('nivel: $nivel, ')
          ..write('armorClass: $armorClass, ')
          ..write('initiative: $initiative, ')
          ..write('speed: $speed, ')
          ..write('maxHitPoints: $maxHitPoints, ')
          ..write('currentHitPoints: $currentHitPoints, ')
          ..write('temporaryHitPoints: $temporaryHitPoints, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('alignment: $alignment, ')
          ..write('background: $background, ')
          ..write('personalityTraits: $personalityTraits, ')
          ..write('ideals: $ideals, ')
          ..write('bonds: $bonds, ')
          ..write('flaws: $flaws, ')
          ..write('experiencePoints: $experiencePoints, ')
          ..write('proficiencyBonus: $proficiencyBonus, ')
          ..write('spells: $spells, ')
          ..write('defeatedBosses: $defeatedBosses, ')
          ..write('proficiencies: $proficiencies, ')
          ..write('armorClassBonus: $armorClassBonus, ')
          ..write('hitDiceUsed: $hitDiceUsed, ')
          ..write('deathSaveSuccesses: $deathSaveSuccesses, ')
          ..write('deathSaveFailures: $deathSaveFailures, ')
          ..write('conditions: $conditions, ')
          ..write('exhaustionLevel: $exhaustionLevel, ')
          ..write('inspiration: $inspiration, ')
          ..write('spellSlotsUsed: $spellSlotsUsed, ')
          ..write('pactSlotsUsed: $pactSlotsUsed, ')
          ..write('copper: $copper, ')
          ..write('silver: $silver, ')
          ..write('electrum: $electrum, ')
          ..write('gold: $gold, ')
          ..write('platinum: $platinum, ')
          ..write('otherProficiencies: $otherProficiencies, ')
          ..write('languages: $languages, ')
          ..write('resourcesUsed: $resourcesUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    nome,
    raca,
    classe,
    nivel,
    armorClass,
    initiative,
    speed,
    maxHitPoints,
    currentHitPoints,
    temporaryHitPoints,
    avatarPath,
    alignment,
    background,
    personalityTraits,
    ideals,
    bonds,
    flaws,
    experiencePoints,
    proficiencyBonus,
    spells,
    defeatedBosses,
    proficiencies,
    armorClassBonus,
    hitDiceUsed,
    deathSaveSuccesses,
    deathSaveFailures,
    conditions,
    exhaustionLevel,
    inspiration,
    spellSlotsUsed,
    pactSlotsUsed,
    copper,
    silver,
    electrum,
    gold,
    platinum,
    otherProficiencies,
    languages,
    resourcesUsed,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterData &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.raca == this.raca &&
          other.classe == this.classe &&
          other.nivel == this.nivel &&
          other.armorClass == this.armorClass &&
          other.initiative == this.initiative &&
          other.speed == this.speed &&
          other.maxHitPoints == this.maxHitPoints &&
          other.currentHitPoints == this.currentHitPoints &&
          other.temporaryHitPoints == this.temporaryHitPoints &&
          other.avatarPath == this.avatarPath &&
          other.alignment == this.alignment &&
          other.background == this.background &&
          other.personalityTraits == this.personalityTraits &&
          other.ideals == this.ideals &&
          other.bonds == this.bonds &&
          other.flaws == this.flaws &&
          other.experiencePoints == this.experiencePoints &&
          other.proficiencyBonus == this.proficiencyBonus &&
          other.spells == this.spells &&
          other.defeatedBosses == this.defeatedBosses &&
          other.proficiencies == this.proficiencies &&
          other.armorClassBonus == this.armorClassBonus &&
          other.hitDiceUsed == this.hitDiceUsed &&
          other.deathSaveSuccesses == this.deathSaveSuccesses &&
          other.deathSaveFailures == this.deathSaveFailures &&
          other.conditions == this.conditions &&
          other.exhaustionLevel == this.exhaustionLevel &&
          other.inspiration == this.inspiration &&
          other.spellSlotsUsed == this.spellSlotsUsed &&
          other.pactSlotsUsed == this.pactSlotsUsed &&
          other.copper == this.copper &&
          other.silver == this.silver &&
          other.electrum == this.electrum &&
          other.gold == this.gold &&
          other.platinum == this.platinum &&
          other.otherProficiencies == this.otherProficiencies &&
          other.languages == this.languages &&
          other.resourcesUsed == this.resourcesUsed);
}

class CharactersCompanion extends UpdateCompanion<CharacterData> {
  final Value<String> id;
  final Value<String> nome;
  final Value<String> raca;
  final Value<String> classe;
  final Value<int> nivel;
  final Value<int> armorClass;
  final Value<int> initiative;
  final Value<int> speed;
  final Value<int> maxHitPoints;
  final Value<int> currentHitPoints;
  final Value<int> temporaryHitPoints;
  final Value<String?> avatarPath;
  final Value<String?> alignment;
  final Value<String?> background;
  final Value<String?> personalityTraits;
  final Value<String?> ideals;
  final Value<String?> bonds;
  final Value<String?> flaws;
  final Value<int> experiencePoints;
  final Value<int> proficiencyBonus;
  final Value<List<String>> spells;
  final Value<List<String>> defeatedBosses;
  final Value<List<String>> proficiencies;
  final Value<int> armorClassBonus;
  final Value<int> hitDiceUsed;
  final Value<int> deathSaveSuccesses;
  final Value<int> deathSaveFailures;
  final Value<List<String>> conditions;
  final Value<int> exhaustionLevel;
  final Value<bool> inspiration;
  final Value<List<int>> spellSlotsUsed;
  final Value<int> pactSlotsUsed;
  final Value<int> copper;
  final Value<int> silver;
  final Value<int> electrum;
  final Value<int> gold;
  final Value<int> platinum;
  final Value<List<String>> otherProficiencies;
  final Value<List<String>> languages;
  final Value<Map<String, int>> resourcesUsed;
  final Value<int> rowid;
  const CharactersCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.raca = const Value.absent(),
    this.classe = const Value.absent(),
    this.nivel = const Value.absent(),
    this.armorClass = const Value.absent(),
    this.initiative = const Value.absent(),
    this.speed = const Value.absent(),
    this.maxHitPoints = const Value.absent(),
    this.currentHitPoints = const Value.absent(),
    this.temporaryHitPoints = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.alignment = const Value.absent(),
    this.background = const Value.absent(),
    this.personalityTraits = const Value.absent(),
    this.ideals = const Value.absent(),
    this.bonds = const Value.absent(),
    this.flaws = const Value.absent(),
    this.experiencePoints = const Value.absent(),
    this.proficiencyBonus = const Value.absent(),
    this.spells = const Value.absent(),
    this.defeatedBosses = const Value.absent(),
    this.proficiencies = const Value.absent(),
    this.armorClassBonus = const Value.absent(),
    this.hitDiceUsed = const Value.absent(),
    this.deathSaveSuccesses = const Value.absent(),
    this.deathSaveFailures = const Value.absent(),
    this.conditions = const Value.absent(),
    this.exhaustionLevel = const Value.absent(),
    this.inspiration = const Value.absent(),
    this.spellSlotsUsed = const Value.absent(),
    this.pactSlotsUsed = const Value.absent(),
    this.copper = const Value.absent(),
    this.silver = const Value.absent(),
    this.electrum = const Value.absent(),
    this.gold = const Value.absent(),
    this.platinum = const Value.absent(),
    this.otherProficiencies = const Value.absent(),
    this.languages = const Value.absent(),
    this.resourcesUsed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CharactersCompanion.insert({
    required String id,
    required String nome,
    required String raca,
    required String classe,
    required int nivel,
    this.armorClass = const Value.absent(),
    this.initiative = const Value.absent(),
    this.speed = const Value.absent(),
    required int maxHitPoints,
    required int currentHitPoints,
    this.temporaryHitPoints = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.alignment = const Value.absent(),
    this.background = const Value.absent(),
    this.personalityTraits = const Value.absent(),
    this.ideals = const Value.absent(),
    this.bonds = const Value.absent(),
    this.flaws = const Value.absent(),
    this.experiencePoints = const Value.absent(),
    this.proficiencyBonus = const Value.absent(),
    this.spells = const Value.absent(),
    this.defeatedBosses = const Value.absent(),
    this.proficiencies = const Value.absent(),
    this.armorClassBonus = const Value.absent(),
    this.hitDiceUsed = const Value.absent(),
    this.deathSaveSuccesses = const Value.absent(),
    this.deathSaveFailures = const Value.absent(),
    this.conditions = const Value.absent(),
    this.exhaustionLevel = const Value.absent(),
    this.inspiration = const Value.absent(),
    this.spellSlotsUsed = const Value.absent(),
    this.pactSlotsUsed = const Value.absent(),
    this.copper = const Value.absent(),
    this.silver = const Value.absent(),
    this.electrum = const Value.absent(),
    this.gold = const Value.absent(),
    this.platinum = const Value.absent(),
    this.otherProficiencies = const Value.absent(),
    this.languages = const Value.absent(),
    this.resourcesUsed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nome = Value(nome),
       raca = Value(raca),
       classe = Value(classe),
       nivel = Value(nivel),
       maxHitPoints = Value(maxHitPoints),
       currentHitPoints = Value(currentHitPoints);
  static Insertable<CharacterData> custom({
    Expression<String>? id,
    Expression<String>? nome,
    Expression<String>? raca,
    Expression<String>? classe,
    Expression<int>? nivel,
    Expression<int>? armorClass,
    Expression<int>? initiative,
    Expression<int>? speed,
    Expression<int>? maxHitPoints,
    Expression<int>? currentHitPoints,
    Expression<int>? temporaryHitPoints,
    Expression<String>? avatarPath,
    Expression<String>? alignment,
    Expression<String>? background,
    Expression<String>? personalityTraits,
    Expression<String>? ideals,
    Expression<String>? bonds,
    Expression<String>? flaws,
    Expression<int>? experiencePoints,
    Expression<int>? proficiencyBonus,
    Expression<String>? spells,
    Expression<String>? defeatedBosses,
    Expression<String>? proficiencies,
    Expression<int>? armorClassBonus,
    Expression<int>? hitDiceUsed,
    Expression<int>? deathSaveSuccesses,
    Expression<int>? deathSaveFailures,
    Expression<String>? conditions,
    Expression<int>? exhaustionLevel,
    Expression<bool>? inspiration,
    Expression<String>? spellSlotsUsed,
    Expression<int>? pactSlotsUsed,
    Expression<int>? copper,
    Expression<int>? silver,
    Expression<int>? electrum,
    Expression<int>? gold,
    Expression<int>? platinum,
    Expression<String>? otherProficiencies,
    Expression<String>? languages,
    Expression<String>? resourcesUsed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (raca != null) 'raca': raca,
      if (classe != null) 'classe': classe,
      if (nivel != null) 'nivel': nivel,
      if (armorClass != null) 'armor_class': armorClass,
      if (initiative != null) 'initiative': initiative,
      if (speed != null) 'speed': speed,
      if (maxHitPoints != null) 'max_hit_points': maxHitPoints,
      if (currentHitPoints != null) 'current_hit_points': currentHitPoints,
      if (temporaryHitPoints != null)
        'temporary_hit_points': temporaryHitPoints,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (alignment != null) 'alignment': alignment,
      if (background != null) 'background': background,
      if (personalityTraits != null) 'personality_traits': personalityTraits,
      if (ideals != null) 'ideals': ideals,
      if (bonds != null) 'bonds': bonds,
      if (flaws != null) 'flaws': flaws,
      if (experiencePoints != null) 'experience_points': experiencePoints,
      if (proficiencyBonus != null) 'proficiency_bonus': proficiencyBonus,
      if (spells != null) 'spells': spells,
      if (defeatedBosses != null) 'defeated_bosses': defeatedBosses,
      if (proficiencies != null) 'proficiencies': proficiencies,
      if (armorClassBonus != null) 'armor_class_bonus': armorClassBonus,
      if (hitDiceUsed != null) 'hit_dice_used': hitDiceUsed,
      if (deathSaveSuccesses != null)
        'death_save_successes': deathSaveSuccesses,
      if (deathSaveFailures != null) 'death_save_failures': deathSaveFailures,
      if (conditions != null) 'conditions': conditions,
      if (exhaustionLevel != null) 'exhaustion_level': exhaustionLevel,
      if (inspiration != null) 'inspiration': inspiration,
      if (spellSlotsUsed != null) 'spell_slots_used': spellSlotsUsed,
      if (pactSlotsUsed != null) 'pact_slots_used': pactSlotsUsed,
      if (copper != null) 'copper': copper,
      if (silver != null) 'silver': silver,
      if (electrum != null) 'electrum': electrum,
      if (gold != null) 'gold': gold,
      if (platinum != null) 'platinum': platinum,
      if (otherProficiencies != null) 'other_proficiencies': otherProficiencies,
      if (languages != null) 'languages': languages,
      if (resourcesUsed != null) 'resources_used': resourcesUsed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CharactersCompanion copyWith({
    Value<String>? id,
    Value<String>? nome,
    Value<String>? raca,
    Value<String>? classe,
    Value<int>? nivel,
    Value<int>? armorClass,
    Value<int>? initiative,
    Value<int>? speed,
    Value<int>? maxHitPoints,
    Value<int>? currentHitPoints,
    Value<int>? temporaryHitPoints,
    Value<String?>? avatarPath,
    Value<String?>? alignment,
    Value<String?>? background,
    Value<String?>? personalityTraits,
    Value<String?>? ideals,
    Value<String?>? bonds,
    Value<String?>? flaws,
    Value<int>? experiencePoints,
    Value<int>? proficiencyBonus,
    Value<List<String>>? spells,
    Value<List<String>>? defeatedBosses,
    Value<List<String>>? proficiencies,
    Value<int>? armorClassBonus,
    Value<int>? hitDiceUsed,
    Value<int>? deathSaveSuccesses,
    Value<int>? deathSaveFailures,
    Value<List<String>>? conditions,
    Value<int>? exhaustionLevel,
    Value<bool>? inspiration,
    Value<List<int>>? spellSlotsUsed,
    Value<int>? pactSlotsUsed,
    Value<int>? copper,
    Value<int>? silver,
    Value<int>? electrum,
    Value<int>? gold,
    Value<int>? platinum,
    Value<List<String>>? otherProficiencies,
    Value<List<String>>? languages,
    Value<Map<String, int>>? resourcesUsed,
    Value<int>? rowid,
  }) {
    return CharactersCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      raca: raca ?? this.raca,
      classe: classe ?? this.classe,
      nivel: nivel ?? this.nivel,
      armorClass: armorClass ?? this.armorClass,
      initiative: initiative ?? this.initiative,
      speed: speed ?? this.speed,
      maxHitPoints: maxHitPoints ?? this.maxHitPoints,
      currentHitPoints: currentHitPoints ?? this.currentHitPoints,
      temporaryHitPoints: temporaryHitPoints ?? this.temporaryHitPoints,
      avatarPath: avatarPath ?? this.avatarPath,
      alignment: alignment ?? this.alignment,
      background: background ?? this.background,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      ideals: ideals ?? this.ideals,
      bonds: bonds ?? this.bonds,
      flaws: flaws ?? this.flaws,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      proficiencyBonus: proficiencyBonus ?? this.proficiencyBonus,
      spells: spells ?? this.spells,
      defeatedBosses: defeatedBosses ?? this.defeatedBosses,
      proficiencies: proficiencies ?? this.proficiencies,
      armorClassBonus: armorClassBonus ?? this.armorClassBonus,
      hitDiceUsed: hitDiceUsed ?? this.hitDiceUsed,
      deathSaveSuccesses: deathSaveSuccesses ?? this.deathSaveSuccesses,
      deathSaveFailures: deathSaveFailures ?? this.deathSaveFailures,
      conditions: conditions ?? this.conditions,
      exhaustionLevel: exhaustionLevel ?? this.exhaustionLevel,
      inspiration: inspiration ?? this.inspiration,
      spellSlotsUsed: spellSlotsUsed ?? this.spellSlotsUsed,
      pactSlotsUsed: pactSlotsUsed ?? this.pactSlotsUsed,
      copper: copper ?? this.copper,
      silver: silver ?? this.silver,
      electrum: electrum ?? this.electrum,
      gold: gold ?? this.gold,
      platinum: platinum ?? this.platinum,
      otherProficiencies: otherProficiencies ?? this.otherProficiencies,
      languages: languages ?? this.languages,
      resourcesUsed: resourcesUsed ?? this.resourcesUsed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (raca.present) {
      map['raca'] = Variable<String>(raca.value);
    }
    if (classe.present) {
      map['classe'] = Variable<String>(classe.value);
    }
    if (nivel.present) {
      map['nivel'] = Variable<int>(nivel.value);
    }
    if (armorClass.present) {
      map['armor_class'] = Variable<int>(armorClass.value);
    }
    if (initiative.present) {
      map['initiative'] = Variable<int>(initiative.value);
    }
    if (speed.present) {
      map['speed'] = Variable<int>(speed.value);
    }
    if (maxHitPoints.present) {
      map['max_hit_points'] = Variable<int>(maxHitPoints.value);
    }
    if (currentHitPoints.present) {
      map['current_hit_points'] = Variable<int>(currentHitPoints.value);
    }
    if (temporaryHitPoints.present) {
      map['temporary_hit_points'] = Variable<int>(temporaryHitPoints.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (alignment.present) {
      map['alignment'] = Variable<String>(alignment.value);
    }
    if (background.present) {
      map['background'] = Variable<String>(background.value);
    }
    if (personalityTraits.present) {
      map['personality_traits'] = Variable<String>(personalityTraits.value);
    }
    if (ideals.present) {
      map['ideals'] = Variable<String>(ideals.value);
    }
    if (bonds.present) {
      map['bonds'] = Variable<String>(bonds.value);
    }
    if (flaws.present) {
      map['flaws'] = Variable<String>(flaws.value);
    }
    if (experiencePoints.present) {
      map['experience_points'] = Variable<int>(experiencePoints.value);
    }
    if (proficiencyBonus.present) {
      map['proficiency_bonus'] = Variable<int>(proficiencyBonus.value);
    }
    if (spells.present) {
      map['spells'] = Variable<String>(
        $CharactersTable.$converterspells.toSql(spells.value),
      );
    }
    if (defeatedBosses.present) {
      map['defeated_bosses'] = Variable<String>(
        $CharactersTable.$converterdefeatedBosses.toSql(defeatedBosses.value),
      );
    }
    if (proficiencies.present) {
      map['proficiencies'] = Variable<String>(
        $CharactersTable.$converterproficiencies.toSql(proficiencies.value),
      );
    }
    if (armorClassBonus.present) {
      map['armor_class_bonus'] = Variable<int>(armorClassBonus.value);
    }
    if (hitDiceUsed.present) {
      map['hit_dice_used'] = Variable<int>(hitDiceUsed.value);
    }
    if (deathSaveSuccesses.present) {
      map['death_save_successes'] = Variable<int>(deathSaveSuccesses.value);
    }
    if (deathSaveFailures.present) {
      map['death_save_failures'] = Variable<int>(deathSaveFailures.value);
    }
    if (conditions.present) {
      map['conditions'] = Variable<String>(
        $CharactersTable.$converterconditions.toSql(conditions.value),
      );
    }
    if (exhaustionLevel.present) {
      map['exhaustion_level'] = Variable<int>(exhaustionLevel.value);
    }
    if (inspiration.present) {
      map['inspiration'] = Variable<bool>(inspiration.value);
    }
    if (spellSlotsUsed.present) {
      map['spell_slots_used'] = Variable<String>(
        $CharactersTable.$converterspellSlotsUsed.toSql(spellSlotsUsed.value),
      );
    }
    if (pactSlotsUsed.present) {
      map['pact_slots_used'] = Variable<int>(pactSlotsUsed.value);
    }
    if (copper.present) {
      map['copper'] = Variable<int>(copper.value);
    }
    if (silver.present) {
      map['silver'] = Variable<int>(silver.value);
    }
    if (electrum.present) {
      map['electrum'] = Variable<int>(electrum.value);
    }
    if (gold.present) {
      map['gold'] = Variable<int>(gold.value);
    }
    if (platinum.present) {
      map['platinum'] = Variable<int>(platinum.value);
    }
    if (otherProficiencies.present) {
      map['other_proficiencies'] = Variable<String>(
        $CharactersTable.$converterotherProficiencies.toSql(
          otherProficiencies.value,
        ),
      );
    }
    if (languages.present) {
      map['languages'] = Variable<String>(
        $CharactersTable.$converterlanguages.toSql(languages.value),
      );
    }
    if (resourcesUsed.present) {
      map['resources_used'] = Variable<String>(
        $CharactersTable.$converterresourcesUsed.toSql(resourcesUsed.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharactersCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('raca: $raca, ')
          ..write('classe: $classe, ')
          ..write('nivel: $nivel, ')
          ..write('armorClass: $armorClass, ')
          ..write('initiative: $initiative, ')
          ..write('speed: $speed, ')
          ..write('maxHitPoints: $maxHitPoints, ')
          ..write('currentHitPoints: $currentHitPoints, ')
          ..write('temporaryHitPoints: $temporaryHitPoints, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('alignment: $alignment, ')
          ..write('background: $background, ')
          ..write('personalityTraits: $personalityTraits, ')
          ..write('ideals: $ideals, ')
          ..write('bonds: $bonds, ')
          ..write('flaws: $flaws, ')
          ..write('experiencePoints: $experiencePoints, ')
          ..write('proficiencyBonus: $proficiencyBonus, ')
          ..write('spells: $spells, ')
          ..write('defeatedBosses: $defeatedBosses, ')
          ..write('proficiencies: $proficiencies, ')
          ..write('armorClassBonus: $armorClassBonus, ')
          ..write('hitDiceUsed: $hitDiceUsed, ')
          ..write('deathSaveSuccesses: $deathSaveSuccesses, ')
          ..write('deathSaveFailures: $deathSaveFailures, ')
          ..write('conditions: $conditions, ')
          ..write('exhaustionLevel: $exhaustionLevel, ')
          ..write('inspiration: $inspiration, ')
          ..write('spellSlotsUsed: $spellSlotsUsed, ')
          ..write('pactSlotsUsed: $pactSlotsUsed, ')
          ..write('copper: $copper, ')
          ..write('silver: $silver, ')
          ..write('electrum: $electrum, ')
          ..write('gold: $gold, ')
          ..write('platinum: $platinum, ')
          ..write('otherProficiencies: $otherProficiencies, ')
          ..write('languages: $languages, ')
          ..write('resourcesUsed: $resourcesUsed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttributesTable extends Attributes
    with TableInfo<$AttributesTable, AttributeData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttributesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<String> characterId = GeneratedColumn<String>(
    'character_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES characters (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _forcaMeta = const VerificationMeta('forca');
  @override
  late final GeneratedColumn<int> forca = GeneratedColumn<int>(
    'forca',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(8),
  );
  static const VerificationMeta _destrezaMeta = const VerificationMeta(
    'destreza',
  );
  @override
  late final GeneratedColumn<int> destreza = GeneratedColumn<int>(
    'destreza',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(8),
  );
  static const VerificationMeta _constituicaoMeta = const VerificationMeta(
    'constituicao',
  );
  @override
  late final GeneratedColumn<int> constituicao = GeneratedColumn<int>(
    'constituicao',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(8),
  );
  static const VerificationMeta _inteligenciaMeta = const VerificationMeta(
    'inteligencia',
  );
  @override
  late final GeneratedColumn<int> inteligencia = GeneratedColumn<int>(
    'inteligencia',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(8),
  );
  static const VerificationMeta _sabedoriaMeta = const VerificationMeta(
    'sabedoria',
  );
  @override
  late final GeneratedColumn<int> sabedoria = GeneratedColumn<int>(
    'sabedoria',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(8),
  );
  static const VerificationMeta _carismaMeta = const VerificationMeta(
    'carisma',
  );
  @override
  late final GeneratedColumn<int> carisma = GeneratedColumn<int>(
    'carisma',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(8),
  );
  @override
  List<GeneratedColumn> get $columns => [
    characterId,
    forca,
    destreza,
    constituicao,
    inteligencia,
    sabedoria,
    carisma,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attributes';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttributeData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('forca')) {
      context.handle(
        _forcaMeta,
        forca.isAcceptableOrUnknown(data['forca']!, _forcaMeta),
      );
    }
    if (data.containsKey('destreza')) {
      context.handle(
        _destrezaMeta,
        destreza.isAcceptableOrUnknown(data['destreza']!, _destrezaMeta),
      );
    }
    if (data.containsKey('constituicao')) {
      context.handle(
        _constituicaoMeta,
        constituicao.isAcceptableOrUnknown(
          data['constituicao']!,
          _constituicaoMeta,
        ),
      );
    }
    if (data.containsKey('inteligencia')) {
      context.handle(
        _inteligenciaMeta,
        inteligencia.isAcceptableOrUnknown(
          data['inteligencia']!,
          _inteligenciaMeta,
        ),
      );
    }
    if (data.containsKey('sabedoria')) {
      context.handle(
        _sabedoriaMeta,
        sabedoria.isAcceptableOrUnknown(data['sabedoria']!, _sabedoriaMeta),
      );
    }
    if (data.containsKey('carisma')) {
      context.handle(
        _carismaMeta,
        carisma.isAcceptableOrUnknown(data['carisma']!, _carismaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {characterId};
  @override
  AttributeData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttributeData(
      characterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}character_id'],
      )!,
      forca: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}forca'],
      )!,
      destreza: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}destreza'],
      )!,
      constituicao: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}constituicao'],
      )!,
      inteligencia: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}inteligencia'],
      )!,
      sabedoria: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sabedoria'],
      )!,
      carisma: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}carisma'],
      )!,
    );
  }

  @override
  $AttributesTable createAlias(String alias) {
    return $AttributesTable(attachedDatabase, alias);
  }
}

class AttributeData extends DataClass implements Insertable<AttributeData> {
  /// Chave estrangeira para o personagem dono destes atributos.
  final String characterId;

  /// Força: capacidade física bruta.
  final int forca;

  /// Destreza: agilidade e coordenação.
  final int destreza;

  /// Constituição: resistência física.
  final int constituicao;

  /// Inteligência: raciocínio e memória.
  final int inteligencia;

  /// Sabedoria: percepção e intuição.
  final int sabedoria;

  /// Carisma: força de personalidade.
  final int carisma;
  const AttributeData({
    required this.characterId,
    required this.forca,
    required this.destreza,
    required this.constituicao,
    required this.inteligencia,
    required this.sabedoria,
    required this.carisma,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['character_id'] = Variable<String>(characterId);
    map['forca'] = Variable<int>(forca);
    map['destreza'] = Variable<int>(destreza);
    map['constituicao'] = Variable<int>(constituicao);
    map['inteligencia'] = Variable<int>(inteligencia);
    map['sabedoria'] = Variable<int>(sabedoria);
    map['carisma'] = Variable<int>(carisma);
    return map;
  }

  AttributesCompanion toCompanion(bool nullToAbsent) {
    return AttributesCompanion(
      characterId: Value(characterId),
      forca: Value(forca),
      destreza: Value(destreza),
      constituicao: Value(constituicao),
      inteligencia: Value(inteligencia),
      sabedoria: Value(sabedoria),
      carisma: Value(carisma),
    );
  }

  factory AttributeData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttributeData(
      characterId: serializer.fromJson<String>(json['characterId']),
      forca: serializer.fromJson<int>(json['forca']),
      destreza: serializer.fromJson<int>(json['destreza']),
      constituicao: serializer.fromJson<int>(json['constituicao']),
      inteligencia: serializer.fromJson<int>(json['inteligencia']),
      sabedoria: serializer.fromJson<int>(json['sabedoria']),
      carisma: serializer.fromJson<int>(json['carisma']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'characterId': serializer.toJson<String>(characterId),
      'forca': serializer.toJson<int>(forca),
      'destreza': serializer.toJson<int>(destreza),
      'constituicao': serializer.toJson<int>(constituicao),
      'inteligencia': serializer.toJson<int>(inteligencia),
      'sabedoria': serializer.toJson<int>(sabedoria),
      'carisma': serializer.toJson<int>(carisma),
    };
  }

  AttributeData copyWith({
    String? characterId,
    int? forca,
    int? destreza,
    int? constituicao,
    int? inteligencia,
    int? sabedoria,
    int? carisma,
  }) => AttributeData(
    characterId: characterId ?? this.characterId,
    forca: forca ?? this.forca,
    destreza: destreza ?? this.destreza,
    constituicao: constituicao ?? this.constituicao,
    inteligencia: inteligencia ?? this.inteligencia,
    sabedoria: sabedoria ?? this.sabedoria,
    carisma: carisma ?? this.carisma,
  );
  AttributeData copyWithCompanion(AttributesCompanion data) {
    return AttributeData(
      characterId: data.characterId.present
          ? data.characterId.value
          : this.characterId,
      forca: data.forca.present ? data.forca.value : this.forca,
      destreza: data.destreza.present ? data.destreza.value : this.destreza,
      constituicao: data.constituicao.present
          ? data.constituicao.value
          : this.constituicao,
      inteligencia: data.inteligencia.present
          ? data.inteligencia.value
          : this.inteligencia,
      sabedoria: data.sabedoria.present ? data.sabedoria.value : this.sabedoria,
      carisma: data.carisma.present ? data.carisma.value : this.carisma,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttributeData(')
          ..write('characterId: $characterId, ')
          ..write('forca: $forca, ')
          ..write('destreza: $destreza, ')
          ..write('constituicao: $constituicao, ')
          ..write('inteligencia: $inteligencia, ')
          ..write('sabedoria: $sabedoria, ')
          ..write('carisma: $carisma')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    characterId,
    forca,
    destreza,
    constituicao,
    inteligencia,
    sabedoria,
    carisma,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttributeData &&
          other.characterId == this.characterId &&
          other.forca == this.forca &&
          other.destreza == this.destreza &&
          other.constituicao == this.constituicao &&
          other.inteligencia == this.inteligencia &&
          other.sabedoria == this.sabedoria &&
          other.carisma == this.carisma);
}

class AttributesCompanion extends UpdateCompanion<AttributeData> {
  final Value<String> characterId;
  final Value<int> forca;
  final Value<int> destreza;
  final Value<int> constituicao;
  final Value<int> inteligencia;
  final Value<int> sabedoria;
  final Value<int> carisma;
  final Value<int> rowid;
  const AttributesCompanion({
    this.characterId = const Value.absent(),
    this.forca = const Value.absent(),
    this.destreza = const Value.absent(),
    this.constituicao = const Value.absent(),
    this.inteligencia = const Value.absent(),
    this.sabedoria = const Value.absent(),
    this.carisma = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttributesCompanion.insert({
    required String characterId,
    this.forca = const Value.absent(),
    this.destreza = const Value.absent(),
    this.constituicao = const Value.absent(),
    this.inteligencia = const Value.absent(),
    this.sabedoria = const Value.absent(),
    this.carisma = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : characterId = Value(characterId);
  static Insertable<AttributeData> custom({
    Expression<String>? characterId,
    Expression<int>? forca,
    Expression<int>? destreza,
    Expression<int>? constituicao,
    Expression<int>? inteligencia,
    Expression<int>? sabedoria,
    Expression<int>? carisma,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (characterId != null) 'character_id': characterId,
      if (forca != null) 'forca': forca,
      if (destreza != null) 'destreza': destreza,
      if (constituicao != null) 'constituicao': constituicao,
      if (inteligencia != null) 'inteligencia': inteligencia,
      if (sabedoria != null) 'sabedoria': sabedoria,
      if (carisma != null) 'carisma': carisma,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttributesCompanion copyWith({
    Value<String>? characterId,
    Value<int>? forca,
    Value<int>? destreza,
    Value<int>? constituicao,
    Value<int>? inteligencia,
    Value<int>? sabedoria,
    Value<int>? carisma,
    Value<int>? rowid,
  }) {
    return AttributesCompanion(
      characterId: characterId ?? this.characterId,
      forca: forca ?? this.forca,
      destreza: destreza ?? this.destreza,
      constituicao: constituicao ?? this.constituicao,
      inteligencia: inteligencia ?? this.inteligencia,
      sabedoria: sabedoria ?? this.sabedoria,
      carisma: carisma ?? this.carisma,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (characterId.present) {
      map['character_id'] = Variable<String>(characterId.value);
    }
    if (forca.present) {
      map['forca'] = Variable<int>(forca.value);
    }
    if (destreza.present) {
      map['destreza'] = Variable<int>(destreza.value);
    }
    if (constituicao.present) {
      map['constituicao'] = Variable<int>(constituicao.value);
    }
    if (inteligencia.present) {
      map['inteligencia'] = Variable<int>(inteligencia.value);
    }
    if (sabedoria.present) {
      map['sabedoria'] = Variable<int>(sabedoria.value);
    }
    if (carisma.present) {
      map['carisma'] = Variable<int>(carisma.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttributesCompanion(')
          ..write('characterId: $characterId, ')
          ..write('forca: $forca, ')
          ..write('destreza: $destreza, ')
          ..write('constituicao: $constituicao, ')
          ..write('inteligencia: $inteligencia, ')
          ..write('sabedoria: $sabedoria, ')
          ..write('carisma: $carisma, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryItemsTable extends InventoryItems
    with TableInfo<$InventoryItemsTable, InventoryItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<String> characterId = GeneratedColumn<String>(
    'character_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES characters (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _itemIndexMeta = const VerificationMeta(
    'itemIndex',
  );
  @override
  late final GeneratedColumn<String> itemIndex = GeneratedColumn<String>(
    'item_index',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipmentCategoryMeta = const VerificationMeta(
    'equipmentCategory',
  );
  @override
  late final GeneratedColumn<String> equipmentCategory =
      GeneratedColumn<String>(
        'equipment_category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _equippedMeta = const VerificationMeta(
    'equipped',
  );
  @override
  late final GeneratedColumn<bool> equipped = GeneratedColumn<bool>(
    'equipped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("equipped" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _requiresAttunementMeta =
      const VerificationMeta('requiresAttunement');
  @override
  late final GeneratedColumn<bool> requiresAttunement = GeneratedColumn<bool>(
    'requires_attunement',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("requires_attunement" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _attunedMeta = const VerificationMeta(
    'attuned',
  );
  @override
  late final GeneratedColumn<bool> attuned = GeneratedColumn<bool>(
    'attuned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("attuned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _detailsLoadedMeta = const VerificationMeta(
    'detailsLoaded',
  );
  @override
  late final GeneratedColumn<bool> detailsLoaded = GeneratedColumn<bool>(
    'details_loaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("details_loaded" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _armorCategoryMeta = const VerificationMeta(
    'armorCategory',
  );
  @override
  late final GeneratedColumn<String> armorCategory = GeneratedColumn<String>(
    'armor_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _armorBaseMeta = const VerificationMeta(
    'armorBase',
  );
  @override
  late final GeneratedColumn<int> armorBase = GeneratedColumn<int>(
    'armor_base',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _armorDexBonusMeta = const VerificationMeta(
    'armorDexBonus',
  );
  @override
  late final GeneratedColumn<bool> armorDexBonus = GeneratedColumn<bool>(
    'armor_dex_bonus',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("armor_dex_bonus" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _armorMaxDexBonusMeta = const VerificationMeta(
    'armorMaxDexBonus',
  );
  @override
  late final GeneratedColumn<int> armorMaxDexBonus = GeneratedColumn<int>(
    'armor_max_dex_bonus',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weaponCategoryMeta = const VerificationMeta(
    'weaponCategory',
  );
  @override
  late final GeneratedColumn<String> weaponCategory = GeneratedColumn<String>(
    'weapon_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weaponRangeMeta = const VerificationMeta(
    'weaponRange',
  );
  @override
  late final GeneratedColumn<String> weaponRange = GeneratedColumn<String>(
    'weapon_range',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _damageDiceMeta = const VerificationMeta(
    'damageDice',
  );
  @override
  late final GeneratedColumn<String> damageDice = GeneratedColumn<String>(
    'damage_dice',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _damageTypeMeta = const VerificationMeta(
    'damageType',
  );
  @override
  late final GeneratedColumn<String> damageType = GeneratedColumn<String>(
    'damage_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versatileDamageDiceMeta =
      const VerificationMeta('versatileDamageDice');
  @override
  late final GeneratedColumn<String> versatileDamageDice =
      GeneratedColumn<String>(
        'versatile_damage_dice',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  weaponProperties =
      GeneratedColumn<String>(
        'weapon_properties',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>(
        $InventoryItemsTable.$converterweaponProperties,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    characterId,
    itemIndex,
    name,
    equipmentCategory,
    quantity,
    weight,
    equipped,
    requiresAttunement,
    attuned,
    detailsLoaded,
    armorCategory,
    armorBase,
    armorDexBonus,
    armorMaxDexBonus,
    weaponCategory,
    weaponRange,
    damageDice,
    damageType,
    versatileDamageDice,
    weaponProperties,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryItemData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('item_index')) {
      context.handle(
        _itemIndexMeta,
        itemIndex.isAcceptableOrUnknown(data['item_index']!, _itemIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIndexMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('equipment_category')) {
      context.handle(
        _equipmentCategoryMeta,
        equipmentCategory.isAcceptableOrUnknown(
          data['equipment_category']!,
          _equipmentCategoryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_equipmentCategoryMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('equipped')) {
      context.handle(
        _equippedMeta,
        equipped.isAcceptableOrUnknown(data['equipped']!, _equippedMeta),
      );
    }
    if (data.containsKey('requires_attunement')) {
      context.handle(
        _requiresAttunementMeta,
        requiresAttunement.isAcceptableOrUnknown(
          data['requires_attunement']!,
          _requiresAttunementMeta,
        ),
      );
    }
    if (data.containsKey('attuned')) {
      context.handle(
        _attunedMeta,
        attuned.isAcceptableOrUnknown(data['attuned']!, _attunedMeta),
      );
    }
    if (data.containsKey('details_loaded')) {
      context.handle(
        _detailsLoadedMeta,
        detailsLoaded.isAcceptableOrUnknown(
          data['details_loaded']!,
          _detailsLoadedMeta,
        ),
      );
    }
    if (data.containsKey('armor_category')) {
      context.handle(
        _armorCategoryMeta,
        armorCategory.isAcceptableOrUnknown(
          data['armor_category']!,
          _armorCategoryMeta,
        ),
      );
    }
    if (data.containsKey('armor_base')) {
      context.handle(
        _armorBaseMeta,
        armorBase.isAcceptableOrUnknown(data['armor_base']!, _armorBaseMeta),
      );
    }
    if (data.containsKey('armor_dex_bonus')) {
      context.handle(
        _armorDexBonusMeta,
        armorDexBonus.isAcceptableOrUnknown(
          data['armor_dex_bonus']!,
          _armorDexBonusMeta,
        ),
      );
    }
    if (data.containsKey('armor_max_dex_bonus')) {
      context.handle(
        _armorMaxDexBonusMeta,
        armorMaxDexBonus.isAcceptableOrUnknown(
          data['armor_max_dex_bonus']!,
          _armorMaxDexBonusMeta,
        ),
      );
    }
    if (data.containsKey('weapon_category')) {
      context.handle(
        _weaponCategoryMeta,
        weaponCategory.isAcceptableOrUnknown(
          data['weapon_category']!,
          _weaponCategoryMeta,
        ),
      );
    }
    if (data.containsKey('weapon_range')) {
      context.handle(
        _weaponRangeMeta,
        weaponRange.isAcceptableOrUnknown(
          data['weapon_range']!,
          _weaponRangeMeta,
        ),
      );
    }
    if (data.containsKey('damage_dice')) {
      context.handle(
        _damageDiceMeta,
        damageDice.isAcceptableOrUnknown(data['damage_dice']!, _damageDiceMeta),
      );
    }
    if (data.containsKey('damage_type')) {
      context.handle(
        _damageTypeMeta,
        damageType.isAcceptableOrUnknown(data['damage_type']!, _damageTypeMeta),
      );
    }
    if (data.containsKey('versatile_damage_dice')) {
      context.handle(
        _versatileDamageDiceMeta,
        versatileDamageDice.isAcceptableOrUnknown(
          data['versatile_damage_dice']!,
          _versatileDamageDiceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryItemData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      characterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}character_id'],
      )!,
      itemIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_index'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      equipmentCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment_category'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      equipped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}equipped'],
      )!,
      requiresAttunement: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}requires_attunement'],
      )!,
      attuned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}attuned'],
      )!,
      detailsLoaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}details_loaded'],
      )!,
      armorCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}armor_category'],
      ),
      armorBase: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}armor_base'],
      ),
      armorDexBonus: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}armor_dex_bonus'],
      )!,
      armorMaxDexBonus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}armor_max_dex_bonus'],
      ),
      weaponCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weapon_category'],
      ),
      weaponRange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weapon_range'],
      ),
      damageDice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}damage_dice'],
      ),
      damageType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}damage_type'],
      ),
      versatileDamageDice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}versatile_damage_dice'],
      ),
      weaponProperties: $InventoryItemsTable.$converterweaponProperties.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}weapon_properties'],
        )!,
      ),
    );
  }

  @override
  $InventoryItemsTable createAlias(String alias) {
    return $InventoryItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterweaponProperties =
      const StringListConverter();
}

class InventoryItemData extends DataClass
    implements Insertable<InventoryItemData> {
  /// Identificador único do item (UUID gerado no domínio).
  final String id;

  /// Chave estrangeira para o personagem dono do item.
  final String characterId;

  /// Identificador do item na API do D&D 5e (ex: "longsword").
  final String itemIndex;

  /// Nome legível do item (ex: "Longsword").
  final String name;

  /// Categoria do equipamento (ex: "Weapon", "Armor").
  final String equipmentCategory;
  final int quantity;
  final double weight;
  final bool equipped;
  final bool requiresAttunement;
  final bool attuned;

  /// `false` nos itens anteriores à versão 10: a ficha completa os dados
  /// pelo compêndio quando tem internet.
  final bool detailsLoaded;
  final String? armorCategory;
  final int? armorBase;
  final bool armorDexBonus;
  final int? armorMaxDexBonus;
  final String? weaponCategory;
  final String? weaponRange;
  final String? damageDice;
  final String? damageType;
  final String? versatileDamageDice;
  final List<String> weaponProperties;
  const InventoryItemData({
    required this.id,
    required this.characterId,
    required this.itemIndex,
    required this.name,
    required this.equipmentCategory,
    required this.quantity,
    required this.weight,
    required this.equipped,
    required this.requiresAttunement,
    required this.attuned,
    required this.detailsLoaded,
    this.armorCategory,
    this.armorBase,
    required this.armorDexBonus,
    this.armorMaxDexBonus,
    this.weaponCategory,
    this.weaponRange,
    this.damageDice,
    this.damageType,
    this.versatileDamageDice,
    required this.weaponProperties,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['character_id'] = Variable<String>(characterId);
    map['item_index'] = Variable<String>(itemIndex);
    map['name'] = Variable<String>(name);
    map['equipment_category'] = Variable<String>(equipmentCategory);
    map['quantity'] = Variable<int>(quantity);
    map['weight'] = Variable<double>(weight);
    map['equipped'] = Variable<bool>(equipped);
    map['requires_attunement'] = Variable<bool>(requiresAttunement);
    map['attuned'] = Variable<bool>(attuned);
    map['details_loaded'] = Variable<bool>(detailsLoaded);
    if (!nullToAbsent || armorCategory != null) {
      map['armor_category'] = Variable<String>(armorCategory);
    }
    if (!nullToAbsent || armorBase != null) {
      map['armor_base'] = Variable<int>(armorBase);
    }
    map['armor_dex_bonus'] = Variable<bool>(armorDexBonus);
    if (!nullToAbsent || armorMaxDexBonus != null) {
      map['armor_max_dex_bonus'] = Variable<int>(armorMaxDexBonus);
    }
    if (!nullToAbsent || weaponCategory != null) {
      map['weapon_category'] = Variable<String>(weaponCategory);
    }
    if (!nullToAbsent || weaponRange != null) {
      map['weapon_range'] = Variable<String>(weaponRange);
    }
    if (!nullToAbsent || damageDice != null) {
      map['damage_dice'] = Variable<String>(damageDice);
    }
    if (!nullToAbsent || damageType != null) {
      map['damage_type'] = Variable<String>(damageType);
    }
    if (!nullToAbsent || versatileDamageDice != null) {
      map['versatile_damage_dice'] = Variable<String>(versatileDamageDice);
    }
    {
      map['weapon_properties'] = Variable<String>(
        $InventoryItemsTable.$converterweaponProperties.toSql(weaponProperties),
      );
    }
    return map;
  }

  InventoryItemsCompanion toCompanion(bool nullToAbsent) {
    return InventoryItemsCompanion(
      id: Value(id),
      characterId: Value(characterId),
      itemIndex: Value(itemIndex),
      name: Value(name),
      equipmentCategory: Value(equipmentCategory),
      quantity: Value(quantity),
      weight: Value(weight),
      equipped: Value(equipped),
      requiresAttunement: Value(requiresAttunement),
      attuned: Value(attuned),
      detailsLoaded: Value(detailsLoaded),
      armorCategory: armorCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(armorCategory),
      armorBase: armorBase == null && nullToAbsent
          ? const Value.absent()
          : Value(armorBase),
      armorDexBonus: Value(armorDexBonus),
      armorMaxDexBonus: armorMaxDexBonus == null && nullToAbsent
          ? const Value.absent()
          : Value(armorMaxDexBonus),
      weaponCategory: weaponCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(weaponCategory),
      weaponRange: weaponRange == null && nullToAbsent
          ? const Value.absent()
          : Value(weaponRange),
      damageDice: damageDice == null && nullToAbsent
          ? const Value.absent()
          : Value(damageDice),
      damageType: damageType == null && nullToAbsent
          ? const Value.absent()
          : Value(damageType),
      versatileDamageDice: versatileDamageDice == null && nullToAbsent
          ? const Value.absent()
          : Value(versatileDamageDice),
      weaponProperties: Value(weaponProperties),
    );
  }

  factory InventoryItemData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryItemData(
      id: serializer.fromJson<String>(json['id']),
      characterId: serializer.fromJson<String>(json['characterId']),
      itemIndex: serializer.fromJson<String>(json['itemIndex']),
      name: serializer.fromJson<String>(json['name']),
      equipmentCategory: serializer.fromJson<String>(json['equipmentCategory']),
      quantity: serializer.fromJson<int>(json['quantity']),
      weight: serializer.fromJson<double>(json['weight']),
      equipped: serializer.fromJson<bool>(json['equipped']),
      requiresAttunement: serializer.fromJson<bool>(json['requiresAttunement']),
      attuned: serializer.fromJson<bool>(json['attuned']),
      detailsLoaded: serializer.fromJson<bool>(json['detailsLoaded']),
      armorCategory: serializer.fromJson<String?>(json['armorCategory']),
      armorBase: serializer.fromJson<int?>(json['armorBase']),
      armorDexBonus: serializer.fromJson<bool>(json['armorDexBonus']),
      armorMaxDexBonus: serializer.fromJson<int?>(json['armorMaxDexBonus']),
      weaponCategory: serializer.fromJson<String?>(json['weaponCategory']),
      weaponRange: serializer.fromJson<String?>(json['weaponRange']),
      damageDice: serializer.fromJson<String?>(json['damageDice']),
      damageType: serializer.fromJson<String?>(json['damageType']),
      versatileDamageDice: serializer.fromJson<String?>(
        json['versatileDamageDice'],
      ),
      weaponProperties: serializer.fromJson<List<String>>(
        json['weaponProperties'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'characterId': serializer.toJson<String>(characterId),
      'itemIndex': serializer.toJson<String>(itemIndex),
      'name': serializer.toJson<String>(name),
      'equipmentCategory': serializer.toJson<String>(equipmentCategory),
      'quantity': serializer.toJson<int>(quantity),
      'weight': serializer.toJson<double>(weight),
      'equipped': serializer.toJson<bool>(equipped),
      'requiresAttunement': serializer.toJson<bool>(requiresAttunement),
      'attuned': serializer.toJson<bool>(attuned),
      'detailsLoaded': serializer.toJson<bool>(detailsLoaded),
      'armorCategory': serializer.toJson<String?>(armorCategory),
      'armorBase': serializer.toJson<int?>(armorBase),
      'armorDexBonus': serializer.toJson<bool>(armorDexBonus),
      'armorMaxDexBonus': serializer.toJson<int?>(armorMaxDexBonus),
      'weaponCategory': serializer.toJson<String?>(weaponCategory),
      'weaponRange': serializer.toJson<String?>(weaponRange),
      'damageDice': serializer.toJson<String?>(damageDice),
      'damageType': serializer.toJson<String?>(damageType),
      'versatileDamageDice': serializer.toJson<String?>(versatileDamageDice),
      'weaponProperties': serializer.toJson<List<String>>(weaponProperties),
    };
  }

  InventoryItemData copyWith({
    String? id,
    String? characterId,
    String? itemIndex,
    String? name,
    String? equipmentCategory,
    int? quantity,
    double? weight,
    bool? equipped,
    bool? requiresAttunement,
    bool? attuned,
    bool? detailsLoaded,
    Value<String?> armorCategory = const Value.absent(),
    Value<int?> armorBase = const Value.absent(),
    bool? armorDexBonus,
    Value<int?> armorMaxDexBonus = const Value.absent(),
    Value<String?> weaponCategory = const Value.absent(),
    Value<String?> weaponRange = const Value.absent(),
    Value<String?> damageDice = const Value.absent(),
    Value<String?> damageType = const Value.absent(),
    Value<String?> versatileDamageDice = const Value.absent(),
    List<String>? weaponProperties,
  }) => InventoryItemData(
    id: id ?? this.id,
    characterId: characterId ?? this.characterId,
    itemIndex: itemIndex ?? this.itemIndex,
    name: name ?? this.name,
    equipmentCategory: equipmentCategory ?? this.equipmentCategory,
    quantity: quantity ?? this.quantity,
    weight: weight ?? this.weight,
    equipped: equipped ?? this.equipped,
    requiresAttunement: requiresAttunement ?? this.requiresAttunement,
    attuned: attuned ?? this.attuned,
    detailsLoaded: detailsLoaded ?? this.detailsLoaded,
    armorCategory: armorCategory.present
        ? armorCategory.value
        : this.armorCategory,
    armorBase: armorBase.present ? armorBase.value : this.armorBase,
    armorDexBonus: armorDexBonus ?? this.armorDexBonus,
    armorMaxDexBonus: armorMaxDexBonus.present
        ? armorMaxDexBonus.value
        : this.armorMaxDexBonus,
    weaponCategory: weaponCategory.present
        ? weaponCategory.value
        : this.weaponCategory,
    weaponRange: weaponRange.present ? weaponRange.value : this.weaponRange,
    damageDice: damageDice.present ? damageDice.value : this.damageDice,
    damageType: damageType.present ? damageType.value : this.damageType,
    versatileDamageDice: versatileDamageDice.present
        ? versatileDamageDice.value
        : this.versatileDamageDice,
    weaponProperties: weaponProperties ?? this.weaponProperties,
  );
  InventoryItemData copyWithCompanion(InventoryItemsCompanion data) {
    return InventoryItemData(
      id: data.id.present ? data.id.value : this.id,
      characterId: data.characterId.present
          ? data.characterId.value
          : this.characterId,
      itemIndex: data.itemIndex.present ? data.itemIndex.value : this.itemIndex,
      name: data.name.present ? data.name.value : this.name,
      equipmentCategory: data.equipmentCategory.present
          ? data.equipmentCategory.value
          : this.equipmentCategory,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      weight: data.weight.present ? data.weight.value : this.weight,
      equipped: data.equipped.present ? data.equipped.value : this.equipped,
      requiresAttunement: data.requiresAttunement.present
          ? data.requiresAttunement.value
          : this.requiresAttunement,
      attuned: data.attuned.present ? data.attuned.value : this.attuned,
      detailsLoaded: data.detailsLoaded.present
          ? data.detailsLoaded.value
          : this.detailsLoaded,
      armorCategory: data.armorCategory.present
          ? data.armorCategory.value
          : this.armorCategory,
      armorBase: data.armorBase.present ? data.armorBase.value : this.armorBase,
      armorDexBonus: data.armorDexBonus.present
          ? data.armorDexBonus.value
          : this.armorDexBonus,
      armorMaxDexBonus: data.armorMaxDexBonus.present
          ? data.armorMaxDexBonus.value
          : this.armorMaxDexBonus,
      weaponCategory: data.weaponCategory.present
          ? data.weaponCategory.value
          : this.weaponCategory,
      weaponRange: data.weaponRange.present
          ? data.weaponRange.value
          : this.weaponRange,
      damageDice: data.damageDice.present
          ? data.damageDice.value
          : this.damageDice,
      damageType: data.damageType.present
          ? data.damageType.value
          : this.damageType,
      versatileDamageDice: data.versatileDamageDice.present
          ? data.versatileDamageDice.value
          : this.versatileDamageDice,
      weaponProperties: data.weaponProperties.present
          ? data.weaponProperties.value
          : this.weaponProperties,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryItemData(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('itemIndex: $itemIndex, ')
          ..write('name: $name, ')
          ..write('equipmentCategory: $equipmentCategory, ')
          ..write('quantity: $quantity, ')
          ..write('weight: $weight, ')
          ..write('equipped: $equipped, ')
          ..write('requiresAttunement: $requiresAttunement, ')
          ..write('attuned: $attuned, ')
          ..write('detailsLoaded: $detailsLoaded, ')
          ..write('armorCategory: $armorCategory, ')
          ..write('armorBase: $armorBase, ')
          ..write('armorDexBonus: $armorDexBonus, ')
          ..write('armorMaxDexBonus: $armorMaxDexBonus, ')
          ..write('weaponCategory: $weaponCategory, ')
          ..write('weaponRange: $weaponRange, ')
          ..write('damageDice: $damageDice, ')
          ..write('damageType: $damageType, ')
          ..write('versatileDamageDice: $versatileDamageDice, ')
          ..write('weaponProperties: $weaponProperties')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    characterId,
    itemIndex,
    name,
    equipmentCategory,
    quantity,
    weight,
    equipped,
    requiresAttunement,
    attuned,
    detailsLoaded,
    armorCategory,
    armorBase,
    armorDexBonus,
    armorMaxDexBonus,
    weaponCategory,
    weaponRange,
    damageDice,
    damageType,
    versatileDamageDice,
    weaponProperties,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryItemData &&
          other.id == this.id &&
          other.characterId == this.characterId &&
          other.itemIndex == this.itemIndex &&
          other.name == this.name &&
          other.equipmentCategory == this.equipmentCategory &&
          other.quantity == this.quantity &&
          other.weight == this.weight &&
          other.equipped == this.equipped &&
          other.requiresAttunement == this.requiresAttunement &&
          other.attuned == this.attuned &&
          other.detailsLoaded == this.detailsLoaded &&
          other.armorCategory == this.armorCategory &&
          other.armorBase == this.armorBase &&
          other.armorDexBonus == this.armorDexBonus &&
          other.armorMaxDexBonus == this.armorMaxDexBonus &&
          other.weaponCategory == this.weaponCategory &&
          other.weaponRange == this.weaponRange &&
          other.damageDice == this.damageDice &&
          other.damageType == this.damageType &&
          other.versatileDamageDice == this.versatileDamageDice &&
          other.weaponProperties == this.weaponProperties);
}

class InventoryItemsCompanion extends UpdateCompanion<InventoryItemData> {
  final Value<String> id;
  final Value<String> characterId;
  final Value<String> itemIndex;
  final Value<String> name;
  final Value<String> equipmentCategory;
  final Value<int> quantity;
  final Value<double> weight;
  final Value<bool> equipped;
  final Value<bool> requiresAttunement;
  final Value<bool> attuned;
  final Value<bool> detailsLoaded;
  final Value<String?> armorCategory;
  final Value<int?> armorBase;
  final Value<bool> armorDexBonus;
  final Value<int?> armorMaxDexBonus;
  final Value<String?> weaponCategory;
  final Value<String?> weaponRange;
  final Value<String?> damageDice;
  final Value<String?> damageType;
  final Value<String?> versatileDamageDice;
  final Value<List<String>> weaponProperties;
  final Value<int> rowid;
  const InventoryItemsCompanion({
    this.id = const Value.absent(),
    this.characterId = const Value.absent(),
    this.itemIndex = const Value.absent(),
    this.name = const Value.absent(),
    this.equipmentCategory = const Value.absent(),
    this.quantity = const Value.absent(),
    this.weight = const Value.absent(),
    this.equipped = const Value.absent(),
    this.requiresAttunement = const Value.absent(),
    this.attuned = const Value.absent(),
    this.detailsLoaded = const Value.absent(),
    this.armorCategory = const Value.absent(),
    this.armorBase = const Value.absent(),
    this.armorDexBonus = const Value.absent(),
    this.armorMaxDexBonus = const Value.absent(),
    this.weaponCategory = const Value.absent(),
    this.weaponRange = const Value.absent(),
    this.damageDice = const Value.absent(),
    this.damageType = const Value.absent(),
    this.versatileDamageDice = const Value.absent(),
    this.weaponProperties = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryItemsCompanion.insert({
    required String id,
    required String characterId,
    required String itemIndex,
    required String name,
    required String equipmentCategory,
    this.quantity = const Value.absent(),
    this.weight = const Value.absent(),
    this.equipped = const Value.absent(),
    this.requiresAttunement = const Value.absent(),
    this.attuned = const Value.absent(),
    this.detailsLoaded = const Value.absent(),
    this.armorCategory = const Value.absent(),
    this.armorBase = const Value.absent(),
    this.armorDexBonus = const Value.absent(),
    this.armorMaxDexBonus = const Value.absent(),
    this.weaponCategory = const Value.absent(),
    this.weaponRange = const Value.absent(),
    this.damageDice = const Value.absent(),
    this.damageType = const Value.absent(),
    this.versatileDamageDice = const Value.absent(),
    this.weaponProperties = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       characterId = Value(characterId),
       itemIndex = Value(itemIndex),
       name = Value(name),
       equipmentCategory = Value(equipmentCategory);
  static Insertable<InventoryItemData> custom({
    Expression<String>? id,
    Expression<String>? characterId,
    Expression<String>? itemIndex,
    Expression<String>? name,
    Expression<String>? equipmentCategory,
    Expression<int>? quantity,
    Expression<double>? weight,
    Expression<bool>? equipped,
    Expression<bool>? requiresAttunement,
    Expression<bool>? attuned,
    Expression<bool>? detailsLoaded,
    Expression<String>? armorCategory,
    Expression<int>? armorBase,
    Expression<bool>? armorDexBonus,
    Expression<int>? armorMaxDexBonus,
    Expression<String>? weaponCategory,
    Expression<String>? weaponRange,
    Expression<String>? damageDice,
    Expression<String>? damageType,
    Expression<String>? versatileDamageDice,
    Expression<String>? weaponProperties,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (characterId != null) 'character_id': characterId,
      if (itemIndex != null) 'item_index': itemIndex,
      if (name != null) 'name': name,
      if (equipmentCategory != null) 'equipment_category': equipmentCategory,
      if (quantity != null) 'quantity': quantity,
      if (weight != null) 'weight': weight,
      if (equipped != null) 'equipped': equipped,
      if (requiresAttunement != null) 'requires_attunement': requiresAttunement,
      if (attuned != null) 'attuned': attuned,
      if (detailsLoaded != null) 'details_loaded': detailsLoaded,
      if (armorCategory != null) 'armor_category': armorCategory,
      if (armorBase != null) 'armor_base': armorBase,
      if (armorDexBonus != null) 'armor_dex_bonus': armorDexBonus,
      if (armorMaxDexBonus != null) 'armor_max_dex_bonus': armorMaxDexBonus,
      if (weaponCategory != null) 'weapon_category': weaponCategory,
      if (weaponRange != null) 'weapon_range': weaponRange,
      if (damageDice != null) 'damage_dice': damageDice,
      if (damageType != null) 'damage_type': damageType,
      if (versatileDamageDice != null)
        'versatile_damage_dice': versatileDamageDice,
      if (weaponProperties != null) 'weapon_properties': weaponProperties,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? characterId,
    Value<String>? itemIndex,
    Value<String>? name,
    Value<String>? equipmentCategory,
    Value<int>? quantity,
    Value<double>? weight,
    Value<bool>? equipped,
    Value<bool>? requiresAttunement,
    Value<bool>? attuned,
    Value<bool>? detailsLoaded,
    Value<String?>? armorCategory,
    Value<int?>? armorBase,
    Value<bool>? armorDexBonus,
    Value<int?>? armorMaxDexBonus,
    Value<String?>? weaponCategory,
    Value<String?>? weaponRange,
    Value<String?>? damageDice,
    Value<String?>? damageType,
    Value<String?>? versatileDamageDice,
    Value<List<String>>? weaponProperties,
    Value<int>? rowid,
  }) {
    return InventoryItemsCompanion(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      itemIndex: itemIndex ?? this.itemIndex,
      name: name ?? this.name,
      equipmentCategory: equipmentCategory ?? this.equipmentCategory,
      quantity: quantity ?? this.quantity,
      weight: weight ?? this.weight,
      equipped: equipped ?? this.equipped,
      requiresAttunement: requiresAttunement ?? this.requiresAttunement,
      attuned: attuned ?? this.attuned,
      detailsLoaded: detailsLoaded ?? this.detailsLoaded,
      armorCategory: armorCategory ?? this.armorCategory,
      armorBase: armorBase ?? this.armorBase,
      armorDexBonus: armorDexBonus ?? this.armorDexBonus,
      armorMaxDexBonus: armorMaxDexBonus ?? this.armorMaxDexBonus,
      weaponCategory: weaponCategory ?? this.weaponCategory,
      weaponRange: weaponRange ?? this.weaponRange,
      damageDice: damageDice ?? this.damageDice,
      damageType: damageType ?? this.damageType,
      versatileDamageDice: versatileDamageDice ?? this.versatileDamageDice,
      weaponProperties: weaponProperties ?? this.weaponProperties,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<String>(characterId.value);
    }
    if (itemIndex.present) {
      map['item_index'] = Variable<String>(itemIndex.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (equipmentCategory.present) {
      map['equipment_category'] = Variable<String>(equipmentCategory.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (equipped.present) {
      map['equipped'] = Variable<bool>(equipped.value);
    }
    if (requiresAttunement.present) {
      map['requires_attunement'] = Variable<bool>(requiresAttunement.value);
    }
    if (attuned.present) {
      map['attuned'] = Variable<bool>(attuned.value);
    }
    if (detailsLoaded.present) {
      map['details_loaded'] = Variable<bool>(detailsLoaded.value);
    }
    if (armorCategory.present) {
      map['armor_category'] = Variable<String>(armorCategory.value);
    }
    if (armorBase.present) {
      map['armor_base'] = Variable<int>(armorBase.value);
    }
    if (armorDexBonus.present) {
      map['armor_dex_bonus'] = Variable<bool>(armorDexBonus.value);
    }
    if (armorMaxDexBonus.present) {
      map['armor_max_dex_bonus'] = Variable<int>(armorMaxDexBonus.value);
    }
    if (weaponCategory.present) {
      map['weapon_category'] = Variable<String>(weaponCategory.value);
    }
    if (weaponRange.present) {
      map['weapon_range'] = Variable<String>(weaponRange.value);
    }
    if (damageDice.present) {
      map['damage_dice'] = Variable<String>(damageDice.value);
    }
    if (damageType.present) {
      map['damage_type'] = Variable<String>(damageType.value);
    }
    if (versatileDamageDice.present) {
      map['versatile_damage_dice'] = Variable<String>(
        versatileDamageDice.value,
      );
    }
    if (weaponProperties.present) {
      map['weapon_properties'] = Variable<String>(
        $InventoryItemsTable.$converterweaponProperties.toSql(
          weaponProperties.value,
        ),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryItemsCompanion(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('itemIndex: $itemIndex, ')
          ..write('name: $name, ')
          ..write('equipmentCategory: $equipmentCategory, ')
          ..write('quantity: $quantity, ')
          ..write('weight: $weight, ')
          ..write('equipped: $equipped, ')
          ..write('requiresAttunement: $requiresAttunement, ')
          ..write('attuned: $attuned, ')
          ..write('detailsLoaded: $detailsLoaded, ')
          ..write('armorCategory: $armorCategory, ')
          ..write('armorBase: $armorBase, ')
          ..write('armorDexBonus: $armorDexBonus, ')
          ..write('armorMaxDexBonus: $armorMaxDexBonus, ')
          ..write('weaponCategory: $weaponCategory, ')
          ..write('weaponRange: $weaponRange, ')
          ..write('damageDice: $damageDice, ')
          ..write('damageType: $damageType, ')
          ..write('versatileDamageDice: $versatileDamageDice, ')
          ..write('weaponProperties: $weaponProperties, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionNotesTable extends SessionNotes
    with TableInfo<$SessionNotesTable, SessionNoteData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<String> characterId = GeneratedColumn<String>(
    'character_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES characters (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    characterId,
    title,
    content,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionNoteData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionNoteData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionNoteData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      characterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}character_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SessionNotesTable createAlias(String alias) {
    return $SessionNotesTable(attachedDatabase, alias);
  }
}

class SessionNoteData extends DataClass implements Insertable<SessionNoteData> {
  /// Identificador único da nota (UUID gerado no domínio).
  final String id;

  /// Chave estrangeira para o personagem dono desta nota.
  final String characterId;

  /// Título resumido da anotação.
  final String title;

  /// Corpo completo da anotação.
  final String content;

  /// Momento de criação da nota; armazenado como epoch ms pelo Drift.
  final DateTime createdAt;
  const SessionNoteData({
    required this.id,
    required this.characterId,
    required this.title,
    required this.content,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['character_id'] = Variable<String>(characterId);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SessionNotesCompanion toCompanion(bool nullToAbsent) {
    return SessionNotesCompanion(
      id: Value(id),
      characterId: Value(characterId),
      title: Value(title),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }

  factory SessionNoteData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionNoteData(
      id: serializer.fromJson<String>(json['id']),
      characterId: serializer.fromJson<String>(json['characterId']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'characterId': serializer.toJson<String>(characterId),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SessionNoteData copyWith({
    String? id,
    String? characterId,
    String? title,
    String? content,
    DateTime? createdAt,
  }) => SessionNoteData(
    id: id ?? this.id,
    characterId: characterId ?? this.characterId,
    title: title ?? this.title,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
  );
  SessionNoteData copyWithCompanion(SessionNotesCompanion data) {
    return SessionNoteData(
      id: data.id.present ? data.id.value : this.id,
      characterId: data.characterId.present
          ? data.characterId.value
          : this.characterId,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionNoteData(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, characterId, title, content, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionNoteData &&
          other.id == this.id &&
          other.characterId == this.characterId &&
          other.title == this.title &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class SessionNotesCompanion extends UpdateCompanion<SessionNoteData> {
  final Value<String> id;
  final Value<String> characterId;
  final Value<String> title;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SessionNotesCompanion({
    this.id = const Value.absent(),
    this.characterId = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionNotesCompanion.insert({
    required String id,
    required String characterId,
    required String title,
    required String content,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       characterId = Value(characterId),
       title = Value(title),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<SessionNoteData> custom({
    Expression<String>? id,
    Expression<String>? characterId,
    Expression<String>? title,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (characterId != null) 'character_id': characterId,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionNotesCompanion copyWith({
    Value<String>? id,
    Value<String>? characterId,
    Value<String>? title,
    Value<String>? content,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SessionNotesCompanion(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<String>(characterId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionNotesCompanion(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CharacterSpellsTable extends CharacterSpells
    with TableInfo<$CharacterSpellsTable, CharacterSpellData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacterSpellsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<String> characterId = GeneratedColumn<String>(
    'character_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES characters (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _spellIndexMeta = const VerificationMeta(
    'spellIndex',
  );
  @override
  late final GeneratedColumn<String> spellIndex = GeneratedColumn<String>(
    'spell_index',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preparedMeta = const VerificationMeta(
    'prepared',
  );
  @override
  late final GeneratedColumn<bool> prepared = GeneratedColumn<bool>(
    'prepared',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("prepared" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    characterId,
    spellIndex,
    name,
    level,
    prepared,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'character_spells';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharacterSpellData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('spell_index')) {
      context.handle(
        _spellIndexMeta,
        spellIndex.isAcceptableOrUnknown(data['spell_index']!, _spellIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_spellIndexMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('prepared')) {
      context.handle(
        _preparedMeta,
        prepared.isAcceptableOrUnknown(data['prepared']!, _preparedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CharacterSpellData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterSpellData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      characterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}character_id'],
      )!,
      spellIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spell_index'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      ),
      prepared: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}prepared'],
      )!,
    );
  }

  @override
  $CharacterSpellsTable createAlias(String alias) {
    return $CharacterSpellsTable(attachedDatabase, alias);
  }
}

class CharacterSpellData extends DataClass
    implements Insertable<CharacterSpellData> {
  final String id;
  final String characterId;

  /// Índice da magia na API 5e-bits (ex: `magic-missile`).
  final String spellIndex;
  final String name;

  /// 0 = truque; `null` = nível ainda desconhecido (magias migradas).
  final int? level;
  final bool prepared;
  const CharacterSpellData({
    required this.id,
    required this.characterId,
    required this.spellIndex,
    required this.name,
    this.level,
    required this.prepared,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['character_id'] = Variable<String>(characterId);
    map['spell_index'] = Variable<String>(spellIndex);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || level != null) {
      map['level'] = Variable<int>(level);
    }
    map['prepared'] = Variable<bool>(prepared);
    return map;
  }

  CharacterSpellsCompanion toCompanion(bool nullToAbsent) {
    return CharacterSpellsCompanion(
      id: Value(id),
      characterId: Value(characterId),
      spellIndex: Value(spellIndex),
      name: Value(name),
      level: level == null && nullToAbsent
          ? const Value.absent()
          : Value(level),
      prepared: Value(prepared),
    );
  }

  factory CharacterSpellData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterSpellData(
      id: serializer.fromJson<String>(json['id']),
      characterId: serializer.fromJson<String>(json['characterId']),
      spellIndex: serializer.fromJson<String>(json['spellIndex']),
      name: serializer.fromJson<String>(json['name']),
      level: serializer.fromJson<int?>(json['level']),
      prepared: serializer.fromJson<bool>(json['prepared']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'characterId': serializer.toJson<String>(characterId),
      'spellIndex': serializer.toJson<String>(spellIndex),
      'name': serializer.toJson<String>(name),
      'level': serializer.toJson<int?>(level),
      'prepared': serializer.toJson<bool>(prepared),
    };
  }

  CharacterSpellData copyWith({
    String? id,
    String? characterId,
    String? spellIndex,
    String? name,
    Value<int?> level = const Value.absent(),
    bool? prepared,
  }) => CharacterSpellData(
    id: id ?? this.id,
    characterId: characterId ?? this.characterId,
    spellIndex: spellIndex ?? this.spellIndex,
    name: name ?? this.name,
    level: level.present ? level.value : this.level,
    prepared: prepared ?? this.prepared,
  );
  CharacterSpellData copyWithCompanion(CharacterSpellsCompanion data) {
    return CharacterSpellData(
      id: data.id.present ? data.id.value : this.id,
      characterId: data.characterId.present
          ? data.characterId.value
          : this.characterId,
      spellIndex: data.spellIndex.present
          ? data.spellIndex.value
          : this.spellIndex,
      name: data.name.present ? data.name.value : this.name,
      level: data.level.present ? data.level.value : this.level,
      prepared: data.prepared.present ? data.prepared.value : this.prepared,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterSpellData(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('spellIndex: $spellIndex, ')
          ..write('name: $name, ')
          ..write('level: $level, ')
          ..write('prepared: $prepared')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, characterId, spellIndex, name, level, prepared);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterSpellData &&
          other.id == this.id &&
          other.characterId == this.characterId &&
          other.spellIndex == this.spellIndex &&
          other.name == this.name &&
          other.level == this.level &&
          other.prepared == this.prepared);
}

class CharacterSpellsCompanion extends UpdateCompanion<CharacterSpellData> {
  final Value<String> id;
  final Value<String> characterId;
  final Value<String> spellIndex;
  final Value<String> name;
  final Value<int?> level;
  final Value<bool> prepared;
  final Value<int> rowid;
  const CharacterSpellsCompanion({
    this.id = const Value.absent(),
    this.characterId = const Value.absent(),
    this.spellIndex = const Value.absent(),
    this.name = const Value.absent(),
    this.level = const Value.absent(),
    this.prepared = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CharacterSpellsCompanion.insert({
    required String id,
    required String characterId,
    required String spellIndex,
    required String name,
    this.level = const Value.absent(),
    this.prepared = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       characterId = Value(characterId),
       spellIndex = Value(spellIndex),
       name = Value(name);
  static Insertable<CharacterSpellData> custom({
    Expression<String>? id,
    Expression<String>? characterId,
    Expression<String>? spellIndex,
    Expression<String>? name,
    Expression<int>? level,
    Expression<bool>? prepared,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (characterId != null) 'character_id': characterId,
      if (spellIndex != null) 'spell_index': spellIndex,
      if (name != null) 'name': name,
      if (level != null) 'level': level,
      if (prepared != null) 'prepared': prepared,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CharacterSpellsCompanion copyWith({
    Value<String>? id,
    Value<String>? characterId,
    Value<String>? spellIndex,
    Value<String>? name,
    Value<int?>? level,
    Value<bool>? prepared,
    Value<int>? rowid,
  }) {
    return CharacterSpellsCompanion(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      spellIndex: spellIndex ?? this.spellIndex,
      name: name ?? this.name,
      level: level ?? this.level,
      prepared: prepared ?? this.prepared,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<String>(characterId.value);
    }
    if (spellIndex.present) {
      map['spell_index'] = Variable<String>(spellIndex.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (prepared.present) {
      map['prepared'] = Variable<bool>(prepared.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacterSpellsCompanion(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('spellIndex: $spellIndex, ')
          ..write('name: $name, ')
          ..write('level: $level, ')
          ..write('prepared: $prepared, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ApiCacheTable extends ApiCache
    with TableInfo<$ApiCacheTable, ApiCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApiCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _requestKeyMeta = const VerificationMeta(
    'requestKey',
  );
  @override
  late final GeneratedColumn<String> requestKey = GeneratedColumn<String>(
    'request_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [requestKey, body, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'api_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<ApiCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('request_key')) {
      context.handle(
        _requestKeyMeta,
        requestKey.isAcceptableOrUnknown(data['request_key']!, _requestKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_requestKeyMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {requestKey};
  @override
  ApiCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ApiCacheEntry(
      requestKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_key'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $ApiCacheTable createAlias(String alias) {
    return $ApiCacheTable(attachedDatabase, alias);
  }
}

class ApiCacheEntry extends DataClass implements Insertable<ApiCacheEntry> {
  final String requestKey;
  final String body;
  final DateTime fetchedAt;
  const ApiCacheEntry({
    required this.requestKey,
    required this.body,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['request_key'] = Variable<String>(requestKey);
    map['body'] = Variable<String>(body);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  ApiCacheCompanion toCompanion(bool nullToAbsent) {
    return ApiCacheCompanion(
      requestKey: Value(requestKey),
      body: Value(body),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory ApiCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ApiCacheEntry(
      requestKey: serializer.fromJson<String>(json['requestKey']),
      body: serializer.fromJson<String>(json['body']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'requestKey': serializer.toJson<String>(requestKey),
      'body': serializer.toJson<String>(body),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  ApiCacheEntry copyWith({
    String? requestKey,
    String? body,
    DateTime? fetchedAt,
  }) => ApiCacheEntry(
    requestKey: requestKey ?? this.requestKey,
    body: body ?? this.body,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  ApiCacheEntry copyWithCompanion(ApiCacheCompanion data) {
    return ApiCacheEntry(
      requestKey: data.requestKey.present
          ? data.requestKey.value
          : this.requestKey,
      body: data.body.present ? data.body.value : this.body,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ApiCacheEntry(')
          ..write('requestKey: $requestKey, ')
          ..write('body: $body, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(requestKey, body, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ApiCacheEntry &&
          other.requestKey == this.requestKey &&
          other.body == this.body &&
          other.fetchedAt == this.fetchedAt);
}

class ApiCacheCompanion extends UpdateCompanion<ApiCacheEntry> {
  final Value<String> requestKey;
  final Value<String> body;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const ApiCacheCompanion({
    this.requestKey = const Value.absent(),
    this.body = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ApiCacheCompanion.insert({
    required String requestKey,
    required String body,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : requestKey = Value(requestKey),
       body = Value(body),
       fetchedAt = Value(fetchedAt);
  static Insertable<ApiCacheEntry> custom({
    Expression<String>? requestKey,
    Expression<String>? body,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (requestKey != null) 'request_key': requestKey,
      if (body != null) 'body': body,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApiCacheCompanion copyWith({
    Value<String>? requestKey,
    Value<String>? body,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return ApiCacheCompanion(
      requestKey: requestKey ?? this.requestKey,
      body: body ?? this.body,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (requestKey.present) {
      map['request_key'] = Variable<String>(requestKey.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApiCacheCompanion(')
          ..write('requestKey: $requestKey, ')
          ..write('body: $body, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CharactersTable characters = $CharactersTable(this);
  late final $AttributesTable attributes = $AttributesTable(this);
  late final $InventoryItemsTable inventoryItems = $InventoryItemsTable(this);
  late final $SessionNotesTable sessionNotes = $SessionNotesTable(this);
  late final $CharacterSpellsTable characterSpells = $CharacterSpellsTable(
    this,
  );
  late final $ApiCacheTable apiCache = $ApiCacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    characters,
    attributes,
    inventoryItems,
    sessionNotes,
    characterSpells,
    apiCache,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'characters',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attributes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'characters',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('inventory_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'characters',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_notes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'characters',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('character_spells', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CharactersTableCreateCompanionBuilder =
    CharactersCompanion Function({
      required String id,
      required String nome,
      required String raca,
      required String classe,
      required int nivel,
      Value<int> armorClass,
      Value<int> initiative,
      Value<int> speed,
      required int maxHitPoints,
      required int currentHitPoints,
      Value<int> temporaryHitPoints,
      Value<String?> avatarPath,
      Value<String?> alignment,
      Value<String?> background,
      Value<String?> personalityTraits,
      Value<String?> ideals,
      Value<String?> bonds,
      Value<String?> flaws,
      Value<int> experiencePoints,
      Value<int> proficiencyBonus,
      Value<List<String>> spells,
      Value<List<String>> defeatedBosses,
      Value<List<String>> proficiencies,
      Value<int> armorClassBonus,
      Value<int> hitDiceUsed,
      Value<int> deathSaveSuccesses,
      Value<int> deathSaveFailures,
      Value<List<String>> conditions,
      Value<int> exhaustionLevel,
      Value<bool> inspiration,
      Value<List<int>> spellSlotsUsed,
      Value<int> pactSlotsUsed,
      Value<int> copper,
      Value<int> silver,
      Value<int> electrum,
      Value<int> gold,
      Value<int> platinum,
      Value<List<String>> otherProficiencies,
      Value<List<String>> languages,
      Value<Map<String, int>> resourcesUsed,
      Value<int> rowid,
    });
typedef $$CharactersTableUpdateCompanionBuilder =
    CharactersCompanion Function({
      Value<String> id,
      Value<String> nome,
      Value<String> raca,
      Value<String> classe,
      Value<int> nivel,
      Value<int> armorClass,
      Value<int> initiative,
      Value<int> speed,
      Value<int> maxHitPoints,
      Value<int> currentHitPoints,
      Value<int> temporaryHitPoints,
      Value<String?> avatarPath,
      Value<String?> alignment,
      Value<String?> background,
      Value<String?> personalityTraits,
      Value<String?> ideals,
      Value<String?> bonds,
      Value<String?> flaws,
      Value<int> experiencePoints,
      Value<int> proficiencyBonus,
      Value<List<String>> spells,
      Value<List<String>> defeatedBosses,
      Value<List<String>> proficiencies,
      Value<int> armorClassBonus,
      Value<int> hitDiceUsed,
      Value<int> deathSaveSuccesses,
      Value<int> deathSaveFailures,
      Value<List<String>> conditions,
      Value<int> exhaustionLevel,
      Value<bool> inspiration,
      Value<List<int>> spellSlotsUsed,
      Value<int> pactSlotsUsed,
      Value<int> copper,
      Value<int> silver,
      Value<int> electrum,
      Value<int> gold,
      Value<int> platinum,
      Value<List<String>> otherProficiencies,
      Value<List<String>> languages,
      Value<Map<String, int>> resourcesUsed,
      Value<int> rowid,
    });

final class $$CharactersTableReferences
    extends BaseReferences<_$AppDatabase, $CharactersTable, CharacterData> {
  $$CharactersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AttributesTable, List<AttributeData>>
  _attributesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attributes,
    aliasName: 'characters__id__attributes__character_id',
  );

  $$AttributesTableProcessedTableManager get attributesRefs {
    final manager = $$AttributesTableTableManager(
      $_db,
      $_db.attributes,
    ).filter((f) => f.characterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_attributesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InventoryItemsTable, List<InventoryItemData>>
  _inventoryItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.inventoryItems,
    aliasName: 'characters__id__inventory_items__character_id',
  );

  $$InventoryItemsTableProcessedTableManager get inventoryItemsRefs {
    final manager = $$InventoryItemsTableTableManager(
      $_db,
      $_db.inventoryItems,
    ).filter((f) => f.characterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_inventoryItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionNotesTable, List<SessionNoteData>>
  _sessionNotesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionNotes,
    aliasName: 'characters__id__session_notes__character_id',
  );

  $$SessionNotesTableProcessedTableManager get sessionNotesRefs {
    final manager = $$SessionNotesTableTableManager(
      $_db,
      $_db.sessionNotes,
    ).filter((f) => f.characterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionNotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CharacterSpellsTable, List<CharacterSpellData>>
  _characterSpellsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.characterSpells,
    aliasName: 'characters__id__character_spells__character_id',
  );

  $$CharacterSpellsTableProcessedTableManager get characterSpellsRefs {
    final manager = $$CharacterSpellsTableTableManager(
      $_db,
      $_db.characterSpells,
    ).filter((f) => f.characterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _characterSpellsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CharactersTableFilterComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get raca => $composableBuilder(
    column: $table.raca,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classe => $composableBuilder(
    column: $table.classe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nivel => $composableBuilder(
    column: $table.nivel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get armorClass => $composableBuilder(
    column: $table.armorClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initiative => $composableBuilder(
    column: $table.initiative,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxHitPoints => $composableBuilder(
    column: $table.maxHitPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentHitPoints => $composableBuilder(
    column: $table.currentHitPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get temporaryHitPoints => $composableBuilder(
    column: $table.temporaryHitPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alignment => $composableBuilder(
    column: $table.alignment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get background => $composableBuilder(
    column: $table.background,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personalityTraits => $composableBuilder(
    column: $table.personalityTraits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ideals => $composableBuilder(
    column: $table.ideals,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bonds => $composableBuilder(
    column: $table.bonds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flaws => $composableBuilder(
    column: $table.flaws,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get experiencePoints => $composableBuilder(
    column: $table.experiencePoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get proficiencyBonus => $composableBuilder(
    column: $table.proficiencyBonus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get spells => $composableBuilder(
    column: $table.spells,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get defeatedBosses => $composableBuilder(
    column: $table.defeatedBosses,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get proficiencies => $composableBuilder(
    column: $table.proficiencies,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get armorClassBonus => $composableBuilder(
    column: $table.armorClassBonus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hitDiceUsed => $composableBuilder(
    column: $table.hitDiceUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deathSaveSuccesses => $composableBuilder(
    column: $table.deathSaveSuccesses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deathSaveFailures => $composableBuilder(
    column: $table.deathSaveFailures,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get conditions => $composableBuilder(
    column: $table.conditions,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get exhaustionLevel => $composableBuilder(
    column: $table.exhaustionLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get inspiration => $composableBuilder(
    column: $table.inspiration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<int>, List<int>, String>
  get spellSlotsUsed => $composableBuilder(
    column: $table.spellSlotsUsed,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get pactSlotsUsed => $composableBuilder(
    column: $table.pactSlotsUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get copper => $composableBuilder(
    column: $table.copper,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get silver => $composableBuilder(
    column: $table.silver,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get electrum => $composableBuilder(
    column: $table.electrum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gold => $composableBuilder(
    column: $table.gold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get platinum => $composableBuilder(
    column: $table.platinum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get otherProficiencies => $composableBuilder(
    column: $table.otherProficiencies,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get languages => $composableBuilder(
    column: $table.languages,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Map<String, int>, Map<String, int>, String>
  get resourcesUsed => $composableBuilder(
    column: $table.resourcesUsed,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> attributesRefs(
    Expression<bool> Function($$AttributesTableFilterComposer f) f,
  ) {
    final $$AttributesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attributes,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttributesTableFilterComposer(
            $db: $db,
            $table: $db.attributes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> inventoryItemsRefs(
    Expression<bool> Function($$InventoryItemsTableFilterComposer f) f,
  ) {
    final $$InventoryItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inventoryItems,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryItemsTableFilterComposer(
            $db: $db,
            $table: $db.inventoryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionNotesRefs(
    Expression<bool> Function($$SessionNotesTableFilterComposer f) f,
  ) {
    final $$SessionNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionNotes,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionNotesTableFilterComposer(
            $db: $db,
            $table: $db.sessionNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> characterSpellsRefs(
    Expression<bool> Function($$CharacterSpellsTableFilterComposer f) f,
  ) {
    final $$CharacterSpellsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characterSpells,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacterSpellsTableFilterComposer(
            $db: $db,
            $table: $db.characterSpells,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CharactersTableOrderingComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get raca => $composableBuilder(
    column: $table.raca,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classe => $composableBuilder(
    column: $table.classe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nivel => $composableBuilder(
    column: $table.nivel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get armorClass => $composableBuilder(
    column: $table.armorClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initiative => $composableBuilder(
    column: $table.initiative,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxHitPoints => $composableBuilder(
    column: $table.maxHitPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentHitPoints => $composableBuilder(
    column: $table.currentHitPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get temporaryHitPoints => $composableBuilder(
    column: $table.temporaryHitPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alignment => $composableBuilder(
    column: $table.alignment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get background => $composableBuilder(
    column: $table.background,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personalityTraits => $composableBuilder(
    column: $table.personalityTraits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ideals => $composableBuilder(
    column: $table.ideals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bonds => $composableBuilder(
    column: $table.bonds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flaws => $composableBuilder(
    column: $table.flaws,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get experiencePoints => $composableBuilder(
    column: $table.experiencePoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get proficiencyBonus => $composableBuilder(
    column: $table.proficiencyBonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spells => $composableBuilder(
    column: $table.spells,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defeatedBosses => $composableBuilder(
    column: $table.defeatedBosses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proficiencies => $composableBuilder(
    column: $table.proficiencies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get armorClassBonus => $composableBuilder(
    column: $table.armorClassBonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hitDiceUsed => $composableBuilder(
    column: $table.hitDiceUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deathSaveSuccesses => $composableBuilder(
    column: $table.deathSaveSuccesses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deathSaveFailures => $composableBuilder(
    column: $table.deathSaveFailures,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conditions => $composableBuilder(
    column: $table.conditions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exhaustionLevel => $composableBuilder(
    column: $table.exhaustionLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get inspiration => $composableBuilder(
    column: $table.inspiration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spellSlotsUsed => $composableBuilder(
    column: $table.spellSlotsUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pactSlotsUsed => $composableBuilder(
    column: $table.pactSlotsUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get copper => $composableBuilder(
    column: $table.copper,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get silver => $composableBuilder(
    column: $table.silver,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get electrum => $composableBuilder(
    column: $table.electrum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gold => $composableBuilder(
    column: $table.gold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get platinum => $composableBuilder(
    column: $table.platinum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get otherProficiencies => $composableBuilder(
    column: $table.otherProficiencies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languages => $composableBuilder(
    column: $table.languages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourcesUsed => $composableBuilder(
    column: $table.resourcesUsed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CharactersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get raca =>
      $composableBuilder(column: $table.raca, builder: (column) => column);

  GeneratedColumn<String> get classe =>
      $composableBuilder(column: $table.classe, builder: (column) => column);

  GeneratedColumn<int> get nivel =>
      $composableBuilder(column: $table.nivel, builder: (column) => column);

  GeneratedColumn<int> get armorClass => $composableBuilder(
    column: $table.armorClass,
    builder: (column) => column,
  );

  GeneratedColumn<int> get initiative => $composableBuilder(
    column: $table.initiative,
    builder: (column) => column,
  );

  GeneratedColumn<int> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<int> get maxHitPoints => $composableBuilder(
    column: $table.maxHitPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentHitPoints => $composableBuilder(
    column: $table.currentHitPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get temporaryHitPoints => $composableBuilder(
    column: $table.temporaryHitPoints,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alignment =>
      $composableBuilder(column: $table.alignment, builder: (column) => column);

  GeneratedColumn<String> get background => $composableBuilder(
    column: $table.background,
    builder: (column) => column,
  );

  GeneratedColumn<String> get personalityTraits => $composableBuilder(
    column: $table.personalityTraits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ideals =>
      $composableBuilder(column: $table.ideals, builder: (column) => column);

  GeneratedColumn<String> get bonds =>
      $composableBuilder(column: $table.bonds, builder: (column) => column);

  GeneratedColumn<String> get flaws =>
      $composableBuilder(column: $table.flaws, builder: (column) => column);

  GeneratedColumn<int> get experiencePoints => $composableBuilder(
    column: $table.experiencePoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get proficiencyBonus => $composableBuilder(
    column: $table.proficiencyBonus,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get spells =>
      $composableBuilder(column: $table.spells, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get defeatedBosses =>
      $composableBuilder(
        column: $table.defeatedBosses,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<String>, String> get proficiencies =>
      $composableBuilder(
        column: $table.proficiencies,
        builder: (column) => column,
      );

  GeneratedColumn<int> get armorClassBonus => $composableBuilder(
    column: $table.armorClassBonus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hitDiceUsed => $composableBuilder(
    column: $table.hitDiceUsed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deathSaveSuccesses => $composableBuilder(
    column: $table.deathSaveSuccesses,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deathSaveFailures => $composableBuilder(
    column: $table.deathSaveFailures,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get conditions =>
      $composableBuilder(
        column: $table.conditions,
        builder: (column) => column,
      );

  GeneratedColumn<int> get exhaustionLevel => $composableBuilder(
    column: $table.exhaustionLevel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get inspiration => $composableBuilder(
    column: $table.inspiration,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<int>, String> get spellSlotsUsed =>
      $composableBuilder(
        column: $table.spellSlotsUsed,
        builder: (column) => column,
      );

  GeneratedColumn<int> get pactSlotsUsed => $composableBuilder(
    column: $table.pactSlotsUsed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get copper =>
      $composableBuilder(column: $table.copper, builder: (column) => column);

  GeneratedColumn<int> get silver =>
      $composableBuilder(column: $table.silver, builder: (column) => column);

  GeneratedColumn<int> get electrum =>
      $composableBuilder(column: $table.electrum, builder: (column) => column);

  GeneratedColumn<int> get gold =>
      $composableBuilder(column: $table.gold, builder: (column) => column);

  GeneratedColumn<int> get platinum =>
      $composableBuilder(column: $table.platinum, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String>
  get otherProficiencies => $composableBuilder(
    column: $table.otherProficiencies,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get languages =>
      $composableBuilder(column: $table.languages, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, int>, String>
  get resourcesUsed => $composableBuilder(
    column: $table.resourcesUsed,
    builder: (column) => column,
  );

  Expression<T> attributesRefs<T extends Object>(
    Expression<T> Function($$AttributesTableAnnotationComposer a) f,
  ) {
    final $$AttributesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attributes,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttributesTableAnnotationComposer(
            $db: $db,
            $table: $db.attributes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> inventoryItemsRefs<T extends Object>(
    Expression<T> Function($$InventoryItemsTableAnnotationComposer a) f,
  ) {
    final $$InventoryItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inventoryItems,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.inventoryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionNotesRefs<T extends Object>(
    Expression<T> Function($$SessionNotesTableAnnotationComposer a) f,
  ) {
    final $$SessionNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionNotes,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionNotesTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> characterSpellsRefs<T extends Object>(
    Expression<T> Function($$CharacterSpellsTableAnnotationComposer a) f,
  ) {
    final $$CharacterSpellsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characterSpells,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacterSpellsTableAnnotationComposer(
            $db: $db,
            $table: $db.characterSpells,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CharactersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharactersTable,
          CharacterData,
          $$CharactersTableFilterComposer,
          $$CharactersTableOrderingComposer,
          $$CharactersTableAnnotationComposer,
          $$CharactersTableCreateCompanionBuilder,
          $$CharactersTableUpdateCompanionBuilder,
          (CharacterData, $$CharactersTableReferences),
          CharacterData,
          PrefetchHooks Function({
            bool attributesRefs,
            bool inventoryItemsRefs,
            bool sessionNotesRefs,
            bool characterSpellsRefs,
          })
        > {
  $$CharactersTableTableManager(_$AppDatabase db, $CharactersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharactersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharactersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharactersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String> raca = const Value.absent(),
                Value<String> classe = const Value.absent(),
                Value<int> nivel = const Value.absent(),
                Value<int> armorClass = const Value.absent(),
                Value<int> initiative = const Value.absent(),
                Value<int> speed = const Value.absent(),
                Value<int> maxHitPoints = const Value.absent(),
                Value<int> currentHitPoints = const Value.absent(),
                Value<int> temporaryHitPoints = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<String?> alignment = const Value.absent(),
                Value<String?> background = const Value.absent(),
                Value<String?> personalityTraits = const Value.absent(),
                Value<String?> ideals = const Value.absent(),
                Value<String?> bonds = const Value.absent(),
                Value<String?> flaws = const Value.absent(),
                Value<int> experiencePoints = const Value.absent(),
                Value<int> proficiencyBonus = const Value.absent(),
                Value<List<String>> spells = const Value.absent(),
                Value<List<String>> defeatedBosses = const Value.absent(),
                Value<List<String>> proficiencies = const Value.absent(),
                Value<int> armorClassBonus = const Value.absent(),
                Value<int> hitDiceUsed = const Value.absent(),
                Value<int> deathSaveSuccesses = const Value.absent(),
                Value<int> deathSaveFailures = const Value.absent(),
                Value<List<String>> conditions = const Value.absent(),
                Value<int> exhaustionLevel = const Value.absent(),
                Value<bool> inspiration = const Value.absent(),
                Value<List<int>> spellSlotsUsed = const Value.absent(),
                Value<int> pactSlotsUsed = const Value.absent(),
                Value<int> copper = const Value.absent(),
                Value<int> silver = const Value.absent(),
                Value<int> electrum = const Value.absent(),
                Value<int> gold = const Value.absent(),
                Value<int> platinum = const Value.absent(),
                Value<List<String>> otherProficiencies = const Value.absent(),
                Value<List<String>> languages = const Value.absent(),
                Value<Map<String, int>> resourcesUsed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharactersCompanion(
                id: id,
                nome: nome,
                raca: raca,
                classe: classe,
                nivel: nivel,
                armorClass: armorClass,
                initiative: initiative,
                speed: speed,
                maxHitPoints: maxHitPoints,
                currentHitPoints: currentHitPoints,
                temporaryHitPoints: temporaryHitPoints,
                avatarPath: avatarPath,
                alignment: alignment,
                background: background,
                personalityTraits: personalityTraits,
                ideals: ideals,
                bonds: bonds,
                flaws: flaws,
                experiencePoints: experiencePoints,
                proficiencyBonus: proficiencyBonus,
                spells: spells,
                defeatedBosses: defeatedBosses,
                proficiencies: proficiencies,
                armorClassBonus: armorClassBonus,
                hitDiceUsed: hitDiceUsed,
                deathSaveSuccesses: deathSaveSuccesses,
                deathSaveFailures: deathSaveFailures,
                conditions: conditions,
                exhaustionLevel: exhaustionLevel,
                inspiration: inspiration,
                spellSlotsUsed: spellSlotsUsed,
                pactSlotsUsed: pactSlotsUsed,
                copper: copper,
                silver: silver,
                electrum: electrum,
                gold: gold,
                platinum: platinum,
                otherProficiencies: otherProficiencies,
                languages: languages,
                resourcesUsed: resourcesUsed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nome,
                required String raca,
                required String classe,
                required int nivel,
                Value<int> armorClass = const Value.absent(),
                Value<int> initiative = const Value.absent(),
                Value<int> speed = const Value.absent(),
                required int maxHitPoints,
                required int currentHitPoints,
                Value<int> temporaryHitPoints = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<String?> alignment = const Value.absent(),
                Value<String?> background = const Value.absent(),
                Value<String?> personalityTraits = const Value.absent(),
                Value<String?> ideals = const Value.absent(),
                Value<String?> bonds = const Value.absent(),
                Value<String?> flaws = const Value.absent(),
                Value<int> experiencePoints = const Value.absent(),
                Value<int> proficiencyBonus = const Value.absent(),
                Value<List<String>> spells = const Value.absent(),
                Value<List<String>> defeatedBosses = const Value.absent(),
                Value<List<String>> proficiencies = const Value.absent(),
                Value<int> armorClassBonus = const Value.absent(),
                Value<int> hitDiceUsed = const Value.absent(),
                Value<int> deathSaveSuccesses = const Value.absent(),
                Value<int> deathSaveFailures = const Value.absent(),
                Value<List<String>> conditions = const Value.absent(),
                Value<int> exhaustionLevel = const Value.absent(),
                Value<bool> inspiration = const Value.absent(),
                Value<List<int>> spellSlotsUsed = const Value.absent(),
                Value<int> pactSlotsUsed = const Value.absent(),
                Value<int> copper = const Value.absent(),
                Value<int> silver = const Value.absent(),
                Value<int> electrum = const Value.absent(),
                Value<int> gold = const Value.absent(),
                Value<int> platinum = const Value.absent(),
                Value<List<String>> otherProficiencies = const Value.absent(),
                Value<List<String>> languages = const Value.absent(),
                Value<Map<String, int>> resourcesUsed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharactersCompanion.insert(
                id: id,
                nome: nome,
                raca: raca,
                classe: classe,
                nivel: nivel,
                armorClass: armorClass,
                initiative: initiative,
                speed: speed,
                maxHitPoints: maxHitPoints,
                currentHitPoints: currentHitPoints,
                temporaryHitPoints: temporaryHitPoints,
                avatarPath: avatarPath,
                alignment: alignment,
                background: background,
                personalityTraits: personalityTraits,
                ideals: ideals,
                bonds: bonds,
                flaws: flaws,
                experiencePoints: experiencePoints,
                proficiencyBonus: proficiencyBonus,
                spells: spells,
                defeatedBosses: defeatedBosses,
                proficiencies: proficiencies,
                armorClassBonus: armorClassBonus,
                hitDiceUsed: hitDiceUsed,
                deathSaveSuccesses: deathSaveSuccesses,
                deathSaveFailures: deathSaveFailures,
                conditions: conditions,
                exhaustionLevel: exhaustionLevel,
                inspiration: inspiration,
                spellSlotsUsed: spellSlotsUsed,
                pactSlotsUsed: pactSlotsUsed,
                copper: copper,
                silver: silver,
                electrum: electrum,
                gold: gold,
                platinum: platinum,
                otherProficiencies: otherProficiencies,
                languages: languages,
                resourcesUsed: resourcesUsed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CharactersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                attributesRefs = false,
                inventoryItemsRefs = false,
                sessionNotesRefs = false,
                characterSpellsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (attributesRefs) db.attributes,
                    if (inventoryItemsRefs) db.inventoryItems,
                    if (sessionNotesRefs) db.sessionNotes,
                    if (characterSpellsRefs) db.characterSpells,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (attributesRefs)
                        await $_getPrefetchedData<
                          CharacterData,
                          $CharactersTable,
                          AttributeData
                        >(
                          currentTable: table,
                          referencedTable: $$CharactersTableReferences
                              ._attributesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CharactersTableReferences(
                                db,
                                table,
                                p0,
                              ).attributesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.characterId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (inventoryItemsRefs)
                        await $_getPrefetchedData<
                          CharacterData,
                          $CharactersTable,
                          InventoryItemData
                        >(
                          currentTable: table,
                          referencedTable: $$CharactersTableReferences
                              ._inventoryItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CharactersTableReferences(
                                db,
                                table,
                                p0,
                              ).inventoryItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.characterId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessionNotesRefs)
                        await $_getPrefetchedData<
                          CharacterData,
                          $CharactersTable,
                          SessionNoteData
                        >(
                          currentTable: table,
                          referencedTable: $$CharactersTableReferences
                              ._sessionNotesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CharactersTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionNotesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.characterId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (characterSpellsRefs)
                        await $_getPrefetchedData<
                          CharacterData,
                          $CharactersTable,
                          CharacterSpellData
                        >(
                          currentTable: table,
                          referencedTable: $$CharactersTableReferences
                              ._characterSpellsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CharactersTableReferences(
                                db,
                                table,
                                p0,
                              ).characterSpellsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.characterId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CharactersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharactersTable,
      CharacterData,
      $$CharactersTableFilterComposer,
      $$CharactersTableOrderingComposer,
      $$CharactersTableAnnotationComposer,
      $$CharactersTableCreateCompanionBuilder,
      $$CharactersTableUpdateCompanionBuilder,
      (CharacterData, $$CharactersTableReferences),
      CharacterData,
      PrefetchHooks Function({
        bool attributesRefs,
        bool inventoryItemsRefs,
        bool sessionNotesRefs,
        bool characterSpellsRefs,
      })
    >;
typedef $$AttributesTableCreateCompanionBuilder =
    AttributesCompanion Function({
      required String characterId,
      Value<int> forca,
      Value<int> destreza,
      Value<int> constituicao,
      Value<int> inteligencia,
      Value<int> sabedoria,
      Value<int> carisma,
      Value<int> rowid,
    });
typedef $$AttributesTableUpdateCompanionBuilder =
    AttributesCompanion Function({
      Value<String> characterId,
      Value<int> forca,
      Value<int> destreza,
      Value<int> constituicao,
      Value<int> inteligencia,
      Value<int> sabedoria,
      Value<int> carisma,
      Value<int> rowid,
    });

final class $$AttributesTableReferences
    extends BaseReferences<_$AppDatabase, $AttributesTable, AttributeData> {
  $$AttributesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CharactersTable _characterIdTable(_$AppDatabase db) =>
      db.characters.createAlias('attributes__character_id__characters__id');

  $$CharactersTableProcessedTableManager get characterId {
    final $_column = $_itemColumn<String>('character_id')!;

    final manager = $$CharactersTableTableManager(
      $_db,
      $_db.characters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_characterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttributesTableFilterComposer
    extends Composer<_$AppDatabase, $AttributesTable> {
  $$AttributesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get forca => $composableBuilder(
    column: $table.forca,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get destreza => $composableBuilder(
    column: $table.destreza,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get constituicao => $composableBuilder(
    column: $table.constituicao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inteligencia => $composableBuilder(
    column: $table.inteligencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sabedoria => $composableBuilder(
    column: $table.sabedoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get carisma => $composableBuilder(
    column: $table.carisma,
    builder: (column) => ColumnFilters(column),
  );

  $$CharactersTableFilterComposer get characterId {
    final $$CharactersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableFilterComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttributesTableOrderingComposer
    extends Composer<_$AppDatabase, $AttributesTable> {
  $$AttributesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get forca => $composableBuilder(
    column: $table.forca,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get destreza => $composableBuilder(
    column: $table.destreza,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get constituicao => $composableBuilder(
    column: $table.constituicao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inteligencia => $composableBuilder(
    column: $table.inteligencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sabedoria => $composableBuilder(
    column: $table.sabedoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get carisma => $composableBuilder(
    column: $table.carisma,
    builder: (column) => ColumnOrderings(column),
  );

  $$CharactersTableOrderingComposer get characterId {
    final $$CharactersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableOrderingComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttributesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttributesTable> {
  $$AttributesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get forca =>
      $composableBuilder(column: $table.forca, builder: (column) => column);

  GeneratedColumn<int> get destreza =>
      $composableBuilder(column: $table.destreza, builder: (column) => column);

  GeneratedColumn<int> get constituicao => $composableBuilder(
    column: $table.constituicao,
    builder: (column) => column,
  );

  GeneratedColumn<int> get inteligencia => $composableBuilder(
    column: $table.inteligencia,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sabedoria =>
      $composableBuilder(column: $table.sabedoria, builder: (column) => column);

  GeneratedColumn<int> get carisma =>
      $composableBuilder(column: $table.carisma, builder: (column) => column);

  $$CharactersTableAnnotationComposer get characterId {
    final $$CharactersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableAnnotationComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttributesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttributesTable,
          AttributeData,
          $$AttributesTableFilterComposer,
          $$AttributesTableOrderingComposer,
          $$AttributesTableAnnotationComposer,
          $$AttributesTableCreateCompanionBuilder,
          $$AttributesTableUpdateCompanionBuilder,
          (AttributeData, $$AttributesTableReferences),
          AttributeData,
          PrefetchHooks Function({bool characterId})
        > {
  $$AttributesTableTableManager(_$AppDatabase db, $AttributesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttributesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttributesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttributesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> characterId = const Value.absent(),
                Value<int> forca = const Value.absent(),
                Value<int> destreza = const Value.absent(),
                Value<int> constituicao = const Value.absent(),
                Value<int> inteligencia = const Value.absent(),
                Value<int> sabedoria = const Value.absent(),
                Value<int> carisma = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttributesCompanion(
                characterId: characterId,
                forca: forca,
                destreza: destreza,
                constituicao: constituicao,
                inteligencia: inteligencia,
                sabedoria: sabedoria,
                carisma: carisma,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String characterId,
                Value<int> forca = const Value.absent(),
                Value<int> destreza = const Value.absent(),
                Value<int> constituicao = const Value.absent(),
                Value<int> inteligencia = const Value.absent(),
                Value<int> sabedoria = const Value.absent(),
                Value<int> carisma = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttributesCompanion.insert(
                characterId: characterId,
                forca: forca,
                destreza: destreza,
                constituicao: constituicao,
                inteligencia: inteligencia,
                sabedoria: sabedoria,
                carisma: carisma,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttributesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({characterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (characterId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.characterId,
                                referencedTable: $$AttributesTableReferences
                                    ._characterIdTable(db),
                                referencedColumn: $$AttributesTableReferences
                                    ._characterIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AttributesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttributesTable,
      AttributeData,
      $$AttributesTableFilterComposer,
      $$AttributesTableOrderingComposer,
      $$AttributesTableAnnotationComposer,
      $$AttributesTableCreateCompanionBuilder,
      $$AttributesTableUpdateCompanionBuilder,
      (AttributeData, $$AttributesTableReferences),
      AttributeData,
      PrefetchHooks Function({bool characterId})
    >;
typedef $$InventoryItemsTableCreateCompanionBuilder =
    InventoryItemsCompanion Function({
      required String id,
      required String characterId,
      required String itemIndex,
      required String name,
      required String equipmentCategory,
      Value<int> quantity,
      Value<double> weight,
      Value<bool> equipped,
      Value<bool> requiresAttunement,
      Value<bool> attuned,
      Value<bool> detailsLoaded,
      Value<String?> armorCategory,
      Value<int?> armorBase,
      Value<bool> armorDexBonus,
      Value<int?> armorMaxDexBonus,
      Value<String?> weaponCategory,
      Value<String?> weaponRange,
      Value<String?> damageDice,
      Value<String?> damageType,
      Value<String?> versatileDamageDice,
      Value<List<String>> weaponProperties,
      Value<int> rowid,
    });
typedef $$InventoryItemsTableUpdateCompanionBuilder =
    InventoryItemsCompanion Function({
      Value<String> id,
      Value<String> characterId,
      Value<String> itemIndex,
      Value<String> name,
      Value<String> equipmentCategory,
      Value<int> quantity,
      Value<double> weight,
      Value<bool> equipped,
      Value<bool> requiresAttunement,
      Value<bool> attuned,
      Value<bool> detailsLoaded,
      Value<String?> armorCategory,
      Value<int?> armorBase,
      Value<bool> armorDexBonus,
      Value<int?> armorMaxDexBonus,
      Value<String?> weaponCategory,
      Value<String?> weaponRange,
      Value<String?> damageDice,
      Value<String?> damageType,
      Value<String?> versatileDamageDice,
      Value<List<String>> weaponProperties,
      Value<int> rowid,
    });

final class $$InventoryItemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $InventoryItemsTable, InventoryItemData> {
  $$InventoryItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CharactersTable _characterIdTable(_$AppDatabase db) => db.characters
      .createAlias('inventory_items__character_id__characters__id');

  $$CharactersTableProcessedTableManager get characterId {
    final $_column = $_itemColumn<String>('character_id')!;

    final manager = $$CharactersTableTableManager(
      $_db,
      $_db.characters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_characterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InventoryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemIndex => $composableBuilder(
    column: $table.itemIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipmentCategory => $composableBuilder(
    column: $table.equipmentCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get equipped => $composableBuilder(
    column: $table.equipped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requiresAttunement => $composableBuilder(
    column: $table.requiresAttunement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get attuned => $composableBuilder(
    column: $table.attuned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get detailsLoaded => $composableBuilder(
    column: $table.detailsLoaded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get armorCategory => $composableBuilder(
    column: $table.armorCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get armorBase => $composableBuilder(
    column: $table.armorBase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get armorDexBonus => $composableBuilder(
    column: $table.armorDexBonus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get armorMaxDexBonus => $composableBuilder(
    column: $table.armorMaxDexBonus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weaponCategory => $composableBuilder(
    column: $table.weaponCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weaponRange => $composableBuilder(
    column: $table.weaponRange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get damageDice => $composableBuilder(
    column: $table.damageDice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get damageType => $composableBuilder(
    column: $table.damageType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get versatileDamageDice => $composableBuilder(
    column: $table.versatileDamageDice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get weaponProperties => $composableBuilder(
    column: $table.weaponProperties,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$CharactersTableFilterComposer get characterId {
    final $$CharactersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableFilterComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemIndex => $composableBuilder(
    column: $table.itemIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipmentCategory => $composableBuilder(
    column: $table.equipmentCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get equipped => $composableBuilder(
    column: $table.equipped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requiresAttunement => $composableBuilder(
    column: $table.requiresAttunement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get attuned => $composableBuilder(
    column: $table.attuned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get detailsLoaded => $composableBuilder(
    column: $table.detailsLoaded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get armorCategory => $composableBuilder(
    column: $table.armorCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get armorBase => $composableBuilder(
    column: $table.armorBase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get armorDexBonus => $composableBuilder(
    column: $table.armorDexBonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get armorMaxDexBonus => $composableBuilder(
    column: $table.armorMaxDexBonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weaponCategory => $composableBuilder(
    column: $table.weaponCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weaponRange => $composableBuilder(
    column: $table.weaponRange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get damageDice => $composableBuilder(
    column: $table.damageDice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get damageType => $composableBuilder(
    column: $table.damageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get versatileDamageDice => $composableBuilder(
    column: $table.versatileDamageDice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weaponProperties => $composableBuilder(
    column: $table.weaponProperties,
    builder: (column) => ColumnOrderings(column),
  );

  $$CharactersTableOrderingComposer get characterId {
    final $$CharactersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableOrderingComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemIndex =>
      $composableBuilder(column: $table.itemIndex, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get equipmentCategory => $composableBuilder(
    column: $table.equipmentCategory,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<bool> get equipped =>
      $composableBuilder(column: $table.equipped, builder: (column) => column);

  GeneratedColumn<bool> get requiresAttunement => $composableBuilder(
    column: $table.requiresAttunement,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get attuned =>
      $composableBuilder(column: $table.attuned, builder: (column) => column);

  GeneratedColumn<bool> get detailsLoaded => $composableBuilder(
    column: $table.detailsLoaded,
    builder: (column) => column,
  );

  GeneratedColumn<String> get armorCategory => $composableBuilder(
    column: $table.armorCategory,
    builder: (column) => column,
  );

  GeneratedColumn<int> get armorBase =>
      $composableBuilder(column: $table.armorBase, builder: (column) => column);

  GeneratedColumn<bool> get armorDexBonus => $composableBuilder(
    column: $table.armorDexBonus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get armorMaxDexBonus => $composableBuilder(
    column: $table.armorMaxDexBonus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weaponCategory => $composableBuilder(
    column: $table.weaponCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weaponRange => $composableBuilder(
    column: $table.weaponRange,
    builder: (column) => column,
  );

  GeneratedColumn<String> get damageDice => $composableBuilder(
    column: $table.damageDice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get damageType => $composableBuilder(
    column: $table.damageType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get versatileDamageDice => $composableBuilder(
    column: $table.versatileDamageDice,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get weaponProperties =>
      $composableBuilder(
        column: $table.weaponProperties,
        builder: (column) => column,
      );

  $$CharactersTableAnnotationComposer get characterId {
    final $$CharactersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableAnnotationComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InventoryItemsTable,
          InventoryItemData,
          $$InventoryItemsTableFilterComposer,
          $$InventoryItemsTableOrderingComposer,
          $$InventoryItemsTableAnnotationComposer,
          $$InventoryItemsTableCreateCompanionBuilder,
          $$InventoryItemsTableUpdateCompanionBuilder,
          (InventoryItemData, $$InventoryItemsTableReferences),
          InventoryItemData,
          PrefetchHooks Function({bool characterId})
        > {
  $$InventoryItemsTableTableManager(
    _$AppDatabase db,
    $InventoryItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> characterId = const Value.absent(),
                Value<String> itemIndex = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> equipmentCategory = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<bool> equipped = const Value.absent(),
                Value<bool> requiresAttunement = const Value.absent(),
                Value<bool> attuned = const Value.absent(),
                Value<bool> detailsLoaded = const Value.absent(),
                Value<String?> armorCategory = const Value.absent(),
                Value<int?> armorBase = const Value.absent(),
                Value<bool> armorDexBonus = const Value.absent(),
                Value<int?> armorMaxDexBonus = const Value.absent(),
                Value<String?> weaponCategory = const Value.absent(),
                Value<String?> weaponRange = const Value.absent(),
                Value<String?> damageDice = const Value.absent(),
                Value<String?> damageType = const Value.absent(),
                Value<String?> versatileDamageDice = const Value.absent(),
                Value<List<String>> weaponProperties = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryItemsCompanion(
                id: id,
                characterId: characterId,
                itemIndex: itemIndex,
                name: name,
                equipmentCategory: equipmentCategory,
                quantity: quantity,
                weight: weight,
                equipped: equipped,
                requiresAttunement: requiresAttunement,
                attuned: attuned,
                detailsLoaded: detailsLoaded,
                armorCategory: armorCategory,
                armorBase: armorBase,
                armorDexBonus: armorDexBonus,
                armorMaxDexBonus: armorMaxDexBonus,
                weaponCategory: weaponCategory,
                weaponRange: weaponRange,
                damageDice: damageDice,
                damageType: damageType,
                versatileDamageDice: versatileDamageDice,
                weaponProperties: weaponProperties,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String characterId,
                required String itemIndex,
                required String name,
                required String equipmentCategory,
                Value<int> quantity = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<bool> equipped = const Value.absent(),
                Value<bool> requiresAttunement = const Value.absent(),
                Value<bool> attuned = const Value.absent(),
                Value<bool> detailsLoaded = const Value.absent(),
                Value<String?> armorCategory = const Value.absent(),
                Value<int?> armorBase = const Value.absent(),
                Value<bool> armorDexBonus = const Value.absent(),
                Value<int?> armorMaxDexBonus = const Value.absent(),
                Value<String?> weaponCategory = const Value.absent(),
                Value<String?> weaponRange = const Value.absent(),
                Value<String?> damageDice = const Value.absent(),
                Value<String?> damageType = const Value.absent(),
                Value<String?> versatileDamageDice = const Value.absent(),
                Value<List<String>> weaponProperties = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryItemsCompanion.insert(
                id: id,
                characterId: characterId,
                itemIndex: itemIndex,
                name: name,
                equipmentCategory: equipmentCategory,
                quantity: quantity,
                weight: weight,
                equipped: equipped,
                requiresAttunement: requiresAttunement,
                attuned: attuned,
                detailsLoaded: detailsLoaded,
                armorCategory: armorCategory,
                armorBase: armorBase,
                armorDexBonus: armorDexBonus,
                armorMaxDexBonus: armorMaxDexBonus,
                weaponCategory: weaponCategory,
                weaponRange: weaponRange,
                damageDice: damageDice,
                damageType: damageType,
                versatileDamageDice: versatileDamageDice,
                weaponProperties: weaponProperties,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InventoryItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({characterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (characterId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.characterId,
                                referencedTable: $$InventoryItemsTableReferences
                                    ._characterIdTable(db),
                                referencedColumn:
                                    $$InventoryItemsTableReferences
                                        ._characterIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InventoryItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InventoryItemsTable,
      InventoryItemData,
      $$InventoryItemsTableFilterComposer,
      $$InventoryItemsTableOrderingComposer,
      $$InventoryItemsTableAnnotationComposer,
      $$InventoryItemsTableCreateCompanionBuilder,
      $$InventoryItemsTableUpdateCompanionBuilder,
      (InventoryItemData, $$InventoryItemsTableReferences),
      InventoryItemData,
      PrefetchHooks Function({bool characterId})
    >;
typedef $$SessionNotesTableCreateCompanionBuilder =
    SessionNotesCompanion Function({
      required String id,
      required String characterId,
      required String title,
      required String content,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SessionNotesTableUpdateCompanionBuilder =
    SessionNotesCompanion Function({
      Value<String> id,
      Value<String> characterId,
      Value<String> title,
      Value<String> content,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$SessionNotesTableReferences
    extends BaseReferences<_$AppDatabase, $SessionNotesTable, SessionNoteData> {
  $$SessionNotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CharactersTable _characterIdTable(_$AppDatabase db) =>
      db.characters.createAlias('session_notes__character_id__characters__id');

  $$CharactersTableProcessedTableManager get characterId {
    final $_column = $_itemColumn<String>('character_id')!;

    final manager = $$CharactersTableTableManager(
      $_db,
      $_db.characters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_characterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionNotesTableFilterComposer
    extends Composer<_$AppDatabase, $SessionNotesTable> {
  $$SessionNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CharactersTableFilterComposer get characterId {
    final $$CharactersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableFilterComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionNotesTable> {
  $$SessionNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CharactersTableOrderingComposer get characterId {
    final $$CharactersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableOrderingComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionNotesTable> {
  $$SessionNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CharactersTableAnnotationComposer get characterId {
    final $$CharactersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableAnnotationComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionNotesTable,
          SessionNoteData,
          $$SessionNotesTableFilterComposer,
          $$SessionNotesTableOrderingComposer,
          $$SessionNotesTableAnnotationComposer,
          $$SessionNotesTableCreateCompanionBuilder,
          $$SessionNotesTableUpdateCompanionBuilder,
          (SessionNoteData, $$SessionNotesTableReferences),
          SessionNoteData,
          PrefetchHooks Function({bool characterId})
        > {
  $$SessionNotesTableTableManager(_$AppDatabase db, $SessionNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> characterId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionNotesCompanion(
                id: id,
                characterId: characterId,
                title: title,
                content: content,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String characterId,
                required String title,
                required String content,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionNotesCompanion.insert(
                id: id,
                characterId: characterId,
                title: title,
                content: content,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionNotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({characterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (characterId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.characterId,
                                referencedTable: $$SessionNotesTableReferences
                                    ._characterIdTable(db),
                                referencedColumn: $$SessionNotesTableReferences
                                    ._characterIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessionNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionNotesTable,
      SessionNoteData,
      $$SessionNotesTableFilterComposer,
      $$SessionNotesTableOrderingComposer,
      $$SessionNotesTableAnnotationComposer,
      $$SessionNotesTableCreateCompanionBuilder,
      $$SessionNotesTableUpdateCompanionBuilder,
      (SessionNoteData, $$SessionNotesTableReferences),
      SessionNoteData,
      PrefetchHooks Function({bool characterId})
    >;
typedef $$CharacterSpellsTableCreateCompanionBuilder =
    CharacterSpellsCompanion Function({
      required String id,
      required String characterId,
      required String spellIndex,
      required String name,
      Value<int?> level,
      Value<bool> prepared,
      Value<int> rowid,
    });
typedef $$CharacterSpellsTableUpdateCompanionBuilder =
    CharacterSpellsCompanion Function({
      Value<String> id,
      Value<String> characterId,
      Value<String> spellIndex,
      Value<String> name,
      Value<int?> level,
      Value<bool> prepared,
      Value<int> rowid,
    });

final class $$CharacterSpellsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CharacterSpellsTable,
          CharacterSpellData
        > {
  $$CharacterSpellsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CharactersTable _characterIdTable(_$AppDatabase db) => db.characters
      .createAlias('character_spells__character_id__characters__id');

  $$CharactersTableProcessedTableManager get characterId {
    final $_column = $_itemColumn<String>('character_id')!;

    final manager = $$CharactersTableTableManager(
      $_db,
      $_db.characters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_characterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CharacterSpellsTableFilterComposer
    extends Composer<_$AppDatabase, $CharacterSpellsTable> {
  $$CharacterSpellsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spellIndex => $composableBuilder(
    column: $table.spellIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get prepared => $composableBuilder(
    column: $table.prepared,
    builder: (column) => ColumnFilters(column),
  );

  $$CharactersTableFilterComposer get characterId {
    final $$CharactersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableFilterComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterSpellsTableOrderingComposer
    extends Composer<_$AppDatabase, $CharacterSpellsTable> {
  $$CharacterSpellsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spellIndex => $composableBuilder(
    column: $table.spellIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get prepared => $composableBuilder(
    column: $table.prepared,
    builder: (column) => ColumnOrderings(column),
  );

  $$CharactersTableOrderingComposer get characterId {
    final $$CharactersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableOrderingComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterSpellsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharacterSpellsTable> {
  $$CharacterSpellsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get spellIndex => $composableBuilder(
    column: $table.spellIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<bool> get prepared =>
      $composableBuilder(column: $table.prepared, builder: (column) => column);

  $$CharactersTableAnnotationComposer get characterId {
    final $$CharactersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableAnnotationComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterSpellsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharacterSpellsTable,
          CharacterSpellData,
          $$CharacterSpellsTableFilterComposer,
          $$CharacterSpellsTableOrderingComposer,
          $$CharacterSpellsTableAnnotationComposer,
          $$CharacterSpellsTableCreateCompanionBuilder,
          $$CharacterSpellsTableUpdateCompanionBuilder,
          (CharacterSpellData, $$CharacterSpellsTableReferences),
          CharacterSpellData,
          PrefetchHooks Function({bool characterId})
        > {
  $$CharacterSpellsTableTableManager(
    _$AppDatabase db,
    $CharacterSpellsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharacterSpellsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharacterSpellsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharacterSpellsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> characterId = const Value.absent(),
                Value<String> spellIndex = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> level = const Value.absent(),
                Value<bool> prepared = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharacterSpellsCompanion(
                id: id,
                characterId: characterId,
                spellIndex: spellIndex,
                name: name,
                level: level,
                prepared: prepared,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String characterId,
                required String spellIndex,
                required String name,
                Value<int?> level = const Value.absent(),
                Value<bool> prepared = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharacterSpellsCompanion.insert(
                id: id,
                characterId: characterId,
                spellIndex: spellIndex,
                name: name,
                level: level,
                prepared: prepared,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CharacterSpellsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({characterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (characterId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.characterId,
                                referencedTable:
                                    $$CharacterSpellsTableReferences
                                        ._characterIdTable(db),
                                referencedColumn:
                                    $$CharacterSpellsTableReferences
                                        ._characterIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CharacterSpellsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharacterSpellsTable,
      CharacterSpellData,
      $$CharacterSpellsTableFilterComposer,
      $$CharacterSpellsTableOrderingComposer,
      $$CharacterSpellsTableAnnotationComposer,
      $$CharacterSpellsTableCreateCompanionBuilder,
      $$CharacterSpellsTableUpdateCompanionBuilder,
      (CharacterSpellData, $$CharacterSpellsTableReferences),
      CharacterSpellData,
      PrefetchHooks Function({bool characterId})
    >;
typedef $$ApiCacheTableCreateCompanionBuilder =
    ApiCacheCompanion Function({
      required String requestKey,
      required String body,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$ApiCacheTableUpdateCompanionBuilder =
    ApiCacheCompanion Function({
      Value<String> requestKey,
      Value<String> body,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$ApiCacheTableFilterComposer
    extends Composer<_$AppDatabase, $ApiCacheTable> {
  $$ApiCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get requestKey => $composableBuilder(
    column: $table.requestKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ApiCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $ApiCacheTable> {
  $$ApiCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get requestKey => $composableBuilder(
    column: $table.requestKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ApiCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $ApiCacheTable> {
  $$ApiCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get requestKey => $composableBuilder(
    column: $table.requestKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$ApiCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ApiCacheTable,
          ApiCacheEntry,
          $$ApiCacheTableFilterComposer,
          $$ApiCacheTableOrderingComposer,
          $$ApiCacheTableAnnotationComposer,
          $$ApiCacheTableCreateCompanionBuilder,
          $$ApiCacheTableUpdateCompanionBuilder,
          (
            ApiCacheEntry,
            BaseReferences<_$AppDatabase, $ApiCacheTable, ApiCacheEntry>,
          ),
          ApiCacheEntry,
          PrefetchHooks Function()
        > {
  $$ApiCacheTableTableManager(_$AppDatabase db, $ApiCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApiCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApiCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ApiCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> requestKey = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApiCacheCompanion(
                requestKey: requestKey,
                body: body,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String requestKey,
                required String body,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => ApiCacheCompanion.insert(
                requestKey: requestKey,
                body: body,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ApiCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ApiCacheTable,
      ApiCacheEntry,
      $$ApiCacheTableFilterComposer,
      $$ApiCacheTableOrderingComposer,
      $$ApiCacheTableAnnotationComposer,
      $$ApiCacheTableCreateCompanionBuilder,
      $$ApiCacheTableUpdateCompanionBuilder,
      (
        ApiCacheEntry,
        BaseReferences<_$AppDatabase, $ApiCacheTable, ApiCacheEntry>,
      ),
      ApiCacheEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CharactersTableTableManager get characters =>
      $$CharactersTableTableManager(_db, _db.characters);
  $$AttributesTableTableManager get attributes =>
      $$AttributesTableTableManager(_db, _db.attributes);
  $$InventoryItemsTableTableManager get inventoryItems =>
      $$InventoryItemsTableTableManager(_db, _db.inventoryItems);
  $$SessionNotesTableTableManager get sessionNotes =>
      $$SessionNotesTableTableManager(_db, _db.sessionNotes);
  $$CharacterSpellsTableTableManager get characterSpells =>
      $$CharacterSpellsTableTableManager(_db, _db.characterSpells);
  $$ApiCacheTableTableManager get apiCache =>
      $$ApiCacheTableTableManager(_db, _db.apiCache);
}
