// ---------------------------------------------------------------------------
// GATOR INPUT DATA MODEL
// ---------------------------------------------------------------------------
// This file defines all the data types used to represent a single GATOR
// to-hit calculation. Each enum carries its own modifier value so the
// calculator never needs a separate lookup table — just call .modifier.
//
// GatorInput is immutable (all fields are final). To change one field,
// use copyWith() which returns a new GatorInput with only that field updated.
// This pattern works cleanly with Riverpod's state management.
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// G — GUNNERY SKILL
// Gunnery skill is stored as a plain int (1–6) on GatorInput, not an enum,
// because it's a continuous number rather than a set of named options.
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// A — ATTACKER MOVEMENT
// Represents how the attacking unit moved this turn.
// Sprint is excluded because no attack is possible when sprinting.
// Each case carries the modifier it adds to the to-hit number.
// ---------------------------------------------------------------------------
enum AttackerMovement {
  stationary(0), // Unit did not move — no penalty
  walk(1), // Unit walked — +1 to hit
  run(2), // Unit ran — +2 to hit
  jump(3); // Unit jumped — +3 to hit (also triggers target jump bonus)

  // The to-hit modifier this movement type contributes.
  final int modifier;
  const AttackerMovement(this.modifier);
}

// ---------------------------------------------------------------------------
// T — TARGET MOVEMENT (additional modifier)
// The base target movement modifier is calculated from hexes moved using
// targetMovementModifier() in gator_calculator.dart. This enum covers the
// additional modifier applied on top of that based on HOW the target moved.
// ---------------------------------------------------------------------------
enum TargetMovementAdditional {
  none(0), // No additional modifier
  jumped(1), // Target jumped — +1 additional to-hit penalty
  sprinted(-1); // Target sprinted — -1 bonus (easier to hit a sprinting mech)

  // The additional to-hit modifier this movement type contributes.
  final int modifier;
  const TargetMovementAdditional(this.modifier);
}

// The target movement bracket based on total hexes moved.
// Players select the bracket directly rather than entering an exact hex count.
enum TargetMovementBracket {
  zero(0, '0-2'),
  one(1, '3-4'),
  two(2, '5-6'),
  three(3, '7-9'),
  four(4, '10-17'),
  five(5, '18-24'),
  six(6, '25+');

  final int modifier;
  final String label;
  const TargetMovementBracket(this.modifier, this.label);
}

// ---------------------------------------------------------------------------
// R — RANGE BRACKET
// The broad range category for the weapon being fired.
// Exact hex distances vary by weapon — the player selects the bracket.
// ---------------------------------------------------------------------------
enum RangeBracket {
  short(0), // Short range — no modifier
  medium(2), // Medium range — +2 to hit
  long(4); // Long range — +4 to hit

  // The to-hit modifier for this range bracket.
  final int modifier;
  const RangeBracket(this.modifier);
}

// ---------------------------------------------------------------------------
// R — MINIMUM RANGE PENALTY
// Some weapons have a minimum range. If the target is within that minimum,
// add +1 for each hex inside the minimum range boundary.
// "equal" means the target is exactly at the minimum range hex (+1 penalty).
// Each step closer adds +1 more.
// ---------------------------------------------------------------------------
enum MinimumRange {
  none(0), // Target is outside minimum range — no penalty
  equal(1), // Target is at exactly the minimum range hex — +1
  minusOne(2), // Target is 1 hex closer than minimum — +2
  minusTwo(3), // Target is 2 hexes closer than minimum — +3
  minusThree(4), // Target is 3 hexes closer than minimum — +4
  minusFour(5), // Target is 4 hexes closer than minimum — +5
  minusFive(6); // Target is 5 hexes closer than minimum — +6

  // The to-hit modifier for this minimum range situation.
  final int modifier;
  const MinimumRange(this.modifier);
}

// ---------------------------------------------------------------------------
// O — OTHER MODIFIERS (enums)
// The following enums cover the named options under the O section of GATOR.
// Simple boolean conditions (targetPartialCover, attackerProne) are stored
// directly as bools on GatorInput rather than enums.
// ---------------------------------------------------------------------------

// Woods or smoke terrain between the attacker and target.
enum WoodsSmoke {
  none(0), // No intervening terrain — no modifier
  light(1), // Light woods or light smoke — +1 to hit
  heavy(2); // Heavy woods or heavy smoke — +2 to hit

  final int modifier;
  const WoodsSmoke(this.modifier);
}

// Whether the target mech is prone, and whether the attacker is adjacent.
// A prone target at range is harder to hit (+1), but very easy to hit when
// the attacker is standing right next to it (-2).
enum TargetProne {
  no(0), // Target is not prone — no modifier
  yes(1), // Target is prone, attacker is not adjacent — +1 to hit
  adjacent(-2); // Target is prone AND attacker is adjacent — -2 to hit

  final int modifier;
  const TargetProne(this.modifier);
}

// Damage to the attacker's arm actuators that affects aiming.
// Shoulder damage is the worst — it effectively locks out the arm.
enum ArmCritical {
  none(0), // No arm damage — no modifier
  upperOrLower(1), // Upper or lower arm actuator hit — +1 to hit
  shoulder(4); // Shoulder actuator hit — +4 to hit

  final int modifier;
  const ArmCritical(this.modifier);
}

// Penalty for firing at a secondary target in the same turn.
// Firing at something not in your front arc is even harder.
enum SecondaryTarget {
  none(0), // No secondary target — no modifier
  inArc(1), // Secondary target is in the front arc — +1 to hit
  outOfArc(2); // Secondary target is outside the front arc — +2 to hit

  final int modifier;
  const SecondaryTarget(this.modifier);
}

