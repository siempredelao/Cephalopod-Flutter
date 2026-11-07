import 'dart:io';

/// Checks that imports follow the dependency rule in docs/architecture.md.
///
/// Run from the repository root: `dart run tool/check_architecture.dart`.
/// Prints every violation and exits with code 1 when a rule is broken.
void main() {
  final violations = [
    for (final file in _dartFiles(_engine)) ..._checkEngineFile(file),
    for (final file in _dartFiles(_app)) ..._checkAppFile(file),
  ];

  if (violations.isEmpty) {
    stdout.writeln('Architecture check passed.');
    return;
  }
  stderr
    ..writeln('Architecture check failed (${violations.length}):')
    ..writeAll(violations.map((violation) => '  $violation\n'));
  exitCode = 1;
}

/// A workspace package: its name and its `lib` folder from the repo root.
typedef _Package = ({String name, String lib});

/// Where a file sits in `app/lib`: `features/game/domain/x.dart` is layer
/// `features`, feature `game`, sublayer `domain`. Inside presentation, the
/// folder says which part it is: `view`, `models` or `bloc`.
typedef _Location = ({
  String layer,
  String? feature,
  String? sublayer,
  String? folder,
});

const _Package _engine = (
  name: 'cephalopod_engine',
  lib: 'packages/cephalopod_engine/lib',
);
const _Package _app = (name: 'cephalopod', lib: 'app/lib');

/// Imports that tie code to Flutter or the platform.
const List<String> _flutterImports = [
  'package:flutter/',
  'package:material_ui/',
  'package:cupertino_ui/',
  'dart:ui',
];

/// The engine stays pure: no Flutter and no I/O.
const List<String> _engineForbidden = [..._flutterImports, 'dart:io'];

/// Which sublayers of the same feature each sublayer may import.
const Map<String, Set<String>> _allowedWithinFeature = {
  'domain': {'domain'},
  'data': {'data', 'domain'},
  'presentation': {'presentation', 'domain'},
};

/// Which folders of the same feature's presentation each folder may import.
/// Views reach the blocs to send them events; UI models are plain data; the
/// blocs build UI models but never widgets (docs/adr/0015).
const Map<String, Set<String>> _allowedWithinPresentation = {
  'view': {'view', 'models', 'bloc'},
  'models': {'models'},
  'bloc': {'bloc', 'models'},
};

/// The presentation folders that only handle UI models, so neither the
/// engine nor the domain (docs/adr/0015).
const Set<String> _uiModelFolders = {'view', 'models'};

final RegExp _directive = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
);

Iterable<String> _checkEngineFile(File file) sync* {
  for (final uri in _directivesOf(file, _engine)) {
    if (_engineForbidden.any(uri.startsWith)) {
      yield '${_path(file)} imports $uri: the engine must stay pure Dart';
    }
  }
}

Iterable<String> _checkAppFile(File file) sync* {
  final from = _locate(_path(file).substring(_app.lib.length + 1));
  for (final uri in _directivesOf(file, _app)) {
    final reason = _appViolation(from, uri);
    if (reason != null) yield '${_path(file)} imports $uri: $reason';
  }
}

/// Why importing [uri] from [from] breaks the dependency rule, or `null`
/// when the import is allowed.
String? _appViolation(_Location from, String uri) {
  if (from.sublayer == 'domain' && _flutterImports.any(uri.startsWith)) {
    return 'domain code must stay pure Dart';
  }
  final rendersUiModels = _uiModelFolders.contains(from.folder);
  if (rendersUiModels && uri.startsWith('package:${_engine.name}/')) {
    return '${from.folder} must not depend on the engine: it uses UI models';
  }
  final ownPackage = 'package:${_app.name}/';
  if (!uri.startsWith(ownPackage)) return null;

  final to = _locate(uri.substring(ownPackage.length));
  if (from.layer == 'core' && to.layer != 'core') {
    return 'core must not depend on app/ or features/';
  }
  if (from.feature == null) return null;
  if (to.layer == 'app') return 'features must not depend on app/';
  if (to.feature != null && to.feature != from.feature) {
    return 'features must not import other features (use core/)';
  }

  final allowed = _allowedWithinFeature[from.sublayer];
  if (to.feature == from.feature &&
      to.sublayer != null &&
      allowed != null &&
      !allowed.contains(to.sublayer)) {
    return '${from.sublayer} must not depend on ${to.sublayer}';
  }
  if (to.feature == from.feature) return _presentationViolation(from, to);
  return null;
}

/// Why [from] may not import [to], both in the same feature, under the UI
/// model rule (docs/adr/0015), or `null` when it may.
String? _presentationViolation(_Location from, _Location to) {
  if (_uiModelFolders.contains(from.folder) && to.sublayer == 'domain') {
    return '${from.folder} must not depend on domain: it uses UI models';
  }
  final allowed = _allowedWithinPresentation[from.folder];
  final toFolder = to.folder;
  if (allowed == null || toFolder == null || allowed.contains(toFolder)) {
    return null;
  }
  return 'presentation/${from.folder} must not depend on '
      'presentation/$toFolder';
}

_Location _locate(String libPath) {
  final parts = libPath.split('/');
  final inFeature = parts.first == 'features' && parts.length > 2;
  final sublayer = inFeature && parts.length > 3 ? parts[2] : null;
  final inPresentation = sublayer == 'presentation' && parts.length > 4;
  return (
    layer: parts.first,
    feature: inFeature ? parts[1] : null,
    sublayer: sublayer,
    folder: inPresentation ? parts[3] : null,
  );
}

/// The import and export URIs of [file]. Relative URIs are turned into
/// `package:` URIs, so every rule compares the same form.
Iterable<String> _directivesOf(File file, _Package package) sync* {
  final path = _path(file);
  final libPrefix = '${package.lib}/';
  for (final line in file.readAsLinesSync()) {
    final uri = _directive.firstMatch(line)?.group(1);
    if (uri == null) continue;
    if (uri.contains(':')) {
      yield uri;
      continue;
    }
    final resolved = Uri.parse(path).resolve(uri).path;
    if (resolved.startsWith(libPrefix)) {
      yield 'package:${package.name}/${resolved.substring(libPrefix.length)}';
    } else {
      yield resolved;
    }
  }
}

Iterable<File> _dartFiles(_Package package) {
  return Directory(package.lib)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

String _path(File file) => file.path.replaceAll(r'\', '/');
