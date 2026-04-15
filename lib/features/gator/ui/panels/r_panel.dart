import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:battletech_calc/features/gator/logic/gator_provider.dart';
import 'package:battletech_calc/features/gator/data/gator_input.dart';
import 'package:battletech_calc/shared/widgets/selector_row.dart';

// Input panel for R — Range.
// Two inputs:
//   1. Range bracket (Short / Medium / Long)
//   2. Minimum range penalty if the target is too close for the weapon
class RPanel extends ConsumerWidget {
  const RPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rangeBracket = ref.watch(gatorProvider.select((s) => s.rangeBracket));
    final minimumRange = ref.watch(gatorProvider.select((s) => s.minimumRange));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Range Bracket', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Is the target at short, medium, or long range for this weapon?',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          SelectorRow<RangeBracket>(
            selected: rangeBracket,
            options: const [
              SelectorOption(label: 'Short', value: RangeBracket.short),
              SelectorOption(label: 'Medium', value: RangeBracket.medium),
              SelectorOption(label: 'Long', value: RangeBracket.long),
            ],
            onSelected: (value) =>
                ref.read(gatorProvider.notifier).updateRangeBracket(value),
          ),
          const SizedBox(height: 24),
          Text('Minimum Range', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Is the target within the weapon\'s minimum range?',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          SelectorRow<MinimumRange>(
            selected: minimumRange,
            columns: 4,
            options: const [
              SelectorOption(label: 'None', value: MinimumRange.none),
              SelectorOption(label: 'Equal', value: MinimumRange.equal),
              SelectorOption(label: '-1', value: MinimumRange.minusOne),
              SelectorOption(label: '-2', value: MinimumRange.minusTwo),
              SelectorOption(label: '-3', value: MinimumRange.minusThree),
              SelectorOption(label: '-4', value: MinimumRange.minusFour),
              SelectorOption(label: '-5', value: MinimumRange.minusFive),
            ],
            onSelected: (value) =>
                ref.read(gatorProvider.notifier).updateMinimumRange(value),
          ),
        ],
      ),
    );
  }
}
