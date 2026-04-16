import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:battletech_calc/features/dice_roller/data/roll_result.dart';
import 'package:battletech_calc/features/dice_roller/logic/dice_provider.dart';
import 'package:battletech_calc/features/dice_roller/logic/dice_roller.dart';

// ---------------------------------------------------------------------------
// DICE ROLLER SCREEN
// ---------------------------------------------------------------------------
// Layout:
//   - Mode selector (1d6 / 2d6) at the top
//   - Large tappable die card(s) in the middle — tap to roll
//   - Total shown below the cards for 2d6
//   - Scrollable roll history below
//   - FAB (+) opens a sheet for labeled multi-roll sets
// ---------------------------------------------------------------------------

// Non-secure RNG used only for the visual animation flicker — not for results.
final _animRng = Random();
int _randomFace() => _animRng.nextInt(6) + 1;

// Delays between animation frames in ms — increases to create a slow-down effect.
const _rollDelays = [40, 50, 65, 85, 115, 155];

class DiceRollerScreen extends ConsumerStatefulWidget {
  const DiceRollerScreen({super.key});

  @override
  ConsumerState<DiceRollerScreen> createState() => _DiceRollerScreenState();
}

class _DiceRollerScreenState extends ConsumerState<DiceRollerScreen> {
  // How many dice are in the current mode — 1 or 2.
  int _mode = 2;

  // Current die values shown on screen. Null before the first roll in this mode.
  // Switching modes resets this so the cards show a fresh "tap to roll" state.
  List<int>? _displayValues;

  // True while the roll animation is running. Prevents double-tapping.
  bool _isRolling = false;

  Timer? _rollTimer;

  @override
  void dispose() {
    _rollTimer?.cancel();
    super.dispose();
  }

  void _roll() {
    if (_isRolling) return;

    final result = rollNd6(_mode);
    _isRolling = true;

    // Recursively schedule animation frames, each with an increasing delay.
    // After all frames, show the real result and record the roll.
    void tick(int frame) {
      if (frame >= _rollDelays.length) {
        if (!mounted) return;
        setState(() {
          _displayValues = result.dice;
          _isRolling = false;
        });
        ref.read(diceProvider.notifier).addRoll(result);
        return;
      }

      // Show a random face for this frame.
      if (mounted) {
        setState(() {
          _displayValues = List.generate(_mode, (_) => _randomFace());
        });
      }

      _rollTimer = Timer(
        Duration(milliseconds: _rollDelays[frame]),
        () => tick(frame + 1),
      );
    }

    tick(0);
  }

  // When the mode changes, clear the current values so the new die cards
  // show "tap to roll" rather than a stale result from the previous mode.
  void _setMode(int mode) {
    if (_isRolling) return;
    setState(() {
      _mode = mode;
      _displayValues = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(diceProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Mode selector — switches between 1d6 and 2d6.
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1d6')),
                ButtonSegment(value: 2, label: Text('2d6')),
              ],
              selected: {_mode},
              onSelectionChanged: (val) => _setMode(val.first),
              showSelectedIcon: false,
            ),

            const SizedBox(height: 32),

            // Die card(s) — tapping rolls the current mode.
            GestureDetector(
              onTap: _roll,
              child: _mode == 1
                  ? _DieCard(value: _displayValues?.first)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _DieCard(value: _displayValues?[0]),
                        const SizedBox(width: 20),
                        _DieCard(value: _displayValues?[1]),
                      ],
                    ),
            ),

            const SizedBox(height: 16),

            // Total for 2d6 — hidden in 1d6 mode and before the first roll.
            if (_mode == 2 && _displayValues != null)
              Text(
                'Total: ${_displayValues!.fold(0, (s, v) => s + v)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),

            const SizedBox(height: 24),
            const Divider(height: 1),

            // Roll history — most recent first.
            Expanded(
              child: history.isEmpty
                  ? const Center(
                      child: Text(
                        'No rolls yet.\nTap the dice or use + to roll.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: history.length,
                      itemBuilder: (context, index) =>
                          _HistoryTile(result: history[index]),
                    ),
            ),

            // Clear history — only shown when there is history.
            if (history.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.tonal(
                  onPressed: () =>
                      ref.read(diceProvider.notifier).clearHistory(),
                  child: const Text('Clear History'),
                ),
              ),
          ],
        ),
      ),

      // FAB opens the multi-roll sheet for labeled weapon rolls.
      floatingActionButton: FloatingActionButton(
        onPressed: _isRolling ? null : () => _showMultiRollSheet(context),
        tooltip: 'Multi roll',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showMultiRollSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MultiRollSheet(ref: ref),
    );
  }
}

// ---------------------------------------------------------------------------
// Die card — a large tappable square showing a drawn die face.
// Shows "?" (unlit card) before the first roll.
// Once a value is set, the primary-colored card draws pips via CustomPainter.
// ---------------------------------------------------------------------------
class _DieCard extends StatelessWidget {
  final int? value;

