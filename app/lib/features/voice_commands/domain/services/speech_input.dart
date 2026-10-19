/// Transcrição da fala do jogador. Fica atrás desta interface para os testes
/// não usarem o microfone.
abstract interface class SpeechInput {
  /// Prepara o reconhecimento de voz e pede a permissão do microfone.
  /// Devolve `false` se o aparelho não tem reconhecimento de voz ou se o
  /// jogador negou a permissão.
  Future<bool> initialize();

  /// Começa a ouvir em pt-BR. [onText] recebe o texto parcial enquanto o
  /// jogador fala; o texto com [isFinal] `true` é o resultado final.
  /// [onError] recebe uma mensagem quando a escuta falha.
  Future<void> listen({
    required void Function(String text, bool isFinal) onText,
    required void Function(String message) onError,
  });

  /// Para de ouvir e entrega o último texto como final.
  Future<void> stop();

  /// Para de ouvir e descarta o texto.
  Future<void> cancel();
}
