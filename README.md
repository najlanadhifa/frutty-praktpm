# 🍅 Frutty — Aplikasi Toko Buah 

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
   git clone https://github.com/najlanadhifa/frutty-tpm.git
   cd frutty-tpm
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

