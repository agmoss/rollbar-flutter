import 'dart:async';

import 'package:rollbar_dart_bump/rollbar.dart';

abstract class Hook {
  FutureOr<void> install(final Config config);

  FutureOr<void> uninstall();
}
