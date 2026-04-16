// ---------------------------------------------------------------------------
// ROLL RESULT
// ---------------------------------------------------------------------------
// Represents the outcome of a single dice roll — one or more d6s.
// Stores individual die values so the UI can show the breakdown (e.g. 3 + 5)
// as well as the total. An optional label ties the roll to a weapon or context.
// ---------------------------------------------------------------------------

class RollResult {
  // Optional label set by the user — e.g. "AC/20" or "LRM-5".
  // Null for quick rolls with no label.
  final String? label;

  // The individual result of each die rolled.
  // 1d6 → one value, 2d6 → two values, etc.
  final List<int> dice;

  // The sum of all dice. Computed once at construction and stored.
  final int total;

  RollResult({this.label, required this.dice})
      : total = dice.fold(0, (sum, d) => sum + d);

  // Convenience — how many dice were in this roll.
  int get dieCount => dice.length;

  // Human-readable description of the roll type, e.g. "2d6".
  String get rollType => '${dieCount}d6';
}