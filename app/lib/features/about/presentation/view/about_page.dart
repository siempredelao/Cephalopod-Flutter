import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/about/presentation/bloc/about_cubit.dart';
import 'package:cephalopod/features/about/presentation/models/about_view_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Shows the app's version, and credits the game's designer, as his rule
/// sheet asks of anyone who programs the game, with links to his website and
/// the official rules, and links to rate the app and to the licenses of the
/// packages it uses.
/// The credits are laid out as in Dipole, the app of another of his games.
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

/// The About page, drawn from the cubit above it.
class _AboutView extends StatelessWidget {
  const _AboutView();

  static const double _gap = 4;

  /// Opens Flutter's page of licenses, which lists those of every package
  /// the app uses: the packages register their own.
  void _showLicenses(BuildContext context) {
    showLicensePage(context: context, applicationName: context.l10n.appTitle);
  }

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
                state.copyright,
                style: textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: _gap),
              _Link(
                label: l10n.aboutMoreGames(state.websiteName),
                onPressed: cubit.openWebsite,
              ),
              _Link(
                label: l10n.aboutOfficialRules,
                onPressed: cubit.openRuleSheet,
              ),
              _Link(
                label: l10n.aboutRateApp,
                onPressed: cubit.openStoreListing,
              ),
              _Link(
                label: l10n.aboutLicenses,
                onPressed: () => _showLicenses(context),
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
