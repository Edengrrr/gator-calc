import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:battletech_calc/features/gator/data/gator_input.dart';
import 'package:battletech_calc/features/gator/logic/gator_provider.dart';

// ---------------------------------------------------------------------------
// Unit tests for GatorNotifier and the derived toHit/meleeToHit providers.
//
// Each test creates its own ProviderContainer — an isolated Riverpod scope
// with no connection to any other test or to the UI. This means tests cannot
// accidentally affect each other through shared state.
//
// Pattern used throughout:
//   final container = makeContainer();
//   final notifier = container.read(gatorProvider.notifier);
//   notifier.updateX(value);
//   expect(container.read(gatorProvider).x, value);
// ---------------------------------------------------------------------------

// Helper that creates a fresh, isolated ProviderContainer for each test.
// Using a helper keeps individual tests short and avoids boilerplate.
ProviderContainer makeContainer() {
  final container = ProviderContainer();
  // addTearDown ensures the container is disposed when the test finishes,
  // freeing any resources Riverpod allocated for it.
  addTearDown(container.dispose);
  return container;
}

void main() {
  // -------------------------------------------------------------------------
  // Initial state — all selector fields are null, otherModifier is 0.
  // -------------------------------------------------------------------------
  group('initial state', () {
    test('gunnery skill starts null (not selected)', () {
      final container = makeContainer();
      expect(container.read(gatorProvider).gunnerySkill, null);
    });

    test('piloting skill starts null (not selected)', () {
      final container = makeContainer();
      expect(container.read(gatorProvider).pilotingSkill, null);
    });

    test('attacker movement starts null (not selected)', () {
      final container = makeContainer();
      expect(container.read(gatorProvider).attackerMovement, null);
    });

    test('otherModifier starts at 0', () {
      final container = makeContainer();
      expect(container.read(gatorProvider).otherModifier, 0);
    });

    test('toHitProvider starts null (gunnery not set)', () {
      final container = makeContainer();
      expect(container.read(toHitProvider), null);
    });

    test('meleeToHitProvider starts null (piloting not set)', () {
      final container = makeContainer();
      expect(container.read(meleeToHitProvider), null);
    });
  });

  // -------------------------------------------------------------------------
  // Update methods — each one changes exactly the right field and nothing else.
  // -------------------------------------------------------------------------
  group('update methods', () {
    test('updateGunnerySkill changes gunnerySkill', () {
      final container = makeContainer();
      container.read(gatorProvider.notifier).updateGunnerySkill(3);
      expect(container.read(gatorProvider).gunnerySkill, 3);
    });

    test('updateGunnerySkill does not affect pilotingSkill', () {
      final container = makeContainer();
      container.read(gatorProvider.notifier).updateGunnerySkill(3);
      expect(container.read(gatorProvider).pilotingSkill, null);
    });

    test('updatePilotingSkill changes pilotingSkill', () {
      final container = makeContainer();
      container.read(gatorProvider.notifier).updatePilotingSkill(4);
      expect(container.read(gatorProvider).pilotingSkill, 4);
    });

    test('updateTargetPilotingSkill changes targetPilotingSkill', () {
      final container = makeContainer();
      container.read(gatorProvider.notifier).updateTargetPilotingSkill(3);
      expect(container.read(gatorProvider).targetPilotingSkill, 3);
    });

    test('updateTargetPilotingSkill does not affect attacker pilotingSkill', () {
      final container = makeContainer();
      container.read(gatorProvider.notifier).updateTargetPilotingSkill(3);
      expect(container.read(gatorProvider).pilotingSkill, null);
    });

    test('updateAttackerMovement changes attackerMovement', () {
      final container = makeContainer();
      container
          .read(gatorProvider.notifier)
          .updateAttackerMovement(AttackerMovement.run);
      expect(
        container.read(gatorProvider).attackerMovement,
        AttackerMovement.run,
      );
    });

    test('updateTargetMovementBracket changes bracket', () {
      final container = makeContainer();
      container
          .read(gatorProvider.notifier)
          .updateTargetMovementBracket(TargetMovementBracket.three);
      expect(
        container.read(gatorProvider).targetMovementBracket,
        TargetMovementBracket.three,
      );
    });

    test('updateTargetMovementAdditional changes additional modifier', () {
      final container = makeContainer();
      container
          .read(gatorProvider.notifier)
          .updateTargetMovementAdditional(TargetMovementAdditional.jumped);
      expect(
        container.read(gatorProvider).targetMovementAdditional,
        TargetMovementAdditional.jumped,
      );
    });

    test('updateRangeBracket changes rangeBracket', () {
      final container = makeContainer();
      container
          .read(gatorProvider.notifier)
          .updateRangeBracket(RangeBracket.long);
      expect(container.read(gatorProvider).rangeBracket, RangeBracket.long);
    });

    test('updateMinimumRange changes minimumRange', () {
      final container = makeContainer();
      container
          .read(gatorProvider.notifier)
          .updateMinimumRange(MinimumRange.minusTwo);
      expect(container.read(gatorProvider).minimumRange, MinimumRange.minusTwo);
    });

    test('updateWoodsSmoke changes woodsSmoke', () {
      final container = makeContainer();
      container
          .read(gatorProvider.notifier)
          .updateWoodsSmoke(WoodsSmoke.heavy);
      expect(container.read(gatorProvider).woodsSmoke, WoodsSmoke.heavy);
    });

    test('updateTargetPartialCover changes targetPartialCover', () {
      final container = makeContainer();
      container
          .read(gatorProvider.notifier)
          .updateTargetPartialCover(true);
      expect(container.read(gatorProvider).targetPartialCover, true);
    });

    test('updateTargetProne changes targetProne', () {
      final container = makeContainer();
      container
          .read(gatorProvider.notifier)
          .updateTargetProne(TargetProne.adjacent);
      expect(container.read(gatorProvider).targetProne, TargetProne.adjacent);
    });

    test('updateAttackerProne changes attackerProne', () {
      final container = makeContainer();
      container.read(gatorProvider.notifier).updateAttackerProne(true);
      expect(container.read(gatorProvider).attackerProne, true);
    });

    test('updateSecondaryTarget changes secondaryTarget', () {
      final container = makeContainer();
      container
          .read(gatorProvider.notifier)
          .updateSecondaryTarget(SecondaryTarget.outOfArc);
      expect(
        container.read(gatorProvider).secondaryTarget,
        SecondaryTarget.outOfArc,
      );
    });

    test('updateArmCritical changes armCritical', () {
      final container = makeContainer();
      container
          .read(gatorProvider.notifier)
          .updateArmCritical(ArmCritical.shoulder);
      expect(container.read(gatorProvider).armCritical, ArmCritical.shoulder);
    });

    test('updateHeatModifier changes heatModifier', () {
      final container = makeContainer();
      container
          .read(gatorProvider.notifier)
          .updateHeatModifier(HeatModifier.heat17);
      expect(container.read(gatorProvider).heatModifier, HeatModifier.heat17);
    });

    test('updateOtherModifier changes otherModifier', () {
      final container = makeContainer();
      container.read(gatorProvider.notifier).updateOtherModifier(3);
      expect(container.read(gatorProvider).otherModifier, 3);
    });

    test('updateOtherModifier accepts negative values', () {
      final container = makeContainer();
      container.read(gatorProvider.notifier).updateOtherModifier(-2);
      expect(container.read(gatorProvider).otherModifier, -2);
    });
  });

  // -------------------------------------------------------------------------
  // Derived providers — toHitProvider and meleeToHitProvider react to changes.
  // -------------------------------------------------------------------------
  group('derived providers update when state changes', () {
    test('toHitProvider updates when attacker movement changes', () {
      final container = makeContainer();
      final notifier = container.read(gatorProvider.notifier);
      notifier.updateGunnerySkill(4);
      notifier.updateAttackerMovement(AttackerMovement.jump);
      // 4 (gunnery) + 3 (jump) = 7
      expect(container.read(toHitProvider), 7);
    });

    test('meleeToHitProvider updates when piloting skill changes', () {
      final container = makeContainer();
      container.read(gatorProvider.notifier).updatePilotingSkill(3);
      expect(container.read(meleeToHitProvider), 3);
    });

    test('toHitProvider reflects multiple sequential updates', () {
      final container = makeContainer();
      final notifier = container.read(gatorProvider.notifier);
      notifier.updateGunnerySkill(4);
      notifier.updateAttackerMovement(AttackerMovement.run); // +2
      notifier.updateRangeBracket(RangeBracket.medium);      // +2
      notifier.updateWoodsSmoke(WoodsSmoke.light);           // +1
      // 4 + 2 + 2 + 1 = 9
      expect(container.read(toHitProvider), 9);
    });
  });

  // -------------------------------------------------------------------------
  // Reset — clears all fields back to null.
  // -------------------------------------------------------------------------
  group('reset', () {
    test('reset clears gunnery skill back to null', () {
      final container = makeContainer();
      container.read(gatorProvider.notifier).updateGunnerySkill(3);
      container.read(gatorProvider.notifier).reset();
      expect(container.read(gatorProvider).gunnerySkill, null);
    });

    test('reset causes toHitProvider to return null', () {
      final container = makeContainer();
      final notifier = container.read(gatorProvider.notifier);
      notifier.updateGunnerySkill(4);
      notifier.updateAttackerMovement(AttackerMovement.jump);
      notifier.reset();
      expect(container.read(toHitProvider), null);
    });

    test('reset clears all fields to null (except otherModifier → 0)', () {
      final container = makeContainer();
      final notifier = container.read(gatorProvider.notifier);
      notifier.updateGunnerySkill(6);
      notifier.updateAttackerMovement(AttackerMovement.jump);
      notifier.updateWoodsSmoke(WoodsSmoke.heavy);
      notifier.updateOtherModifier(5);
      notifier.reset();
      final state = container.read(gatorProvider);
      expect(state.gunnerySkill, null);
      expect(state.attackerMovement, null);
      expect(state.woodsSmoke, null);
      expect(state.otherModifier, 0);
    });
  });

  // -------------------------------------------------------------------------
  // Reset modifiers — keeps attacker skills, clears everything else.
  // -------------------------------------------------------------------------
  group('resetModifiers', () {
    test('preserves gunnery skill', () {
      final container = makeContainer();
      container.read(gatorProvider.notifier).updateGunnerySkill(3);
      container.read(gatorProvider.notifier).resetModifiers();
      expect(container.read(gatorProvider).gunnerySkill, 3);
    });

    test('preserves piloting skill', () {
      final container = makeContainer();
      container.read(gatorProvider.notifier).updatePilotingSkill(4);
      container.read(gatorProvider.notifier).resetModifiers();
      expect(container.read(gatorProvider).pilotingSkill, 4);
    });

    test('clears attacker movement', () {
      final container = makeContainer();
      final notifier = container.read(gatorProvider.notifier);
      notifier.updateAttackerMovement(AttackerMovement.run);
      notifier.resetModifiers();
      expect(container.read(gatorProvider).attackerMovement, null);
    });

    test('clears target piloting skill', () {
      final container = makeContainer();
      final notifier = container.read(gatorProvider.notifier);
      notifier.updateTargetPilotingSkill(3);
      notifier.resetModifiers();
      expect(container.read(gatorProvider).targetPilotingSkill, null);
    });

    test('toHitProvider still returns a number if gunnery was set', () {
      final container = makeContainer();
      final notifier = container.read(gatorProvider.notifier);
      notifier.updateGunnerySkill(4);
      notifier.updateAttackerMovement(AttackerMovement.jump);
      notifier.resetModifiers();
      // Jump cleared, only gunnery remains → total = 4
      expect(container.read(toHitProvider), 4);
    });
  });
}