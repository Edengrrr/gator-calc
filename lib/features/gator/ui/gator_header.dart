import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:battletech_calc/features/gator/logic/gator_provider.dart';

// Enum representing which GATOR letter is currently selected.
// Used by GatorScreen to determine which input panel to display.
// fullName is shown inside the circle when that section is active.
enum GatorSection {
  g, a, t, o, r;

  String get fullName => switch (this) {
    GatorSection.g => 'Gunnery',
    GatorSection.a => 'Attacker',
    GatorSection.t => 'Target',
    GatorSection.o => 'Other',
    GatorSection.r => 'Range',
  };
}

// GatorHeader displays the full top section of the GATOR calculator screen:
//   - A row of tappable letter circles (G, A, T, O, R)
//   - A row of smaller circles showing each letter's current modifier value
//   - Two stacked total circles on the right (Ranged and Melee)
//
// The selected letter is highlighted. Tapping a letter calls onSectionTap
// so the parent screen can swap the input panel below.
class GatorHeader extends ConsumerWidget {
  // Which GATOR letter is currently active/highlighted.
  // Null when the intro panel is showing — no circle is highlighted.
  final GatorSection? selected;

  // Callback fired when the user taps a different letter.
  final ValueChanged<GatorSection> onSectionTap;

  const GatorHeader({
    super.key,
    required this.selected,
    required this.onSectionTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final input = ref.watch(gatorProvider);
    final rangedTotal = ref.watch(toHitProvider);
    final meleeTotal = ref.watch(meleeToHitProvider);

    // The modifier value displayed under each GATOR letter circle.
    // Index matches GatorSection.index (g=0, a=1, t=2, o=3, r=4).
    // Null fields contribute 0 to modifier sums. G shows '?' until selected.
    final values = [
      // G — gunnery skill, 0 if not yet selected
      '${input.gunnerySkill ?? 0}',
      // A — attacker movement modifier (0 if not yet selected)
      '${input.attackerMovement?.modifier ?? 0}',
      // T — bracket modifier + jumped/sprinted additional modifier
      '${(input.targetMovementBracket?.modifier ?? 0) + (input.targetMovementAdditional?.modifier ?? 0)}',
      // O — sum of all other modifiers (null fields treated as 0)
      '${(input.woodsSmoke?.modifier ?? 0) + (input.targetPartialCover == true ? 1 : 0) + (input.targetProne?.modifier ?? 0) + (input.attackerProne == true ? 2 : 0) + (input.secondaryTarget?.modifier ?? 0) + (input.armCritical?.modifier ?? 0) + (input.heatModifier?.modifier ?? 0) + input.otherModifier}',
      // R — range bracket + minimum range penalty
      '${(input.rangeBracket?.modifier ?? 0) + (input.minimumRange?.modifier ?? 0)}',
    ];

    return Column(
      children: [
        // Top section — tappable GATOR letter circles and their modifier values.
        Row(
          children: GatorSection.values.map((section) {
            final index = section.index;
            final isSelected = selected == section;
            // Show the full section name when active, letter when inactive.
            final label = isSelected
                ? section.fullName
                : section.name.toUpperCase();

            return Expanded(
              child: GestureDetector(
                onTap: () => onSectionTap(section),
                child: Column(
                  children: [
                    // Large letter circle — shows full name when active.
                    _Circle(label: label, highlighted: isSelected),
                    const SizedBox(height: 4),
                    // Small value circle — shows the current modifier for this section.
                    _Circle(
                      label: values[index],
                      highlighted: false,
                      small: true,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        // Divider separating the inputs from the output totals.
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(height: 1),
        ),

        // Bottom section — Ranged and Melee to-hit totals.
        // These are read-only outputs, not tappable.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Ranged total — gunnery skill + all modifiers.
            Row(
              children: [
                const Text('Ranged', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                _Circle(
                  label: rangedTotal != null ? '$rangedTotal' : '?',
                  highlighted: true,
                  small: true,
                ),
              ],
            ),

            // Melee total — piloting skill + all modifiers.
            // Kick attacks subtract 2 from this number.
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Melee', style: TextStyle(fontSize: 12)),
                    Text('(kick -2)', style: TextStyle(fontSize: 10)),
                  ],
                ),
                const SizedBox(width: 8),
                _Circle(
                  label: meleeTotal != null ? '$meleeTotal' : '?',
                  highlighted: true,
                  small: true,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// A circular display widget used for both the GATOR letter circles
// and the value/total sub-circles.
// highlighted = filled with the primary theme color (used for selected letter and totals)
// small = smaller diameter, used for value and total circles
class _Circle extends StatelessWidget {
  final String label;
  final bool highlighted;
  final bool small;

  const _Circle({
    required this.label,
    required this.highlighted,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = small ? 40.0 : 56.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: highlighted
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      // FittedBox scales the text down automatically if it's too wide for the
      // circle — needed when the full section name is shown on selection.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: small ? 14 : 22,
              fontWeight: FontWeight.bold,
              color: highlighted
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
