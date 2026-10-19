/// Funções que limpam o texto falado antes do parser.

const _accents = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'é': 'e', 'ê': 'e', 'í': 'i', //
  'ó': 'o', 'ô': 'o', 'õ': 'o', 'ú': 'u', 'ü': 'u', 'ç': 'c',
};

/// Texto em minúsculas, sem acentos e sem pontuação (menos `+` e `-`), com
/// um espaço entre as palavras.
String normalizeSpoken(String text) {
  final lower = text.toLowerCase().split('').map((c) => _accents[c] ?? c);
  return lower
      .join()
      .replaceAll(RegExp(r'[^a-z0-9+\- ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

const _units = {
  'zero': 0, 'um': 1, 'uma': 1, 'dois': 2, 'duas': 2, 'tres': 3, //
  'quatro': 4, 'cinco': 5, 'seis': 6, 'sete': 7, 'oito': 8, 'nove': 9,
  'dez': 10, 'onze': 11, 'doze': 12, 'treze': 13, 'quatorze': 14,
  'catorze': 14, 'quinze': 15, 'dezesseis': 16, 'dezessete': 17,
  'dezoito': 18, 'dezenove': 19, 'vinte': 20, 'trinta': 30, 'quarenta': 40,
  'cinquenta': 50, 'sessenta': 60, 'setenta': 70, 'oitenta': 80,
  'noventa': 90, 'cem': 100, 'cento': 100, 'duzentos': 200,
  'trezentos': 300, 'quatrocentos': 400, 'quinhentos': 500,
  'seiscentos': 600, 'setecentos': 700, 'oitocentos': 800, 'novecentos': 900,
};

/// Troca os números por extenso por algarismos, num texto já normalizado
/// (ex: "vinte e cinco de dano" → "25 de dano").
///
/// Palavras seguidas, ou ligadas por "e", somam: "cento e vinte e cinco" é
/// 125. Uma palavra de valor igual ou maior que a anterior começa outro
/// número ("dois seis" → "2 6").
String replaceNumberWords(String normalized) {
  final words = normalized.split(' ');
  final out = <String>[];
  var i = 0;
  while (i < words.length) {
    final first = _units[words[i]];
    if (first == null) {
      out.add(words[i]);
      i++;
      continue;
    }
    var total = first;
    var last = first;
    var j = i + 1;
    while (j < words.length) {
      final linkedByE =
          words[j] == 'e' &&
          j + 1 < words.length &&
          _units[words[j + 1]] != null;
      final next = linkedByE ? _units[words[j + 1]]! : _units[words[j]];
      if (next == null || next >= last || _digits(next) >= _digits(last)) {
        break;
      }
      total += next;
      last = next;
      j += linkedByE ? 2 : 1;
    }
    out.add('$total');
    i = j;
  }
  return out.join(' ');
}

/// Ordem de grandeza: 1 para unidades, 2 para dezenas e 3 para centenas.
int _digits(int n) => n >= 100 ? 3 : (n >= 10 && n % 10 == 0 ? 2 : 1);
