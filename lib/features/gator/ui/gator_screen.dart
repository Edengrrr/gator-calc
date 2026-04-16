import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:battletech_calc/features/gator/logic/gator_provider.dart';
import 'package:battletech_calc/features/gator/ui/gator_header.dart';
import 'package:battletech_calc/features/gator/ui/panels/g_panel.dart';
import 'package:battletech_calc/features/gator/ui/panels/a_panel.dart';
import 'package:battletech_calc/features/gator/ui/panels/t_panel.dart';
import 'package:battletech_calc/features/gator/ui/panels/o_panel.dart';
import 'package:battletech_calc/features/gator/ui/panels/r_panel.dart';

// GatorScreen is the main screen for the GATOR to-hit calculator.
// It uses ConsumerStatefulWidget instead of ConsumerWidget because it needs
// both local UI state (_selected section) AND access to Riverpod providers.
// - ConsumerWidget: Riverpod access only, no local state
// - ConsumerStatefulWidget: both local state AND Riverpod access
class GatorScreen extends ConsumerStatefulWidget {
  const GatorScreen({super.key});

  @override
  ConsumerState<GatorScreen> createState() => _GatorScreenState();
}

class _GatorScreenState extends ConsumerState<GatorScreen> {
  // Tracks which GATOR letter the user has tapped.
  // Null on first load — shows the intro panel instead of any input panel.
  // Once set, navigating away and back restores the last selected section.
  GatorSection? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // GatorHeader displays the G-A-T-O-R letter circles, their current
            // modifier values, and the total to-hit number.
            // selected is null until the user taps a letter for the first time.
            Padding(
              padding: const EdgeInsets.all(12),
              child: GatorHeader(
                selected: _selected,
                onSectionTap: (section) {
                  setState(() => _selected = section);
                },
              ),
            ),

            // Visual separator between the header and the input panel.
            const Divider(height: 1),

            // Shows the intro panel on first load, otherwise the selected panel.
            Expanded(child: _buildPanel(_selected)),

            // Reset buttons — hidden on the intro panel since there's nothing to reset.
            if (_selected != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Clears modifiers and target data, but keeps the attacker's
                    // own gunnery and piloting skills so they don't need re-entering.
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () =>
                            ref.read(gatorProvider.notifier).resetModifiers(),
                        child: const Text('Reset Modifiers'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Clears everything — full blank slate including skills.
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () =>
                            ref.read(gatorProvider.notifier).reset(),
                        child: const Text('Full Reset'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Returns the intro panel when nothing is selected, otherwise the input panel
  // for the active GATOR section.
  Widget _buildPanel(GatorSection? section) {
    if (section == null) return const _IntroPanel();
    switch (section) {
      case GatorSection.g:
        return const GPanel();
      case GatorSection.a:
        return const APanel();
      case GatorSection.t:
        return const TPanel();
      case GatorSection.o:
        return const OPanel();
      case GatorSection.r:
        return const RPanel();
    }
  }
}

// Shown on first load before the user selects a GATOR section.
// Explains what GATOR stands for and prompts the user to tap a letter above.
class _IntroPanel extends StatelessWidget {
  const _IntroPanel();

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    final bodyStyle = Theme.of(context).textTheme.bodySmall;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GATOR To-Hit Calculator', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Calculate your attack roll target number by entering the modifiers '
            'for each letter above. Tap a circle to begin.',
            style: bodyStyle,
          ),
          const SizedBox(height: 24),

          // Brief breakdown of each GATOR letter.
          _IntroRow(
            letter: 'G',
            title: 'Gunnery',
            description: "Your pilot's base gunnery skill from their record sheet.",
            titleStyle: titleStyle,
            bodyStyle: bodyStyle,
          ),
          _IntroRow(
            letter: 'A',
            title: 'Attacker Movement',
            description: 'Modifier based on how your unit moved this turn.',
            titleStyle: titleStyle,
            bodyStyle: bodyStyle,
          ),
          _IntroRow(
            letter: 'T',
            title: 'Target Movement',
            description: 'Modifier based on how far and how the target moved.',
            titleStyle: titleStyle,
            bodyStyle: bodyStyle,
          ),
          _IntroRow(
            letter: 'O',
            title: 'Other Modifiers',
            description:
                'Terrain, cover, heat, prone, criticals, and secondary targets.',
            titleStyle: titleStyle,
            bodyStyle: bodyStyle,
          ),
          _IntroRow(
            letter: 'R',
            title: 'Range',
            description: 'Range bracket and minimum range penalty for the weapon.',
            titleStyle: titleStyle,
            bodyStyle: bodyStyle,
          ),

          const SizedBox(height: 24),
          Text(
            'Roll 2d6 — if your result meets or exceeds the total, the attack hits.',
            style: bodyStyle?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// A single row in the intro panel showing a GATOR letter, its full name,
// and a brief description of what it covers.
class _IntroRow extends StatelessWidget {
  final String letter;
  final String title;
  final String description;
  final TextStyle? titleStyle;
  final TextStyle? bodyStyle;

  const _IntroRow({
    required this.letter,
    required this.title,
    required this.description,
    required this.titleStyle,
    required this.bodyStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Letter badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title and description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: titleStyle),
                const SizedBox(height: 2),
                Text(description, style: bodyStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
