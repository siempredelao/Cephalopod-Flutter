import 'dart:async';

import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/core/navigation/feature_module.dart';
import 'package:cephalopod/features/about/domain/app_version_source.dart';
import 'package:cephalopod/features/about/domain/link_opener.dart';
import 'package:cephalopod/features/about/presentation/bloc/about_cubit.dart';
import 'package:cephalopod/features/about/presentation/view/about_page.dart';
import 'package:go_router/go_router.dart';

/// Wires the about feature on the version source and the link opener the
/// composition root picks. Each visit to the page gets its own `AboutCubit`.
final class AboutModule implements FeatureModule {
  AboutModule({
    required this._appVersionSource,
    required this._linkOpener,
  });

  final AppVersionSource _appVersionSource;
  final LinkOpener _linkOpener;

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

  AboutCubit _createCubit() {
    final cubit = AboutCubit(
      appVersionSource: _appVersionSource,
      linkOpener: _linkOpener,
      ruleSheet: ruleSheet,
    );
    // The version shows when it arrives; the page does not wait for it.
    unawaited(cubit.load());
    return cubit;
  }
}