  const _DieCard({this.value});

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: hasValue ? cs.primary : cs.surfaceContainerHighest,
        border: Border.all(color: cs.outline, width: 2),
      ),
      child: hasValue
          ? Padding(
              // Inset so pips don't crowd the rounded corners.
              padding: const EdgeInsets.all(14),
              child: CustomPaint(
                painter: _DieFacePainter(
                  value: value!,
                  pipColor: cs.onPrimary,
                ),
              ),
            )
          : Center(
              child: Text(
                '?',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Die face painter — draws the correct pip layout for values 1–6.
//
// Pip grid (as fractions of the paint area after padding):
//
//   (0.18, 0.18)  ·  ·  (0.82, 0.18)      ← top row
//   (0.18, 0.50)  ·  ·  (0.82, 0.50)      ← middle row
//   (0.18, 0.82)  ·  ·  (0.82, 0.82)      ← bottom row
//                    (0.50, 0.50)          ← center
//
// Standard d6 face layouts:
//   1 →                            center
//   2 → top-right,                 bottom-left
//   3 → top-right,  center,        bottom-left
//   4 → top corners,               bottom corners
//   5 → top corners, center,       bottom corners
//   6 → left column (top/mid/bot), right column (top/mid/bot)
// ---------------------------------------------------------------------------
class _DieFacePainter extends CustomPainter {
  final int value;
  final Color pipColor;

  _DieFacePainter({required this.value, required this.pipColor});

  // (dx, dy) fractions of the paint area for each face value.
  static const _pips = <int, List<(double, double)>>{
    1: [(0.50, 0.50)],
    2: [(0.82, 0.18), (0.18, 0.82)],
    3: [(0.82, 0.18), (0.50, 0.50), (0.18, 0.82)],
    4: [(0.18, 0.18), (0.82, 0.18), (0.18, 0.82), (0.82, 0.82)],
    5: [(0.18, 0.18), (0.82, 0.18), (0.50, 0.50), (0.18, 0.82), (0.82, 0.82)],
    6: [
      (0.18, 0.18), (0.82, 0.18),
      (0.18, 0.50), (0.82, 0.50),
      (0.18, 0.82), (0.82, 0.82),
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = pipColor
      ..style = PaintingStyle.fill;

    // Pip radius scales with the available area so it looks right at any size.
    final pipRadius = size.shortestSide * 0.13;

    for (final (fx, fy) in _pips[value] ?? const <(double, double)>[]) {
      canvas.drawCircle(
        Offset(size.width * fx, size.height * fy),
        pipRadius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DieFacePainter old) =>
      old.value != value || old.pipColor != pipColor;
}

// ---------------------------------------------------------------------------
// History tile — one past roll in the scrollable list.
// ---------------------------------------------------------------------------
class _HistoryTile extends StatelessWidget {
  final RollResult result;

  const _HistoryTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final breakdown = result.dice.join(' + ');
    final subtitle = result.dieCount > 1 ? breakdown : null;

    return ListTile(
      dense: true,
      title: Text(result.label ?? result.rollType),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Text(
        '${result.total}',
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Multi-roll bottom sheet — build a named set of rolls and fire them all.
// ---------------------------------------------------------------------------
class _MultiRollSheet extends StatefulWidget {
  final WidgetRef ref;

  const _MultiRollSheet({required this.ref});

  @override
  State<_MultiRollSheet> createState() => _MultiRollSheetState();
}

class _MultiRollSheetState extends State<_MultiRollSheet> {
  final List<({TextEditingController controller, int dieCount})> _entries = [
    (controller: TextEditingController(), dieCount: 2),
    (controller: TextEditingController(), dieCount: 2),
  ];

  @override
  void dispose() {
    for (final e in _entries) {
      e.controller.dispose();
    }
    super.dispose();
  }

  void _addEntry() {
    setState(() {
      _entries.add((controller: TextEditingController(), dieCount: 2));
    });
  }

  void _removeEntry(int index) {
    setState(() {
      _entries[index].controller.dispose();
      _entries.removeAt(index);
    });
  }

  void _setDieCount(int index, int count) {
    setState(() {
      final old = _entries[index];
      _entries[index] = (controller: old.controller, dieCount: count);
    });
  }

  void _rollAll() {
    for (final entry in _entries) {
      final label = entry.controller.text.trim().isEmpty
          ? null
          : entry.controller.text.trim();
      widget.ref
          .read(diceProvider.notifier)
          .addRoll(rollNd6(entry.dieCount, label: label));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Multi Roll', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Label each roll with a weapon or note, then roll all at once.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),

          ..._entries.asMap().entries.map((entry) {
            final index = entry.key;
            final e = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: e.controller,
                      decoration: const InputDecoration(
                        hintText: 'Label (optional)',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 1, label: Text('1d6')),
                      ButtonSegment(value: 2, label: Text('2d6')),
                    ],
                    selected: {e.dieCount},
                    onSelectionChanged: (val) => _setDieCount(index, val.first),
                    showSelectedIcon: false,
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (_entries.length > 1)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _removeEntry(index),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
            );
          }),

          TextButton.icon(
            onPressed: _addEntry,
            icon: const Icon(Icons.add),
            label: const Text('Add roll'),
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _entries.isEmpty ? null : _rollAll,
              child: const Text('Roll All'),
            ),
          ),
        ],
      ),
    );
  }
}