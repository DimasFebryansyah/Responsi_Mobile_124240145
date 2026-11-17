import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/library_controller.dart';
import '../models/game.dart';
import 'game_detail_page.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final library = Get.find<LibraryController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Library',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Obx(() {
        final games = library.games;
        if (games.isEmpty) {
          return const Center(
            child: Text('Library masih kosong. Tambahkan game dari Home.'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LibraryItem(
                game: game,
                onTap: () => _openGame(context, game),
                onDelete: () => library.remove(game),
              ),
            );
          },
        );
      }),
    );
  }

  void _openGame(BuildContext context, Game game) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => GameDetailPage(gameId: game.id)),
    );
  }
}

class _LibraryItem extends StatelessWidget {
  const _LibraryItem({
    required this.game,
    required this.onTap,
    required this.onDelete,
  });

  final Game game;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 76,
            height: 58,
            child: game.thumbnail == null
                ? ColoredBox(
                    color: colors.surfaceContainerHighest,
                    child: const Icon(Icons.sports_esports_rounded),
                  )
                : Image.network(
                    game.thumbnail!,
                    fit: BoxFit.cover,
                    webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                    errorBuilder: (context, error, stackTrace) => ColoredBox(
                      color: colors.surfaceContainerHighest,
                      child: const Icon(Icons.sports_esports_rounded),
                    ),
                  ),
          ),
        ),
        title: Text(game.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${game.genre} · ${game.platform}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          tooltip: 'Hapus dari Library',
          onPressed: onDelete,
          icon: Icon(Icons.delete_outline, color: colors.error),
        ),
      ),
    );
  }
}
