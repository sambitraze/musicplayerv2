import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:musicplayerv2/Models/audiobooks.dart';

class AudioBookService {
  static const String baseUrl = 'http://13.126.119.195:3000/items/';
  static const String baseImageUrl = 'http://13.126.119.195:3000/assets/';

  static Future<List<AudioBook>> getAudioBooks() async {
    final response = await http.get(Uri.parse(
        baseUrl + 'AudioBooks/?fields=*,audiolists.audiofile_id.*,category.*,reader.*'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final audioBooks = json['data'] as List;
      return audioBooks
          .map((audioBook) => AudioBook.fromJson(audioBook))
          .toList();
    } else {
      throw Exception('Failed to load audiobooks');
    }
  }

  static Future<List<AudioBook>> getAudioBooksById(String id) async {
    final response = await http.get(Uri.parse(
        baseUrl + 'AudioBooks/$id?fields=*,audiolists.audiofile_id.*,category.*,reader.*'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final audioBooks = json['data'] as List;
      return audioBooks
          .map((audioBook) => AudioBook.fromJson(audioBook))
          .toList();
    } else {
      throw Exception('Failed to load audiobooks');
    }
  }
}
