import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/game.dart';

class GameServiceException implements Exception {
  const GameServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GameService {
  GameService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://www.freetogame.com/api';
  final http.Client _client;

  Future<List<Game>> fetchGames() async {
    final response = await _client
        .get(Uri.parse('$_baseUrl/games'))
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw GameServiceException(
        'FreeToGame mengembalikan status ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const GameServiceException(
        'Format daftar game dari FreeToGame tidak valid.',
      );
    }

    return decoded
        .whereType<Map>()
        .map((item) => Game.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<Game> fetchGame(int id) async {
    final response = await _client
        .get(Uri.parse('$_baseUrl/game?id=$id'))
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw GameServiceException(
        'Detail game tidak ditemukan (status ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const GameServiceException(
        'Format detail game dari FreeToGame tidak valid.',
      );
    }

    return Game.fromJson(Map<String, dynamic>.from(decoded));
  }
}
