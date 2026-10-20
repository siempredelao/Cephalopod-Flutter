import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Start screen. "New game" arrives with the playable MVP (M2).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
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
                OutlinedButton(
                  onPressed: () => context.goNamed(AppRoute.about.name),
                  child: const Text('About'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
