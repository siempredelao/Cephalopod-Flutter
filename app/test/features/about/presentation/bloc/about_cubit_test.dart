import 'package:cephalopod/features/about/presentation/bloc/about_cubit.dart';
import 'package:cephalopod/features/about/presentation/models/about_view_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AboutCubit', () {
    test('starts with the address of the rule sheet', () {
      final cubit = AboutCubit(
        ruleSheet: Uri.parse('https://example.org/rules.pdf'),
      );

      expect(
        cubit.state,
        const AboutViewState(ruleSheetAddress: 'https://example.org/rules.pdf'),
      );
    });
  });
}
