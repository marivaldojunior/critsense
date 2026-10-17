/// Tipos de moeda do SRD, do menor para o maior valor.
enum Coin {
  copper('PC', 'Cobre', 1),
  silver('PP', 'Prata', 10),
  electrum('PE', 'Electro', 50),
  gold('PO', 'Ouro', 100),
  platinum('PL', 'Platina', 1000);

  /// Sigla usada na ficha em português (PC, PP, PE, PO, PL).
  final String abbreviation;
  final String label;

  /// Valor em peças de cobre.
  final int valueInCopper;

  const Coin(this.abbreviation, this.label, this.valueInCopper);
}

/// Moedas do personagem.
class Coins {
  final Map<Coin, int> amounts;

  const Coins([this.amounts = const {}]);

  int of(Coin coin) => amounts[coin] ?? 0;

  Coins withAmount(Coin coin, int amount) =>
      Coins({...amounts, coin: amount < 0 ? 0 : amount});

  int get totalCoins => Coin.values.fold(0, (sum, coin) => sum + of(coin));

  /// Valor total convertido em peças de ouro.
  double get totalInGold =>
      Coin.values.fold(0, (sum, coin) => sum + of(coin) * coin.valueInCopper) /
      Coin.gold.valueInCopper;

  /// No SRD, 50 moedas pesam 1 libra.
  double get weight => totalCoins / 50;
}
