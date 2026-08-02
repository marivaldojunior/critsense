import 'package:dio/dio.dart';

import '../models/spell_detail_model.dart';
import '../models/spell_summary_model.dart';

/// Contrato para o acesso remoto ao compêndio de magias.
abstract interface class ICompendiumRemoteDataSource {
  /// Busca a lista de magias na API remota.
  Future<List<SpellSummaryModel>> getSpells();

  /// Busca os detalhes completos da magia identificada por [index].
  Future<SpellDetailModel> getSpellDetail(String index);
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

  // URL base da API pública do D&D 5e.
  static const _spellsEndpoint = 'https://www.dnd5eapi.co/api/spells';

  /// Recebe o [Dio] pré-configurado via construtor para facilitar testes com mocks.
  const CompendiumRemoteDataSourceImpl(Dio dio) : _dio = dio;

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
}
