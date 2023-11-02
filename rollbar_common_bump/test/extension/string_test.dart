import 'package:test/test.dart';
import 'package:rollbar_common_bump/src/extension/string.dart';

void main() {
  group('String Extensions', () {
    test('String replaceLast replaces the last occurrence in a string', () {
      expect('0.0001'.replaceLast(RegExp(r'0'), ''), equals('0.001'));
      expect('0.0001'.replaceLast(RegExp(r'0'), '1'), equals('0.0011'));
    });

    test('String CamelCase to snake_case conversion', () {
      expect('CamelCase'.toSnakeCase(), equals('camel_case'));
      expect('camelCase'.toSnakeCase(), equals('camel_case'));
      expect('_CamelCase'.toSnakeCase(), equals('_camel_case'));
      expect('__CamelCase'.toSnakeCase(), equals('__camel_case'));
      expect('_camelCase'.toSnakeCase(), equals('_camel_case'));
      expect('__camelCase'.toSnakeCase(), equals('__camel_case'));
      expect('CamelCase_'.toSnakeCase(), equals('camel_case_'));
      expect('camelCase_'.toSnakeCase(), equals('camel_case_'));
      expect('_CamelCase_'.toSnakeCase(), equals('_camel_case_'));
      expect('Camel2Case2'.toSnakeCase(), equals('camel2_case2'));
      expect(
        'CamelCaseCamelCase'.toSnakeCase(),
        equals('camel_case_camel_case'),
      );
      expect(
        'CamelCASECamelCASE'.toSnakeCase(),
        equals('camel_case_camel_case'),
      );
      expect(
        'CAMELCaseCAMELCase'.toSnakeCase(),
        equals('camel_case_camel_case'),
      );
      expect(
        'already_is_snake_case'.toSnakeCase(),
        equals('already_is_snake_case'),
      );
    });
  });
}
