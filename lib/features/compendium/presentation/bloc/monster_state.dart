part of 'monster_bloc.dart';

/// Enum que descreve a fase atual do carregamento do bestiário.
enum MonsterStatus {
  /// Estado inicial antes de qualquer requisição.
  initial,

  /// Última operação concluída com sucesso.
  success,

  /// Última operação resultou em falha.
  failure,
}

/// Estado único e imutável do [MonsterBloc], atualizado via [copyWith].
///
/// Diferentemente da hierarquia `sealed` usada nos outros BLoCs do compêndio,
/// aqui adotamos uma única classe com `copyWith` — padrão idiomático do
/// `flutter_bloc` para scroll infinito, pois precisamos *acumular* a lista
/// entre emissões sem descartar o estado anterior.
///
/// A imutabilidade é garantida da mesma forma que os `record` do C# 9+:
/// `copyWith` nunca modifica o objeto original; cria e retorna uma nova
/// instância substituindo apenas os campos fornecidos. Assim como
/// `record with { Status = MonsterStatus.Success }` em C#, cada `copyWith`
/// produz um snapshot independente, eliminando mutações acidentais e
/// tornando cada estado rastreável e testável de forma isolada.
class MonsterState {
  /// Fase atual do carregamento.
  final MonsterStatus status;

  /// Lista acumulada de monstros carregados até o momento.
  final List<MonsterSummary> monsters;

  /// Indica que todas as páginas disponíveis já foram carregadas.
  final bool hasReachedMax;

  const MonsterState({
    this.status = MonsterStatus.initial,
    this.monsters = const [],
    this.hasReachedMax = false,
  });

  /// Retorna uma cópia deste estado substituindo apenas os campos fornecidos.
  MonsterState copyWith({
    MonsterStatus? status,
    List<MonsterSummary>? monsters,
    bool? hasReachedMax,
  }) {
    return MonsterState(
      status: status ?? this.status,
      monsters: monsters ?? this.monsters,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
