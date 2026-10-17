import 'package:flutter/material.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

import '../../domain/rules/equipment_rules.dart';
import '../pages/character_sheet_tabs/inventory_tab.dart' show damageTypeLabel;

/// Ataques com as armas equipadas e o ataque desarmado.
class AttacksCard extends StatelessWidget {
  const AttacksCard({super.key, required this.attacks, this.onAttackTap});

  final List<WeaponAttack> attacks;

  /// Chamado ao tocar num ataque (ex: rolar o ataque).
  final ValueChanged<WeaponAttack>? onAttackTap;

  String _signed(int value) => value >= 0 ? '+$value' : '$value';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  const DnDIcon(
                    assetPath: 'assets/icons/combat/melee.svg',
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Ataques', style: theme.textTheme.titleSmall),
                  ),
                ],
              ),
            ),
            for (final attack in attacks)
              ListTile(
                dense: true,
                onTap: onAttackTap == null ? null : () => onAttackTap!(attack),
                title: Text(
                  attack.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  [
                    '${attack.damage} ${damageTypeLabel(attack.damageType)}',
                    if (attack.versatileDamage != null)
                      '${attack.versatileDamage} com duas mãos',
                    if (!attack.proficient) 'sem proficiência',
                  ].join(' · '),
                ),
                trailing: Text(
                  _signed(attack.attackBonus),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (attacks.length == 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Equipe armas na aba Inventário para ver os ataques delas.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
