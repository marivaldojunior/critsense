/// Estado do modelo de IA no aparelho (Gemini Nano).
enum OnDeviceAiStatus {
  /// O modelo está pronto.
  available,

  /// O aparelho tem suporte, mas o modelo ainda não foi baixado.
  downloadable,

  /// O Android está baixando o modelo.
  downloading,

  /// O aparelho não tem suporte (ou não é Android).
  unavailable,
}

/// Modelo de linguagem que roda no aparelho, sem enviar o texto para a
/// nuvem. Fica atrás desta interface para os testes não usarem o Android.
abstract interface class OnDeviceAi {
  Future<OnDeviceAiStatus> status();

  /// Baixa o modelo. Devolve `true` quando ele fica pronto.
  Future<bool> download();

  /// Gera um texto a partir de [prompt]. Devolve `null` se o modelo não
  /// respondeu.
  Future<String?> generate(
    String prompt, {
    double temperature = 0.1,
    int maxOutputTokens = 256,
  });
}
