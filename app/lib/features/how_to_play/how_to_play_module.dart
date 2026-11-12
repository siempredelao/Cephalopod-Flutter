import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/core/navigation/feature_module.dart';
import 'package:cephalopod/features/how_to_play/domain/how_to_play_repository.dart';
import 'package:cephalopod/features/how_to_play/presentation/bloc/how_to_play_cubit.dart';
import 'package:cephalopod/features/how_to_play/presentation/view/how_to_play_page.dart';
import 'package:go_router/go_router.dart';

/// Wires the How to play feature on the repository the composition root
/// picks. Each visit to its route gets its own [HowToPlayCubit].
final class HowToPlayModule implements FeatureModule {
  HowToPlayModule({required this._howToPlayRepository});

  final HowToPlayRepository _howToPlayRepository;

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: 'how-to-play',
      name: AppRoute.howToPlay.name,
      builder: (_, _) => HowToPlayPage(createCubit: _createCubit),
    ),
  ];

  /// Whether How to play has been shown on this device. A plain function,
  /// so the composition root can hand it to Home, which opens How to play
  /// by itself on the first launch only.
  Future<bool> hasSeenHowToPlay() => _howToPlayRepository.hasSeenHowToPlay();

  HowToPlayCubit _createCubit() {
    return HowToPlayCubit(howToPlayRepository: _howToPlayRepository);
  }
}
