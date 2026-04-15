import 'package:flutter/material.dart';

// A horizontal row of labeled buttons where only one can be selected at a time.
// Used throughout the GATOR input panels for choosing between named options.
//
// Generic type T represents the value type (usually an enum).
// When a button is tapped, onSelected is called with that button's value
// so the caller can update the provider.
//
// Optional columns parameter: when provided, chips are given a fixed width
// so exactly that many fit per row before wrapping. Useful when you want
// a specific grid layout (e.g. 4 per row for the T panel bracket selector).
class SelectorRow<T> extends StatelessWidget {
  // The list of options to display as buttons.
  final List<SelectorOption<T>> options;

  // The currently selected value — that button will appear highlighted.
  // Null means nothing is selected yet (no button highlighted).
  final T? selected;

  // Called with the new value when the user taps a different button.
  final ValueChanged<T> onSelected;

  // Optional: forces exactly this many chips per row by setting a fixed width.
  // If null, chips wrap naturally based on their label width.
  final int? columns;

  const SelectorRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.columns,
  });

  @override
  Widget build(BuildContext context) {
    const double spacing = 8;

    // If columns is specified, use LayoutBuilder to calculate the exact chip
    // width that fits that many per row, accounting for spacing between them.
    if (columns != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth =
              (constraints.maxWidth - (spacing * (columns! - 1))) / columns!;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: WrapAlignment.center,
            children: options.map((option) {
              final isSelected = selected != null && option.value == selected;
              return SizedBox(
                width: itemWidth,
                child: ChoiceChip(
                  label: Center(child: Text(option.label)),
                  selected: isSelected,
                  // Hide checkmark so it doesn't push text out of the fixed width.
                  showCheckmark: false,
                  labelPadding: EdgeInsets.zero,
                  onSelected: (_) => onSelected(option.value),
                ),
              );
            }).toList(),
          );
        },
      );
    }

    // Default behavior — chips wrap naturally, rows are centered.
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      children: options.map((option) {
        final isSelected = selected != null && option.value == selected;
        return ChoiceChip(
          label: Text(option.label),
          selected: isSelected,
          showCheckmark: false,
          onSelected: (_) => onSelected(option.value),
        );
      }).toList(),
    );
  }
}

// Represents a single option in a SelectorRow.
// label is what the user sees, value is what gets passed to the provider.
class SelectorOption<T> {
  final String label;
  final T value;

  const SelectorOption({required this.label, required this.value});
}
