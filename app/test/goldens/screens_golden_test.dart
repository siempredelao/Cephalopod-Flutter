import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/golden.dart';
import '../helpers/pump_app.dart';
import '../helpers/real_fonts.dart';

/// The main screens, drawn as images and compared pixel by pixel with the
/// ones kept in `images/`. A change to how a screen looks fails here until
/// someone looks at it and draws the images again (see the README).
void main() {
  setUpAll(loadRealFonts);

  testWidgets('Home, in English, light', (tester) async {
    const locale = Locale('en');
    useGoldenPhone(tester, locale, Brightness.light);
    await pumpApp(tester);

    await expectGolden('home', locale, Brightness.light);
  });
}
