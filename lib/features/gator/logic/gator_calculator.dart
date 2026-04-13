import 'package:battletech_calc/features/gator/data/gator_input.dart';

// Returns the target movement modifier based on total hexes moved.
int targetMovementModifier(int hexesMoved) {
  if (hexesMoved <= 2) return 0;
  if (hexesMoved <= 4) return 1;
  if (hexesMoved <= 6) return 2;
  if (hexesMoved <= 9) return 3;
  if (hexesMoved <= 17) return 4;
  return 5; // 18-25 hexes
}
