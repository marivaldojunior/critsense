import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/skeleton_bones.dart';

import '../../domain/entities/character.dart';
import '../bloc/character_bloc.dart';
import '../widgets/character_avatar.dart';
import 'character_form_screen.dart';
import 'character_sheet_screen.dart';

/// Tela de listagem de personagens da Ficha de RPG.
///
/// [StatefulWidget] apenas para guardar [_pendingDeleteIds]: o conjunto de
/// personagens removidos visualmente da lista, mas cuja exclusão real no
/// repositório ainda está "em espera" enquanto o SnackBar de desfazer está
/// visível. Todo o resto do estado (a lista em si) continua vivendo no
/// [CharacterBloc], fornecido pela árvore de widgets via [BlocProvider].
class CharacterListScreen extends StatefulWidget {
  const CharacterListScreen({super.key});

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  /// IDs de personagens já removidos da lista visível, mas ainda não
  /// excluídos do repositório — a exclusão real só é disparada quando o
  /// SnackBar correspondente fecha sem que "Desfazer" tenha sido tocado.
  final Set<String> _pendingDeleteIds = {};

  /// Remove [character] da lista visível imediatamente e agenda a exclusão
  /// real para quando o SnackBar fechar sem interação (timeout ou
  /// substituição por outro SnackBar). Tocar em "Desfazer" apenas retira o
  /// id de [_pendingDeleteIds], fazendo o item reaparecer — a chamada ao
  /// [CharacterBloc] só acontece se isso não ocorrer a tempo.
  void _handleDelete(BuildContext context, Character character) {
    setState(() => _pendingDeleteIds.add(character.id));
    final bloc = context.read<CharacterBloc>();

    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text('${character.name} excluído.'),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () {
                if (!mounted) return;
                setState(() => _pendingDeleteIds.remove(character.id));
              },
            ),
          ),
        )
        .closed
        .then((reason) {
          if (!mounted) return;
          if (reason != SnackBarClosedReason.action) {
            bloc.add(DeleteCharacterEvent(character.id));
          }
          setState(() => _pendingDeleteIds.remove(character.id));
        });
  }

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
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: switch (state) {
              CharacterInitial() =>
                const SizedBox.shrink(key: ValueKey('initial')),
              CharacterLoading() =>
                const _CharacterListSkeleton(key: ValueKey('loading')),
              CharacterLoaded(:final characters) => _buildLoaded(
                context,
                characters,
              ),
              CharacterError(:final message) => Center(
                key: const ValueKey('error'),
                child: Text(
                  'Erro: $message',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            },
          );
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

  /// Filtra [_pendingDeleteIds] de [characters] antes de decidir entre o
  /// estado vazio e a lista — um personagem em espera de exclusão some da
  /// tela assim que o swipe termina, mesmo que a exclusão real ainda não
  /// tenha sido persistida.
  Widget _buildLoaded(BuildContext context, List<Character> characters) {
    final visible = characters
        .where((c) => !_pendingDeleteIds.contains(c.id))
        .toList();

    if (visible.isEmpty) {
      return const Center(
        key: ValueKey('empty'),
        child: Text('Nenhum personagem encontrado.'),
      );
    }

    return ListView.builder(
      key: const ValueKey('loaded'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: visible.length,
      itemBuilder: (context, index) {
        final character = visible[index];
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
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (_) => _handleDelete(context, character),
          child: _CharacterCard(character: character),
        );
      },
    );
  }
}

/// Esqueleto de carregamento que imita a silhueta exata de [_CharacterCard]:
/// mesmo [Card]/[ListTile] real, só trocando o conteúdo por [SkeletonBones]
/// — o avatar circular de [CharacterAvatar] tem raio padrão 22 (diâmetro
/// 44), reproduzido aqui como um osso circular do mesmo tamanho.
class _CharacterListSkeleton extends StatelessWidget {
  const _CharacterListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: const SkeletonBones.circle(size: 44),
            title: const Align(
              alignment: Alignment.centerLeft,
              child: SkeletonBones.rect(width: 140, height: 14),
            ),
            subtitle: const Padding(
              padding: EdgeInsets.only(top: 6),
              child: SkeletonBones.rect(width: 100, height: 11),
            ),
            trailing: const SkeletonBones.rect(
              width: 64,
              height: 24,
              borderRadius: 12,
            ),
          ),
        ),
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
        leading: CharacterAvatar(character: character),
        title: Text(
          character.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${character.characterClass} • Nível ${character.level}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Chip(
          label: Text(
            'HP ${character.currentHitPoints}/${character.maxHitPoints}',
          ),
          visualDensity: VisualDensity.compact,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<CharacterBloc>(),
              child: CharacterSheetScreen(character: character),
            ),
          ),
        ),
      ),
    );
  }
}
