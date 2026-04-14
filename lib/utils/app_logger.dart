import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// App-wide logging. Prefer [AppLog.d]/[i]/[w]/[e] over [print] for filterable,
/// level-based output. In release builds only [w] and [e] are emitted by default.
///
/// Usage:
/// ```dart
/// AppLog.d('Debug detail');
/// AppLog.i('User opened dashboard');
/// AppLog.w('Retrying request');
/// AppLog.e('Save failed', e, st);
/// ```
class AppLog {
  AppLog._();

  static Logger? _logger;

  /// Call once from [main] after [WidgetsFlutterBinding.ensureInitialized].
  static void init() {
    _logger = Logger(
      level: kReleaseMode ? Level.warning : Level.debug,
      filter: _InvoiceSathiLogFilter(),
      printer: PrettyPrinter(
        methodCount: kReleaseMode ? 0 : 2,
        errorMethodCount: 8,
        lineLength: 100,
        colors: !kReleaseMode,
        printEmojis: !kReleaseMode,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: ConsoleOutput(),
    );
  }

  static Logger get _l {
    final existing = _logger;
    if (existing != null) return existing;
    // Fallback if [init] was skipped (e.g. tests).
    _logger = Logger(
      level: Level.debug,
      printer: PrettyPrinter(methodCount: 0, colors: false, printEmojis: false),
    );
    return _logger!;
  }

  static void t(dynamic message) => _l.t(message);
  static void d(dynamic message) => _l.d(message);
  static void i(dynamic message) => _l.i(message);
  static void w(dynamic message) => _l.w(message);
  static void e(
    dynamic message, [
    Object? error,
    StackTrace? stackTrace,
  ]) =>
      _l.e(message, error: error, stackTrace: stackTrace);

  /// Fatal / unexpected — always worth seeing in release.
  static void f(
    dynamic message, [
    Object? error,
    StackTrace? stackTrace,
  ]) =>
      _l.f(message, error: error, stackTrace: stackTrace);
}

class _InvoiceSathiLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (kReleaseMode) {
      return event.level.index >= Level.warning.index;
    }
    return event.level.index >= Level.debug.index;
  }
}
