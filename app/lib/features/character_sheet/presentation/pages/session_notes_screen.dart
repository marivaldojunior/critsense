import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/core/presentation/widgets/skeleton_bones.dart';
import 'package:crit_sense/di/injection_container.dart';
import 'package:crit_sense/features/voice_commands/domain/entities/voice_command.dart';
import 'package:crit_sense/features/voice_commands/domain/services/on_device_ai.dart';
import 'package:crit_sense/features/voice_commands/domain/services/session_summarizer.dart';
import 'package:crit_sense/features/voice_commands/presentation/cubit/voice_command_cubit.dart';
import 'package:crit_sense/features/voice_commands/presentation/widgets/voice_command_sheet.dart';

import '../../domain/entities/session_note.dart';
import '../bloc/session_notes_bloc.dart';

/// Tela do Diário de Campanha: lista e gerencia as notas de sessão de um personagem.
///
/// Recebe [characterId] e [characterName] como parâmetros de rota para exibir
/// e persistir notas vinculadas ao personagem correto. O estado das notas
/// fica no [SessionNotesBloc], criado por esta tela.
class SessionNotesScreen extends StatelessWidget {
  /// Identificador do personagem dono das notas.
  final String characterId;

  /// Nome do personagem, usado apenas para exibição no título da tela.
  final String characterName;

  /// Caminho local do avatar do personagem; nulo quando não definido.
  final String? avatarPath;

  const SessionNotesScreen({
    super.key,
    required this.characterId,
    required this.characterName,
    this.avatarPath,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SessionNotesBloc>(
      create: (_) =>
          sl<SessionNotesBloc>()..add(LoadSessionNotesEvent(characterId)),
      child: _SessionNotesView(
        characterId: characterId,
        characterName: characterName,
        avatarPath: avatarPath,
      ),
    );
  }
}

class _SessionNotesView extends StatelessWidget {
  final String characterId;
  final String characterName;
  final String? avatarPath;

  const _SessionNotesView({
    required this.characterId,
    required this.characterName,
    this.avatarPath,
  });

  /// Esconde [note] da lista imediatamente e só confirma a exclusão no
  /// [SessionNotesBloc] quando o SnackBar de desfazer fecha sem interação
  /// (timeout ou substituição por outro SnackBar). Tocar em "Desfazer"
  /// devolve a nota à posição original e a exclusão nunca é persistida.
  ///
  /// O SnackBar vive no `ScaffoldMessenger` raiz e pode fechar depois que a
  /// tela saiu — por isso o `isClosed`: nesse caso o próprio
  /// [SessionNotesBloc.close] já concluiu a exclusão.
  void _handleDeleteNote(BuildContext context, SessionNote note) {
    final bloc = context.read<SessionNotesBloc>()
      ..add(HideSessionNoteEvent(note));

    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: const Text('Nota excluída.'),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () {
                if (!bloc.isClosed) bloc.add(UndoHideSessionNoteEvent(note));
              },
            ),
          ),
        )
        .closed
        .then((reason) {
          if (reason == SnackBarClosedReason.action || bloc.isClosed) return;
          bloc.add(ConfirmDeleteSessionNoteEvent(note));
        });
  }

  /// Exibe o painel de criação de nota e envia a nota ao [SessionNotesBloc]
  /// ao confirmar. [title] e [content] preenchem o painel (ex: uma nota
  /// ditada), e o jogador ainda pode editar antes de salvar.
  void _showAddNoteSheet(
    BuildContext context, {
    String title = '',
    String content = '',
  }) {
    final bloc = context.read<SessionNotesBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddNoteSheet(
        initialTitle: title,
        initialContent: content,
        onSave: (title, content) => bloc.add(
          AddSessionNoteEvent(
            SessionNote(
              id: const Uuid().v4(),
              characterId: characterId,
              title: title,
              content: content,
              createdAt: DateTime.now(),
            ),
          ),
        ),
      ),
    );
  }

  /// Resume as notas do último dia de jogo com o Gemini Nano, no aparelho.
  /// O resumo pode virar uma nota nova.
  Future<void> _summarize(BuildContext context) async {
    final bloc = context.read<SessionNotesBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    void tell(String text) =>
        messenger.showSnackBar(SnackBar(content: Text(text)));

    final notes = SessionSummarizer.notesOfLastSession(bloc.state.notes);
    if (notes.isEmpty) {
      tell('Escreva as notas da sessão antes de pedir o resumo.');
      return;
    }
    final ai = sl<OnDeviceAi>();
    final status = await ai.status();
    if (!context.mounted) return;
    if (status == OnDeviceAiStatus.unavailable) {
      tell('A IA do aparelho (Gemini Nano) não está disponível neste celular.');
      return;
    }
    if (status != OnDeviceAiStatus.available) {
      final download = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Baixar a IA do aparelho?'),
          content: const Text(
            'O resumo usa o Gemini Nano, que roda no celular. O Android baixa '
            'o modelo uma vez. As notas não saem do aparelho.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Baixar'),
            ),
          ],
        ),
      );
      if (download != true) return;
      tell('Baixando a IA do aparelho. Isso pode levar alguns minutos.');
      if (!await ai.download()) {
        tell('Não foi possível baixar a IA do aparelho.');
        return;
      }
      if (!context.mounted) return;
    }

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text('Resumindo ${notes.length} nota(s)...')),
            ],
          ),
        ),
      ),
    );
    final summary = await SessionSummarizer(ai).summarize(notes);
    navigator.pop();
    if (!context.mounted) return;
    if (summary == null) {
      tell('A IA do aparelho não respondeu. Tente de novo.');
      return;
    }

    final day = DateFormat('dd/MM/yyyy').format(notes.last.createdAt);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Resumo da sessão de $day'),
        content: SingleChildScrollView(child: Text(summary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
          FilledButton(
            onPressed: () {
              bloc.add(
                AddSessionNoteEvent(
                  SessionNote(
                    id: const Uuid().v4(),
                    characterId: characterId,
                    title: 'Resumo da sessão de $day',
                    content: summary,
                    createdAt: DateTime.now(),
                  ),
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Salvar no diário'),
          ),
        ],
      ),
    );
  }

  /// Dita uma nota por voz e abre o painel já preenchido.
  Future<void> _dictateNote(BuildContext context) async {
    final command = await showVoiceCommandSheet(
      context,
      scope: VoiceScope.dictation,
    );
    if (command is! NoteCommand || !context.mounted) return;
    _showAddNoteSheet(
      context,
      title: noteTitleFrom(command.text),
      content: command.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: avatarPath != null
            ? Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundImage: FileImage(File(avatarPath!)),
                ),
              )
            : null,
        title: Text(
          'Diário: $characterName',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Resumir sessão',
            icon: const Icon(Icons.auto_awesome_outlined),
            onPressed: () => _summarize(context),
          ),
          VoiceCommandButton(
            tooltip: 'Ditar nota',
            onPressed: () => _dictateNote(context),
          ),
        ],
      ),
      body: BlocConsumer<SessionNotesBloc, SessionNotesState>(
        // Erros de escrita (salvar/excluir) não trocam a lista por uma tela
        // de erro: aparecem só num SnackBar. O erro de carga já tem a sua
        // própria tela, então não gera SnackBar.
        listenWhen: (previous, current) =>
            current.errorMessage != null &&
            current.status != SessionNotesStatus.failure,
        listener: (context, state) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        },
        builder: (context, state) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildBody(context, theme, state),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteSheet(context),
        tooltip: 'Nova anotação',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Resolve o corpo da tela a partir do [state] — cada branch tem uma
  /// [ValueKey] distinta para o [AnimatedSwitcher] disparar o fade.
  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    SessionNotesState state,
  ) {
    switch (state.status) {
      case SessionNotesStatus.initial:
      case SessionNotesStatus.loading:
        return const _SessionNotesSkeleton(key: ValueKey('loading'));
      case SessionNotesStatus.failure:
        return Center(
          key: const ValueKey('failure'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Não foi possível carregar as notas.'),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => context.read<SessionNotesBloc>().add(
                  LoadSessionNotesEvent(characterId),
                ),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        );
      case SessionNotesStatus.success:
        if (state.notes.isEmpty) {
          return Center(
            key: const ValueKey('empty'),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DnDIcon(
                  assetPath: 'assets/icons/entity/book.svg',
                  size: 64,
                  color: theme.colorScheme.outlineVariant,
                ),
                const SizedBox(height: 12),
                const Text('Nenhuma anotação ainda.'),
              ],
            ),
          );
        }
        return ListView.builder(
          key: const ValueKey('loaded'),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: state.notes.length,
          itemBuilder: (context, index) {
            final note = state.notes[index];
            return _SessionNoteCard(
              note: note,
              onDismissed: () => _handleDeleteNote(context, note),
            );
          },
        );
    }
  }
}

