import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wrld/data/local_post_data_source.dart';
import 'package:wrld/providers/post_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const genreId = '7b3f3fcfe1124ba69c0708d4343f42ea';
  const subGenreId = 'hh-rage';
  const seededPostId = 'p1';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads seeded threads when persisted data is missing', () async {
    final dataSource = LocalPostDataSource();

    final threads = await dataSource.loadThreads();

    expect(threads, isNotEmpty);
    expect(threads['$genreId:$subGenreId'], isNotEmpty);
  });

  test('persists posts and likes across provider reloads', () async {
    final provider = PostProvider(dataSource: LocalPostDataSource());
    await provider.waitUntilLoaded();

    await provider.addPost(
      genreId: genreId,
      subGenreId: subGenreId,
      content: 'Persistence check from test',
    );
    await provider.toggleLike(
      genreId: genreId,
      subGenreId: subGenreId,
      postId: seededPostId,
    );

    final reloadedThreads = await LocalPostDataSource().loadThreads();
    final posts = reloadedThreads['$genreId:$subGenreId'] ?? const [];

    expect(
      posts.any((post) => post.content == 'Persistence check from test'),
      isTrue,
    );

    final likedSeededPost = posts.firstWhere((post) => post.id == seededPostId);
    expect(likedSeededPost.isLikedByUser, isTrue);
    expect(likedSeededPost.likes, 248);
  });
}
