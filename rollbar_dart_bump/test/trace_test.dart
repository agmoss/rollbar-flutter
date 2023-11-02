import 'package:rollbar_dart_bump/src/stacktrace.dart';
import 'package:test/test.dart';

void main() {
  group('Obfuscation tests', () {
    test('Can parse obfuscated android trace', () async {
      // An actual trace, from the rollbar-flutter example app
      final input = '''
Warning: This VM has been configured to produce stack traces that violate the Dart standard.
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
pid: 8193, tid: 8210, name 1.ui
build_id: 'a425928b1721b04b00574e4498620d0a'
isolate_dso_base: 74207f2e0000, vm_dso_base: 74207f2e0000
isolate_instructions: 74207f2ee000, vm_instructions: 74207f2e2000
    #00 abs 000074207f4c41c4 virt 00000000001e41c4 _kDartIsolateSnapshotInstructions+0x1d61c4
    #01 abs 000074207f36e53b virt 000000000008e53b _kDartIsolateSnapshotInstructions+0x8053b
<asynchronous suspension>
    #02 abs 000074207f3e2b1b virt 0000000000102b1b _kDartIsolateSnapshotInstructions+0xf4b1b
<asynchronous suspension>
    #03 abs 000074207f3e2ed9 virt 0000000000102ed9 _kDartIsolateSnapshotInstructions+0xf4ed9
<asynchronous suspension>
''';
      final trace = StackTrace.fromString(input);
      final frames = [
        '#00 abs 000074207f4c41c4 virt 00000000001e41c4 _kDartIsolateSnapshotInstructions+0x1d61c4',
        '#01 abs 000074207f36e53b virt 000000000008e53b _kDartIsolateSnapshotInstructions+0x8053b',
        '#02 abs 000074207f3e2b1b virt 0000000000102b1b _kDartIsolateSnapshotInstructions+0xf4b1b',
        '#03 abs 000074207f3e2ed9 virt 0000000000102ed9 _kDartIsolateSnapshotInstructions+0xf4ed9'
      ];

      expect(trace.rawTrace, equals(input));
      expect(trace.frames, hasLength(4));
      expect(trace.frames[0].method, equals(frames[0]));
      expect(trace.frames[1].method, equals(frames[1]));
      expect(trace.frames[2].method, equals(frames[2]));
      expect(trace.frames[3].method, equals(frames[3]));
    });
  });
}
