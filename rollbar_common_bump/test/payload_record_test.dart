import 'dart:convert';

import 'package:rollbar_common_bump/src/data/payload_record.dart';
import 'package:rollbar_common_bump/src/persistable.dart';
import 'package:test/test.dart';

void main() {
  group('PayloadRecord serialization tests', () {
    test('Json roundtrip serialization test', () {
      final record = PayloadRecord(
          accessToken: 'TOKEN1',
          endpoint: 'wwww.site.com',
          payload: 'PAYLOAD1');

      final asMap = record.toMap();
      final asJson = jsonEncode(asMap);
      final recovered = PayloadRecord.fromMap(jsonDecode(asJson));
      expect(recovered, equals(record));
      expect(recovered.id, equals(record.id));
      expect(recovered.timestamp, equals(record.timestamp));
      expect(recovered.accessToken, equals(record.accessToken));
      expect(recovered.endpoint, equals(record.endpoint));
      expect(recovered.payload, equals(record.payload));
    });

    test('Persisting key types are well-formed', () {
      final kt = PayloadRecord.persistingKeyTypes;
      expect(kt.containsKey('id'), isTrue);
      expect(kt.containsKey('accessToken'), isTrue);
      expect(kt.containsKey('endpoint'), isTrue);
      expect(kt.containsKey('payload'), isTrue);
      expect(kt.containsKey('timestamp'), isTrue);

      expect(kt['accessToken']?.sqlTypeDeclaration, equals('TEXT NOT NULL'));
      expect(kt['endpoint']?.sqlTypeDeclaration, equals('TEXT NOT NULL'));
      expect(kt['payload']?.sqlTypeDeclaration, equals('TEXT NOT NULL'));
      expect(kt['timestamp']?.sqlTypeDeclaration, equals('INTEGER NOT NULL'));
      expect(kt['id']?.sqlTypeDeclaration,
          equals('BINARY(16) NOT NULL PRIMARY KEY'));
    });
  });

  group('PayloadRecord serialization tests', () {
    test('Json roundtrip serialization test', () {
      final record = PayloadRecord(
          accessToken: 'TOKEN1',
          endpoint: 'wwww.site.com',
          payload: 'PAYLOAD1');

      final asMap = record.toMap();
      final asJson = jsonEncode(asMap);
      final recovered = PayloadRecord.fromMap(jsonDecode(asJson));
      expect(recovered, equals(record));
      expect(recovered.id, equals(record.id));
      expect(recovered.timestamp, equals(record.timestamp));
      expect(recovered.accessToken, equals(record.accessToken));
      expect(recovered.endpoint, equals(record.endpoint));
      expect(recovered.payload, equals(record.payload));
    });

    test('Persisting key types are well-formed', () {
      final kt = PayloadRecord.persistingKeyTypes;
      expect(kt.containsKey('id'), isTrue);
      expect(kt.containsKey('accessToken'), isTrue);
      expect(kt.containsKey('endpoint'), isTrue);
      expect(kt.containsKey('payload'), isTrue);
      expect(kt.containsKey('timestamp'), isTrue);

      expect(kt['accessToken']?.sqlTypeDeclaration, equals('TEXT NOT NULL'));
      expect(kt['endpoint']?.sqlTypeDeclaration, equals('TEXT NOT NULL'));
      expect(kt['payload']?.sqlTypeDeclaration, equals('TEXT NOT NULL'));
      expect(kt['timestamp']?.sqlTypeDeclaration, equals('INTEGER NOT NULL'));
      expect(kt['id']?.sqlTypeDeclaration,
          equals('BINARY(16) NOT NULL PRIMARY KEY'));
    });
  });
}
