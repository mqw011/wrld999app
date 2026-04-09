// Place this file in: lib/data/firestore_post_data_source.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/post.dart';
import 'local_post_data_source.dart';

class FirestorePostDataSource implements PostDataSource {
  FirestorePostDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<Map<String, List<Post>>> loadThreads() async {
    final seededThreads = _seededThreads();
    final snapshot = await _firestore.collection('posts').get();

    if (snapshot.docs.isEmpty) {
      return seededThreads;
    }

    final loadedThreads = <String, List<Post>>{};
    for (final threadDoc in snapshot.docs) {
      final messagesSnapshot = await threadDoc.reference
          .collection('messages')
          .orderBy('timestamp')
          .get();

      final posts = messagesSnapshot.docs
          .map((doc) => Post.fromJson(doc.data()))
          .toList(growable: false);

      loadedThreads[threadDoc.id] = posts;
    }

    for (final entry in seededThreads.entries) {
      loadedThreads.putIfAbsent(entry.key, () => entry.value);
    }

    return loadedThreads;
  }

  @override
  Future<void> saveThreads(Map<String, List<Post>> threads) async {
    final batch = _firestore.batch();

    for (final entry in threads.entries) {
      final threadRef = _firestore.collection('posts').doc(entry.key);
      batch.set(threadRef, {
        'threadKey': entry.key,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      for (final post in entry.value) {
        final postRef = threadRef.collection('messages').doc(post.id);
        batch.set(postRef, post.toJson());
      }
    }

    await batch.commit();
  }

  Map<String, List<Post>> _seededThreads() {
    return {
      for (final entry in Post.seededThreadPosts.entries)
        entry.key: entry.value.map((post) => post.copyWith()).toList(),
    };
  }
}
