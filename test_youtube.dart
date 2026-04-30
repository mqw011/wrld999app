import 'package:youtube_explode_dart_alpha/youtube_explode_dart_alpha.dart';
import 'package:http/http.dart' as http;

void main() async {
  final yt = YoutubeExplode();
  final video = await yt.videos.get('09cZRYupO4s');
  final manifest = await yt.videos.streamsClient.getManifest(video.id);
  final streamInfo = manifest.audioOnly.sortByBitrate().first;
  print('URL: ${streamInfo.url}');

  final res = await http.get(streamInfo.url, headers: {'user-agent': 'com.google.android.youtube/20.10.38 (Linux; U; Android 11) gzip'});
  print('GET status: ${res.statusCode}');
  
  yt.close();
}
