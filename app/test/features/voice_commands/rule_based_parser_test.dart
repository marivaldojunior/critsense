import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/features/voice_commands/domain/entities/voice_command.dart';
import 'package:crit_sense/features/voice_commands/domain/services/rule_based_parser.dart';
import 'package:crit_sense/features/voice_commands/domain/services/spoken_text.dart';

/// Testa as regras fixas que convertem a fala em comandos.
void main() {
  const parser = RuleBasedParser();

  group('números por extenso', () {
    String n(String text) => replaceNumberWords(normalizeSpoken(text));

    test('converte unidades, dezenas e centenas', () {
      expect(n('doze'), '12');
      expect(n('vinte e cinco de dano'), '25 de dano');
      expect(n('cento e vinte e três'), '123');
      expect(n('um dê vinte'), '1 de 20');
      expect(n('dois seis'), '2 6');
      expect(n('Goblin dois toma oito'), 'goblin 2 toma 8');
    });

    test('tira acentos e pontuação', () {
      expect(normalizeSpoken('Próximo   turno!'), 'proximo turno');
      expect(normalizeSpoken('2d6+3'), '2d6+3');
    });
  });

  group('dano e cura', () {
    test('dano no próprio personagem', () {
      expect(parser.parse('dano 12'), const DamageCommand(12));
      expect(
        parser.parse('levei sete de dano cortante'),
        const DamageCommand(7),
      );
      expect(parser.parse('Tomei 15 de dano de fogo'), const DamageCommand(15));
      expect(parser.parse('perdi 4 pontos de vida'), const DamageCommand(4));
    });

    test('dano numa criatura do combate', () {
      expect(
        parser.parse('o lobo leva 8 de dano'),
        const DamageCommand(8, target: 'lobo'),
      );
      expect(
        parser.parse('goblin dois toma oito de dano'),
        const DamageCommand(8, target: 'goblin 2'),
      );
      expect(
        parser.parse('dano de 6 no ogro'),
        const DamageCommand(6, target: 'ogro'),
      );
    });

    test('cura e PV temporários', () {
      expect(parser.parse('curar 5'), const HealCommand(5));
      expect(
        parser.parse('recuperei dez pontos de vida'),
        const HealCommand(10),
      );
      expect(
        parser.parse('cura o lobo em 3'),
        const HealCommand(3, target: 'lobo'),
      );
      expect(
        parser.parse('ganhei 5 de vida temporária'),
        const TempHpCommand(5),
      );
    });
  });

  group('dados', () {
    test('rola a notação falada', () {
      expect(parser.parse('rolar 2d6 mais 3'), const RollCommand('2d6+3'));
      expect(
        parser.parse('rola dois dê seis mais três'),
        const RollCommand('2d6+3'),
      );
      expect(
        parser.parse('jogar um d vinte menos um'),
        const RollCommand('1d20-1'),
      );
      expect(parser.parse('d20'), const RollCommand('d20'));
      expect(parser.parse('rolar 3D8'), const RollCommand('3d8'));
    });

    test('recusa um dado que não existe', () {
      expect(parser.parse('rolar 1d7'), isNull);
    });

    test('iniciativa', () {
      expect(parser.parse('rolar iniciativa'), const InitiativeRollCommand());
    });
  });

  group('descanso, turno, concentração e notas', () {
    test('descansos', () {
      expect(parser.parse('descanso curto'), const ShortRestCommand());
      expect(parser.parse('fazer um descanso longo'), const LongRestCommand());
    });

    test('turnos', () {
      expect(parser.parse('próximo turno'), const NextTurnCommand());
      expect(parser.parse('passa a vez'), const NextTurnCommand());
      expect(parser.parse('voltar o turno'), const PreviousTurnCommand());
    });

    test('concentração', () {
      expect(
        parser.parse('concentrar em bless'),
        const ConcentrationCommand('Bless'),
      );
      expect(
        parser.parse('perdi a concentração'),
        const ConcentrationCommand(null),
      );
    });

    test('notas guardam o texto original', () {
      expect(
        parser.parse('anotar o rei mentiu sobre o dragão'),
        const NoteCommand('O rei mentiu sobre o dragão'),
      );
      expect(
        parser.parse('Nota: a taverna fica em Phandalin'),
        const NoteCommand('A taverna fica em Phandalin'),
      );
    });
  });

  test('frase sem comando devolve null', () {
    expect(parser.parse(''), isNull);
    expect(parser.parse('o mestre está atrasado'), isNull);
    expect(parser.parse('dano'), isNull);
  });
}
