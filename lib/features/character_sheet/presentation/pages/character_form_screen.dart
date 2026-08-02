import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/attribute.dart';
import '../../domain/entities/character.dart';
import '../bloc/character_bloc.dart';

/// Tela de criação de um novo personagem via formulário.
///
/// Usa [StatefulWidget] porque precisa manter [TextEditingController]s
/// ativos enquanto o widget existir na árvore.
class CharacterFormScreen extends StatefulWidget {
  const CharacterFormScreen({super.key});

  @override
  State<CharacterFormScreen> createState() => _CharacterFormScreenState();
}

class _CharacterFormScreenState extends State<CharacterFormScreen> {
  // GlobalKey<FormState> cumpre o mesmo papel que ModelState em APIs .NET:
  // é o identificador que permite acionar a validação de todos os campos do
  // Form de uma vez (formKey.currentState!.validate() ≈ ModelState.IsValid).
  // Sem ele, cada TextFormField seria validado de forma independente e seria
  // impossível coordenar um único ponto de disparo de salvamento.
  final _formKey = GlobalKey<FormState>();

  // Controllers mantidos como campos da State para que possam ser
  // inicializados uma vez no ciclo de vida e descartados em dispose().
  // TextEditingController aloca recursos nativos (listeners, streams internos):
  // sem dispose(), esses recursos continuam vivos mesmo após o widget ser
  // removido da árvore — causando memory leaks e callbacks em objetos mortos.
  late final TextEditingController _nameCtrl;
  late final TextEditingController _raceCtrl;
  late final TextEditingController _classCtrl;
  late final TextEditingController _levelCtrl;
  late final TextEditingController _strengthCtrl;
  late final TextEditingController _dexterityCtrl;
  late final TextEditingController _constitutionCtrl;
  late final TextEditingController _intelligenceCtrl;
  late final TextEditingController _wisdomCtrl;
  late final TextEditingController _charismaCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _raceCtrl = TextEditingController();
    _classCtrl = TextEditingController();
    _levelCtrl = TextEditingController();
    _strengthCtrl = TextEditingController();
    _dexterityCtrl = TextEditingController();
    _constitutionCtrl = TextEditingController();
    _intelligenceCtrl = TextEditingController();
    _wisdomCtrl = TextEditingController();
    _charismaCtrl = TextEditingController();
  }

  @override
  void dispose() {
    // Libera os recursos nativos de cada controller na ordem inversa de criação.
    _nameCtrl.dispose();
    _raceCtrl.dispose();
    _classCtrl.dispose();
    _levelCtrl.dispose();
    _strengthCtrl.dispose();
    _dexterityCtrl.dispose();
    _constitutionCtrl.dispose();
    _intelligenceCtrl.dispose();
    _wisdomCtrl.dispose();
    _charismaCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final level = int.parse(_levelCtrl.text);
    // HP máximo calculado pela fórmula base: 10 + (Constituição × Nível).
    final constitution = int.parse(_constitutionCtrl.text);
    final maxHp = 10 + constitution * level;

    final character = Character(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      race: _raceCtrl.text.trim(),
      characterClass: _classCtrl.text.trim(),
      level: level,
      maxHp: maxHp,
      currentHp: maxHp,
      attributes: Attribute(
        strength: int.parse(_strengthCtrl.text),
        dexterity: int.parse(_dexterityCtrl.text),
        constitution: constitution,
        intelligence: int.parse(_intelligenceCtrl.text),
        wisdom: int.parse(_wisdomCtrl.text),
        charisma: int.parse(_charismaCtrl.text),
      ),
    );

    context.read<CharacterBloc>().add(SaveCharacterEvent(character));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Personagem')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _SectionHeader(title: 'Informações Básicas'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _nameCtrl,
              label: 'Nome',
              validator: _requiredValidator,
            ),
            _buildTextField(
              controller: _raceCtrl,
              label: 'Raça',
              validator: _requiredValidator,
            ),
            _buildTextField(
              controller: _classCtrl,
              label: 'Classe',
              validator: _requiredValidator,
            ),
            _buildTextField(
              controller: _levelCtrl,
              label: 'Nível',
              numeric: true,
              validator: _positiveIntValidator,
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Atributos'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _strengthCtrl,
              label: 'Força',
              numeric: true,
              validator: _attributeValidator,
            ),
            _buildTextField(
              controller: _dexterityCtrl,
              label: 'Destreza',
              numeric: true,
              validator: _attributeValidator,
            ),
            _buildTextField(
              controller: _constitutionCtrl,
              label: 'Constituição',
              numeric: true,
              validator: _attributeValidator,
            ),
            _buildTextField(
              controller: _intelligenceCtrl,
              label: 'Inteligência',
              numeric: true,
              validator: _attributeValidator,
            ),
            _buildTextField(
              controller: _wisdomCtrl,
              label: 'Sabedoria',
              numeric: true,
              validator: _attributeValidator,
            ),
            _buildTextField(
              controller: _charismaCtrl,
              label: 'Carisma',
              numeric: true,
              validator: _attributeValidator,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Salvar Personagem'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool numeric = false,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        inputFormatters: numeric
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        validator: validator,
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatório.';
    return null;
  }

  String? _positiveIntValidator(String? value) {
    final n = int.tryParse(value ?? '');
    if (n == null || n < 1) return 'Informe um número maior que zero.';
    return null;
  }

  /// Valida atributos entre 1 e 20 (limite padrão D&D 5e).
  String? _attributeValidator(String? value) {
    final n = int.tryParse(value ?? '');
    if (n == null || n < 1 || n > 20) return 'Informe um valor entre 1 e 20.';
    return null;
  }
}

/// Cabeçalho visual de seção do formulário.
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
      ],
    );
  }
}
