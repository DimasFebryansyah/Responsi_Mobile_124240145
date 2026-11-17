import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:latres/app/controllers/library_controller.dart';
import 'package:latres/app/models/game.dart';

void main() {
  late Directory directory;
  late Box<Game> box;

  setUp(() async {
    await Hive.close();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(GameAdapter());
    }
    directory = await Directory.systemTemp.createTemp('hydra-library-');
    Hive.init(directory.path);
    box = await Hive.openBox<Game>('library_games');
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('adds and deletes games in Hive', () async {
    final controller = LibraryController(box);
    final game = Game(
      id: 8,
      title: 'Example Game',
      genre: 'MMORPG',
      platform: 'PC (Windows)',
    );

    await controller.add(game);

    expect(controller.contains(game), isTrue);
    expect(controller.games.single.title, 'Example Game');
    expect(box.containsKey(game.id), isTrue);

    await controller.remove(game);

    expect(controller.contains(game), isFalse);
    expect(controller.games, isEmpty);
    expect(box.containsKey(game.id), isFalse);
  });

  test('stores game details and screenshots across a Hive reload', () async {
    final game = Game(
      id: 21,
      title: 'Saved Game',
      genre: 'Strategy',
      platform: 'Web Browser',
      screenshots: const ['https://example.com/screenshot.jpg'],
    );
    await box.put(game.id, game);
    await box.close();
    box = await Hive.openBox<Game>('library_games');

    final restored = box.get(21);
    expect(restored?.title, 'Saved Game');
    expect(restored?.screenshots, ['https://example.com/screenshot.jpg']);
  });
}
