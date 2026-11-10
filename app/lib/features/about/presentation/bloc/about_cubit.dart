import 'package:bloc/bloc.dart';
import 'package:cephalopod/features/about/domain/app_version_source.dart';
import 'package:cephalopod/features/about/domain/link_opener.dart';
import 'package:cephalopod/features/about/presentation/models/about_view_state.dart';

/// The About page's view model: it looks up the app's version, and opens
/// Mark Steere's website and the official rule sheet in the browser when
/// asked.
class AboutCubit extends Cubit<AboutViewState> {
  AboutCubit({
    required this._appVersionSource,
    required this._linkOpener,
    required this._website,
    required this._ruleSheet,
  }) : super(const AboutViewState());

  final AppVersionSource _appVersionSource;
  final LinkOpener _linkOpener;
  final Uri _website;
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

  /// Opens Mark Steere's website.
  Future<void> openWebsite() => _open(_website);

  /// Opens the official rule sheet.
  Future<void> openRuleSheet() => _open(_ruleSheet);

  /// Opens [address]. When it does not open, the page says so and shows the
  /// address; when it does, that note goes away.
  Future<void> _open(Uri address) async {
    final opened = await _linkOpener(address);
    if (isClosed) return;
    emit(state.copyWith(failedLinkAddress: opened ? null : '$address'));
  }
}
