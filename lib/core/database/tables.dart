import 'package:drift/drift.dart';

/// Tabela de personagens persistidos no banco de dados local.
///
/// Usa texto como chave primária para compatibilidade com UUIDs gerados
/// na camada de domínio, evitando dependência de auto-incremento do SQLite.
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

  /// Pontos de vida máximos.
  IntColumn get hpMaximo => integer()();

  /// Pontos de vida atuais.
  IntColumn get hpAtual => integer()();

  /// Caminho local para a imagem de avatar do personagem; pode ser nulo.
  TextColumn get avatarPath => text().nullable()();

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

  /// Força: capacidade física bruta.
  IntColumn get forca => integer()();

  /// Destreza: agilidade e coordenação.
  IntColumn get destreza => integer()();

  /// Constituição: resistência física.
  IntColumn get constituicao => integer()();

  /// Inteligência: raciocínio e memória.
  IntColumn get inteligencia => integer()();

  /// Sabedoria: percepção e intuição.
  IntColumn get sabedoria => integer()();

  /// Carisma: força de personalidade.
  IntColumn get carisma => integer()();

  @override
  Set<Column> get primaryKey => {characterId};
}

/// Tabela de itens do inventário de um personagem.
///
/// Relação 1:N com [Characters]: um personagem possui zero ou mais itens.
///
/// No Entity Framework Core (.NET), essa relação seria configurada via Fluent
/// API: `modelBuilder.Entity<Character>().HasMany(c => c.InventoryItems)
/// .WithOne(i => i.Character).HasForeignKey(i => i.CharacterId)
/// .OnDelete(DeleteBehavior.Cascade)`. O EF gerencia a FK e o cascade
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

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabela de notas de sessão de RPG, vinculada 1:N a [Characters].
///
/// No EF Core, esta relação seria configurada assim:
/// `modelBuilder.Entity<Character>().HasMany(c => c.SessionNotes)
/// .WithOne(n => n.Character).HasForeignKey(n => n.CharacterId)
/// .OnDelete(DeleteBehavior.Cascade)`.
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
