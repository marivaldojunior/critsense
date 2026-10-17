import 'dart:convert';

import 'package:drift/drift.dart';

/// Converte `List<String>` (domínio) em `TEXT` (SQLite) via JSON, para
/// colunas que guardam listas simples de identificadores sem precisar de
/// uma tabela relacionada dedicada — diferente de [InventoryItems], que é
/// uma tabela própria por ter atributos além do identificador (ex:
/// [InventoryItems.equipmentCategory]).
///
/// Usado com `.map(const StringListConverter())` numa [TextColumn]: o
/// Drift passa a expor o campo já como `List<String>` no código gerado,
/// aplicando [fromSql]/[toSql] automaticamente em cada leitura/escrita —
/// nenhum `jsonEncode`/`jsonDecode` manual é necessário fora deste arquivo.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    return (jsonDecode(fromDb) as List<dynamic>).cast<String>();
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

/// Tabela de personagens persistidos no banco de dados local.
///
/// Usa texto como chave primária para compatibilidade com UUIDs gerados
/// na camada de domínio, evitando dependência de auto-incremento do SQLite.
/// Converte uma lista de inteiros em JSON (ex: espaços de magia gastos por
/// nível). Mesmo motivo de [StringListConverter].
class IntListConverter extends TypeConverter<List<int>, String> {
  const IntListConverter();

  @override
  List<int> fromSql(String fromDb) {
    return (jsonDecode(fromDb) as List<dynamic>)
        .cast<num>()
        .map((n) => n.toInt())
        .toList();
  }

  @override
  String toSql(List<int> value) => jsonEncode(value);
}

/// Converte um mapa de texto para inteiro em JSON (ex: usos gastos de cada
/// recurso de classe). Mesmo motivo de [StringListConverter].
class IntMapConverter extends TypeConverter<Map<String, int>, String> {
  const IntMapConverter();

  @override
  Map<String, int> fromSql(String fromDb) {
    return (jsonDecode(fromDb) as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, (value as num).toInt()),
    );
  }

  @override
  String toSql(Map<String, int> value) => jsonEncode(value);
}

@DataClassName('CharacterData')
class Characters extends Table {
  /// Identificador único do personagem (UUID proveniente do domínio).
  TextColumn get id => text()();

  /// Nome do personagem.
  TextColumn get nome => text()();

  /// Raça do personagem.
  TextColumn get raca => text()();

  /// Classe do personagem.
  TextColumn get classe => text()();

  /// Nível atual do personagem.
  IntColumn get nivel => integer()();

  // ── Status de Combate ─────────────────────────────────────────────────
  // Reflete o bloco central da primeira página da ficha oficial (CA,
  // iniciativa, deslocamento e a caixa de pontos de vida).

  /// Classe de Armadura (CA). Default 10: CA base sem armadura no SRD do
  /// D&D 5e — usado para não quebrar personagens já persistidos antes
  /// desta coluna existir.
  IntColumn get armorClass => integer().withDefault(const Constant(10))();

  /// Modificador de iniciativa somado à rolagem de d20 no início do combate.
  IntColumn get initiative => integer().withDefault(const Constant(0))();

  /// Deslocamento em pés por turno. Default 30: valor padrão da maioria das
  /// raças jogáveis no SRD do D&D 5e.
  IntColumn get speed => integer().withDefault(const Constant(30))();

  /// Pontos de vida máximos. Renomeada de `hpMaximo` para alinhar com a
  /// nomenclatura em inglês do restante do bloco de Status de Combate.
  IntColumn get maxHitPoints => integer()();

  /// Pontos de vida atuais. Renomeada de `hpAtual`; ver [maxHitPoints].
  IntColumn get currentHitPoints => integer()();

  /// Pontos de vida temporários — absorvidos antes dos PV atuais, zerados
  /// (não subtraídos) ao sofrer dano restante, conforme a regra do SRD.
  IntColumn get temporaryHitPoints =>
      integer().withDefault(const Constant(0))();

