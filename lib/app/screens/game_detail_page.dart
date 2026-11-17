import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/library_controller.dart';
import '../models/game.dart';
import '../services/game_service.dart';

class GameDetailPage extends StatefulWidget {
  const GameDetailPage({required this.gameId, super.key});

  final int gameId;

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  final _service = GameService();
  late Future<Game> _gameFuture;

  @override
  void initState() {
    super.initState();
    _gameFuture = _service.fetchGame(widget.gameId);
  }

  void _retry() {
    setState(() => _gameFuture = _service.fetchGame(widget.gameId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail game')),
      body: FutureBuilder<Game>(
        future: _gameFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Detail game tidak dapat dimuat.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: _retry,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final game = snapshot.data;
          if (game == null) {
            return const Center(child: Text('Data game tidak tersedia.'));
          }
          return _GameDetails(game: game);
        },
      ),
    );
  }
}

class _GameDetails extends StatelessWidget {
  const _GameDetails({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final library = Get.find<LibraryController>();
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            height: 240,
            child: game.thumbnail == null
                ? ColoredBox(
                    color: colors.surfaceContainerHighest,
                    child: const Icon(Icons.sports_esports_rounded, size: 72),
                  )
                : Image.network(
                    game.thumbnail!,
                    fit: BoxFit.cover,
                    webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                    errorBuilder: (context, error, stackTrace) => ColoredBox(
                      color: colors.surfaceContainerHighest,
                      child: const Icon(Icons.sports_esports_rounded, size: 72),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          game.title,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            Chip(label: Text(game.genre)),
            Chip(label: Text(game.platform)),
          ],
        ),
        const SizedBox(height: 8),
        _GameInformation(game: game),
        if (game.screenshots.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text(
            'Screenshots',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: game.screenshots.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  game.screenshots[index],
                  width: 240,
                  fit: BoxFit.cover,
                  webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                  errorBuilder: (context, error, stackTrace) => SizedBox(
                    width: 240,
                    child: ColoredBox(
                      color: colors.surfaceContainerHighest,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 22),
        Text(
          'Deskripsi',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          game.description.isNotEmpty
              ? game.description
              : game.shortDescription.isNotEmpty
              ? game.shortDescription
              : 'Deskripsi belum tersedia.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 22),
        Obx(() {
          final isOwned = library.contains(game);
          return FilledButton.icon(
            onPressed: () async {
              if (isOwned) {
                await library.remove(game);
                Get.snackbar(
                  'Game dihapus',
                  '${game.title} dihapus dari Library.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } else {
                await library.add(game);
                Get.snackbar(
                  'Game ditambahkan',
                  '${game.title} sekarang ada di Library.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            icon: Icon(
              isOwned ? Icons.delete_outline : Icons.library_add_outlined,
            ),
            label: Text(isOwned ? 'Hapus dari Library' : 'Dapatkan game'),
            style: FilledButton.styleFrom(
              backgroundColor: isOwned ? colors.error : colors.primary,
              minimumSize: const Size.fromHeight(52),
            ),
          );
        }),
      ],
    );
  }
}

class _GameInformation extends StatelessWidget {
  const _GameInformation({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _InfoRow(label: 'Tanggal rilis', value: game.releaseDate),
          const Divider(height: 1),
          _InfoRow(label: 'Publisher', value: game.publisher),
          const Divider(height: 1),
          _InfoRow(label: 'Developer', value: game.developer),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? 'Tidak tersedia' : value)),
        ],
      ),
    );
  }
}
