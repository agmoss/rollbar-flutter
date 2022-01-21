import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:isolate';

import 'package:async/async.dart';
import 'package:rollbar_common/rollbar_common.dart';
import 'package:rollbar_dart/rollbar_dart.dart';

import '_internal/module.dart';
import 'http_sender.dart';
import 'payload_repository/payload_repository.dart';

class RollbarInfrastructure {
  final ReceivePort _receivePort = ReceivePort();
  late final SendPort _sendPort;

  RollbarInfrastructure._() {
    Isolate.spawn(_processWorkItemsInBackground, _receivePort.sendPort,
        debugName: 'RollbarInfrastructureIsolate');
  }

  Future<SendPort> initialize({required Config rollbarConfig}) async {
    _sendPort = await _receivePort.first;
    ModuleLogger.moduleLogger.info('Send port: $_sendPort');
    _sendPort.send(rollbarConfig);
    return _sendPort;
  }

  Future<void> dispose() async {
    // Send a signal to the spawned isolate indicating that it should exit:
    _sendPort.send(null);
  }

  static final RollbarInfrastructure instance = RollbarInfrastructure._();

  void process({required PayloadRecord record}) {
    _sendPort.send(record);
  }

  static Future<void> _processWorkItemsInBackground(SendPort sendPort) async {
    ModuleLogger.moduleLogger.info('Infrastructure isolate started.');

    // Send a SendPort to the main isolate (RollbarInfrastructure)
    // so that it can send JSON strings to this isolate:
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    // Wait for messages from the main isolate.
    await for (final message in receivePort) {
      if (message is Config) {
        _processConfig(message);
      } else if (message is PayloadRecord) {
        await _processPayloadRecord(message);
      } else if (message == null) {
        // Exit if the main isolate sends a null message, indicating there are no
        // more files to read and parse.
        break;
      }
    }

    ModuleLogger.moduleLogger.info('Infrastructure isolate finished.');
    Isolate.exit();
  }

  static void _processConfig(Config config) {
    if (ServiceLocator.instance.registrationsCount == 0) {
      ServiceLocator.instance.register<PayloadRepository, PayloadRepository>(
          PayloadRepository.create(config.persistPayloads ?? false));
      ServiceLocator.instance.register<Sender, HttpSender>(HttpSender(
          endpoint: config.endpoint, accessToken: config.accessToken));
    }
  }

  static Future<void> _processPayloadRecord(PayloadRecord payloadRecord) async {
    final repo = ServiceLocator.instance.tryResolve<PayloadRepository>();
    if (repo != null) {
      repo.addPayloadRecord(payloadRecord);
      await _processDestinationPendindRecords(payloadRecord.destination, repo);
    } else {
      ModuleLogger.moduleLogger
          .severe('PayloadRepository service was never registered!');
      await HttpSender(
              endpoint: payloadRecord.destination.endpoint,
              accessToken: payloadRecord.destination.accessToken)
          .sendString(payloadRecord.payloadJson);
      return; // we tried our best.
    }
  }

  static Future<void> _processDestinationPendindRecords(
      Destination destination, PayloadRepository repo) async {
    final records =
        await repo.getPayloadRecordsForDestinationAsync(destination);
    if (records.isEmpty) {
      return;
    }

    print('sending ${records.length} payloads to destination: $destination...');
    final sender = HttpSender(
        endpoint: destination.endpoint, accessToken: destination.accessToken);
    for (var record in records) {
      await _processPendingRecord(record, sender, repo);
    }
  }

  static Future<void> _processPendingRecord(
      PayloadRecord record, Sender sender, PayloadRepository repo) async {
    print('sending payload: ${record.payloadJson}...');
    final response = await sender.sendString(record.payloadJson);
    print('response: $response');
    if (response != null && !response.isError()) {
      print('removing sent record from repo...');
      await repo.removePayloadRecordAsync(record);
    } else {
      //TODO: update ConnectivityMonitor...

      final cutoffTime =
          DateTime.now().toUtc().subtract(const Duration(days: 1));
      if (record.timestamp.compareTo(cutoffTime) < 0) {
        await repo.removePayloadRecordAsync(record);
      }
    }
  }
}
