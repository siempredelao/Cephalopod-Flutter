import 'package:cephalopod/core/l10n/l10n.dart';
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
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(l10n.appTitle, style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(l10n.aboutCredit),
          const SizedBox(height: 24),
          Text(l10n.aboutOfficialRules, style: textTheme.titleMedium),
          const SizedBox(height: 4),
          const SelectableText(_ruleSheetUrl),
        ],
      ),
    );
  }
}