/// Esqueleto de carregamento que imita a silhueta de [_SessionNoteCard]:
/// título + data numa linha e três linhas de prévia do conteúdo, a última
/// mais curta para reproduzir o fim natural de um parágrafo.
/// Painel de criação de nota. É um [StatefulWidget] para os controllers
/// viverem até o fim da animação de fechar do painel.
class _AddNoteSheet extends StatefulWidget {
  const _AddNoteSheet({
    required this.initialTitle,
    required this.initialContent,
    required this.onSave,
  });

  final String initialTitle;
  final String initialContent;
  final void Function(String title, String content) onSave;

  @override
  State<_AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends State<_AddNoteSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _titleCtrl = TextEditingController(text: widget.initialTitle);
  late final _contentCtrl = TextEditingController(text: widget.initialContent);

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nova Anotação',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obrigatório.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contentCtrl,
              decoration: const InputDecoration(
                labelText: 'Conteúdo',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obrigatório.' : null,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.save_outlined),
              label: const Text('Salvar'),
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                widget.onSave(_titleCtrl.text.trim(), _contentCtrl.text.trim());
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionNotesSkeleton extends StatelessWidget {
  const _SessionNotesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    SkeletonBones.rect(width: 140, height: 14),
                    Spacer(),
                    SkeletonBones.rect(width: 70, height: 11),
                  ],
                ),
                SizedBox(height: 12),
                SkeletonBones.rect(width: double.infinity, height: 11),
                SizedBox(height: 6),
                SkeletonBones.rect(width: double.infinity, height: 11),
                SizedBox(height: 6),
                SkeletonBones.rect(width: 180, height: 11),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Card de exibição de uma nota de sessão com suporte a deleção por swipe.
///
/// Não mostra SnackBar nem persiste a exclusão: apenas notifica [onDismissed]
/// quando o swipe termina — quem decide o fluxo de desfazer/exclusão real é
/// a tela pai, dona da lista.
class _SessionNoteCard extends StatelessWidget {
  final SessionNote note;
  final VoidCallback onDismissed;

  const _SessionNoteCard({required this.note, required this.onDismissed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatted = DateFormat('dd/MM/yyyy HH:mm').format(note.createdAt);

    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDismissed(),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    formatted,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: theme.textTheme.bodyMedium,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
