import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/core/navigation/feature_module.dart';
import 'package:cephalopod/features/about/presentation/bloc/about_cubit.dart';
import 'package:cephalopod/features/about/presentation/view/about_page.dart';
import 'package:go_router/go_router.dart';

/// Wires the about feature, which has no dependencies. Each visit to the
/// page gets its own `AboutCubit`.
final class AboutModule implements FeatureModule {
  const AboutModule();

  /// The official rule sheet by Mark Steere, the game's inventor.
  static final Uri ruleSheet = Uri.parse(
    'https://www.marksteeregames.com/Cephalopod_rules.pdf',
  );

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: 'about',
      name: AppRoute.about.name,
      builder: (_, _) => AboutPage(createCubit: _createCubit),
    ),
  ];

  AboutCubit _createCubit() => AboutCubit(ruleSheet: ruleSheet);
}
