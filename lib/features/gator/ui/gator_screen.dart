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
  // This controls which input panel is shown in the body below the header.
  // Defaults to G so the app opens ready for gunnery skill input.
  GatorSection _selected = GatorSection.g;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GATOR')),
      body: Column(
        children: [
          // GatorHeader displays the G-A-T-O-R letter circles, their current
          // modifier values, and the total to-hit number.
          // It notifies us when a letter is tapped so we can swap the input panel.
          Padding(
            padding: const EdgeInsets.all(12),
            child: GatorHeader(
              selected: _selected,
              onSectionTap: (section) {
                // setState triggers a rebuild so the input panel below updates.
                setState(() => _selected = section);
              },
            ),
          ),

          // Visual separator between the header and the input panel.
          const Divider(height: 1),

          // Shows the input panel for the currently selected GATOR section.
          Expanded(child: _buildPanel(_selected)),

          // Two reset buttons side by side.
          // ref.read is used because we only need to call a method — no rebuild needed.
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
                    onPressed: () => ref.read(gatorProvider.notifier).reset(),
                    child: const Text('Full Reset'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Returns the appropriate input panel widget for the selected GATOR section.
  Widget _buildPanel(GatorSection section) {
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
