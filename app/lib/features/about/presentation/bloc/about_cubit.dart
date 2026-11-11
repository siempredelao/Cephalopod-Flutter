import 'package:bloc/bloc.dart';
import 'package:cephalopod/features/about/domain/app_version_source.dart';
import 'package:cephalopod/features/about/domain/link_opener.dart';
import 'package:cephalopod/features/about/domain/models/credits.dart';
import 'package:cephalopod/features/about/presentation/models/about_view_state.dart';

/// The About page's view model: it shows the game's [Credits], looks up the
/// app's version, and opens the designer's website and the official rule
/// sheet in the browser when asked.
class AboutCubit extends Cubit<AboutViewState> {
  AboutCubit({
    required this._appVersionSource,
    required this._linkOpener,
    required Credits credits,
  }) : _credits = credits,
       super(
         AboutViewState(
           copyright: credits.copyright,
           websiteName: _nameOf(credits.website),
         ),
       );

  final AppVersionSource _appVersionSource;
  final LinkOpener _linkOpener;
  final Credits _credits;

  /// The website's name, as a link to it shows it: its host, without `www.`.
  static String _nameOf(Uri website) {
    final host = website.host;
    return host.startsWith('www.') ? host.substring('www.'.length) : host;
  }

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

  /// Opens the designer's website.
  Future<void> openWebsite() => _open(_credits.website);

  /// Opens the official rule sheet.
  Future<void> openRuleSheet() => _open(_credits.ruleSheet);

  /// Opens [address]. When it does not open, the page says so and shows the
  /// address; when it does, that note goes away.
  Future<void> _open(Uri address) async {
    final opened = await _linkOpener(address);
    if (isClosed) return;
    emit(state.copyWith(failedLinkAddress: opened ? null : '$address'));
  }
}
