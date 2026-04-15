import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:battletech_calc/features/gator/logic/gator_provider.dart';
import 'package:battletech_calc/features/gator/data/gator_input.dart';
import 'package:battletech_calc/shared/widgets/selector_row.dart';

// Input panel for O — Other Modifiers.
// Contains all situational modifiers that don't fit under G, A, T, or R.
// This panel is scrollable since it has the most inputs.
class OPanel extends ConsumerWidget {
  const OPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final input = ref.watch(gatorProvider);

    // ScrollController is required for Scrollbar to work on desktop/web.
    // On mobile the scrollbar is shown automatically, but we pass the controller
    // explicitly so the thumb is always visible (thumbVisibility: true).
    final scrollController = ScrollController();

    return Scrollbar(
      controller: scrollController,
      // Always show the scrollbar thumb so users immediately see that this
      // panel has more content below the fold.
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Woods / Smoke
            Text(
              'Woods / Smoke',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SelectorRow<WoodsSmoke>(
              selected: input.woodsSmoke,
              options: const [
                SelectorOption(label: 'None', value: WoodsSmoke.none),
                SelectorOption(label: 'Light', value: WoodsSmoke.light),
                SelectorOption(label: 'Heavy', value: WoodsSmoke.heavy),
              ],
              onSelected: (value) =>
                  ref.read(gatorProvider.notifier).updateWoodsSmoke(value),
            ),

            const SizedBox(height: 24),

            // Target Partial Cover
            Text(
              'Target Partial Cover',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SelectorRow<bool>(
              selected: input.targetPartialCover,
              options: const [
                SelectorOption(label: 'No', value: false),
                SelectorOption(label: 'Yes', value: true),
              ],
              onSelected: (value) => ref
                  .read(gatorProvider.notifier)
                  .updateTargetPartialCover(value),
            ),

            const SizedBox(height: 24),

            // Target Prone
            Text(
              'Target Prone',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SelectorRow<TargetProne>(
              selected: input.targetProne,
              options: const [
                SelectorOption(label: 'No', value: TargetProne.no),
                SelectorOption(label: 'Yes', value: TargetProne.yes),
                SelectorOption(label: 'Adjacent', value: TargetProne.adjacent),
              ],
              onSelected: (value) =>
                  ref.read(gatorProvider.notifier).updateTargetProne(value),
            ),

            const SizedBox(height: 24),

            // Attacker Prone
            Text(
              'Attacker Prone',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SelectorRow<bool>(
              selected: input.attackerProne,
              options: const [
                SelectorOption(label: 'No', value: false),
                SelectorOption(label: 'Yes', value: true),
              ],
              onSelected: (value) =>
                  ref.read(gatorProvider.notifier).updateAttackerProne(value),
            ),

            const SizedBox(height: 24),

            // Secondary Target
            Text(
              'Secondary Target',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SelectorRow<SecondaryTarget>(
              selected: input.secondaryTarget,
              options: const [
                SelectorOption(label: 'None', value: SecondaryTarget.none),
                SelectorOption(label: 'In Arc', value: SecondaryTarget.inArc),
                SelectorOption(
                  label: 'Out of Arc',
                  value: SecondaryTarget.outOfArc,
                ),
              ],
              onSelected: (value) =>
                  ref.read(gatorProvider.notifier).updateSecondaryTarget(value),
            ),

            const SizedBox(height: 24),

            // Arm Criticals
            Text(
              'Arm Criticals',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SelectorRow<ArmCritical>(
              selected: input.armCritical,
              options: const [
                SelectorOption(label: 'None', value: ArmCritical.none),
                SelectorOption(
                  label: 'Upper/Lower',
                  value: ArmCritical.upperOrLower,
                ),
                SelectorOption(label: 'Shoulder', value: ArmCritical.shoulder),
              ],
              onSelected: (value) =>
                  ref.read(gatorProvider.notifier).updateArmCritical(value),
            ),

            const SizedBox(height: 24),

            // Heat
            Text('Heat', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            // Labels use the heat range strings from the HeatModifier enum.
            // columns: 3 forces a 3+2 grid so the ranges don't clip.
            SelectorRow<HeatModifier>(
              selected: input.heatModifier,
              columns: 3,
              options: HeatModifier.values
                  .map((h) => SelectorOption(label: h.label, value: h))
                  .toList(),
              onSelected: (value) =>
                  ref.read(gatorProvider.notifier).updateHeatModifier(value),
            ),

            const SizedBox(height: 24),

            // Other — free entry field
            Text('Other', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Manual modifier for edge cases not covered above.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => ref
                      .read(gatorProvider.notifier)
                      .updateOtherModifier(input.otherModifier - 1),
                ),
                Text(
                  '${input.otherModifier}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => ref
                      .read(gatorProvider.notifier)
                      .updateOtherModifier(input.otherModifier + 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
