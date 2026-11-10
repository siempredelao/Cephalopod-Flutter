import 'package:bloc/bloc.dart';
import 'package:cephalopod/features/about/domain/app_version_source.dart';
import 'package:cephalopod/features/about/presentation/models/about_view_state.dart';

/// The About page's view model: it looks up the app's version and shows it
/// beside the address of the rule sheet.
class AboutCubit extends Cubit<AboutViewState> {
  AboutCubit({
    required this._appVersionSource,
    required Uri ruleSheet,
  }) : super(AboutViewState(ruleSheetAddress: ruleSheet.toString()));

  final AppVersionSource _appVersionSource;

  /// Shows the app's version, if it can be known.
  Future<void> load() async {
    final version = await _appVersionSource();
    if (isClosed || version == null) return;
    emit(
      state.copyWith(
        version: (version: version.name, build: version.buildNumber),
      ),
    );
  }
}
