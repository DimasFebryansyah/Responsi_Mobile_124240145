import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/games_controller.dart';
import '../services/game_service.dart';
import '../widgets/game_card.dart';
import 'game_detail_page.dart';

class ShowsPage extends StatefulWidget {
  const ShowsPage({super.key});

  @override
  State<ShowsPage> createState() => _ShowsPageState();
}

class _ShowsPageState extends State<ShowsPage> {
  final _controller = Get.put(GamesController(GameService()));

  void _openGame(int id) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => GameDetailPage(gameId: id)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hydra Games',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang daftar game',
            onPressed: _controller.fetchGames,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              onChanged: (value) => _controller.searchQuery.value = value,
              decoration: const InputDecoration(
                hintText: 'Cari game...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value && _controller.games.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_controller.errorMessage.isNotEmpty &&
                  _controller.games.isEmpty) {
                return _ErrorState(
                  message: _controller.errorMessage.value,
                  onRetry: _controller.fetchGames,
                );
              }

              final games = _controller.filteredGames;
              if (games.isEmpty) {
                return Center(
                  child: Text(
                    _controller.games.isEmpty
                        ? 'Belum ada data game.'
                        : 'Game tidak ditemukan.',
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _controller.fetchGames,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GameCard(
                        game: game,
                        onTap: () => _openGame(game.id),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 42),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
