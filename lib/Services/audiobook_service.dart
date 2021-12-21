import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:musicplayerv2/Models/audiobooks.dart';

class AudioBookService {
  static const String baseUrl = 'http://13.126.119.195:3000/items/';

  static Future<List<AudioBook>> getAudioBooks(String id) async {
    final response = await http.get(Uri.parse(baseUrl + 'AudioBooks?fields=*,audiolists.*,category.*,reader.*'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final audioBooks = json['data'] as List;
      return audioBooks.map((audioBook) => AudioBook.fromJson(audioBook)).toList();
    } else {
      throw Exception('Failed to load audiobooks');
    }
  }
}