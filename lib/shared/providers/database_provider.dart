import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database_helper.dart';

/// Provides the singleton [DatabaseHelper] instance throughout the app.
final databaseHelperProvider = Provider<DatabaseHelper>(
  (ref) => DatabaseHelper.instance,
  name: 'databaseHelperProvider',
);
