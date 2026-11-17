import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latres/app/services/game_service.dart';

void main() {
  group('GameService', () {
    test('fetches and parses the game list', () async {
      final service = GameService(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString(),
            'https://www.freetogame.com/api/games',
          );
          return http.Response(
            jsonEncode([
              {
                'id': 42,
                'title': 'Example Game',
                'thumbnail': 'https://example.com/thumbnail.jpg',
                'genre': 'MMORPG',
                'platform': 'PC (Windows)',
              },
            ]),
            200,
          );
        }),
      );

      final games = await service.fetchGames();

      expect(games, hasLength(1));
      expect(games.single.id, 42);
      expect(games.single.title, 'Example Game');
      expect(games.single.genre, 'MMORPG');
      expect(games.single.platform, 'PC (Windows)');
      expect(games.single.thumbnail, 'https://example.com/thumbnail.jpg');
    });

    test('fetches detail and parses screenshots and optional fields', () async {
      final service = GameService(
        client: MockClient((request) async {
          expect(
            request.url.toString(),
            'https://www.freetogame.com/api/game?id=7',
          );
          return http.Response(
            jsonEncode({
              'id': 7,
              'title': 'Example Game',
              'genre': 'Shooter',
              'platform': 'Web Browser',
              'publisher': 'Example Publisher',
              'developer': 'Example Developer',
              'release_date': '2024-01-01',
              'description': 'A game description.',
              'screenshots': [
                {'id': 1, 'image': 'https://example.com/screenshot.jpg'},
              ],
            }),
            200,
          );
        }),
      );

      final game = await service.fetchGame(7);

      expect(game.id, 7);
      expect(game.publisher, 'Example Publisher');
      expect(game.developer, 'Example Developer');
      expect(game.releaseDate, '2024-01-01');
      expect(game.description, 'A game description.');
      expect(game.screenshots, ['https://example.com/screenshot.jpg']);
      expect(game.thumbnail, isNull);
    });

    test(
      'reports unsuccessful API responses and invalid data shapes',
      () async {
        final unsuccessful = GameService(
          client: MockClient((_) async => http.Response('not found', 404)),
        );
        final invalid = GameService(
          client: MockClient((_) async => http.Response('{}', 200)),
        );

        expect(
          unsuccessful.fetchGame(123),
          throwsA(isA<GameServiceException>()),
        );
        expect(invalid.fetchGames(), throwsA(isA<GameServiceException>()));
      },
    );
  });
}