  /// Caminho local para a imagem de avatar do personagem; pode ser nulo.
  TextColumn get avatarPath => text().nullable()();

  /// Tendência (alinhamento), ex: "Leal e Bom". Nullable para não quebrar
  /// personagens já persistidos antes desta coluna existir.
  TextColumn get alignment => text().nullable()();

  /// Antecedente (background) do personagem. Mesma justificativa de
  /// nullability de [alignment].
  TextColumn get background => text().nullable()();

  // ── Traços de Personalidade ───────────────────────────────────────────
  // Reflete o bloco lateral esquerdo da primeira página da ficha oficial.
  // Nullable pelo mesmo motivo de [alignment]/[background]: texto livre
  // ausente em personagens persistidos antes desta coluna existir.

  /// Traços de personalidade do personagem.
  TextColumn get personalityTraits => text().nullable()();

  /// Ideais que guiam as ações do personagem.
  TextColumn get ideals => text().nullable()();

  /// Vínculos (pessoas, lugares ou causas importantes) do personagem.
  TextColumn get bonds => text().nullable()();

  /// Defeitos ou fraquezas de personalidade do personagem.
  TextColumn get flaws => text().nullable()();

  // ── Evolução ───────────────────────────────────────────────────────────
  // Reflete o bloco de progressão da ficha oficial (canto da caixa de
  // nível/classe): pontos de experiência e o bônus de proficiência
  // derivado do nível.

  /// Pontos de experiência acumulados. Default 0: início de aventura.
  IntColumn get experiencePoints => integer().withDefault(const Constant(0))();

  /// Bônus de proficiência aplicado a testes, ataques e resistências.
  /// Default 2: valor do SRD do D&D 5e para personagens de nível 1 a 4.
  IntColumn get proficiencyBonus => integer().withDefault(const Constant(2))();

  // ── Magias e Monstros Derrotados ────────────────────────────────────────
  // Listas simples de identificadores vinculadas ao personagem — ver
  // [StringListConverter] para o porquê de serem colunas de texto JSON em
  // vez de tabelas relacionadas.

  /// Magias conhecidas/vinculadas ao personagem, como JSON de `List<String>`.
  /// Default `'[]'`: nenhum personagem existente antes desta coluna tinha
  /// magias registradas.
  TextColumn get spells => text()
      .withDefault(const Constant('[]'))
      .map(const StringListConverter())();

  /// Monstros/chefes derrotados pelo personagem, como JSON de `List<String>`.
  /// Mesma justificativa de default de [spells].
  TextColumn get defeatedBosses => text()
      .withDefault(const Constant('[]'))
      .map(const StringListConverter())();

  // ── Proficiências ───────────────────────────────────────────────────────
  // Perícias e Testes de Resistência marcados na ficha, como lista JSON de
  // chaves (`skill:stealth`, `save:dexterity`). A conversão entre a chave e
  // a entidade `Proficiency` fica no `CharacterRepositoryImpl`, para o
  // schema não depender das entidades de domínio.
  TextColumn get proficiencies => text()
      .withDefault(const Constant('[]'))
      .map(const StringListConverter())();

  // ── Combate e descanso (versão 8) ─────────────────────────────────────
  // `armorClass`, `initiative` e `proficiencyBonus` (acima) continuam no
  // banco, mas o app só grava neles o valor calculado: a fonte da verdade
  // são as regras do domínio. O que o jogador ajusta à mão fica aqui.
  IntColumn get armorClassBonus => integer().withDefault(const Constant(0))();
  IntColumn get hitDiceUsed => integer().withDefault(const Constant(0))();
  IntColumn get deathSaveSuccesses =>
      integer().withDefault(const Constant(0))();
  IntColumn get deathSaveFailures => integer().withDefault(const Constant(0))();
  TextColumn get conditions => text()
      .withDefault(const Constant('[]'))
      .map(const StringListConverter())();
  IntColumn get exhaustionLevel => integer().withDefault(const Constant(0))();
  BoolColumn get inspiration => boolean().withDefault(const Constant(false))();

