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
  List<int>? _currentValues;

  // Rolls the dice for the current mode, updates the display, and adds to history.
  void _roll() {
    final result = rollNd6(_mode);
    setState(() => _currentValues = result.dice);
    ref.read(diceProvider.notifier).addRoll(result);
  }

  // When the mode changes, clear the current values so the new die cards
  // show "tap to roll" rather than a stale result from the previous mode.
  void _setMode(int mode) {
    setState(() {
      _mode = mode;
      _currentValues = null;
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
                  ? _DieCard(value: _currentValues?.first)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _DieCard(value: _currentValues?[0]),
                        const SizedBox(width: 20),
                        _DieCard(value: _currentValues?[1]),
                      ],
                    ),
            ),

            const SizedBox(height: 16),

            // Total for 2d6 — hidden in 1d6 mode and before the first roll.
            if (_mode == 2 && _currentValues != null)
              Text(
                'Total: ${_currentValues!.fold(0, (s, v) => s + v)}',
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
        onPressed: () => _showMultiRollSheet(context),
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
// Die card — a large tappable square displaying a single die value.
// Shows "?" before the first roll. The card's background uses the primary
// color once a value is present, matching the GATOR total circle style.
// ---------------------------------------------------------------------------
class _DieCard extends StatelessWidget {
  // The value to display (1–6), or null if not yet rolled.
  final int? value;

  const _DieCard({this.value});

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: hasValue
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          hasValue ? '$value' : '?',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: hasValue
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
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