// Heat level thresholds that impose a to-hit penalty.
// Select the highest threshold your mech's current heat meets or exceeds.
// Heat builds up from weapons fire, jumping, and environmental factors.
enum HeatModifier {
  none(0, '0-7'), // Heat 0–7 — no modifier
  heat8(1, '8-12'), // Heat 8–12 — +1 to hit
  heat13(2, '13-16'), // Heat 13–16 — +2 to hit
  heat17(3, '17-23'), // Heat 17–23 — +3 to hit
  heat24(4, '24+'); // Heat 24+ — +4 to hit

  final int modifier;
  final String label;
  const HeatModifier(this.modifier, this.label);
}

// ---------------------------------------------------------------------------
// GATOR INPUT — the complete set of inputs for one to-hit calculation.
// ---------------------------------------------------------------------------

// Holds all inputs needed to calculate a GATOR to-hit number.
// This class is immutable — every field is final and set at construction time.
// Use copyWith() to produce a modified copy when a single field changes.
//
// All selector fields are nullable. Null means the player has not yet made
// a selection for that input. The calculator treats null modifiers as 0 and
// returns null for the total if the base skill (gunnery/piloting) is unset.
// otherModifier stays as int because the stepper always has a numeric value.
class GatorInput {
  // G — the attacker's gunnery skill from their record sheet.
  // Null until the player selects a value.
  final int? gunnerySkill;

  // G — the attacker's piloting skill, used for melee (punch/kick) attacks.
  // Null until the player selects a value.
  final int? pilotingSkill;

  // G — the target's piloting skill from their record sheet.
  // Not yet used in any calculation — stored for future features
  // (e.g. determining if a target falls after a physical attack).
  final int? targetPilotingSkill;

  // A — how the attacking unit moved this turn.
  final AttackerMovement? attackerMovement;

  // T — the bracket representing how far the target moved this turn.
  final TargetMovementBracket? targetMovementBracket;

  // T — additional modifier based on HOW the target moved (jumped/sprinted).
  final TargetMovementAdditional? targetMovementAdditional;

  // R — the range bracket (short/medium/long) for the weapon being fired.
  final RangeBracket? rangeBracket;

  // R — minimum range penalty if the target is too close for the weapon.
  final MinimumRange? minimumRange;

  // O — woods or smoke terrain intervening between attacker and target.
  final WoodsSmoke? woodsSmoke;

  // O — true if the target is in partial cover (+1 to hit).
  final bool? targetPartialCover;

  // O — whether the target is prone and the attacker's adjacency.
  final TargetProne? targetProne;

  // O — true if the attacking mech is itself prone (+2 to hit).
  final bool? attackerProne;

  // O — penalty for firing at a secondary target this turn.
  final SecondaryTarget? secondaryTarget;

  // O — penalty from damaged arm actuators on the attacking mech.
  final ArmCritical? armCritical;

  // O — heat threshold the attacker's mech is currently at.
  final HeatModifier? heatModifier;

  // O — free-entry modifier for edge cases not covered by the standard options.
  // Kept as int (not nullable) because the stepper always holds a numeric value.
  // Starts at 0, which means no additional modifier.
  final int otherModifier;

  const GatorInput({
    this.gunnerySkill,
    this.pilotingSkill,
    this.targetPilotingSkill,
    this.attackerMovement,
    this.targetMovementBracket,
    this.targetMovementAdditional,
    this.rangeBracket,
    this.minimumRange,
    this.woodsSmoke,
    this.targetPartialCover,
    this.targetProne,
    this.attackerProne,
    this.secondaryTarget,
    this.armCritical,
    this.heatModifier,
    this.otherModifier = 0,
  });

  // Returns a new GatorInput identical to this one, except for the fields
  // explicitly passed as arguments. Fields not passed keep their current value.
  // The ?? operator means: use the new value if provided, otherwise keep existing.
  // Example: state.copyWith(gunnerySkill: 3) updates only gunnery skill.
  GatorInput copyWith({
    int? gunnerySkill,
    int? pilotingSkill,
    int? targetPilotingSkill,
    AttackerMovement? attackerMovement,
    TargetMovementBracket? targetMovementBracket,
    TargetMovementAdditional? targetMovementAdditional,
    RangeBracket? rangeBracket,
    MinimumRange? minimumRange,
    WoodsSmoke? woodsSmoke,
    bool? targetPartialCover,
    TargetProne? targetProne,
    bool? attackerProne,
    SecondaryTarget? secondaryTarget,
    ArmCritical? armCritical,
    HeatModifier? heatModifier,
    int? otherModifier,
  }) {
    return GatorInput(
      gunnerySkill: gunnerySkill ?? this.gunnerySkill,
      pilotingSkill: pilotingSkill ?? this.pilotingSkill,
      targetPilotingSkill: targetPilotingSkill ?? this.targetPilotingSkill,
      attackerMovement: attackerMovement ?? this.attackerMovement,
      targetMovementBracket:
          targetMovementBracket ?? this.targetMovementBracket,
      targetMovementAdditional:
          targetMovementAdditional ?? this.targetMovementAdditional,
      rangeBracket: rangeBracket ?? this.rangeBracket,
      minimumRange: minimumRange ?? this.minimumRange,
      woodsSmoke: woodsSmoke ?? this.woodsSmoke,
      targetPartialCover: targetPartialCover ?? this.targetPartialCover,
      targetProne: targetProne ?? this.targetProne,
      attackerProne: attackerProne ?? this.attackerProne,
      secondaryTarget: secondaryTarget ?? this.secondaryTarget,
      armCritical: armCritical ?? this.armCritical,
      heatModifier: heatModifier ?? this.heatModifier,
      otherModifier: otherModifier ?? this.otherModifier,
    );
  }
}
