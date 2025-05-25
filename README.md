# 🥭 Frutty — Aplikasi Mobile Informasi & Toko Buah Pintar

Frutty adalah aplikasi mobile bertema buah yang dikembangkan sebagai tugas akhir mata kuliah **Teknologi dan Pemrograman Mobile**. Aplikasi ini memadukan fitur edukasi buah, toko buah digital, serta pemanfaatan API, konversi, sensor, dan database lokal.

## 📱 Fitur Utama

- 🔐 Login dengan enkripsi dan session (tanpa Firebase)
- 🍎 Menampilkan data buah & nutrisinya dari [Fruityvice API](https://www.fruityvice.com/api/fruit/all)
- 🛒 Toko buah (pilih buah dan tambahkan ke keranjang)
- 🔍 Pencarian buah berdasarkan nama
- 💰 Konversi mata uang (IDR, USD, EUR)
- 🕒 Konversi waktu (WIB, WITA, WIT, London)
- 🔔 Notifikasi seputar konsumsi buah
- 📡 Sensor sederhana (accelerometer)
- 👤 Profil pengguna (termasuk foto)
- 📝 Saran dan kesan terhadap mata kuliah
- 🚪 Logout dan manajemen sesi

## 🛠️ Teknologi yang Digunakan

- **Bahasa**: Dart
- **Framework**: Flutter
- **Database Lokal**: SQLite
- **State Management**: Provider
- **API**: [Fruityvice](https://www.fruityvice.com/)
- **Enkripsi Password**: `crypto`
- **Session**: `shared_preferences`
- **Notifikasi**: `flutter_local_notifications`
- **Sensor**: `flutter_sensors`
- **Konversi Waktu**: `intl`

## 📂 Struktur Proyek 

```

lib/
├── main.dart
├── core/
│   ├── constants/
│   ├── services/
│   ├── utils/
├── models/
├── views/
│   ├── auth/
│   ├── home/
│   ├── profile/
│   ├── conversion/
│   ├── splash/
├── widgets/
├── providers/

````

## 🚀 Cara Menjalankan Aplikasi

1. **Clone repositori**
   ```
   git clone https://github.com/username/frutty.git
   cd frutty
   ````
2. **Install dependencies**
   ```
   flutter pub get
   ````

3. **Jalankan aplikasi**

   ```
   flutter run
   ````

> Pastikan emulator aktif atau perangkat Android terhubung.

## 📚 Lisensi

Proyek ini dikembangkan untuk keperluan pendidikan dan tidak untuk tujuan komersial.

```

