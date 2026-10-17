import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/character_bloc.dart';

/// BottomSheet para aplicar dano, cura ou PV temporário ao personagem
/// [characterId] — aberto pelo botão "Gerenciar Vida" do cartão de PV na
/// aba Status & Combate.
///
/// [StatefulWidget] apenas para guardar o [TextEditingController] do campo
/// numérico; a mudança de PV em si nunca fica em estado local, sempre vai
/// para o [CharacterBloc] via [ApplyDamageEvent]/[HealHpEvent]/
/// [AddTempHpEvent].
class HpManagementSheet extends StatefulWidget {
  const HpManagementSheet({super.key, required this.characterId});

  final String characterId;

  @override
  State<HpManagementSheet> createState() => _HpManagementSheetState();
}

class _HpManagementSheetState extends State<HpManagementSheet> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Lê o valor do campo, dispara [buildEvent] no [CharacterBloc] e fecha o
  /// sheet — ou apenas mostra um aviso se o campo não tiver um número > 0.
  void _dispatch(CharacterEvent Function(int amount) buildEvent) {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informe um valor válido.')));
      return;
    }

    context.read<CharacterBloc>().add(buildEvent(amount));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      // `viewInsets.bottom` empurra o conteúdo para cima do teclado numérico
      // quando o TextField ganha foco, em vez de ficar coberto por ele.
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Gerenciar Vida', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Quantidade',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () => _dispatch(
                (amount) => HealHpEvent(widget.characterId, amount),
              ),
              icon: const Icon(Icons.favorite),
              label: const Text('Cura'),
              style: FilledButton.styleFrom(
                foregroundColor: Colors.green.shade700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () => _dispatch(
                (amount) => ApplyDamageEvent(widget.characterId, amount),
              ),
              icon: const Icon(Icons.local_fire_department),
              label: const Text('Dano'),
              style: FilledButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () => _dispatch(
                (amount) => AddTempHpEvent(widget.characterId, amount),
              ),
              icon: const Icon(Icons.shield_outlined),
              label: const Text('HP Temporário'),
            ),
          ),
        ],
      ),
    );
  }
}
