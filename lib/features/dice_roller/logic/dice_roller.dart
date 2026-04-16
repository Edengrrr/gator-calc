import 'dart:math';
import 'package:battletech_calc/features/dice_roller/data/roll_result.dart';

// ---------------------------------------------------------------------------
// DICE ROLLER
// ---------------------------------------------------------------------------
// Uses Random.secure() which draws from the OS-level cryptographic entropy
// pool (Android: /dev/urandom, iOS: SecRandomCopyBytes). This is seeded by
// real hardware events — touch, sensor noise, network timing — making it as
// close to truly random as a consumer device can get without an external
// service. One instance is created and reused to avoid the overhead of
// instantiating a new secure RNG on every roll.
// ---------------------------------------------------------------------------

final _rng = Random.secure();

// Rolls a single die with the given number of sides.
// nextInt(sides) returns 0 to sides-1, so +1 shifts the range to 1..sides.
int _rollDie(int sides) => _rng.nextInt(sides) + 1;

// Rolls a single d6. Returns a RollResult with one die value.
RollResult roll1d6({String? label}) =>
    RollResult(label: label, dice: [_rollDie(6)]);

// Rolls two d6s. Returns a RollResult with both individual values and their sum.
RollResult roll2d6({String? label}) =>
    RollResult(label: label, dice: [_rollDie(6), _rollDie(6)]);

// Rolls any number of d6s. Used for multi-roll weapon sets.
RollResult rollNd6(int count, {String? label}) =>
    RollResult(label: label, dice: List.generate(count, (_) => _rollDie(6)));
