import 'package:battletech_calc/features/gator/data/gator_input.dart';

// Calculates the final GATOR to-hit number by summing all modifiers.
// Each letter of GATOR contributes one or more values:
//   G = gunnerySkill (base to-hit, null if not yet selected)
//   A = attackerMovement.modifier (null treated as 0)
//   T = targetMovementBracket.modifier + targetMovementAdditional.modifier
//   O = woodsSmoke + targetPartialCover + targetProne + attackerProne
//       + secondaryTarget + armCritical + heatModifier + otherModifier
//   R = rangeBracket + minimumRange
//
// Returns null if gunnerySkill has not been selected yet — the UI displays
// '?' in that case rather than showing a misleading number.
// All other null fields contribute 0 to the total.
int? calculateToHit(GatorInput input) {
  final gunnery = input.gunnerySkill;
  if (gunnery == null) return null;

  return gunnery +
      (input.attackerMovement?.modifier ?? 0) +              // A
      (input.targetMovementBracket?.modifier ?? 0) +         // T (bracket)
      (input.targetMovementAdditional?.modifier ?? 0) +      // T (jumped/sprinted)
      (input.rangeBracket?.modifier ?? 0) +                  // R (bracket)
      (input.minimumRange?.modifier ?? 0) +                  // R (minimum range)
      (input.woodsSmoke?.modifier ?? 0) +                    // O
      (input.targetPartialCover == true ? 1 : 0) +           // O
      (input.targetProne?.modifier ?? 0) +                   // O
      (input.attackerProne == true ? 2 : 0) +                // O
      (input.secondaryTarget?.modifier ?? 0) +               // O
      (input.armCritical?.modifier ?? 0) +                   // O
      (input.heatModifier?.modifier ?? 0) +                  // O
      input.otherModifier;                                   // O (free entry)
}

// Calculates the to-hit number for a melee attack (punch or kick).
// Uses piloting skill as the base instead of gunnery skill.
// Returns null if pilotingSkill has not been selected yet.
// All other modifiers behave identically to the ranged calculation.
int? calculateMeleeToHit(GatorInput input) {
  final piloting = input.pilotingSkill;
  if (piloting == null) return null;

  return piloting +
      (input.attackerMovement?.modifier ?? 0) +              // A
      (input.targetMovementBracket?.modifier ?? 0) +         // T (bracket)
      (input.targetMovementAdditional?.modifier ?? 0) +      // T (jumped/sprinted)
      (input.rangeBracket?.modifier ?? 0) +                  // R (bracket)
      (input.minimumRange?.modifier ?? 0) +                  // R (minimum range)
      (input.woodsSmoke?.modifier ?? 0) +                    // O
      (input.targetPartialCover == true ? 1 : 0) +           // O
      (input.targetProne?.modifier ?? 0) +                   // O
      (input.attackerProne == true ? 2 : 0) +                // O
      (input.secondaryTarget?.modifier ?? 0) +               // O
      (input.armCritical?.modifier ?? 0) +                   // O
      (input.heatModifier?.modifier ?? 0) +                  // O
      input.otherModifier;                                   // O (free entry)
}