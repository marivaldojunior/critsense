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
