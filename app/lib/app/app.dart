import 'package:cephalopod/app/flavor.dart';
import 'package:cephalopod/app/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Root widget. It receives everything it needs, so tests can build it with
/// any router and flavor.
class App extends StatelessWidget {
  const App({required this.flavor, required this.router, super.key});

  final Flavor flavor;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cephalopod',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: flavor == Flavor.dev,
    );
  }
}
