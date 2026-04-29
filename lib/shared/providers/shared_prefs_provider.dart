import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the [SharedPreferences] instance initialised in [main].
/// Override with [ProviderScope(overrides: [...])] before [runApp].
final sharedPrefsProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError(
    'sharedPrefsProvider must be overridden in main() before runApp.',
  ),
  name: 'sharedPrefsProvider',
);
