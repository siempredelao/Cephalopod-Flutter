import 'package:material_ui/material_ui.dart';

const String _ruleSheetUrl =
    'https://www.marksteeregames.com/Cephalopod_rules.pdf';

/// Credits the game's inventor, as his rule sheet asks of anyone who
/// programs the game, and links to the official rules.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Cephalopod', style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
            'Cephalopod was invented by Mark Steere on February 25, 2006. '
            'This app follows his rules without changes.',
          ),
          const SizedBox(height: 24),
          Text('Official rules', style: textTheme.titleMedium),
          const SizedBox(height: 4),
          const SelectableText(_ruleSheetUrl),
        ],
      ),
    );
  }
}
