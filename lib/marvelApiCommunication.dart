import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class MarvelApi {
  String publicKey = dotenv.env['PUBLIC_KEY'].toString();
  final String privateKey = dotenv.env['PRIVATE_KEY'].toString();
  final String baseUrl = 'https://gateway.marvel.com/v1/public';

  String _generateHash(String ts) {
    var content = ts + privateKey + publicKey;
    return md5.convert(utf8.encode(content)).toString();
  }

  Future<Map<String, dynamic>> getAllCharacters(int offset) async {
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = _generateHash(ts);
    int nbrCharacter = 40;
    final url =
        '$baseUrl/characters?limit=$nbrCharacter&offset=$offset&ts=$ts&apikey=$publicKey&hash=$hash';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      return data['data'];
    } catch (e) {
      print('Error: $e');
      return <String, dynamic>{};
    }
  }

  Future<Map<String, dynamic>> getFilteredCharacter(
      int offset, String name) async {
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = _generateHash(ts);
    int nbrCharacter = 40;
    final url =
        '$baseUrl/characters?nameStartsWith=$name&limit=$nbrCharacter&offset=$offset&ts=$ts&apikey=$publicKey&hash=$hash';
    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      return data['data'];
    } catch (e) {
      print('Error: $e');
      return <String, dynamic>{};
    }
  }
}
