import 'dart:io';

void main() {
  final file = File('lib/Services/audio_service.dart');
  String text = file.readAsStringSync();
  
  if (!text.contains('_ytHeaders')) {
    text = text.replaceFirst(
      'bool jobRunning = false;',
      'bool jobRunning = false;\n  static const Map<String, String> _ytHeaders = {\'user-agent\': \'com.google.android.youtube/20.10.38 (Linux; U; Android 11) gzip\'};'
    );
  }

  text = text.replaceFirst(
'''                if (cacheSong) {
                  audioSource = LockCachingAudioSource(
                    Uri.parse(cachedData['url'].toString()),
                  );
                } else {
                  audioSource =
                      AudioSource.uri(Uri.parse(cachedData['url'].toString()));
                }''',
'''                final bool isYtUrl = cachedData['url'].toString().contains('googlevideo.com') || cachedData['url'].toString().contains('youtube.com');
                if (cacheSong) {
                  audioSource = LockCachingAudioSource(
                    Uri.parse(cachedData['url'].toString()),
                    headers: isYtUrl ? _ytHeaders : null,
                  );
                } else {
                  audioSource = AudioSource.uri(
                    Uri.parse(cachedData['url'].toString()),
                    headers: isYtUrl ? _ytHeaders : null,
                  );
                }'''
  );

  text = text.replaceFirst(
'''            if (cacheSong) {
              audioSource = LockCachingAudioSource(
                Uri.parse(mediaItem.extras!['url'].toString()),
              );
            } else {
              audioSource = AudioSource.uri(
                Uri.parse(mediaItem.extras!['url'].toString()),
              );
            }''',
'''            final bool isYtUrl = mediaItem.extras!['url'].toString().contains('googlevideo.com') || mediaItem.extras!['url'].toString().contains('youtube.com');
            if (cacheSong) {
              audioSource = LockCachingAudioSource(
                Uri.parse(mediaItem.extras!['url'].toString()),
                headers: isYtUrl ? _ytHeaders : null,
              );
            } else {
              audioSource = AudioSource.uri(
                Uri.parse(mediaItem.extras!['url'].toString()),
                headers: isYtUrl ? _ytHeaders : null,
              );
            }'''
  );

  text = text.replaceFirst(
'''        } else {
          if (cacheSong) {
            audioSource = LockCachingAudioSource(
              Uri.parse(
                mediaItem.extras!['url'].toString().replaceAll(
                      '_96.',
                      "_\${preferredQuality.replaceAll(' kbps', '')}.",
                    ),
              ),
            );
          } else {
            audioSource = AudioSource.uri(
              Uri.parse(
                mediaItem.extras!['url'].toString().replaceAll(
                      '_96.',
                      "_\${preferredQuality.replaceAll(' kbps', '')}.",
                    ),
              ),
            );
          }
        }''',
'''        } else {
          final String urlStr = mediaItem.extras!['url'].toString().replaceAll(
                '_96.',
                "_\${preferredQuality.replaceAll(' kbps', '')}.",
              );
          final bool isYtUrl = urlStr.contains('googlevideo.com') || urlStr.contains('youtube.com');
          if (cacheSong) {
            audioSource = LockCachingAudioSource(
              Uri.parse(urlStr),
              headers: isYtUrl ? _ytHeaders : null,
            );
          } else {
            audioSource = AudioSource.uri(
              Uri.parse(urlStr),
              headers: isYtUrl ? _ytHeaders : null,
            );
          }
        }'''
  );

  file.writeAsStringSync(text);
}