  // ── Magia (versão 9) ──────────────────────────────────────────────────
  // As magias do grimório ficam na tabela [CharacterSpells]; a coluna
  // antiga `spells` (só nomes) não é mais lida.
  TextColumn get spellSlotsUsed => text()
      .withDefault(const Constant('[0,0,0,0,0,0,0,0,0]'))
      .map(const IntListConverter())();
  IntColumn get pactSlotsUsed => integer().withDefault(const Constant(0))();

  // ── Moedas (versão 10) ────────────────────────────────────────────────
  IntColumn get copper => integer().withDefault(const Constant(0))();
  IntColumn get silver => integer().withDefault(const Constant(0))();
  IntColumn get electrum => integer().withDefault(const Constant(0))();
  IntColumn get gold => integer().withDefault(const Constant(0))();
  IntColumn get platinum => integer().withDefault(const Constant(0))();

  // ── Outras proficiências e idiomas (versão 11) ────────────────────────
  TextColumn get otherProficiencies => text()
      .withDefault(const Constant('[]'))
      .map(const StringListConverter())();
  TextColumn get languages => text()
      .withDefault(const Constant('[]'))
      .map(const StringListConverter())();

  // ── Recursos de classe (versão 13) ────────────────────────────────────
  TextColumn get resourcesUsed =>
      text().withDefault(const Constant('{}')).map(const IntMapConverter())();

  // ── Concentração (versão 14) ──────────────────────────────────────────
  TextColumn get concentrationSpell => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabela de atributos base, vinculada 1:1 a [Characters].
///
/// A deleção em cascata garante integridade referencial: ao remover um
/// personagem, seus atributos são automaticamente excluídos pelo SQLite
/// sem necessidade de queries manuais adicionais.
@DataClassName('AttributeData')
class Attributes extends Table {
  /// Chave estrangeira para o personagem dono destes atributos.
  TextColumn get characterId =>
      text().references(Characters, #id, onDelete: KeyAction.cascade)();

  // Default 8: ponto de partida do sistema de Compra de Pontos (Point Buy)
  // do D&D 5e — a aplicação sempre envia os 6 valores explicitamente ao
  // salvar, então este default só importa para inserções feitas fora do
  // fluxo do formulário (ex: scripts, testes manuais no banco).

  /// Força: capacidade física bruta.
  IntColumn get forca => integer().withDefault(const Constant(8))();

  /// Destreza: agilidade e coordenação.
  IntColumn get destreza => integer().withDefault(const Constant(8))();

  /// Constituição: resistência física.
  IntColumn get constituicao => integer().withDefault(const Constant(8))();

  /// Inteligência: raciocínio e memória.
  IntColumn get inteligencia => integer().withDefault(const Constant(8))();

  /// Sabedoria: percepção e intuição.
  IntColumn get sabedoria => integer().withDefault(const Constant(8))();

  /// Carisma: força de personalidade.
  IntColumn get carisma => integer().withDefault(const Constant(8))();

  @override
  Set<Column> get primaryKey => {characterId};
}

/// Tabela de itens do inventário de um personagem.
///
/// Relação 1:N com [Characters]: um personagem possui zero ou mais itens.
///
/// No Entity Framework Core (.NET), essa relação seria configurada via Fluent
/// API:
/// `modelBuilder.Entity<Character>().HasMany(c => c.InventoryItems).WithOne(i => i.Character).HasForeignKey(i => i.CharacterId).OnDelete(DeleteBehavior.Cascade)`.
/// O EF gerencia a FK e o cascade
/// automaticamente na migração. No Drift, declaramos a FK explicitamente
/// com `.references(Characters, #id, onDelete: KeyAction.cascade)`, e o
/// próprio Drift gera o DDL correspondente em `app_database.g.dart`.
/// Assim como um `Add-Migration` + `Update-Database` no EF, após qualquer
/// alteração nas tabelas é necessário rodar:
/// `dart run build_runner build --delete-conflicting-outputs`
/// para regenerar o arquivo `.g.dart` e sincronizar o esquema do banco.
@DataClassName('InventoryItemData')
class InventoryItems extends Table {
  /// Identificador único do item (UUID gerado no domínio).
  TextColumn get id => text()();

