import 'package:bloc/bloc.dart';
import 'package:cephalopod/features/about/domain/app_version_source.dart';
import 'package:cephalopod/features/about/domain/link_opener.dart';
import 'package:cephalopod/features/about/presentation/models/about_view_state.dart';

/// The About page's view model: it looks up the app's version, and opens
/// the official rule sheet in the browser when asked.
class AboutCubit extends Cubit<AboutViewState> {
  AboutCubit({
    required this._appVersionSource,
    required this._linkOpener,
    required this._ruleSheet,
  }) : super(AboutViewState(ruleSheetAddress: _ruleSheet.toString()));

  final AppVersionSource _appVersionSource;
  final LinkOpener _linkOpener;
  final Uri _ruleSheet;

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

  /// Opens the rule sheet. When it does not open, the page says so.
  Future<void> openRuleSheet() async {
    final opened = await _linkOpener(_ruleSheet);
    if (isClosed) return;
    emit(state.copyWith(linkFailed: !opened));
  }
}
