import '../entities/dice_result.dart';
import '../repositories/i_dice_repository.dart';

/// Caso de uso responsável por orquestrar o lançamento de um dado.
///
/// Use Cases são a **camada de aplicação**: coordenam o fluxo entre
/// entidades e repositórios, sem conter regras de UI ou de infraestrutura.
/// Cada Use Case representa uma única ação de negócio coesa ("rolar o dado").
///
/// Manter um Use Case por arquivo facilita:
/// - Localização rápida de funcionalidades;
/// - Testes unitários focados;
/// - Evolução independente de cada comportamento.
class RollDiceUseCase {
  /// Referência à abstração do repositório, nunca à implementação concreta.
  ///
  /// `final` garante que a dependência não seja trocada após a construção,
  /// evitando estados inconsistentes ao longo do ciclo de vida do objeto.
  // Depender da interface `IDiceRepository` (e não de uma classe concreta)
  // é a aplicação direta do Princípio da Inversão de Dependência (DIP).
  final IDiceRepository _repository;

  /// Injeta o repositório via construtor (Dependency Injection manual).
  ///
  /// Ao receber `IDiceRepository` pelo construtor, este Use Case se torna
  /// completamente desacoplado da origem do dado aleatório. Em produção
  /// pode-se passar `DiceRepository()` (que usa `dart:math`); nos testes,
  /// um `MockDiceRepository` que retorna valores determinísticos.
  ///
  /// Parâmetros posicionais são preferidos aqui porque o Use Case tem
  /// apenas uma dependência, tornando a assinatura explícita e concisa.
  const RollDiceUseCase(this._repository);

  /// Executa o lançamento de dado delegando ao repositório injetado.
  ///
  /// O método `call()` é o padrão idiomático para Use Cases em Dart/Flutter:
  /// permite invocar a instância como se fosse uma função —
  /// `rollDiceUseCase()` — tornando o código nos presenters mais limpo.
  ///
  /// Retorna um [DiceResult] com o valor e os estados críticos já avaliados.
  DiceResult call() {
    // Delega a geração do número ao repositório: o Use Case não sabe (nem
    // deve saber) como o número aleatório é produzido — somente que ele
    // chegará embrulhado em um DiceResult com as regras de negócio aplicadas.
    return _repository.rollDice();
  }
}
