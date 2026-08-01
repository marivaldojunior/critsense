import 'dart:async';
import 'dart:math';

import 'package:crit_sense/features/dice_roller/domain/entities/dice_result.dart';
import 'package:crit_sense/features/dice_roller/domain/repositories/i_dice_repository.dart';
import '../datasources/sensor_datasource.dart';

/// Implementação concreta de [IDiceRepository] que combina geração de
/// número aleatório (Dart puro) com feedback nativo de hardware.
///
/// Responsabilidades desta classe:
/// 1. Gerar um valor inteiro aleatório entre 1 e 20 usando [Random].
/// 2. Encapsular o valor em uma entidade [DiceResult] (com lógica de crítico).
/// 3. Disparar feedback sensorial no hardware para resultados críticos.
/// 4. Retornar o [DiceResult] ao chamador.
///
/// A separação entre *geração do número* (domínio/dados) e *feedback*
/// (hardware/datasource) mantém cada componente com uma única razão para
/// mudar — Princípio da Responsabilidade Única (SRP).
class DiceRepositoryImpl implements IDiceRepository {
  /// Dependência de abstração de sensor/feedback, injetada via construtor.
  ///
  /// `final` garante que a referência não seja trocada após a construção,
  /// evitando estados inconsistentes ao longo da vida do objeto.
  final ISensorDataSource _sensorDataSource;

  /// Gerador de números aleatórios criptograficamente inseguro, mas suficiente
  /// para simular lançamentos de dado em um jogo de RPG de mesa.
  ///
  /// [Random] é instanciado uma vez e reutilizado: isso melhora a distribuição
  /// pseudo-aleatória (seeds repetidas produzem sequências iguais; uma única
  /// instância avança o estado interno continuamente).
  final Random _random;

  /// Injeta as dependências via construtor posicional.
  ///
  /// [_random] tem valor padrão para que o chamador de produção não precise
  /// criar um [Random] explicitamente, mas testes podem passar um [Random]
  /// com seed fixa para resultados determinísticos:
  ///
  /// ```dart
  /// final repo = DiceRepositoryImpl(mockSensor, random: Random(42));
  /// ```
  DiceRepositoryImpl(this._sensorDataSource, {Random? random})
    : _random = random ?? Random();

  /// Rola um dado de 20 faces, aciona feedback de hardware e retorna o resultado.
  ///
  /// **Por que o método é síncrono se o feedback é assíncrono?**
  ///
  /// O contrato [IDiceRepository.rollDice] é síncrono porque a **regra de
  /// negócio** (gerar e retornar o dado) é instantânea e não depende de I/O.
  /// O feedback sensorial é um **efeito colateral opcional** — se falhar, o
  /// dado já foi lançado e o resultado já é válido.
  ///
  /// Usamos `unawaited()` para disparar o [Future] do feedback sem bloquear
  /// o retorno. `unawaited` (de `dart:async`) documenta a intenção explícita
  /// de "fogo e esqueça", suprimindo avisos do linter sobre Futures ignorados.
  ///
  /// Qualquer [PlatformException] lançada pelo canal nativo já é absorvida
  /// internamente pelo [HardwareBridge] e não escala até aqui.
  @override
  DiceResult rollDice() {
    // `nextInt(20)` gera [0, 19]; somamos 1 para obter o intervalo [1, 20].
    final value = _random.nextInt(20) + 1;

    // A entidade calcula isCriticalSuccess/isCriticalFailure internamente —
    // o repositório não precisa conhecer os limiares críticos.
    final result = DiceResult(value: value);

    // Feedback: disparado apenas em resultados extremos (1 ou 20).
    // `unawaited` torna explícito que o Future é intencional e não um
    // esquecimento — o linter (unawaited_futures) não emitirá aviso.
    if (result.isCriticalSuccess) {
      unawaited(_sensorDataSource.triggerCriticalSuccess());
    } else if (result.isCriticalFailure) {
      unawaited(_sensorDataSource.triggerCriticalFailure());
    }

    return result;
  }
}
