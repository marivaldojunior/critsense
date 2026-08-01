import '../entities/dice_result.dart';

/// Contrato (interface) que define as operações de lançamento de dado.
///
/// Em Clean Architecture, o repositório pertence à camada de domínio como
/// uma **abstração**: o domínio declara o que precisa, mas não sabe como
/// será implementado (banco de dados, gerador aleatório, chamada de API etc.).
///
/// Isso garante a **Inversão de Dependência** (o "D" do SOLID): camadas
/// internas (domínio) nunca dependem de camadas externas (infraestrutura).
/// A implementação concreta ficará na camada `data/` e será injetada
/// via construtor nos Use Cases.
abstract interface class IDiceRepository {
  /// Realiza um lançamento de dado e retorna o resultado encapsulado.
  ///
  /// O retorno é um [DiceResult], não um primitivo `int`, para que toda
  /// a lógica de negócio (crítico, falha) viaje junto com o valor — sem
  /// que o chamador precise replicar essas verificações.
  ///
  /// A assinatura é síncrona intencionalmente: gerar um número aleatório
  /// local não exige I/O assíncrono. Caso uma implementação futura precise
  /// de assincronicidade (ex: servidor remoto), basta criar uma segunda
  /// interface ou adaptar esta para retornar `Future<DiceResult>`.
  DiceResult rollDice();
}
