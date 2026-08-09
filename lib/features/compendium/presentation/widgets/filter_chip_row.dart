import 'package:flutter/material.dart';

/// Uma opção de filtro rápido: rótulo exibido no chip e valor enviado ao
/// BLoC via `FilterToggled(filterType, value)`.
class FilterChipOption {
  const FilterChipOption({required this.label, required this.value});

  final String label;
  final dynamic value;
}

/// Fileira horizontal e rolável de [FilterChip]s para um único [filterType]
/// (ex: nível de magia, CR de monstro, categoria de equipamento).
///
/// Nenhuma cor é definida manualmente: [FilterChip] já herda seleção/
/// contorno/rótulo do `ColorScheme.fromSeed` do tema ambiente.
class FilterChipRow extends StatelessWidget {
  const FilterChipRow({
    super.key,
    required this.filterType,
    required this.options,
    required this.activeFilters,
    required this.onToggle,
  });

  final String filterType;
  final List<FilterChipOption> options;
  final Map<String, dynamic> activeFilters;
  final void Function(String filterType, dynamic value) onToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            for (final option in options) ...[
              FilterChip(
                label: Text(option.label),
                selected: activeFilters[filterType] == option.value,
                onSelected: (_) => onToggle(filterType, option.value),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}
