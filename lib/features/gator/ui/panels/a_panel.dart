import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:battletech_calc/features/gator/logic/gator_provider.dart';
import 'package:battletech_calc/features/gator/data/gator_input.dart';
import 'package:battletech_calc/shared/widgets/selector_row.dart';

// Input panel for A — Attacker Movement.
// The player selects how their mech moved this turn.
// Sprint is excluded — no attack is possible when sprinting.
class APanel extends ConsumerWidget {
  const APanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(gatorProvider.select((s) => s.attackerMovement));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attacker Movement',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'How did the attacking mech move this turn?',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          SelectorRow<AttackerMovement>(
            selected: current,
            columns: 2,
            options: const [
              SelectorOption(
                label: 'Stationary',
                value: AttackerMovement.stationary,
              ),
              SelectorOption(label: 'Walk', value: AttackerMovement.walk),
              SelectorOption(label: 'Run', value: AttackerMovement.run),
              SelectorOption(label: 'Jump', value: AttackerMovement.jump),
            ],
            onSelected: (value) =>
                ref.read(gatorProvider.notifier).updateAttackerMovement(value),
          ),
        ],
      ),
    );
  }
}
