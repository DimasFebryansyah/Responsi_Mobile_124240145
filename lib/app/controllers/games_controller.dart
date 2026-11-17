import 'package:get/get.dart';

import '../models/game.dart';
import '../services/game_service.dart';

class GamesController extends GetxController {
  GamesController(this._service);

  final GameService _service;
  final games = <Game>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;

  List<Game> get filteredGames {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return games;
    return games
        .where((game) => game.title.toLowerCase().contains(query))
        .toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    fetchGames();
  }

  Future<void> fetchGames() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      games.assignAll(await _service.fetchGames());
    } on Exception catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
