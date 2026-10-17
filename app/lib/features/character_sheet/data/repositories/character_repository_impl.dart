import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/attribute.dart';
import '../../domain/entities/attribute_type.dart';
import '../../domain/entities/condition.dart';
import '../../domain/entities/character.dart';
import '../../domain/entities/character_spell.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/proficiency.dart';
import '../../domain/entities/session_note.dart';
import '../../domain/entities/skill.dart';
import '../../domain/repositories/i_character_repository.dart';

/// Implementação concreta de [ICharacterRepository] usando o banco SQLite via Drift.
///
/// Por que mapear [CharacterData]/[AttributeData] → [Character]/[Attribute]?
/// As classes geradas pelo Drift são artefatos de infraestrutura: mudar o ORM,
/// renomear colunas ou trocar de banco impactaria apenas esta camada, nunca
/// o Domínio. O mapeamento é a fronteira que garante esse isolamento.
class CharacterRepositoryImpl implements ICharacterRepository {
  final AppDatabase _db;

  /// Injeta [AppDatabase] via construtor para facilitar testes com mocks/fakes.
  const CharacterRepositoryImpl(this._db);

  /// Persiste ou atualiza um personagem e seus atributos de forma atômica.
  ///
  /// O Drift envolve as duas inserções em uma única [transaction] SQL: se a
  /// inserção dos atributos falhar, a do personagem é revertida automaticamente,
  /// mantendo o banco em estado consistente (atomicidade ACID).
  ///
  /// [insertOnConflictUpdate] implementa UPSERT nativo:
  /// `INSERT … ON CONFLICT(id) DO UPDATE SET …`, eliminando a necessidade
  /// de verificar existência prévia com um SELECT separado.
  @override
  Future<void> saveCharacter(Character character) async {
    await _db.transaction(() async {
      await _db
          .into(_db.characters)
          .insertOnConflictUpdate(character._toCompanion());

      await _db
          .into(_db.attributes)
          .insertOnConflictUpdate(
            character.attributes._toCompanion(character.id),
          );
    });
  }

  /// Retorna todos os personagens com seus atributos via JOIN.
  ///
  /// O Drift converte o [select] + [innerJoin] em uma única query SQL, evitando
  /// o problema N+1 que ocorreria ao buscar atributos individualmente por personagem.
  /// [TypedResult.readTable] extrai com type-safety cada linha da tabela do resultado.
  @override
  Future<List<Character>> getAllCharacters() async {
    final query = _db.select(_db.characters).join([
      innerJoin(
        _db.attributes,
        _db.attributes.characterId.equalsExp(_db.characters.id),
      ),
    ]);

    final rows = await query.get();

    return rows.map((row) {
      final charData = row.readTable(_db.characters);
      final attrData = row.readTable(_db.attributes);
      return charData._toDomain(attrData);
    }).toList();
  }

  /// Remove o personagem identificado por [id].
  ///
  /// Graças à `CASCADE` definida em [Attributes.characterId], o SQLite exclui
  /// automaticamente os atributos relacionados sem queries adicionais.
  @override
  Future<void> deleteCharacter(String id) async {
    await (_db.delete(_db.characters)..where((t) => t.id.equals(id))).go();
  }

  /// Insere um item no inventário usando UPSERT para evitar duplicatas por id.
  @override
  Future<void> addInventoryItem(InventoryItem item) async {
    await _db
        .into(_db.inventoryItems)
        .insertOnConflictUpdate(item._toCompanion());
  }

  /// Retorna todos os itens do personagem via query filtrada por [characterId].
  @override
  Future<List<InventoryItem>> getCharacterInventory(String characterId) async {
    final rows = await (_db.select(
      _db.inventoryItems,
    )..where((t) => t.characterId.equals(characterId))).get();
    return rows.map((row) => row._toDomain()).toList();
  }

  /// Remove o item identificado por [itemId]; sem CASCADE a considerar aqui,
  /// pois itens de inventário não possuem filhos.
  @override
  Future<void> deleteInventoryItem(String itemId) async {
    await (_db.delete(
      _db.inventoryItems,
    )..where((t) => t.id.equals(itemId))).go();
  }

