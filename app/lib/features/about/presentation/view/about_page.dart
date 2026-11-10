import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/about/presentation/bloc/about_cubit.dart';
import 'package:cephalopod/features/about/presentation/models/about_view_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Credits the game's inventor, as his rule sheet asks of anyone who
/// programs the game, shows the app's version, and shows the address of the
/// official rules.
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: BlocBuilder<AboutCubit, AboutViewState>(
        builder: (context, state) {
          final version = state.version;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(l10n.appTitle, style: textTheme.headlineSmall),
              if (version != null)
                Text(
                  l10n.aboutVersion(version.version, version.build),
                  style: textTheme.bodyMedium,
                ),
              const SizedBox(height: 8),
              Text(l10n.aboutCredit),
              const SizedBox(height: 24),
              Text(l10n.aboutOfficialRules, style: textTheme.titleMedium),
              const SizedBox(height: 4),
              SelectableText(state.ruleSheetAddress),
            ],
          );
        },
      ),
    );
  }
}
