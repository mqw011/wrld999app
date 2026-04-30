import 'dart:io';
void main() {
  Directory.current = Directory('/home/wrld/Documents/aiu/dart-flutter/rubezhka/BlackHole');
  final possiblePaths = [
    '${Platform.environment['HOME']}/.local/share/wrld999',
    '${Platform.environment['HOME']}/.local/share/BlackHole',
    '${Platform.environment['HOME']}/.config/wrld999',
    '${Platform.environment['HOME']}/Documents/aiu/dart-flutter/rubezhka/BlackHole/wrld999'
  ];
  for (var path in possiblePaths) {
    final d = Directory(path);
    if (d.existsSync()) {
      print('Clearing: $path');
      d.deleteSync(recursive: true);
    }
  }
}
