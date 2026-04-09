// Place this file in: lib/services/migration_service.dart

import 'package:shared_preferences/shared_preferences.dart';

import '../data/firestore_post_data_source.dart';
import '../data/local_post_data_source.dart';

class MigrationService {
  MigrationService({
    LocalPostDataSource? localPostDataSource,
    FirestorePostDataSource? firestorePostDataSource,
  }) : _localPostDataSource = localPostDataSource ?? LocalPostDataSource(),
       _firestorePostDataSource =
           firestorePostDataSource ?? FirestorePostDataSource();

  static const String migrationDoneKey = 'wrld.migration.v1.done';
  static const String _localPostsStorageKey = 'wrld.posts.persistence.v1';

  final LocalPostDataSource _localPostDataSource;
  final FirestorePostDataSource _firestorePostDataSource;

  Future<void> migrate() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyMigrated = prefs.getBool(migrationDoneKey) ?? false;
    if (alreadyMigrated) {
      return;
    }

    final localThreads = await _localPostDataSource.loadThreads();
    await _firestorePostDataSource.saveThreads(localThreads);

    await prefs.remove(_localPostsStorageKey);
    await prefs.setBool(migrationDoneKey, true);
  }
}
