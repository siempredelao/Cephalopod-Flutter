import 'dart:io';

/// Fails when line coverage in an lcov file is below a minimum percentage.
///
/// Usage: `dart run tool/check_coverage.dart <lcov.info> <min-percent>`.
/// Generated files (`*.g.dart`, `*.freezed.dart`) are left out of the total.
void main(List<String> args) {
  final minimum = args.length == 2 ? double.tryParse(args[1]) : null;
  final file = args.isEmpty ? null : File(args.first);
  if (minimum == null || file == null || !file.existsSync()) {
    stderr.writeln(
      'Usage: dart run tool/check_coverage.dart <lcov.info> <min-percent>',
    );
    exitCode = 64;
    return;
  }

  final (:hit, :total) = _lineCoverage(file.readAsLinesSync());
  if (total == 0) {
    stderr.writeln('${args.first}: no coverable lines found.');
    exitCode = 1;
    return;
  }

  final percent = 100 * hit / total;
  final summary =
      '${args.first}: ${percent.toStringAsFixed(1)}% of $total lines '
      '(minimum $minimum%)';
  if (percent < minimum) {
    stderr.writeln('Coverage too low. $summary');
    exitCode = 1;
  } else {
    stdout.writeln('Coverage OK. $summary');
  }
}

const List<String> _generatedSuffixes = ['.g.dart', '.freezed.dart'];

({int hit, int total}) _lineCoverage(List<String> lcov) {
  var hit = 0;
  var total = 0;
  var skipFile = false;
  for (final line in lcov) {
    if (line.startsWith('SF:')) {
      skipFile = _generatedSuffixes.any(line.endsWith);
    } else if (!skipFile && line.startsWith('DA:')) {
      // DA:<line number>,<execution count>[,<checksum>]
      final count = int.tryParse(line.substring(3).split(',')[1]) ?? 0;
      total++;
      if (count > 0) hit++;
    }
  }
  return (hit: hit, total: total);
}
