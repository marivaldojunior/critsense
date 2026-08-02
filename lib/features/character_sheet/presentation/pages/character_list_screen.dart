import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/character.dart';
import '../bloc/character_bloc.dart';
import 'character_form_screen.dart';
import 'session_notes_screen.dart';

/// Tela de listagem de personagens da Ficha de RPG.
///
/// É um [StatelessWidget] puro: não gerencia estado internamente.
/// Todo o estado vive no [CharacterBloc], que é fornecido pela árvore de
/// widgets via [BlocProvider].
class CharacterListScreen extends StatelessWidget {
  const CharacterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personagens')),
      // BlocBuilder observa o stream do CharacterBloc e reconstrói apenas
      // o subwidget que envolve — análogo ao React: em vez de re-renderizar
      // o componente pai inteiro, apenas o filho "conectado" ao store é
      // atualizado. O Scaffold, AppBar e FAB permanecem intocados entre
      // mudanças de estado, preservando performance e animações.
      body: BlocBuilder<CharacterBloc, CharacterState>(
        builder: (context, state) {
          return switch (state) {
            CharacterInitial() => const SizedBox.shrink(),
            CharacterLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            CharacterLoaded(:final characters) when characters.isEmpty =>
              const Center(child: Text('Nenhum personagem encontrado.')),
            CharacterLoaded(:final characters) => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];
                // Key é obrigatória em listas dinâmicas: o Flutter usa as Keys
                // para rastrear a identidade de cada elemento entre rebuilds.
                // Sem elas, ao remover o item de índice 2 numa lista de 5,
                // o framework pode associar o estado do item removido ao
                // vizinho — causando animações erradas ou onDismissed
                // disparando no elemento incorreto. ValueKey(id) garante
                // que cada Dismissible seja inequivocamente identificado pelo
                // dado que representa, não pela posição efêmera na lista.
                return Dismissible(
                  key: ValueKey(character.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) {
                    context.read<CharacterBloc>().add(
                      DeleteCharacterEvent(character.id),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${character.name} excluído.')),
                    );
                  },
                  child: _CharacterCard(character: character),
                );
              },
            ),
            CharacterError(:final message) => Center(
              child: Text(
                'Erro: $message',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CharacterBloc>(),
                child: const CharacterFormScreen(),
              ),
            ),
          );
        },
        tooltip: 'Criar personagem',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Card de exibição resumida de um personagem.
///
/// Extraído como widget privado para que o [ListView.builder] reconstrua
/// apenas os itens visíveis — sem impacto no restante da tela.
class _CharacterCard extends StatelessWidget {
  final Character character;

  const _CharacterCard({required this.character});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          character.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${character.characterClass} • Nível ${character.level}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Chip(
          label: Text('HP ${character.currentHp}/${character.maxHp}'),
          visualDensity: VisualDensity.compact,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SessionNotesScreen(
              characterId: character.id,
              characterName: character.name,
              avatarPath: character.avatarPath,
            ),
          ),
        ),
      ),
    );
  }
}
