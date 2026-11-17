# Hydra Games

Aplikasi Flutter untuk menjelajahi game gratis dari FreeToGame, melihat detail game, dan menyimpan koleksi pribadi di perangkat.

## Fitur

- Login menggunakan email dan password pilihan pengguna. Sesi dan email disimpan menggunakan `SharedPreferences`; password tidak disimpan.
- Home mengambil daftar game dari `https://www.freetogame.com/api/games`, menyediakan pencarian, thumbnail, genre, platform, indikator loading, dan tarik-untuk-muat-ulang.
- Detail mengambil data terbaru dari `https://www.freetogame.com/api/game?id={game_id}` dan menampilkan gambar, genre, platform, tanggal rilis, publisher, developer, screenshots, serta deskripsi.
- Game dapat ditambahkan ke atau dihapus dari Library. Koleksi disimpan sebagai objek `Game` dengan Hive `TypeAdapter`.
- Bottom navigation menyediakan Home, Library, dan Profile. Profile menampilkan email, jumlah game di Library, serta tombol logout.

## Menjalankan aplikasi

Pastikan Flutter tersedia, lalu ambil dependency:

```bash
flutter pub get
```

Masuk dengan alamat email yang valid dan password apa pun yang tidak kosong. Akun tidak diverifikasi ke server karena responsi tidak menyediakan layanan autentikasi backend. Koneksi internet diperlukan untuk mengambil data dan gambar dari FreeToGame.

## Struktur penting

```text
lib/
  main.dart
  app/
    controllers/   # sesi login, daftar game, dan koleksi Library
    models/        # model Game dan Hive adapter
    screens/       # login, Home, detail game, Library, dan Profile
    services/      # request dan parsing API FreeToGame
    widgets/       # komponen daftar game
```

## Pengujian

```bash
flutter analyze
flutter test
```
