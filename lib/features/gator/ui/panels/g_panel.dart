import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:battletech_calc/features/gator/logic/gator_provider.dart';
import 'package:battletech_calc/shared/widgets/selector_row.dart';

// Input panel for G — Gunnery Skill.
// Displays buttons for skill values 1 through 6.
// Lower gunnery skill = better accuracy (4 is the standard MechWarrior value).
class GPanel extends ConsumerWidget {
  const GPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch only the gunnery skill value so this widget only rebuilds
    // when that specific field changes, not on every input change.
    final current = ref.watch(gatorProvider.select((s) => s.gunnerySkill));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gunnery Skill', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            "Attacking pilot's gunnery skill from their record sheet.",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          SelectorRow<int>(
            selected: current,
            columns: 6,
            options: [
              1,
              2,
              3,
              4,
              5,
              6,
            ].map((n) => SelectorOption(label: '$n', value: n)).toList(),
            // When a number is tapped, update gunnery skill in the provider.
            onSelected: (value) =>
                ref.read(gatorProvider.notifier).updateGunnerySkill(value),
          ),
          const SizedBox(height: 24),
          Text(
            'Piloting Skill',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "Attacking pilot's piloting skill from their record sheet.",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '* Used for melee attacks (punch/kick)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              fontSize:
                  (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) - 1,
            ),
          ),
          const SizedBox(height: 16),
          SelectorRow<int>(
            selected: ref.watch(gatorProvider.select((s) => s.pilotingSkill)),
            columns: 6,
            options: [
              1,
              2,
              3,
              4,
              5,
              6,
            ].map((n) => SelectorOption(label: '$n', value: n)).toList(),
            onSelected: (value) =>
                ref.read(gatorProvider.notifier).updatePilotingSkill(value),
          ),
          const SizedBox(height: 24),
          Text(
            "Target Piloting Skill",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "Target pilot's piloting skill from their record sheet.",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '* Used for charge attacks and death from above',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              fontSize:
                  (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) - 1,
            ),
          ),
          const SizedBox(height: 16),
          SelectorRow<int>(
            selected: ref.watch(
              gatorProvider.select((s) => s.targetPilotingSkill),
            ),
            columns: 6,
            options: [
              1,
              2,
              3,
              4,
              5,
              6,
            ].map((n) => SelectorOption(label: '$n', value: n)).toList(),
            onSelected: (value) => ref
                .read(gatorProvider.notifier)
                .updateTargetPilotingSkill(value),
          ),
        ],
      ),
    );
  }
}
