import 'package:cephalopod_engine/src/agents/search/node_budget.dart';
import 'package:test/test.dart';

void main() {
  group('NodeBudget', () {
    test('allows every position until it is enforced', () {
      final budget = NodeBudget(0);

      final allowed = [for (var i = 0; i < 3; i++) budget.trySpend()];

      expect(allowed, [true, true, true]);
      expect(budget.spent, 3);
      expect(budget.ranOut, isFalse);
    });

    test('once enforced, refuses positions past the limit', () {
      final budget = NodeBudget(2)..enforce();

      final allowed = [for (var i = 0; i < 4; i++) budget.trySpend()];

      expect(allowed, [true, true, false, false]);
      expect(budget.spent, 2);
      expect(budget.ranOut, isTrue);
    });

    test('counts the free positions towards the limit', () {
      final budget = NodeBudget(3);
      final free = [budget.trySpend(), budget.trySpend()];
      budget.enforce();

      expect(free, [true, true]);
      expect(budget.trySpend(), isTrue);
      expect(budget.trySpend(), isFalse);
    });

    test('rejects a negative limit', () {
      expect(() => NodeBudget(-1), throwsRangeError);
    });
  });
}