  /// Retorna as notas de sessão do personagem, ordenadas da mais recente para a mais antiga.
  @override
  Future<List<SessionNote>> getSessionNotes(String characterId) async {
    final rows =
        await (_db.select(_db.sessionNotes)
              ..where((t) => t.characterId.equals(characterId))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();
    return rows.map((row) => row._toDomain()).toList();
  }

  /// Persiste uma nota usando UPSERT para garantir idempotência pelo [SessionNote.id].
  @override
  Future<void> addSessionNote(SessionNote note) async {
    await _db
        .into(_db.sessionNotes)
        .insertOnConflictUpdate(note._toCompanion());
  }

  /// Remove a nota identificada por [noteId]; a CASCADE não é necessária aqui
  /// pois notas não possuem filhos.
  @override
  Future<void> deleteSessionNote(String noteId) async {
    await (_db.delete(
      _db.sessionNotes,
    )..where((t) => t.id.equals(noteId))).go();
  }

  @override
  Future<List<CharacterSpell>> getCharacterSpells(String characterId) async {
    final rows =
        await (_db.select(_db.characterSpells)
              ..where((t) => t.characterId.equals(characterId))
              ..orderBy([
                (t) => OrderingTerm.asc(t.level, nulls: NullsOrder.last),
                (t) => OrderingTerm.asc(t.name),
              ]))
            .get();
    return rows.map((row) => row._toDomain()).toList();
  }

  @override
  Future<void> saveCharacterSpell(CharacterSpell spell) async {
    await _db.transaction(() async {
      final existing =
          await (_db.select(_db.characterSpells)..where(
                (t) =>
                    t.characterId.equals(spell.characterId) &
                    t.spellIndex.equals(spell.spellIndex) &
                    t.id.equals(spell.id).not(),
              ))
              .getSingleOrNull();
      final id = existing?.id ?? spell.id;
      await _db
          .into(_db.characterSpells)
          .insertOnConflictUpdate(
            CharacterSpellsCompanion(
              id: Value(id),
              characterId: Value(spell.characterId),
              spellIndex: Value(spell.spellIndex),
              name: Value(spell.name),
              level: Value(spell.level ?? existing?.level),
              prepared: Value(spell.prepared),
            ),
          );
    });
  }

  @override
  Future<void> deleteCharacterSpell(String spellId) async {
    await (_db.delete(
      _db.characterSpells,
    )..where((t) => t.id.equals(spellId))).go();
  }
}

// ---------------------------------------------------------------------------
// Mappers privados — mantidos neste arquivo pois são exclusivos da camada de
// dados. Expô-los em arquivos públicos vazaria detalhes de infraestrutura.
// ---------------------------------------------------------------------------

extension _CharacterDataMapper on CharacterData {
  /// Converte a linha gerada pelo Drift para a entidade pura de domínio [Character].
  ///
  /// [alignment]/[background]/[personalityTraits]/[ideals]/[bonds]/[flaws]
  /// são nullable no banco (colunas adicionadas em migrações posteriores);
  /// personagens salvos antes delas viram string vazia aqui — o domínio
  /// permanece non-null, a infraestrutura absorve a lacuna de dados legados.
  Character _toDomain(AttributeData attrData) {
    return Character(
      id: id,
      name: nome,
      race: raca,
      characterClass: classe,
      level: nivel,
      armorClassBonus: armorClassBonus,
      speed: speed,
      maxHitPoints: maxHitPoints,
      currentHitPoints: currentHitPoints,
      temporaryHitPoints: temporaryHitPoints,
      hitDiceUsed: hitDiceUsed,
      deathSaveSuccesses: deathSaveSuccesses,
      deathSaveFailures: deathSaveFailures,
      conditions: conditions
          .map(Condition.fromName)
          .whereType<Condition>()
          .toList(),
      exhaustionLevel: exhaustionLevel,
      inspiration: inspiration,
      attributes: attrData._toDomain(),
      alignment: alignment ?? '',
      background: background ?? '',
      personalityTraits: personalityTraits ?? '',
      ideals: ideals ?? '',
      bonds: bonds ?? '',
      flaws: flaws ?? '',
      experiencePoints: experiencePoints,
      proficiencies: proficiencies
          .map(_proficiencyFromKey)
          .whereType<Proficiency>()
          .toList(),
      avatarPath: avatarPath,
      spellSlotsUsed: spellSlotsUsed,
      pactSlotsUsed: pactSlotsUsed,
      defeatedBosses: defeatedBosses,
    );
  }
}

// Chaves das proficiências na coluna `proficiencies` — usam o `name` dos
// enums, então renomear um valor de [Skill] ou [AttributeType] exige uma
// migração dos dados salvos.
const _skillKeyPrefix = 'skill:';
const _savingThrowKeyPrefix = 'save:';

String _proficiencyToKey(Proficiency proficiency) => switch (proficiency) {
  SkillProficiency(:final skill) => '$_skillKeyPrefix${skill.name}',
  SavingThrowProficiency(:final attribute) =>
    '$_savingThrowKeyPrefix${attribute.name}',
};

/// Converte a chave salva de volta para a [Proficiency]. Uma chave
/// desconhecida (ex: valor de enum removido) vira `null` e é ignorada, em
/// vez de impedir a carga do personagem.
Proficiency? _proficiencyFromKey(String key) {
  if (key.startsWith(_skillKeyPrefix)) {
    final name = key.substring(_skillKeyPrefix.length);
    final skill = Skill.values.where((s) => s.name == name).firstOrNull;
    return skill == null ? null : SkillProficiency(skill);
  }
  if (key.startsWith(_savingThrowKeyPrefix)) {
    final name = key.substring(_savingThrowKeyPrefix.length);
    final attribute = AttributeType.values
        .where((a) => a.name == name)
        .firstOrNull;
    return attribute == null ? null : SavingThrowProficiency(attribute);
  }
  return null;
}

extension _AttributeDataMapper on AttributeData {
  /// Converte a linha gerada pelo Drift para a entidade pura de domínio [Attribute].
  Attribute _toDomain() {
    return Attribute(
      strength: forca,
      dexterity: destreza,
      constitution: constituicao,
      intelligence: inteligencia,
      wisdom: sabedoria,
      charisma: carisma,
    );
  }
}

extension _CharacterToCompanion on Character {
  /// Converte a entidade de domínio [Character] para o [CharactersCompanion] do Drift.
  CharactersCompanion _toCompanion() {
    return CharactersCompanion(
      id: Value(id),
      nome: Value(name),
      raca: Value(race),
      classe: Value(characterClass),
      nivel: Value(level),
      // Valores calculados, gravados só como referência (ver `tables.dart`).
      armorClass: Value(armorClass),
      initiative: Value(initiative),
      armorClassBonus: Value(armorClassBonus),
      speed: Value(speed),
      maxHitPoints: Value(maxHitPoints),
      currentHitPoints: Value(currentHitPoints),
      temporaryHitPoints: Value(temporaryHitPoints),
      hitDiceUsed: Value(hitDiceUsed),
      deathSaveSuccesses: Value(deathSaveSuccesses),
      deathSaveFailures: Value(deathSaveFailures),
      conditions: Value(conditions.map((c) => c.name).toList()),
      exhaustionLevel: Value(exhaustionLevel),
      inspiration: Value(inspiration),
      alignment: Value(alignment),
      background: Value(background),
      personalityTraits: Value(personalityTraits),
      ideals: Value(ideals),
      bonds: Value(bonds),
      flaws: Value(flaws),
      experiencePoints: Value(experiencePoints),
      proficiencyBonus: Value(proficiencyBonus),
      avatarPath: Value(avatarPath),
      // Coluna antiga, substituída por `character_spells` (versão 9).
      spells: const Value([]),
      spellSlotsUsed: Value(spellSlotsUsed),
      pactSlotsUsed: Value(pactSlotsUsed),
      defeatedBosses: Value(defeatedBosses),
      proficiencies: Value(proficiencies.map(_proficiencyToKey).toList()),
    );
  }
}

extension _AttributeToCompanion on Attribute {
  /// Converte a entidade de domínio [Attribute] para o [AttributesCompanion] do Drift.
  AttributesCompanion _toCompanion(String characterId) {
    return AttributesCompanion(
      characterId: Value(characterId),
      forca: Value(strength),
      destreza: Value(dexterity),
      constituicao: Value(constitution),
      inteligencia: Value(intelligence),
      sabedoria: Value(wisdom),
      carisma: Value(charisma),
    );
  }
}

extension _InventoryItemDataMapper on InventoryItemData {
  /// Converte a linha do Drift para a entidade pura de domínio [InventoryItem].
  InventoryItem _toDomain() {
    return InventoryItem(
      id: id,
      characterId: characterId,
      itemIndex: itemIndex,
      name: name,
      equipmentCategory: equipmentCategory,
    );
  }
}

extension _InventoryItemToCompanion on InventoryItem {
  /// Converte a entidade [InventoryItem] para o [InventoryItemsCompanion] do Drift.
  InventoryItemsCompanion _toCompanion() {
    return InventoryItemsCompanion(
      id: Value(id),
      characterId: Value(characterId),
      itemIndex: Value(itemIndex),
      name: Value(name),
      equipmentCategory: Value(equipmentCategory),
    );
  }
}

extension _SessionNoteDataMapper on SessionNoteData {
  /// Converte a linha gerada pelo Drift para a entidade pura de domínio [SessionNote].
  SessionNote _toDomain() {
    return SessionNote(
      id: id,
      characterId: characterId,
      title: title,
      content: content,
      createdAt: createdAt,
    );
  }
}

extension _SessionNoteToCompanion on SessionNote {
  /// Converte a entidade [SessionNote] para o [SessionNotesCompanion] do Drift.
  SessionNotesCompanion _toCompanion() {
    return SessionNotesCompanion(
      id: Value(id),
      characterId: Value(characterId),
      title: Value(title),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }
}

extension _CharacterSpellDataMapper on CharacterSpellData {
  CharacterSpell _toDomain() {
    return CharacterSpell(
      id: id,
      characterId: characterId,
      spellIndex: spellIndex,
      name: name,
      level: level,
      prepared: prepared,
    );
  }
}
