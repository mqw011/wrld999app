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
  
  // A simpler way: we just ensure the user-agent header is added whenever audio sources are built.
  // Actually, we can just edit the AudioPlayerHandlerImpl.getAudioSource method.
}
