import '../entities/api_reference.dart';
import '../entities/equipment_detail.dart';
import '../entities/equipment_summary.dart';
import '../entities/monster_detail.dart';
import '../entities/monster_summary.dart';
import '../entities/spell_detail.dart';
import '../entities/spell_summary.dart';

/// Contrato para acesso ao compêndio de recursos do D&D 5e.
abstract interface class ICompendiumRepository {
  /// Retorna a lista resumida das magias que casam com [name]/[level]/
  /// [school] (todos opcionais — quando nulos, retorna a lista completa).
  Future<List<SpellSummary>> getSpells({String? name, int? level, String? school});

  /// Retorna os detalhes completos da magia identificada por [index].
  Future<SpellDetail> getSpellDetail(String index);

  /// Retorna a lista resumida dos equipamentos que casam com [name]/
  /// [equipmentCategory] (ambos opcionais).
  Future<List<EquipmentSummary>> getEquipments({
    String? name,
    String? equipmentCategory,
  });

  /// Retorna os detalhes completos do equipamento identificado por [index].
  Future<EquipmentDetail> getEquipmentDetail(String index);

  /// Retorna uma página de monstros a partir de [offset] com até [limit]
  /// itens, dentre os que casam com [name]/[challengeRating] quando
  /// informados.
  Future<List<MonsterSummary>> getMonsters({
    required int offset,
    required int limit,
    String? name,
    num? challengeRating,
  });

  /// Retorna os detalhes completos do monstro identificado por [index].
  Future<MonsterDetail> getMonsterDetail(String index);

  /// Retorna a lista de classes jogáveis disponíveis na API.
  Future<List<ApiReference>> getClasses();

  /// Retorna a lista de raças jogáveis disponíveis na API.
  Future<List<ApiReference>> getRaces();
}
