import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/about/presentation/bloc/about_cubit.dart';
import 'package:cephalopod/features/about/presentation/models/about_view_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Shows the app's version, and credits the game's designer, as his rule
/// sheet asks of anyone who programs the game, with links to his website and
/// the official rules. The credits are laid out as in Dipole, the app of
/// another of his games.
///
/// It gets an `AboutCubit` from [createCubit] for as long as it is on
/// screen, and draws its [AboutViewState].
class AboutPage extends StatelessWidget {
  const AboutPage({required this.createCubit, super.key});

  /// Builds the page's cubit. The about module wires it to the platform.
  final AboutCubit Function() createCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit(),
      child: const _AboutView(),
    );
  }
}

/// The copyright line of Mark Steere's rule sheet. It stays in English, word
/// for word, in every language.
const String _copyright = 'Copyright © February 2006 by Mark Steere';

/// The name of Mark Steere's website, as the link to it shows it.
const String _websiteName = 'marksteeregames.com';

/// The About page, drawn from the cubit above it.
class _AboutView extends StatelessWidget {
  const _AboutView();

  static const double _gap = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final l10n = context.l10n;
    final cubit = context.read<AboutCubit>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: BlocBuilder<AboutCubit, AboutViewState>(
        builder: (context, state) {
          final version = state.version;
          final failedLinkAddress = state.failedLinkAddress;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(l10n.appTitle, style: textTheme.headlineSmall),
              if (version != null)
                Text(
                  l10n.aboutVersion(version.version, version.build),
                  style: textTheme.bodyMedium,
                ),
              const SizedBox(height: 16),
              Divider(color: theme.colorScheme.outline),
              const SizedBox(height: 8),
              Text(l10n.aboutDesignedBy, style: textTheme.bodyMedium),
              const SizedBox(height: _gap),
              Text(
                _copyright,
                style: textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: _gap),
              _Link(
                label: l10n.aboutMoreGames(_websiteName),
                onPressed: cubit.openWebsite,
              ),
              _Link(
                label: l10n.aboutOfficialRules,
                onPressed: cubit.openRuleSheet,
              ),
              if (failedLinkAddress != null) ...[
                const SizedBox(height: 8),
                Text(l10n.aboutLinkFailed),
                const SizedBox(height: _gap),
                SelectableText(failedLinkAddress),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// A link that opens in the browser, drawn as a text button, as in Dipole.
class _Link extends StatelessWidget {
  const _Link({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton(onPressed: onPressed, child: Text(label)),
    );
  }
}
