import 'package:cephalopod/app/app.dart';
import 'package:cephalopod/app/flavor.dart';
import 'package:cephalopod/app/router.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter/widgets.dart';

/// Composition root: the only code that creates concrete dependencies and
/// wires them together. Repositories, use cases and blocs are added here as
/// later milestones need them, and handed down through constructors.
void bootstrap(Flavor flavor) {
  final rules = CephalopodRules();
  runApp(App(flavor: flavor, router: createRouter(rules: rules)));
}
