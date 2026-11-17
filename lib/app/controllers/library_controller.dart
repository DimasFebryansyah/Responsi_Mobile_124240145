import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/game.dart';

class LibraryController extends GetxController {
  LibraryController(this._box);

  final Box<Game> _box;
  final games = <Game>[].obs;

  @override
  void onInit() {
    super.onInit();
    _reload();
  }

  bool contains(Game game) => games.any((item) => item.id == game.id);

  Future<void> add(Game game) async {
    await _box.put(game.id, game);
    _reload();
  }

  Future<void> remove(Game game) async {
    await _box.delete(game.id);
    _reload();
  }

  void _reload() {
    games.assignAll(_box.values);
  }
}
