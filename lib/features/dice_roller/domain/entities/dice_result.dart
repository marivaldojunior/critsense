/// Representa o resultado de um único lançamento de dado (d20).
///
/// Esta entidade é o objeto central da camada de domínio: ela carrega
/// o valor bruto do dado e os dois estados especiais de RPG — acerto
/// crítico e falha crítica — calculados no momento da criação do objeto.
///
/// Por ser uma entidade de domínio puro, não depende de nenhuma camada
/// externa (UI, banco de dados, Flutter SDK), garantindo que as regras de
/// negócio sejam testáveis de forma isolada.
class DiceResult {
  /// O valor numérico obtido no lançamento (de 1 a 20 para um d20).
  // `final` impede reatribuição após a construção, tornando a entidade
  // imutável — comportamento desejado em domínios funcionais/puros.
  final int value;

  /// Indica se o lançamento foi um acerto crítico (valor == 20).
  ///
  /// Em sistemas d20, o 20 natural representa o máximo possível,
  /// desencadeando efeitos especiais independentemente de modificadores.
  final bool isCriticalSuccess;

  /// Indica se o lançamento foi uma falha crítica (valor == 1).
  ///
  /// O 1 natural representa o pior resultado possível, podendo causar
  /// consequências negativas automáticas no sistema de jogo.
  final bool isCriticalFailure;

  /// Construtor principal com inicialização explícita de todos os campos.
  ///
  /// Recebe apenas o [value] bruto; os booleanos de estado crítico são
  /// derivados dele via initializer list (`: isCriticalSuccess = ...`),
  /// centralizando a regra de negócio no próprio construtor e evitando
  /// que o chamador precise conhecer os limiares críticos.
  ///
  /// O uso de initializer list (em vez de corpo `{}`) é idiomático em Dart
  /// para campos `final` que dependem de outros parâmetros: eles precisam
  /// ser resolvidos antes que o corpo do construtor execute.
  const DiceResult({
    required this.value,
    // Os campos críticos são calculados aqui, na initializer list,
    // porque `final` exige atribuição antes do corpo do construtor.
  }) : isCriticalSuccess = value == 20,
       isCriticalFailure = value == 1;

  /// Construtor nomeado de fábrica para facilitar testes e cenários especiais.
  ///
  /// `factory` é preferível a `const` aqui porque permite lógica condicional
  /// antes de delegar ao construtor principal, sem expor essa lógica ao chamador.
  ///
  /// Exemplo de uso em testes:
  /// ```dart
  /// final result = DiceResult.criticalSuccess();
  /// assert(result.isCriticalSuccess == true);
  /// ```
  factory DiceResult.criticalSuccess() => const DiceResult(value: 20);

  /// Construtor nomeado de fábrica que cria diretamente uma falha crítica.
  ///
  /// Segue o mesmo padrão de [DiceResult.criticalSuccess], promovendo
  /// legibilidade nos testes ao nomear o cenário explicitamente.
  factory DiceResult.criticalFailure() => const DiceResult(value: 1);

  @override
  String toString() =>
      'DiceResult(value: $value, criticalSuccess: $isCriticalSuccess, criticalFailure: $isCriticalFailure)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiceResult &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
