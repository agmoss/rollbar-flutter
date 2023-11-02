import 'dart:math';

import 'package:test/test.dart';
import 'package:rollbar_common_bump/rollbar_common_bump.dart' hide isTrue, isFalse;
import 'package:rollbar_dart_bump/rollbar_dart_bump.dart';

final rnd = Random();

void main() {
  group('Config tests', () {
    test('Serialization uses camelCase for keys', () {
      expect(
          Config(accessToken: rnd.nextString(16))
              .toMap()
              .anyKey((k) => k.contains('_')),
          isFalse);
    });
  });
}
