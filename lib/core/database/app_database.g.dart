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
  static const VerificationMeta _hpMaximoMeta = const VerificationMeta(
    'hpMaximo',
  );
  @override
  late final GeneratedColumn<int> hpMaximo = GeneratedColumn<int>(
    'hp_maximo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hpAtualMeta = const VerificationMeta(
    'hpAtual',
  );
  @override
  late final GeneratedColumn<int> hpAtual = GeneratedColumn<int>(
    'hp_atual',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    raca,
    classe,
    nivel,
    hpMaximo,
    hpAtual,
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
    if (data.containsKey('hp_maximo')) {
      context.handle(
        _hpMaximoMeta,
        hpMaximo.isAcceptableOrUnknown(data['hp_maximo']!, _hpMaximoMeta),
      );
    } else if (isInserting) {
      context.missing(_hpMaximoMeta);
    }
    if (data.containsKey('hp_atual')) {
      context.handle(
        _hpAtualMeta,
        hpAtual.isAcceptableOrUnknown(data['hp_atual']!, _hpAtualMeta),
      );
    } else if (isInserting) {
      context.missing(_hpAtualMeta);
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
      hpMaximo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hp_maximo'],
      )!,
      hpAtual: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hp_atual'],
      )!,
    );
  }

  @override
  $CharactersTable createAlias(String alias) {
    return $CharactersTable(attachedDatabase, alias);
  }
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

  /// Pontos de vida máximos.
  final int hpMaximo;

  /// Pontos de vida atuais.
  final int hpAtual;
  const CharacterData({
    required this.id,
    required this.nome,
    required this.raca,
    required this.classe,
    required this.nivel,
    required this.hpMaximo,
    required this.hpAtual,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nome'] = Variable<String>(nome);
    map['raca'] = Variable<String>(raca);
    map['classe'] = Variable<String>(classe);
    map['nivel'] = Variable<int>(nivel);
    map['hp_maximo'] = Variable<int>(hpMaximo);
    map['hp_atual'] = Variable<int>(hpAtual);
    return map;
  }

  CharactersCompanion toCompanion(bool nullToAbsent) {
    return CharactersCompanion(
      id: Value(id),
      nome: Value(nome),
      raca: Value(raca),
      classe: Value(classe),
      nivel: Value(nivel),
      hpMaximo: Value(hpMaximo),
      hpAtual: Value(hpAtual),
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
      hpMaximo: serializer.fromJson<int>(json['hpMaximo']),
      hpAtual: serializer.fromJson<int>(json['hpAtual']),
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
      'hpMaximo': serializer.toJson<int>(hpMaximo),
      'hpAtual': serializer.toJson<int>(hpAtual),
    };
  }

  CharacterData copyWith({
    String? id,
    String? nome,
    String? raca,
    String? classe,
    int? nivel,
    int? hpMaximo,
    int? hpAtual,
  }) => CharacterData(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    raca: raca ?? this.raca,
    classe: classe ?? this.classe,
    nivel: nivel ?? this.nivel,
    hpMaximo: hpMaximo ?? this.hpMaximo,
    hpAtual: hpAtual ?? this.hpAtual,
  );
  CharacterData copyWithCompanion(CharactersCompanion data) {
    return CharacterData(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      raca: data.raca.present ? data.raca.value : this.raca,
      classe: data.classe.present ? data.classe.value : this.classe,
      nivel: data.nivel.present ? data.nivel.value : this.nivel,
      hpMaximo: data.hpMaximo.present ? data.hpMaximo.value : this.hpMaximo,
      hpAtual: data.hpAtual.present ? data.hpAtual.value : this.hpAtual,
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
          ..write('hpMaximo: $hpMaximo, ')
          ..write('hpAtual: $hpAtual')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nome, raca, classe, nivel, hpMaximo, hpAtual);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterData &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.raca == this.raca &&
          other.classe == this.classe &&
          other.nivel == this.nivel &&
          other.hpMaximo == this.hpMaximo &&
          other.hpAtual == this.hpAtual);
}

