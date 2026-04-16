import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:battletech_calc/features/gator/logic/gator_provider.dart';
import 'package:battletech_calc/features/gator/data/gator_input.dart';
import 'package:battletech_calc/shared/widgets/selector_row.dart';

// Input panel for T — Target Movement.
// Two inputs:
//   1. The hex bracket the target moved (0-2, 3-4, etc.)
//   2. Whether the target jumped or sprinted (additional modifier on top of bracket)
class TPanel extends ConsumerWidget {
  const TPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bracket = ref.watch(
      gatorProvider.select((s) => s.targetMovementBracket),
    );
    final additional = ref.watch(
      gatorProvider.select((s) => s.targetMovementAdditional),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target Hexes Moved',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'How many hexes did the target move?',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),

          // Bracket selector — labels match the hex ranges from the rules.
          // The modifier for each bracket is stored on the enum value.
          // columns: 4 forces the 7 brackets into a 4+3 grid layout.
          SelectorRow<TargetMovementBracket>(
            selected: bracket,
            columns: 4,
            options: TargetMovementBracket.values
                .map((b) => SelectorOption(label: b.label, value: b))
                .toList(),
            onSelected: (value) => ref
                .read(gatorProvider.notifier)
                .updateTargetMovementBracket(value),
          ),

          const SizedBox(height: 24),
          Text(
            'Additional Modifier',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Did the target jump or sprint this turn?',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),

          SelectorRow<TargetMovementAdditional>(
            selected: additional,
            columns: 3,
            options: const [
              SelectorOption(
                label: 'None',
                value: TargetMovementAdditional.none,
              ),
              SelectorOption(
                label: 'Jumped',
                value: TargetMovementAdditional.jumped,
              ),
              SelectorOption(
                label: 'Sprinted',
                value: TargetMovementAdditional.sprinted,
              ),
            ],
            onSelected: (value) => ref
                .read(gatorProvider.notifier)
                .updateTargetMovementAdditional(value),
          ),
        ],
      ),
    );
  }
}
