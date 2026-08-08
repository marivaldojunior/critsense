import 'package:dio/dio.dart';

import '../models/api_reference_model.dart';
import '../models/equipment_detail_model.dart';
import '../models/equipment_summary_model.dart';
import '../models/monster_summary_model.dart';
import '../models/spell_detail_model.dart';
import '../models/spell_summary_model.dart';

/// Contrato para o acesso remoto ao compêndio do D&D 5e.
abstract interface class ICompendiumRemoteDataSource {
  /// Busca a lista de magias na API remota.
  Future<List<SpellSummaryModel>> getSpells();

  /// Busca os detalhes completos da magia identificada por [index].
  Future<SpellDetailModel> getSpellDetail(String index);

  /// Busca a lista de equipamentos na API remota.
  Future<List<EquipmentSummaryModel>> getEquipments();

  /// Busca os detalhes completos do equipamento identificado por [index].
  Future<EquipmentDetailModel> getEquipmentDetail(String index);

  /// Retorna uma página de monstros a partir de [offset] com até [limit] itens.
  Future<List<MonsterSummaryModel>> getMonsters(int offset, int limit);

  /// Busca a lista de classes jogáveis na API remota.
  Future<List<ApiReferenceModel>> getClasses();

  /// Busca a lista de raças jogáveis na API remota.
  Future<List<ApiReferenceModel>> getRaces();
}

/// Implementação do datasource remoto usando Dio.
///
/// O Dio, assim como o `HttpClient` do .NET, encapsula o ciclo completo de
/// uma requisição HTTP. A diferença é que o Dio retorna `Future<Response>` —
/// o equivalente Dart do `Task<HttpResponseMessage>` do C#. Ambos representam
/// uma operação assíncrona pendente que pode ser aguardada (`await`) sem
/// bloquear a thread principal, mas no Dart o event loop de thread única torna
/// o `await` ainda mais crítico: qualquer operação bloqueante travaria toda a UI.
class CompendiumRemoteDataSourceImpl implements ICompendiumRemoteDataSource {
  final Dio _dio;

  // Endpoints da API pública do D&D 5e.
  static const _spellsEndpoint = 'https://www.dnd5eapi.co/api/spells';
  static const _monstersEndpoint = 'https://www.dnd5eapi.co/api/monsters';
  static const _classesEndpoint = 'https://www.dnd5eapi.co/api/classes';
  static const _racesEndpoint = 'https://www.dnd5eapi.co/api/races';
  static const _equipmentEndpoint = 'https://www.dnd5eapi.co/api/equipment';

  /// Cache em memória de todos os monstros carregados na primeira requisição.
  ///
  /// Esta estratégia é equivalente a um `IMemoryCache` do .NET populado na
  /// primeira chamada e reutilizado nas seguintes — o padrão "cache-aside".
  /// A paginação subsequente via `.skip(offset).take(limit)` em Dart é análoga
  /// ao `IQueryable<T>.Skip(offset).Take(limit)` do LINQ sobre Entity Framework,
  /// com a diferença fundamental de que aqui operamos sobre uma lista já
  /// materializada em RAM, enquanto o EF traduz `Skip/Take` para
  /// `OFFSET/FETCH NEXT` no SQL, adiando a materialização para o banco de dados.
  List<MonsterSummaryModel>? _cachedMonsters;

  /// Recebe o [Dio] pré-configurado via construtor para facilitar testes com mocks.
  CompendiumRemoteDataSourceImpl(Dio dio) : _dio = dio;

  /// Busca todas as magias e mapeia a lista `"results"` do payload para modelos.
  @override
  Future<List<SpellSummaryModel>> getSpells() async {
    final response = await _dio.get<Map<String, dynamic>>(_spellsEndpoint);

    final results = response.data!['results'] as List<dynamic>;
    return results
        .cast<Map<String, dynamic>>()
        .map(SpellSummaryModel.fromJson)
        .toList();
  }

  /// Busca os detalhes da magia pelo [index]; o payload raiz já é o objeto.
  @override
  Future<SpellDetailModel> getSpellDetail(String index) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_spellsEndpoint/$index',
    );
    return SpellDetailModel.fromJson(response.data!);
  }

  /// Busca todos os equipamentos e mapeia a lista `"results"` para modelos.
  @override
  Future<List<EquipmentSummaryModel>> getEquipments() async {
    final response = await _dio.get<Map<String, dynamic>>(_equipmentEndpoint);
    final results = response.data!['results'] as List<dynamic>;
    return results
        .cast<Map<String, dynamic>>()
        .map(EquipmentSummaryModel.fromJson)
        .toList();
  }

  /// Busca os detalhes do equipamento pelo [index]; o payload raiz já é o objeto.
  @override
  Future<EquipmentDetailModel> getEquipmentDetail(String index) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_equipmentEndpoint/$index',
    );
    return EquipmentDetailModel.fromJson(response.data!);
  }

  /// Retorna uma página de monstros, buscando da API apenas na primeira chamada.
  ///
  /// Se [_cachedMonsters] ainda não foi populado, faz um único GET à API e
  /// armazena o resultado completo. As chamadas seguintes pulam a rede e
  /// fatiam diretamente a lista em memória com `.skip(offset).take(limit)`.
  ///
  /// Em C# com Entity Framework, a paginação equivalente seria:
  /// `dbContext.Monsters.OrderBy(m => m.Name).Skip(offset).Take(limit).ToListAsync()`
  /// Aqui, contudo, a coleção já está em RAM, então `skip/take` são operações
  /// O(n) sobre `Iterable`, sem custo de I/O ou geração de SQL.
  @override
  Future<List<MonsterSummaryModel>> getMonsters(int offset, int limit) async {
    if (_cachedMonsters == null) {
      final response = await _dio.get<Map<String, dynamic>>(_monstersEndpoint);
      final results = response.data!['results'] as List<dynamic>;
      _cachedMonsters = results
          .cast<Map<String, dynamic>>()
          .map(MonsterSummaryModel.fromJson)
          .toList();
    }
    return _cachedMonsters!.skip(offset).take(limit).toList();
  }

  /// Busca todas as classes e mapeia a lista `"results"` do payload para modelos.
  @override
  Future<List<ApiReferenceModel>> getClasses() async {
    final response = await _dio.get<Map<String, dynamic>>(_classesEndpoint);
    final results = response.data!['results'] as List<dynamic>;
    return results
        .cast<Map<String, dynamic>>()
        .map(ApiReferenceModel.fromJson)
        .toList();
  }

  /// Busca todas as raças e mapeia a lista `"results"` do payload para modelos.
  @override
  Future<List<ApiReferenceModel>> getRaces() async {
    final response = await _dio.get<Map<String, dynamic>>(_racesEndpoint);
    final results = response.data!['results'] as List<dynamic>;
    return results
        .cast<Map<String, dynamic>>()
        .map(ApiReferenceModel.fromJson)
        .toList();
  }
}