class CharactersCompanion extends UpdateCompanion<CharacterData> {
  final Value<String> id;
  final Value<String> nome;
  final Value<String> raca;
  final Value<String> classe;
  final Value<int> nivel;
  final Value<int> hpMaximo;
  final Value<int> hpAtual;
  final Value<int> rowid;
  const CharactersCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.raca = const Value.absent(),
    this.classe = const Value.absent(),
    this.nivel = const Value.absent(),
    this.hpMaximo = const Value.absent(),
    this.hpAtual = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CharactersCompanion.insert({
    required String id,
    required String nome,
    required String raca,
    required String classe,
    required int nivel,
    required int hpMaximo,
    required int hpAtual,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nome = Value(nome),
       raca = Value(raca),
       classe = Value(classe),
       nivel = Value(nivel),
       hpMaximo = Value(hpMaximo),
       hpAtual = Value(hpAtual);
  static Insertable<CharacterData> custom({
    Expression<String>? id,
    Expression<String>? nome,
    Expression<String>? raca,
    Expression<String>? classe,
    Expression<int>? nivel,
    Expression<int>? hpMaximo,
    Expression<int>? hpAtual,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (raca != null) 'raca': raca,
      if (classe != null) 'classe': classe,
      if (nivel != null) 'nivel': nivel,
      if (hpMaximo != null) 'hp_maximo': hpMaximo,
      if (hpAtual != null) 'hp_atual': hpAtual,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CharactersCompanion copyWith({
    Value<String>? id,
    Value<String>? nome,
    Value<String>? raca,
    Value<String>? classe,
    Value<int>? nivel,
    Value<int>? hpMaximo,
    Value<int>? hpAtual,
    Value<int>? rowid,
  }) {
    return CharactersCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      raca: raca ?? this.raca,
      classe: classe ?? this.classe,
      nivel: nivel ?? this.nivel,
      hpMaximo: hpMaximo ?? this.hpMaximo,
      hpAtual: hpAtual ?? this.hpAtual,
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
    if (hpMaximo.present) {
      map['hp_maximo'] = Variable<int>(hpMaximo.value);
    }
    if (hpAtual.present) {
      map['hp_atual'] = Variable<int>(hpAtual.value);
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
          ..write('hpMaximo: $hpMaximo, ')
          ..write('hpAtual: $hpAtual, ')
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
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
    } else if (isInserting) {
      context.missing(_forcaMeta);
    }
    if (data.containsKey('destreza')) {
      context.handle(
        _destrezaMeta,
        destreza.isAcceptableOrUnknown(data['destreza']!, _destrezaMeta),
      );
    } else if (isInserting) {
      context.missing(_destrezaMeta);
    }
    if (data.containsKey('constituicao')) {
      context.handle(
        _constituicaoMeta,
        constituicao.isAcceptableOrUnknown(
          data['constituicao']!,
          _constituicaoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_constituicaoMeta);
    }
    if (data.containsKey('inteligencia')) {
      context.handle(
        _inteligenciaMeta,
        inteligencia.isAcceptableOrUnknown(
          data['inteligencia']!,
          _inteligenciaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inteligenciaMeta);
    }
    if (data.containsKey('sabedoria')) {
      context.handle(
        _sabedoriaMeta,
        sabedoria.isAcceptableOrUnknown(data['sabedoria']!, _sabedoriaMeta),
      );
    } else if (isInserting) {
      context.missing(_sabedoriaMeta);
    }
    if (data.containsKey('carisma')) {
      context.handle(
        _carismaMeta,
        carisma.isAcceptableOrUnknown(data['carisma']!, _carismaMeta),
      );
    } else if (isInserting) {
      context.missing(_carismaMeta);
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
    required int forca,
    required int destreza,
    required int constituicao,
    required int inteligencia,
    required int sabedoria,
    required int carisma,
    this.rowid = const Value.absent(),
  }) : characterId = Value(characterId),
       forca = Value(forca),
       destreza = Value(destreza),
       constituicao = Value(constituicao),
       inteligencia = Value(inteligencia),
       sabedoria = Value(sabedoria),
       carisma = Value(carisma);
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CharactersTable characters = $CharactersTable(this);
  late final $AttributesTable attributes = $AttributesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [characters, attributes];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'characters',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attributes', kind: UpdateKind.delete)],
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
      required int hpMaximo,
      required int hpAtual,
      Value<int> rowid,
    });
typedef $$CharactersTableUpdateCompanionBuilder =
    CharactersCompanion Function({
      Value<String> id,
      Value<String> nome,
      Value<String> raca,
      Value<String> classe,
      Value<int> nivel,
      Value<int> hpMaximo,
      Value<int> hpAtual,
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

  ColumnFilters<int> get hpMaximo => $composableBuilder(
    column: $table.hpMaximo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hpAtual => $composableBuilder(
    column: $table.hpAtual,
    builder: (column) => ColumnFilters(column),
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

  ColumnOrderings<int> get hpMaximo => $composableBuilder(
    column: $table.hpMaximo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hpAtual => $composableBuilder(
    column: $table.hpAtual,
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

  GeneratedColumn<int> get hpMaximo =>
      $composableBuilder(column: $table.hpMaximo, builder: (column) => column);

  GeneratedColumn<int> get hpAtual =>
      $composableBuilder(column: $table.hpAtual, builder: (column) => column);

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
          PrefetchHooks Function({bool attributesRefs})
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
                Value<int> hpMaximo = const Value.absent(),
                Value<int> hpAtual = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharactersCompanion(
                id: id,
                nome: nome,
                raca: raca,
                classe: classe,
                nivel: nivel,
                hpMaximo: hpMaximo,
                hpAtual: hpAtual,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nome,
                required String raca,
                required String classe,
                required int nivel,
                required int hpMaximo,
                required int hpAtual,
                Value<int> rowid = const Value.absent(),
              }) => CharactersCompanion.insert(
                id: id,
                nome: nome,
                raca: raca,
                classe: classe,
                nivel: nivel,
                hpMaximo: hpMaximo,
                hpAtual: hpAtual,
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
          prefetchHooksCallback: ({attributesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (attributesRefs) db.attributes],
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
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
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
      PrefetchHooks Function({bool attributesRefs})
    >;
typedef $$AttributesTableCreateCompanionBuilder =
    AttributesCompanion Function({
      required String characterId,
      required int forca,
      required int destreza,
      required int constituicao,
      required int inteligencia,
      required int sabedoria,
      required int carisma,
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
                required int forca,
                required int destreza,
                required int constituicao,
                required int inteligencia,
                required int sabedoria,
                required int carisma,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CharactersTableTableManager get characters =>
      $$CharactersTableTableManager(_db, _db.characters);
  $$AttributesTableTableManager get attributes =>
      $$AttributesTableTableManager(_db, _db.attributes);
}
