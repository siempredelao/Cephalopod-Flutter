import 'package:cephalopod/core/navigation/external_links.dart';
import 'package:material_ui/material_ui.dart';

/// How to play, in short. The rule IDs match the engine's (R1–R8) so a
/// question about a rule can be traced to its code and tests.
const List<({String title, String body})> _sections = [
  (
    title: 'The board',
    body:
        'Cephalopod is played on a 5 × 5 board that starts empty. Player 1 '
        'plays the coral dice and Player 2 the cream ones, taking turns. '
        '(R1)',
  ),
  (
    title: 'Your turn',
    body: 'Place one die on any empty square. You cannot pass. (R2)',
  ),
  (
    title: 'Capturing',
    body:
        'Look at the dice next to that square: above, below, left and '
        'right, never diagonally. If two or more of them add up to 6 or '
        'less, you must capture: they leave the board, whatever their '
        'colour, and your new die shows their total. When more than one set '
        'adds up to 6 or less, you choose which: tap its dice, then '
        'Capture. (R3–R6)',
  ),
  (
    title: 'No capture',
    body: 'When nothing can be captured, your new die shows 1. (R7)',
  ),
  (
    title: 'Winning',
    body:
        'The game ends when all 25 squares are full. The player with more '
        'dice on the board wins. (R8)',
  ),
];

/// Explains the rules, and links to Mark Steere's official rule sheet.
class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('How to play')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          for (final section in _sections) ...[
            Text(section.title, style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(section.body),
            const SizedBox(height: 20),
          ],
          Text('Official rules', style: textTheme.titleMedium),
          const SizedBox(height: 4),
          const SelectableText(ruleSheetUrl),
        ],
      ),
    );
  }
}
