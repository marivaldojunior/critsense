import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/core/presentation/widgets/skeleton_bones.dart';
import 'package:crit_sense/di/injection_container.dart';
import '../../domain/entities/session_note.dart';
import '../../domain/usecases/add_session_note_usecase.dart';
import '../../domain/usecases/delete_session_note_usecase.dart';
import '../../domain/usecases/get_session_notes_usecase.dart';

/// Tela do Diário de Campanha: lista e gerencia as notas de sessão de um personagem.
///
/// Recebe [characterId] e [characterName] como parâmetros de rota para exibir
/// e persistir notas vinculadas ao personagem correto.
class SessionNotesScreen extends StatefulWidget {
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
  State<SessionNotesScreen> createState() => _SessionNotesScreenState();
}

class _SessionNotesScreenState extends State<SessionNotesScreen> {
  final _getNotesUseCase = sl<GetSessionNotesUseCase>();
  final _addNoteUseCase = sl<AddSessionNoteUseCase>();
  final _deleteNoteUseCase = sl<DeleteSessionNoteUseCase>();

  /// Lista de notas carregadas do banco; recarregada após cada mutação.
  List<SessionNote> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  /// Carrega (ou recarrega) as notas do personagem a partir do repositório.
  Future<void> _loadNotes() async {
    final notes = await _getNotesUseCase(widget.characterId);
    if (!mounted) return;
    setState(() {
      _notes = notes;
      _isLoading = false;
    });
  }

  /// Remove [note] da lista visível imediatamente e agenda a exclusão real
  /// no repositório para quando o SnackBar de desfazer fechar sem
  /// interação (timeout ou substituição por outro SnackBar). Tocar em
  /// "Desfazer" reinsere a nota na posição original e a exclusão real
  /// nunca chega a ser persistida.
  void _handleDeleteNote(SessionNote note) {
    final index = _notes.indexOf(note);
    setState(() => _notes.removeAt(index));

    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: const Text('Nota excluída.'),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () {
                if (!mounted) return;
                setState(
                  () => _notes.insert(index.clamp(0, _notes.length), note),
                );
              },
            ),
          ),
        )
        .closed
        .then((reason) async {
          if (reason == SnackBarClosedReason.action) return;
          await _deleteNoteUseCase(note.id);
        });
  }

  /// Exibe o painel de criação de nota e persiste ao confirmar.
  void _showAddNoteSheet() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Nova Anotação', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Campo obrigatório.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: contentCtrl,
                decoration: const InputDecoration(
                  labelText: 'Conteúdo',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Campo obrigatório.'
                    : null,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                icon: const Icon(Icons.save_outlined),
                label: const Text('Salvar'),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  final note = SessionNote(
                    id: const Uuid().v4(),
                    characterId: widget.characterId,
                    title: titleCtrl.text.trim(),
                    content: contentCtrl.text.trim(),
                    createdAt: DateTime.now(),
                  );

                  await _addNoteUseCase(note);
                  if (ctx.mounted) Navigator.pop(ctx);
                  await _loadNotes();
                },
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      titleCtrl.dispose();
      contentCtrl.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: widget.avatarPath != null
            ? Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundImage: FileImage(File(widget.avatarPath!)),
                ),
              )
            : null,
        title: Text(
          'Diário: ${widget.characterName}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isLoading
            ? const _SessionNotesSkeleton(key: ValueKey('loading'))
            : _notes.isEmpty
            ? Center(
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
              )
            : ListView.builder(
                key: const ValueKey('loaded'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return _SessionNoteCard(
                    note: note,
                    onDismissed: () => _handleDeleteNote(note),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteSheet,
        tooltip: 'Nova anotação',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Esqueleto de carregamento que imita a silhueta de [_SessionNoteCard]:
/// título + data numa linha e três linhas de prévia do conteúdo, a última
/// mais curta para reproduzir o fim natural de um parágrafo.
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
