import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:battletech_calc/features/dice_roller/data/roll_result.dart';

// ---------------------------------------------------------------------------
// DICE PROVIDER
// ---------------------------------------------------------------------------
// Holds the roll history for the current session.
// Most recent roll is always first. History is capped at 20 entries so the
// list doesn't grow unbounded during a long gaming session.
// ---------------------------------------------------------------------------

class DiceNotifier extends Notifier<List<RollResult>> {
  static const _maxHistory = 20;

  @override
  List<RollResult> build() => [];

  // Adds a new roll to the front of the history list.
  // Trims to _maxHistory entries so old rolls fall off naturally.
  void addRoll(RollResult result) {
    state = [result, ...state].take(_maxHistory).toList();
  }

  // Clears the entire roll history.
  void clearHistory() => state = [];
}

final diceProvider = NotifierProvider<DiceNotifier, List<RollResult>>(
  DiceNotifier.new,
);
