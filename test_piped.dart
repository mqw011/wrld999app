import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final res = await http.get(Uri.parse('https://pipedapi.kavin.rocks/streams/09cZRYupO4s'));
  print('API status: ${res.statusCode}');
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    final audio = (data['audioStreams'] as List).first;
    print('URL: ${audio['url']}');
    
    final head = await http.get(Uri.parse(audio['url']));
    print('Stream GET status: ${head.statusCode}');
  }
}
