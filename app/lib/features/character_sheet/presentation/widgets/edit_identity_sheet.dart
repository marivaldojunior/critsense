import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:crit_sense/core/files/avatar_storage.dart';

import '../../domain/entities/alignment.dart' as dnd;
import '../../domain/entities/character.dart';
import '../../domain/srd/srd_class.dart';
import '../../domain/srd/srd_race.dart';
import '../bloc/character_bloc.dart';

/// Converte o índice da API no nome em inglês que a API usa
/// (ex: `half-elf` → `Half-Elf`).
String titleFromApiIndex(String index) => index
    .split('-')
    .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join('-');

/// Abre o painel de edição dos dados básicos de [character].
Future<void> showEditIdentitySheet(BuildContext context, Character character) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: context.read<CharacterBloc>(),
      child: EditIdentitySheet(character: character),
    ),
  );
}

/// Painel para corrigir o nome, a raça, a classe, a tendência e a foto do
/// personagem depois da criação.
///
/// Trocar a raça ou a classe não recalcula os atributos, os PV nem as
/// proficiências. O painel avisa o jogador disso.
class EditIdentitySheet extends StatefulWidget {
  const EditIdentitySheet({
    super.key,
    required this.character,
    this.pickAvatar = pickAndStoreAvatar,
  });

  final Character character;

  /// Escolhe e guarda a foto; os testes passam uma versão falsa.
  final Future<File?> Function(ImageSource source) pickAvatar;

  @override
  State<EditIdentitySheet> createState() => _EditIdentitySheetState();
}

class _EditIdentitySheetState extends State<EditIdentitySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late String _race;
  late String _class;
  late String _alignment;
  String? _avatarPath;

  late final List<String> _raceOptions;
  late final List<String> _classOptions;
  late final List<String> _alignmentOptions;

  @override
  void initState() {
    super.initState();
    final c = widget.character;
    _nameCtrl = TextEditingController(text: c.name);
    _avatarPath = c.avatarPath;

    // Um valor fora do SRD (ou vazio) continua na lista, para o jogador não
    // perder o que já escreveu.
    final srdRace = SrdRace.fromName(c.race);
    _race = srdRace != null ? titleFromApiIndex(srdRace.apiIndex) : c.race;
    _raceOptions = [
      for (final race in SrdRace.values) titleFromApiIndex(race.apiIndex),
    ];
    if (!_raceOptions.contains(_race)) _raceOptions.insert(0, _race);

    final srdClass = SrdClass.fromName(c.characterClass);
    _class = srdClass != null
        ? titleFromApiIndex(srdClass.apiIndex)
        : c.characterClass;
    _classOptions = [
      for (final srdClass in SrdClass.values)
        titleFromApiIndex(srdClass.apiIndex),
    ];
    if (!_classOptions.contains(_class)) _classOptions.insert(0, _class);

    _alignment = c.alignment;
    _alignmentOptions = [for (final a in dnd.Alignment.values) a.label];
    if (!_alignmentOptions.contains(_alignment)) {
      _alignmentOptions.insert(0, _alignment);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final file = await widget.pickAvatar(source);
    if (file == null || !mounted) return;
    setState(() => _avatarPath = file.path);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final c = widget.character;
    context.read<CharacterBloc>().add(
      UpdateIdentityEvent(
        c.id,
        name: _nameCtrl.text,
        race: _race,
        characterClass: _class,
        alignment: _alignment,
        avatarPath: _avatarPath != c.avatarPath ? _avatarPath : null,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rulesChanged =
        SrdRace.fromName(_race) != SrdRace.fromName(widget.character.race) ||
        SrdClass.fromName(_class) !=
            SrdClass.fromName(widget.character.characterClass);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Editar personagem', style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: _avatarPath != null
                        ? FileImage(File(_avatarPath!))
                        : null,
                    child: _avatarPath == null
                        ? const Icon(Icons.person, size: 36)
                        : null,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () => _pick(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Câmera'),
                    ),
                    TextButton.icon(
                      onPressed: () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Galeria'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Informe o nome.'
                      : null,
                ),
                const SizedBox(height: 12),
                _dropdown(
                  label: 'Raça',
                  value: _race,
                  options: _raceOptions,
                  onChanged: (v) => setState(() => _race = v),
                ),
                const SizedBox(height: 12),
                _dropdown(
                  label: 'Classe',
                  value: _class,
                  options: _classOptions,
                  onChanged: (v) => setState(() => _class = v),
                ),
                const SizedBox(height: 12),
                _dropdown(
                  label: 'Tendência',
                  value: _alignment,
                  options: _alignmentOptions,
                  onChanged: (v) => setState(() => _alignment = v),
                ),
                if (rulesChanged) ...[
                  const SizedBox(height: 12),
                  Text(
                    'A troca de raça ou classe não muda os atributos, os PV '
                    'nem as proficiências. Ajuste esses valores na ficha.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(onPressed: _save, child: const Text('Salvar')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final option in options)
          DropdownMenuItem(
            value: option,
            child: Text(option.isEmpty ? '—' : option),
          ),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
