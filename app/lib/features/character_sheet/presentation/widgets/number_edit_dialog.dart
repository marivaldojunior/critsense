import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Diálogo simples para editar um número inteiro da ficha (bônus de CA,
/// deslocamento...). Devolve o número digitado, ou `null` se o jogador
/// cancelar.
Future<int?> showNumberEditDialog(
  BuildContext context, {
  required String title,
  required int initialValue,
  String? helperText,
  bool allowNegative = false,
}) {
  return showDialog<int>(
    context: context,
    builder: (context) => _NumberEditDialog(
      title: title,
      initialValue: initialValue,
      helperText: helperText,
      allowNegative: allowNegative,
    ),
  );
}

class _NumberEditDialog extends StatefulWidget {
  const _NumberEditDialog({
    required this.title,
    required this.initialValue,
    required this.helperText,
    required this.allowNegative,
  });

  final String title;
  final int initialValue;
  final String? helperText;
  final bool allowNegative;

  @override
  State<_NumberEditDialog> createState() => _NumberEditDialogState();
}

class _NumberEditDialogState extends State<_NumberEditDialog> {
  late final _controller = TextEditingController(
    text: '${widget.initialValue}',
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_controller.text.trim());
    if (value == null || (!widget.allowNegative && value < 0)) {
      setState(() => _error = 'Informe um número válido.');
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.numberWithOptions(
          signed: widget.allowNegative,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            widget.allowNegative ? RegExp(r'^-?\d*') : RegExp(r'\d*'),
          ),
        ],
        decoration: InputDecoration(
          helperText: widget.helperText,
          helperMaxLines: 3,
          errorText: _error,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Salvar')),
      ],
    );
  }
}
