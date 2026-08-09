import 'package:flutter/material.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

/// Barra de busca Material 3 padrão das listagens do Compêndio.
///
/// Envolvida num [ListenableBuilder] ouvindo o próprio [controller] para
/// que o botão de limpar (`trailing`) apareça/desapareça reativamente
/// conforme o texto é digitado, sem exigir `setState` do widget pai — que
/// só precisa possuir e descartar o [controller].
class CompendiumSearchBar extends StatelessWidget {
  const CompendiumSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return SearchBar(
          controller: controller,
          hintText: hintText,
          leading: const DnDIcon(
            assetPath: 'assets/icons/util/search.svg',
            size: 20,
          ),
          trailing: controller.text.isEmpty
              ? null
              : [
                  IconButton(
                    icon: const DnDIcon(
                      assetPath: 'assets/icons/util/cross.svg',
                      size: 18,
                    ),
                    tooltip: 'Limpar busca',
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
                ],
          onChanged: onChanged,
        );
      },
    );
  }
}
