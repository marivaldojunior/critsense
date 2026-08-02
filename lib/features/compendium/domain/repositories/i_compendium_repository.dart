import '../entities/equipment_summary.dart';
import '../entities/monster_summary.dart';
import '../entities/spell_detail.dart';
import '../entities/spell_summary.dart';

/// Contrato para acesso ao compêndio de magias do D&D 5e.
abstract interface class ICompendiumRepository {
  /// Retorna a lista resumida de todas as magias disponíveis na API.
  Future<List<SpellSummary>> getSpells();

  /// Retorna os detalhes completos da magia identificada por [index].
  Future<SpellDetail> getSpellDetail(String index);

  /// Retorna a lista resumida de todos os equipamentos disponíveis na API.
  Future<List<EquipmentSummary>> getEquipments();

  /// Retorna uma página de monstros a partir de [offset] com até [limit] itens.
  Future<List<MonsterSummary>> getMonsters({
    required int offset,
    required int limit,
  });
}
