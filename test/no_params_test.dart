import 'package:flutter_test/flutter_test.dart';
import 'package:cd_shop/core/usecases/usecase.dart';

void main() {
  test('NoParams supports equality', () {
    const a = NoParams();
    const b = NoParams();
    expect(a, equals(b));
  });
}
