/// Modo de rolagem aplicável exclusivamente aos dados d20 do pool.
///
/// Em [advantage], cada d20 do pool é rolado duas vezes e o maior valor é
/// mantido; em [disadvantage], o menor. Outros tipos de dado ignoram este
/// modo — a regra de vantagem/desvantagem é específica do d20.
enum D20RollMode { normal, advantage, disadvantage }
