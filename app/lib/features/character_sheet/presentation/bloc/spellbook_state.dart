part of 'spellbook_bloc.dart';

enum SpellbookStatus { initial, loading, success, failure }

/// Estado do [SpellbookBloc]. Mesmo formato do `InventoryState`: uma falha
/// ao salvar mantém [spells] na tela e só preenche [errorMessage].
class SpellbookState extends Equatable {
  final SpellbookStatus status;

  /// Magias do grimório, por nível e nome.
  final List<CharacterSpell> spells;

  final String? errorMessage;

  const SpellbookState({
    this.status = SpellbookStatus.initial,
    this.spells = const [],
    this.errorMessage,
  });

  /// [errorMessage] não é herdado: toda emissão nova limpa o erro anterior.
  SpellbookState copyWith({
    SpellbookStatus? status,
    List<CharacterSpell>? spells,
    String? errorMessage,
  }) {
    return SpellbookState(
      status: status ?? this.status,
      spells: spells ?? this.spells,
      errorMessage: errorMessage,
    );
  }

  /// Quantas magias (sem contar truques) estão preparadas.
  int get preparedCount =>
      spells.where((s) => s.prepared && !s.isCantrip).length;

  @override
  List<Object?> get props => [status, spells, errorMessage];
}
