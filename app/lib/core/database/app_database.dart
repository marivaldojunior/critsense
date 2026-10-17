import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'tables.dart';

// Arquivo gerado pelo build_runner. Execute:
// dart run build_runner build --delete-conflicting-outputs
part 'app_database.g.dart';

/// Ponto central de acesso ao banco de dados SQLite da aplicação via Drift.
///
/// O Drift gera, a partir das anotações e das [Tables], toda a infraestrutura
/// de queries type-safe em [app_database.g.dart]. Nunca edite o arquivo `.g.dart`.
@DriftDatabase(
  tables: [
    Characters,
    Attributes,
    InventoryItems,
    SessionNotes,
    CharacterSpells,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Cria a instância recebendo o executor de queries.
  AppDatabase(super.e);

  @override
  int get schemaVersion => 11;

  /// Aplica migrações incrementais quando o banco existente é mais antigo que
  /// [schemaVersion]. Equivale ao `Update-Database` do EF Core, que aplica
  /// apenas as migrations pendentes sem recriar o banco.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    // O SQLite desativa foreign keys por padrão; este PRAGMA as habilita
    // para que a cascade delete em [Attributes], [InventoryItems] e
    // [SessionNotes] funcione. Fica no `beforeOpen` (e não no `setup` do
    // `NativeDatabase`) para valer em qualquer executor — inclusive o banco
    // em memória dos testes.
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await m.createTable(sessionNotes);
      }
      if (from < 4) {
        await m.addColumn(characters, characters.alignment);
        await m.addColumn(characters, characters.background);
      }
      if (from < 5) {
        // `hpMaximo`/`hpAtual` viram `maxHitPoints`/`currentHitPoints` para
        // alinhar com a nomenclatura em inglês do restante do bloco de
        // Status de Combate — mesmo dado, só o nome da coluna muda.
        await m.renameColumn(characters, 'hp_maximo', characters.maxHitPoints);
        await m.renameColumn(
          characters,
          'hp_atual',
          characters.currentHitPoints,
        );
        await m.addColumn(characters, characters.armorClass);
        await m.addColumn(characters, characters.initiative);
        await m.addColumn(characters, characters.speed);
        await m.addColumn(characters, characters.temporaryHitPoints);
        await m.addColumn(characters, characters.personalityTraits);
        await m.addColumn(characters, characters.ideals);
        await m.addColumn(characters, characters.bonds);
        await m.addColumn(characters, characters.flaws);
        await m.addColumn(characters, characters.experiencePoints);
        await m.addColumn(characters, characters.proficiencyBonus);
      }
      if (from < 6) {
        // Magias e monstros/chefes derrotados vinculados ao personagem —
        // ver [StringListConverter] em `tables.dart`. O `withDefault('[]')`
        // da coluna garante que as linhas já existentes recebam uma lista
        // vazia válida em vez de `NULL`.
        await m.addColumn(characters, characters.spells);
        await m.addColumn(characters, characters.defeatedBosses);
      }
      if (from < 7) {
        // Proficiências em Perícias e Testes de Resistência. Antes desta
        // versão elas só existiam em memória e se perdiam ao reabrir o app.
        await m.addColumn(characters, characters.proficiencies);
      }
      if (from < 8) {
        // Combate e descanso: dados de vida, salvaguardas contra a morte,
        // condições, exaustão, inspiração e o bônus manual de CA.
        await m.addColumn(characters, characters.armorClassBonus);
        await m.addColumn(characters, characters.hitDiceUsed);
        await m.addColumn(characters, characters.deathSaveSuccesses);
        await m.addColumn(characters, characters.deathSaveFailures);
        await m.addColumn(characters, characters.conditions);
        await m.addColumn(characters, characters.exhaustionLevel);
        await m.addColumn(characters, characters.inspiration);
      }
      if (from < 9) {
        // Grimório: as magias saem da lista de nomes em `characters.spells`
        // e vão para a tabela `character_spells`, com índice e nível.
        await m.addColumn(characters, characters.spellSlotsUsed);
        await m.addColumn(characters, characters.pactSlotsUsed);
        await m.createTable(characterSpells);
        await _migrateSpellNames();
      }
      if (from < 10) {
        // Inventário completo: quantidade, peso, equipado, sintonia, dados
        // de armadura e de arma, e as moedas do personagem.
        for (final column in [
          inventoryItems.quantity,
          inventoryItems.weight,
          inventoryItems.equipped,
          inventoryItems.requiresAttunement,
          inventoryItems.attuned,
          inventoryItems.detailsLoaded,
          inventoryItems.armorCategory,
          inventoryItems.armorBase,
          inventoryItems.armorDexBonus,
          inventoryItems.armorMaxDexBonus,
          inventoryItems.weaponCategory,
          inventoryItems.weaponRange,
          inventoryItems.damageDice,
          inventoryItems.damageType,
          inventoryItems.versatileDamageDice,
          inventoryItems.weaponProperties,
        ]) {
          await m.addColumn(inventoryItems, column);
        }
        // Os itens antigos não têm peso nem dados de combate.
        await customStatement(
          'UPDATE inventory_items SET details_loaded = 0',
        );
        for (final column in [
          characters.copper,
          characters.silver,
          characters.electrum,
          characters.gold,
          characters.platinum,
        ]) {
          await m.addColumn(characters, column);
        }
      }
      if (from < 11) {
        // Proficiências em armaduras, armas e ferramentas, e idiomas.
        await m.addColumn(characters, characters.otherProficiencies);
        await m.addColumn(characters, characters.languages);
      }
    },
  );

  /// Copia cada nome de `characters.spells` para uma linha de
  /// `character_spells`. O índice vem do nome no formato da API 5e-bits
  /// (ex: "Magic Missile" -> `magic-missile`); o nível fica `null` até a
  /// ficha buscar a magia no compêndio.
  Future<void> _migrateSpellNames() async {
    final rows = await customSelect('SELECT id, spells FROM characters').get();
    for (final row in rows) {
      final characterId = row.read<String>('id');
      final names = const StringListConverter().fromSql(
        row.read<String>('spells'),
      );
      for (final name in names) {
        await into(characterSpells).insert(
          CharacterSpellsCompanion.insert(
            id: const Uuid().v4(),
            characterId: characterId,
            spellIndex: spellIndexFromName(name),
            name: name,
          ),
        );
      }
    }
    await customStatement("UPDATE characters SET spells = '[]'");
  }

  /// Converte o nome de uma magia no índice da API 5e-bits.
  static String spellIndexFromName(String name) => name
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r"[^a-z0-9]+"), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  /// Cria a conexão lazy com o arquivo `critsense.sqlite` no diretório de documentos.
  ///
  /// [LazyDatabase] adia a abertura do arquivo até a primeira query, garantindo
  /// que [getApplicationDocumentsDirectory] seja chamado apenas após a inicialização
  /// completa do Flutter Engine — seguro para uso em `main.dart`.
  ///
  /// [NativeDatabase.createInBackground] abre o banco em um isolate dedicado,
  /// evitando bloqueio da thread principal durante leituras e escritas pesadas.
  static QueryExecutor openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'critsense.sqlite'));

      return NativeDatabase.createInBackground(file);
    });
  }
}
