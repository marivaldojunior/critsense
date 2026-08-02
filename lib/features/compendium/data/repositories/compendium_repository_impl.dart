import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/api_reference.dart';
import '../../domain/entities/equipment_summary.dart';
import '../../domain/entities/monster_summary.dart';
import '../../domain/entities/spell_detail.dart';
import '../../domain/entities/spell_summary.dart';
import '../../domain/repositories/i_compendium_repository.dart';
import '../datasources/compendium_remote_datasource.dart';

/// Implementação concreta de [ICompendiumRepository].
///
/// Isolar [ICompendiumRemoteDataSource] do domínio garante que trocar
/// o cliente HTTP (ex: Dio → http) nunca impacte Use Cases ou BLoCs.
class CompendiumRepositoryImpl implements ICompendiumRepository {
  final ICompendiumRemoteDataSource _remoteDataSource;

  const CompendiumRepositoryImpl(ICompendiumRemoteDataSource remoteDataSource)
    : _remoteDataSource = remoteDataSource;

  /// Delega a busca ao datasource e converte erros de rede em [ServerException].
  ///
  /// O `DioException` é capturado aqui na fronteira de infraestrutura para que
  /// o domínio nunca precise depender do pacote Dio — princípio de inversão de
  /// dependência. O Use Case recebe apenas [SpellSummary]s ou uma exceção
  /// agnóstica de infraestrutura.
  @override
  Future<List<SpellSummary>> getSpells() async {
    try {
      return await _remoteDataSource.getSpells();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Erro de rede desconhecido.');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Busca os detalhes da magia e converte erros de rede em [ServerException].
  @override
  Future<SpellDetail> getSpellDetail(String index) async {
    try {
      return await _remoteDataSource.getSpellDetail(index);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Erro de rede desconhecido.');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Busca os equipamentos e converte erros de rede em [ServerException].
  @override
  Future<List<EquipmentSummary>> getEquipments() async {
    try {
      return await _remoteDataSource.getEquipments();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Erro de rede desconhecido.');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Busca a página de monstros e converte erros de rede em [ServerException].
  @override
  Future<List<MonsterSummary>> getMonsters({
    required int offset,
    required int limit,
  }) async {
    try {
      return await _remoteDataSource.getMonsters(offset, limit);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Erro de rede desconhecido.');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Busca a lista de classes e converte erros de rede em [ServerException].
  @override
  Future<List<ApiReference>> getClasses() async {
    try {
      return await _remoteDataSource.getClasses();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Erro de rede desconhecido.');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Busca a lista de raças e converte erros de rede em [ServerException].
  @override
  Future<List<ApiReference>> getRaces() async {
    try {
      return await _remoteDataSource.getRaces();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Erro de rede desconhecido.');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
