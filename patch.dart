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
  
  text = text.replaceAllMapped(
    RegExp(r'audioSource = LockCachingAudioSource\(\s*Uri\.parse\((.*?)\),\s*\);'),
    (match) => 'audioSource = LockCachingAudioSource(\nUri.parse(${match.group(1)}),\nheaders: ${match.group(1)}.toString().contains("googlevideo.com") ? _ytHeaders : null,\n);'
  );
  
  text = text.replaceAllMapped(
    RegExp(r'audioSource\s*=\s*AudioSource\.uri\(\s*Uri\.parse\((.*?)\)\s*\);'),
    (match) => 'audioSource = AudioSource.uri(Uri.parse(${match.group(1)}),\nheaders: ${match.group(1)}.toString().contains("googlevideo.com") ? _ytHeaders : null,);'
  );
  
  file.writeAsStringSync(text);
}
