import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/character.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/character_bloc.dart';
import 'package:crit_sense/features/character_sheet/presentation/widgets/character_avatar.dart';

/// BottomSheet reutilizável para escolher um dos personagens salvos
/// localmente — usado sempre que uma tela do Compêndio precisa vincular
/// algo (magia, item, monstro derrotado) a uma ficha.
///
/// Escuta o [CharacterBloc] já provido na raiz do app (ver `main.dart`,
/// acima do `Navigator`), exibindo a lista em avatar + nome. Ao tocar num
/// personagem, fecha o modal retornando-o via `Navigator.pop(context,
/// character)` — quem chamou [show] decide o que fazer com a seleção (qual
/// evento disparar, qual mensagem exibir).
class CharacterPickerBottomSheet extends StatelessWidget {
  const CharacterPickerBottomSheet({super.key, required this.bloc});

  final CharacterBloc bloc;

  /// Abre o BottomSheet e retorna o [Character] escolhido, ou `null` se o
  /// usuário fechar sem selecionar nenhum.
  ///
  /// Captura o [CharacterBloc] a partir de [context] *antes* de abrir o
  /// modal: o `context` interno do `showModalBottomSheet` não é descendente
  /// da árvore de onde ele foi chamado, então um `context.read` de dentro
  /// do modal não encontraria o provider.
  static Future<Character?> show(BuildContext context) {
    final bloc = context.read<CharacterBloc>();
    return showModalBottomSheet<Character>(
      context: context,
      builder: (_) => CharacterPickerBottomSheet(bloc: bloc),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<CharacterBloc, CharacterState>(
        // Usa o BLoC capturado em [show] via `bloc:`, sem depender de um
        // `context.read` local — ver o comentário em [show].
        bloc: bloc,
        builder: (context, state) {
          if (state is! CharacterLoaded || state.characters.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Nenhum personagem disponível.')),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Selecione um personagem',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.characters.length,
                  itemBuilder: (_, index) {
                    final character = state.characters[index];
                    return ListTile(
                      leading: CharacterAvatar(character: character),
                      title: Text(
                        character.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${character.characterClass} • Nível ${character.level}',
                      ),
                      onTap: () => Navigator.pop(context, character),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
