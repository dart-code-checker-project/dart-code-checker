import 'package:test/test.dart';
import 'package:test_action_package/abacus.dart';

void main() {
  test('sum returns sum of all arguments', () {
    final abacus = Abacus();

    expect(abacus.sum(1, 2, 3, 4, 5, 6), equals(21));
  });
}