  /// Chave estrangeira para o personagem dono do item.
  TextColumn get characterId =>
      text().references(Characters, #id, onDelete: KeyAction.cascade)();

  /// Identificador do item na API do D&D 5e (ex: "longsword").
  TextColumn get itemIndex => text()();

  /// Nome legível do item (ex: "Longsword").
  TextColumn get name => text()();

  /// Categoria do equipamento (ex: "Weapon", "Armor").
  TextColumn get equipmentCategory => text()();

  // ── Quantidade, peso, equipado e sintonia (versão 10) ─────────────────
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  RealColumn get weight => real().withDefault(const Constant(0))();
  BoolColumn get equipped => boolean().withDefault(const Constant(false))();
  BoolColumn get requiresAttunement =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get attuned => boolean().withDefault(const Constant(false))();

  /// `false` nos itens anteriores à versão 10: a ficha completa os dados
  /// pelo compêndio quando tem internet.
  BoolColumn get detailsLoaded => boolean().withDefault(const Constant(true))();

  // Armadura
  TextColumn get armorCategory => text().nullable()();
  IntColumn get armorBase => integer().nullable()();
  BoolColumn get armorDexBonus =>
      boolean().withDefault(const Constant(false))();
  IntColumn get armorMaxDexBonus => integer().nullable()();

  // Arma
  TextColumn get weaponCategory => text().nullable()();
  TextColumn get weaponRange => text().nullable()();
  TextColumn get damageDice => text().nullable()();
  TextColumn get damageType => text().nullable()();
  TextColumn get versatileDamageDice => text().nullable()();
  TextColumn get weaponProperties => text()
      .withDefault(const Constant('[]'))
      .map(const StringListConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabela de notas de sessão de RPG, vinculada 1:N a [Characters].
///
/// No EF Core, esta relação seria configurada assim:
/// `modelBuilder.Entity<Character>().HasMany(c => c.SessionNotes).WithOne(n => n.Character).HasForeignKey(n => n.CharacterId).OnDelete(DeleteBehavior.Cascade)`.
/// O EF gerencia a FK e o DDL automaticamente via migração.
/// No Drift, declaramos a FK explicitamente com `.references(...)` e
/// executamos `dart run build_runner build` para sincronizar o esquema.
@DataClassName('SessionNoteData')
class SessionNotes extends Table {
  /// Identificador único da nota (UUID gerado no domínio).
  TextColumn get id => text()();

  /// Chave estrangeira para o personagem dono desta nota.
  TextColumn get characterId =>
      text().references(Characters, #id, onDelete: KeyAction.cascade)();

  /// Título resumido da anotação.
  TextColumn get title => text()();

  /// Corpo completo da anotação.
  TextColumn get content => text()();

  /// Momento de criação da nota; armazenado como epoch ms pelo Drift.
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Magias do grimório de um personagem (versão 9). Antes, as magias eram só
/// uma lista de nomes em `characters.spells`.
@DataClassName('CharacterSpellData')
class CharacterSpells extends Table {
  TextColumn get id => text()();
  TextColumn get characterId =>
      text().references(Characters, #id, onDelete: KeyAction.cascade)();

  /// Índice da magia na API 5e-bits (ex: `magic-missile`).
  TextColumn get spellIndex => text()();
  TextColumn get name => text()();

  /// 0 = truque; `null` = nível ainda desconhecido (magias migradas).
  IntColumn get level => integer().nullable()();
  BoolColumn get prepared => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cópia das respostas GET do compêndio, para uso sem internet (versão 12).
/// A chave é a URL completa da requisição (ver `OfflineCacheInterceptor`).
@DataClassName('ApiCacheEntry')
class ApiCache extends Table {
  TextColumn get requestKey => text()();
  TextColumn get body => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {requestKey};
}
