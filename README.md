# Pokédex

Aplikasi mobile Flutter yang menampilkan data Pokémon dari [PokéAPI](https://pokeapi.co/).
Dibuat untuk UTS Pemrograman Mobile - Praktikum G.

## Identitas
- **Nama Lengkap:** Raditya Bintang Maulana
- **NIM:** 240605110167
- **Kelas:** Mobile Programming Practicum G

## Deskripsi
Pokédex adalah aplikasi untuk menjelajahi Pokémon dari 9 region/generasi (default: Kanto, 151 Pokémon). Pengguna dapat
mencari dan memfilter Pokémon, lalu melihat detail lengkap: deskripsi, evolusi, statistik,
dan lokasi ditemukannya di tiap game. Seluruh data diambil secara dinamis dari PokéAPI.

## Fitur Utama
- Daftar Pokémon (grid) dengan gambar dan warna kartu sesuai tipe.
- Pencarian berdasarkan nama dan filter berdasarkan tipe.
- Detail Pokémon: tipe, tinggi, berat, base EXP, kemampuan, dan base stats.
- Deskripsi dan rantai evolusi (lengkap dengan syarat evolusi, dapat diketuk untuk membuka detail).
- Lokasi ditemukan per versi game.
- Menu navigasi (drawer): pilih region/generasi (Kanto sampai Paldea) atau tampilkan Semua Region (1025 Pokémon), mode terang/gelap, dan Tentang Aplikasi.
- Penanganan kondisi loading, success, dan error (tombol "Coba Lagi") dengan `FutureBuilder`.

## Teknologi dan Package
- Flutter & Dart (Material 3)
- [`http`](https://pub.dev/packages/http) - permintaan HTTP ke API

## Endpoint API
| Kegunaan | Endpoint |
|---|---|
| Daftar Pokémon (per region) | `https://pokeapi.co/api/v2/pokemon?limit=151&offset=0` |
| Peta tipe (18 request paralel) | `https://pokeapi.co/api/v2/type/{nama}` |
| Detail | `https://pokeapi.co/api/v2/pokemon/{id}` |
| Deskripsi | `https://pokeapi.co/api/v2/pokemon-species/{id}` |
| Evolusi | `url` pada `evolution_chain` (`/evolution-chain/{id}`) |
| Lokasi per game | `https://pokeapi.co/api/v2/pokemon/{id}/encounters` |

## Struktur Folder
```
lib/
├── main.dart
├── models/      # pokemon_summary, pokemon_detail, species_info,
│                # evolution_link, encounter_group, home_data, region
├── services/    # pokemon_service.dart (HTTP + error handling)
├── screens/     # home_screen.dart, detail_screen.dart
├── widgets/     # pokemon_card, error_view, species_section, encounter_section
└── utils/       # type_color.dart, text_utils.dart
test/
└── pokemon_test.dart
```

## Cara Menjalankan
1. Pastikan Flutter SDK sudah terpasang (`flutter doctor`).
2. Clone repositori ini lalu masuk ke foldernya.
3. Jika folder `android/` / `ios/` belum ada, jalankan `flutter create .`
4. Jalankan `flutter pub get`
5. Jalankan emulator atau hubungkan perangkat, lalu `flutter run`
6. (Opsional) Jalankan unit test dengan `flutter test`

> Android: pastikan `android/app/src/main/AndroidManifest.xml` memuat
> `<uses-permission android:name="android.permission.INTERNET"/>` agar aplikasi
> dapat mengakses internet pada mode release.

## Catatan
- Deskripsi Pokémon tersedia dalam bahasa Inggris (sesuai data PokéAPI).
- Beberapa Pokémon tidak memiliki data lokasi alam liar (misalnya hasil evolusi atau legendaris).
