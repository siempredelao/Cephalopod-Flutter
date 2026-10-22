import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Start screen: continue the saved game, start a new one, learn how to
/// play, or read about the game.
class HomePage extends StatefulWidget {
  const HomePage({required this.hasGameToContinue, super.key});

  /// Whether there is a saved game to continue. Asked when the page opens
  /// and again each time the player comes back from a game.
  final Future<bool> Function() hasGameToContinue;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<bool> _canContinue = widget.hasGameToContinue();

  /// Opens a game, new or [resume]d, and asks again whether there is one to
  /// continue once the player is back.
  Future<void> _openGame({required bool resume}) async {
    await context.pushNamed(
      AppRoute.game.name,
      queryParameters: {if (resume) 'resume': 'true'},
    );
    if (!mounted) return;
    final canContinue = widget.hasGameToContinue();
    // A block body: an arrow would return the Future, which setState rejects.
    setState(() {
      _canContinue = canContinue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: FutureBuilder<bool>(
              future: _canContinue,
              builder: (context, snapshot) {
                final canContinue = snapshot.data ?? false;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Cephalopod', style: textTheme.displaySmall),
                    const SizedBox(height: 8),
                    Text(
                      'A two-player dice game on a 5×5 board.',
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    if (canContinue) ...[
                      FilledButton(
                        onPressed: () => _openGame(resume: true),
                        child: const Text('Continue'),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.tonal(
                        onPressed: () => _openGame(resume: false),
                        child: const Text('New game'),
                      ),
                    ] else
                      FilledButton(
                        onPressed: () => _openGame(resume: false),
                        child: const Text('New game'),
                      ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.goNamed(AppRoute.howToPlay.name),
                      child: const Text('How to play'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.goNamed(AppRoute.about.name),
                      child: const Text('About'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
