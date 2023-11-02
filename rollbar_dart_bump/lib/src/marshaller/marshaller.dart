import 'package:rollbar_dart_bump/rollbar_dart_bump.dart';
import 'package:rollbar_dart_bump/src/data/event.dart';

/// The class of types that can serialize events received by the Rollbar
/// library into a sendable data object interpretable by the Rollbar API.
abstract class Marshaller {
  Data marshall({
    required final Context context,
    required final Notification event,
  });
}
