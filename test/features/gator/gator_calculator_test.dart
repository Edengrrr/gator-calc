import 'package:flutter_test/flutter_test.dart';
import 'package:battletech_calc/features/gator/data/gator_input.dart';
import 'package:battletech_calc/features/gator/logic/gator_calculator.dart';

// ---------------------------------------------------------------------------
// Unit tests for calculateToHit() and calculateMeleeToHit().
//
// Both functions return int? — null when the base skill (gunnery/piloting)
// has not been selected yet. All other null fields contribute 0.
//
// Tests always supply gunnerySkill/pilotingSkill explicitly so the function
// returns a number rather than null, keeping assertions simple.
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Null base skill — returns null when gunnery/piloting not selected.
  // -------------------------------------------------------------------------
  group('null base skill', () {
    test('returns null when gunnerySkill is not set', () {
      const input = GatorInput();
      expect(calculateToHit(input), null);
    });

    test('returns null when pilotingSkill is not set', () {
      const input = GatorInput();
      expect(calculateMeleeToHit(input), null);
    });

    test('returns a number once gunnerySkill is set', () {
      const input = GatorInput(gunnerySkill: 4);
      expect(calculateToHit(input), isNotNull);
    });
  });

  // -------------------------------------------------------------------------
  // Baseline — correct starting values when skills are set.
  // -------------------------------------------------------------------------
  group('baseline', () {
    test('gunnery 4 with no other modifiers gives ranged total of 4', () {
      const input = GatorInput(gunnerySkill: 4);
      expect(calculateToHit(input), 4);
    });

    test('piloting 5 with no other modifiers gives melee total of 5', () {
      const input = GatorInput(pilotingSkill: 5);
      expect(calculateMeleeToHit(input), 5);
    });
  });

  // -------------------------------------------------------------------------
  // G — Gunnery / Piloting skill changes the base.
  // -------------------------------------------------------------------------
  group('G — gunnery and piloting skill', () {
    test('gunnery 3 gives ranged total of 3', () {
      const input = GatorInput(gunnerySkill: 3);
      expect(calculateToHit(input), 3);
    });

    test('gunnery 6 gives ranged total of 6', () {
      const input = GatorInput(gunnerySkill: 6);
      expect(calculateToHit(input), 6);
    });

    test('piloting 4 gives melee total of 4', () {
      const input = GatorInput(pilotingSkill: 4);
      expect(calculateMeleeToHit(input), 4);
    });
  });

  // -------------------------------------------------------------------------
  // A — Attacker movement modifier.
  // -------------------------------------------------------------------------
  group('A — attacker movement', () {
    test('stationary adds 0', () {
      const input = GatorInput(
        gunnerySkill: 4,
        attackerMovement: AttackerMovement.stationary,
      );
      expect(calculateToHit(input), 4);
    });

    test('walk adds 1', () {
      const input = GatorInput(
        gunnerySkill: 4,
        attackerMovement: AttackerMovement.walk,
      );
      expect(calculateToHit(input), 5);
    });

    test('run adds 2', () {
      const input = GatorInput(
        gunnerySkill: 4,
        attackerMovement: AttackerMovement.run,
      );
      expect(calculateToHit(input), 6);
    });

    test('jump adds 3', () {
      const input = GatorInput(
        gunnerySkill: 4,
        attackerMovement: AttackerMovement.jump,
      );
      expect(calculateToHit(input), 7);
    });

    test('null attacker movement adds 0', () {
      const input = GatorInput(gunnerySkill: 4);
      expect(calculateToHit(input), 4);
    });
  });

  // -------------------------------------------------------------------------
  // T — Target movement bracket + additional modifier.
  // -------------------------------------------------------------------------
  group('T — target movement', () {
    test('bracket 3-4 adds 1', () {
      const input = GatorInput(
        gunnerySkill: 4,
        targetMovementBracket: TargetMovementBracket.one,
      );
      expect(calculateToHit(input), 5);
    });

    test('bracket 25+ adds 6', () {
      const input = GatorInput(
        gunnerySkill: 4,
        targetMovementBracket: TargetMovementBracket.six,
      );
      expect(calculateToHit(input), 10);
    });

    test('jumped adds 1 on top of bracket', () {
      const input = GatorInput(
        gunnerySkill: 4,
        targetMovementBracket: TargetMovementBracket.one,   // +1
        targetMovementAdditional: TargetMovementAdditional.jumped, // +1
      );
      expect(calculateToHit(input), 6);
    });

    test('sprinted subtracts 1 from bracket', () {
      const input = GatorInput(
        gunnerySkill: 4,
        targetMovementBracket: TargetMovementBracket.one,     // +1
        targetMovementAdditional: TargetMovementAdditional.sprinted, // -1
      );
      expect(calculateToHit(input), 4);
    });

    test('null target movement adds 0', () {
      const input = GatorInput(gunnerySkill: 4);
      expect(calculateToHit(input), 4);
    });
  });

  // -------------------------------------------------------------------------
  // R — Range bracket + minimum range penalty.
  // -------------------------------------------------------------------------
  group('R — range', () {
    test('short range adds 0', () {
      const input = GatorInput(
        gunnerySkill: 4,
        rangeBracket: RangeBracket.short,
      );
      expect(calculateToHit(input), 4);
    });

    test('medium range adds 2', () {
      const input = GatorInput(
        gunnerySkill: 4,
        rangeBracket: RangeBracket.medium,
      );
      expect(calculateToHit(input), 6);
    });

    test('long range adds 4', () {
      const input = GatorInput(
        gunnerySkill: 4,
        rangeBracket: RangeBracket.long,
      );
      expect(calculateToHit(input), 8);
    });

    test('minimum range equal adds 1', () {
      const input = GatorInput(
        gunnerySkill: 4,
        minimumRange: MinimumRange.equal,
      );
      expect(calculateToHit(input), 5);
    });

    test('minimum range minus 3 adds 4', () {
      const input = GatorInput(
        gunnerySkill: 4,
        minimumRange: MinimumRange.minusThree,
      );
      expect(calculateToHit(input), 8);
    });

    test('null range adds 0', () {
      const input = GatorInput(gunnerySkill: 4);
      expect(calculateToHit(input), 4);
    });
  });

  // -------------------------------------------------------------------------
  // O — Other modifiers (each one tested individually).
  // -------------------------------------------------------------------------
  group('O — other modifiers', () {
    test('light woods adds 1', () {
      const input = GatorInput(
        gunnerySkill: 4,
        woodsSmoke: WoodsSmoke.light,
      );
      expect(calculateToHit(input), 5);
    });

    test('heavy woods adds 2', () {
      const input = GatorInput(
        gunnerySkill: 4,
        woodsSmoke: WoodsSmoke.heavy,
      );
      expect(calculateToHit(input), 6);
    });

    test('target partial cover adds 1', () {
      const input = GatorInput(
        gunnerySkill: 4,
        targetPartialCover: true,
      );
      expect(calculateToHit(input), 5);
    });

    test('null targetPartialCover adds 0', () {
      const input = GatorInput(gunnerySkill: 4);
      expect(calculateToHit(input), 4);
    });

    test('target prone (range) adds 1', () {
      const input = GatorInput(
        gunnerySkill: 4,
        targetProne: TargetProne.yes,
      );
      expect(calculateToHit(input), 5);
    });

    test('target prone adjacent subtracts 2', () {
      const input = GatorInput(
        gunnerySkill: 4,
        targetProne: TargetProne.adjacent,
      );
      expect(calculateToHit(input), 2);
    });

    test('attacker prone adds 2', () {
      const input = GatorInput(
        gunnerySkill: 4,
        attackerProne: true,
      );
      expect(calculateToHit(input), 6);
    });

    test('null attackerProne adds 0', () {
      const input = GatorInput(gunnerySkill: 4);
      expect(calculateToHit(input), 4);
    });

    test('secondary target in arc adds 1', () {
      const input = GatorInput(
        gunnerySkill: 4,
        secondaryTarget: SecondaryTarget.inArc,
      );
      expect(calculateToHit(input), 5);
    });

    test('secondary target out of arc adds 2', () {
      const input = GatorInput(
        gunnerySkill: 4,
        secondaryTarget: SecondaryTarget.outOfArc,
      );
      expect(calculateToHit(input), 6);
    });

    test('upper/lower arm critical adds 1', () {
      const input = GatorInput(
        gunnerySkill: 4,
        armCritical: ArmCritical.upperOrLower,
      );
      expect(calculateToHit(input), 5);
    });

    test('shoulder critical adds 4', () {
      const input = GatorInput(
        gunnerySkill: 4,
        armCritical: ArmCritical.shoulder,
      );
      expect(calculateToHit(input), 8);
    });

    test('heat 8-12 adds 1', () {
      const input = GatorInput(
        gunnerySkill: 4,
        heatModifier: HeatModifier.heat8,
      );
      expect(calculateToHit(input), 5);
    });

    test('heat 24+ adds 4', () {
      const input = GatorInput(
        gunnerySkill: 4,
        heatModifier: HeatModifier.heat24,
      );
      expect(calculateToHit(input), 8);
    });

    test('other modifier +3 adds 3', () {
      const input = GatorInput(gunnerySkill: 4, otherModifier: 3);
      expect(calculateToHit(input), 7);
    });

    test('other modifier -2 subtracts 2', () {
      const input = GatorInput(gunnerySkill: 4, otherModifier: -2);
      expect(calculateToHit(input), 2);
    });
  });

  // -------------------------------------------------------------------------
  // Combined — realistic mid-game scenarios that stack several modifiers.
  // -------------------------------------------------------------------------
  group('combined scenarios', () {
    test('typical attack: gunnery 4, run, target moved 5-6, medium range', () {
      // G=4, A=run(+2), T=5-6 bracket(+2), R=medium(+2) → 10
      const input = GatorInput(
        gunnerySkill: 4,
        attackerMovement: AttackerMovement.run,
        targetMovementBracket: TargetMovementBracket.two,
        rangeBracket: RangeBracket.medium,
      );
      expect(calculateToHit(input), 10);
    });

    test('nightmare scenario: everything stacked', () {
      // G=5, A=jump(+3), T=10-17(+4)+jumped(+1), R=long(+4),
      // O=heavy woods(+2) + partial cover(+1) + heat 24+(+4) → 24
      const input = GatorInput(
        gunnerySkill: 5,
        attackerMovement: AttackerMovement.jump,
        targetMovementBracket: TargetMovementBracket.four,
        targetMovementAdditional: TargetMovementAdditional.jumped,
        rangeBracket: RangeBracket.long,
        woodsSmoke: WoodsSmoke.heavy,
        targetPartialCover: true,
        heatModifier: HeatModifier.heat24,
      );
      expect(calculateToHit(input), 24);
    });
  });
}