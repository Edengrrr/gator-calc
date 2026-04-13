import 'package:flutter/material.dart';

// Represents the attacker's movement state and its to-hit modifier.
// Sprint is excluded — no attack is possible when sprinting.
enum AttackerMovement {
  stationary(0),
  walk(1),
  run(2),
  jump(3);

  final int modifier;
  const AttackerMovement(this.modifier);
}

// Additional modifier based on how the target moved.
enum TargetMovementAdditional {
  none(0),
  jumped(1),
  sprinted(-1);

  final int modifier;
  const TargetMovementAdditional(this.modifier);
}

// The range bracket to the target.
enum RangeBracket {
  short(0),
  medium(2),
  long(4);

  final int modifier;
  const RangeBracket(this.modifier);
}

// How far inside the weapon's minimum range the target is.
// None means the target is outside minimum range (no penalty).
enum MinimumRange {
  none(0),
  equal(1),
  minusOne(2),
  minusTwo(3),
  minusThree(4),
  minusFour(5),
  minusFive(6);

  final int modifier;
  const MinimumRange(this.modifier);
}

// Woods or smoke between attacker and target.
enum WoodsSmoke {
  none(0),
  light(1),
  heavy(2);

  final int modifier;
  const WoodsSmoke(this.modifier);
}

// Whether the target is prone and whether the attacker is adjacent.
enum TargetProne {
  no(0),
  yes(1),
  adjacent(-2);

  final int modifier;
  const TargetProne(this.modifier);
}

// Damage to the attacker's arm actuators affecting weapon accuracy.
enum ArmCritical {
  none(0),
  upperOrLower(1),
  shoulder(4);

  final int modifier;
  const ArmCritical(this.modifier);
}

// Secondary target modifier depends on whether it's in the front arc.
enum SecondaryTarget {
  none(0),
  inArc(1),
  outOfArc(2);

  final int modifier;
  const SecondaryTarget(this.modifier);
}

// Heat level of the attacker and its to-hit modifier.
// Select the highest threshold your current heat meets or exceeds.
enum HeatModifier {
  none(0),
  heat8(1),
  heat13(2),
  heat17(3),
  heat24(4);

  final int modifier;
  const HeatModifier(this.modifier);
}

// Holds all inputs needed to calculate a GATOR to-hit number.
// All fields have defaults so the calculator starts in a clean zero state.
class GatorInput {
  final int gunnerySkill;
  final AttackerMovement attackerMovement;
  final int targetHexesMoved;
  final TargetMovementAdditional targetMovementAdditional;
  final RangeBracket rangeBracket;
  final MinimumRange minimumRange;
  final WoodsSmoke woodsSmoke;
  final bool targetPartialCover;
  final TargetProne targetProne;
  final bool attackerProne;
  final SecondaryTarget secondaryTarget;
  final ArmCritical armCritical;
  final HeatModifier heatModifier;
  final int otherModifier; // free entry field for edge cases

  const GatorInput({
    this.gunnerySkill = 4,
    this.attackerMovement = AttackerMovement.stationary,
    this.targetHexesMoved = 0,
    this.targetMovementAdditional = TargetMovementAdditional.none,
    this.rangeBracket = RangeBracket.short,
    this.minimumRange = MinimumRange.none,
    this.woodsSmoke = WoodsSmoke.none,
    this.targetPartialCover = false,
    this.targetProne = TargetProne.no,
    this.attackerProne = false,
    this.secondaryTarget = SecondaryTarget.none,
    this.armCritical = ArmCritical.none,
    this.heatModifier = HeatModifier.none,
    this.otherModifier = 0,
  });
}
