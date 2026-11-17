import 'package:hive/hive.dart';

part 'game.g.dart';

@HiveType(typeId: 0)
class Game {
  const Game({
    required this.id,
    required this.title,
    required this.genre,
    required this.platform,
    this.thumbnail,
    this.gameUrl,
    this.publisher = '',
    this.developer = '',
    this.releaseDate = '',
    this.shortDescription = '',
    this.description = '',
    this.screenshots = const [],
  });

  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String genre;

  @HiveField(3)
  final String platform;

  @HiveField(4)
  final String? thumbnail;

  @HiveField(5)
  final String? gameUrl;

  @HiveField(6)
  final String publisher;

  @HiveField(7)
  final String developer;

  @HiveField(8)
  final String releaseDate;

  @HiveField(9)
  final String shortDescription;

  @HiveField(10)
  final String description;

  @HiveField(11)
  final List<String> screenshots;

  factory Game.fromJson(Map<String, dynamic> json) {
    final rawScreenshots = json['screenshots'];
    return Game(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? 'Untitled game',
      genre: json['genre'] as String? ?? 'Unknown genre',
      platform: json['platform'] as String? ?? 'Unknown platform',
      thumbnail: json['thumbnail'] as String?,
      gameUrl: json['game_url'] as String?,
      publisher: json['publisher'] as String? ?? '',
      developer: json['developer'] as String? ?? '',
      releaseDate: json['release_date'] as String? ?? '',
      shortDescription: json['short_description'] as String? ?? '',
      description: json['description'] as String? ?? '',
      screenshots: rawScreenshots is List
          ? rawScreenshots
                .whereType<Map>()
                .map((item) => item['image'])
                .whereType<String>()
                .toList(growable: false)
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'genre': genre,
    'platform': platform,
    'thumbnail': thumbnail,
    'game_url': gameUrl,
    'publisher': publisher,
    'developer': developer,
    'release_date': releaseDate,
    'short_description': shortDescription,
    'description': description,
    'screenshots': screenshots
        .map((image) => {'image': image})
        .toList(growable: false),
  };
}
