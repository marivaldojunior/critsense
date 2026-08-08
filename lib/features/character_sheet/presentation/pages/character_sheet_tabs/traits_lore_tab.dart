import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/character.dart';
import '../../bloc/character_bloc.dart';

/// Aba "Características & Lore": os campos de texto longo do bloco lateral
/// esquerdo da ficha oficial (Traços, Ideais, Vínculos, Fraquezas) mais o
/// Antecedente/Histórico do cabeçalho.
///
/// [StatefulWidget] porque mantém um rascunho local ([_draft]) e um único
/// debounce compartilhado entre os cinco campos: cada [SaveCharacterEvent]
/// precisa do [Character] inteiro, então salvar um campo isoladamente com
/// o [character] original (sem as edições feitas nos outros campos ainda
/// não persistidas) sobrescreveria essas edições com dados desatualizados.
class TraitsLoreTab extends StatefulWidget {
  const TraitsLoreTab({super.key, required this.character});

  final Character character;

  @override
  State<TraitsLoreTab> createState() => _TraitsLoreTabState();
}

class _TraitsLoreTabState extends State<TraitsLoreTab> {
  late Character _draft;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _draft = widget.character;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Aplica [apply] ao rascunho acumulado e reagenda o salvamento para
  /// 500ms após a última edição em qualquer campo desta aba.
  void _onFieldChanged(Character Function(Character) apply) {
    _draft = apply(_draft);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<CharacterBloc>().add(SaveCharacterEvent(_draft));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _LoreField(
          label: 'Traços de Personalidade',
          initialValue: widget.character.personalityTraits,
          onChanged: (v) =>
              _onFieldChanged((c) => c.copyWith(personalityTraits: v)),
        ),
        const SizedBox(height: 16),
        _LoreField(
          label: 'Ideais',
          initialValue: widget.character.ideals,
          onChanged: (v) => _onFieldChanged((c) => c.copyWith(ideals: v)),
        ),
        const SizedBox(height: 16),
        _LoreField(
          label: 'Vínculos',
          initialValue: widget.character.bonds,
          onChanged: (v) => _onFieldChanged((c) => c.copyWith(bonds: v)),
        ),
        const SizedBox(height: 16),
        _LoreField(
          label: 'Fraquezas',
          initialValue: widget.character.flaws,
          onChanged: (v) => _onFieldChanged((c) => c.copyWith(flaws: v)),
        ),
        const SizedBox(height: 16),
        _LoreField(
          label: 'Histórico',
          initialValue: widget.character.background,
          minLines: 5,
          onChanged: (v) => _onFieldChanged((c) => c.copyWith(background: v)),
        ),
      ],
    );
  }
}

/// Campo de texto longo padronizado desta aba: rótulo fixo no topo mesmo
/// vazio ([alignLabelWithHint]) e altura mínima maior que um campo comum,
/// já que o conteúdo típico (traços, ideais...) costuma ter várias linhas.
class _LoreField extends StatelessWidget {
  const _LoreField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.minLines = 3,
  });

  final String label;
  final String initialValue;
  final int minLines;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      minLines: minLines,
      maxLines: minLines + 3,
      textCapitalization: TextCapitalization.sentences,
      onChanged: onChanged,
    );
  }
}
