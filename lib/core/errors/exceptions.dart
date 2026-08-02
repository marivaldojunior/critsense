/// Exceção lançada quando a API retorna um erro ou a conexão falha.
class ServerException implements Exception {
  final String message;

  const ServerException([this.message = 'Erro no servidor.']);

  @override
  String toString() => 'ServerException: $message';
}
