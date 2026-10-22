# DompetKu - Aplikasi Pencatatan Keuangan Pintar (Android & Mobile)

Aplikasi mobile pencatatan keuangan end-to-end dengan UI modern, responsif, dan kaya fitur yang diadaptasi dari studi kasus mobile UI/UX **DompetKu App**.

![DompetKu Banner](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

---

## 📱 Fitur Utama (Sesuai Mockup UI/UX)

### 1. Dashboard Utama (Home)
- **Header Profil Pengguna:** Sapaan cerdas *"Halo, [Nama]!"* dengan avatar pengguna dan notifikasi badge. Nama pengguna dapat diedit langsung.
- **Kartu Total Saldo Gabungan:** Gradient card premium dengan saldo gabungan real-time, tombol privasi *show/hide balance*, serta tombol aksi cepat **+ Pemasukan** dan **- Pengeluaran**.
- **Indikator Sisa Anggaran Bulanan:** Progress bar interaktif sisa budget bulan berjalan (contoh: *Sisa Budget: 65%*).
- **Daftar Transaksi Terakhir:** Riwayat transaksi lengkap dengan ikon kategori, sumber dompet, format tanggal dinamis (*Hari ini, Kemarin*), serta swipe-to-delete dengan konfirmasi dialog untuk mencegah kehilangan data secara tidak sengaja.
- **Pencarian Transaksi:** Filter dan cari riwayat transaksi secara langsung berdasarkan nama/kategori/dompet.

### 2. Tambah & Edit Transaksi (3-Tap Quick Input)
- **Modal Input Cepat:** Bottom sheet terintegrasi dengan animasi halus.
- **Tipe Transaksi:** Segmented button dinamis *Pengeluaran* dan *Pemasukan*.
- **Grid Kategori Visual:** Pilihan kategori dengan ikon emoji (🍔 Makan, 🚗 Transport, 🛒 Belanja, 🎬 Hiburan, 💡 Tagihan, 💰 Gaji, 💻 Freelance, 📈 Investasi).
- **Sumber Dana & Kalender:** Dropdown sumber dompet aktif dan pemilih tanggal (*Date Picker*).
- **Custom Numpad Interaktif:** Numpad 4 kolom dengan shortcut cepat (+50rb, Backspace, serta simulasi **Scan Struk Cerdas OCR**).

### 3. Analisis Keuangan (Analytics)
- **Navigasi Waktu/Bulan:** Selector bulan interaktif (`< Bulan Tahun >`) untuk melihat tren per bulan.
- **Custom Animated Donut Chart:** Visualisasi grafik lingkaran donat kategori pengeluaran/pemasukan dengan nominal total di tengah (*"Rp 3.200.000 Total Keluar"*).
- **Rincian Persentase Kategori:** Breakdown tiap kategori lengkap dengan nominal, persentase kontribusi, dan progress bar berwarna.
- **Ringkasan Cash Flow:** Komparasi total masuk vs total keluar bulan berjalan.

### 4. Dompet & Anggaran (Wallets & Budget)
- **Kelola Dompet Multi-Akun:** Tambah dompet baru (*+ Tambah*), ubah saldo, edit nama/ikon, atau hapus dompet.
- **Transfer Antar Dompet:** Fitur perpindahan saldo instan antar dompet (misal: Bank BCA ke GoPay) yang otomatis tercatat dalam riwayat mutasi.
- **Manajemen Batas Anggaran (Budget Bulanan):** Atur batas budget per kategori pengeluaran dengan badge peringatan (⚠️) saat pengeluaran mendekati atau melampaui batas.

### 5. Fitur Pendukung Lainnya
- **Mode Gelap / Terang (Dark Mode / Light Mode):** Dukungan penuh tema gelap modern (*Deep Slate / Dark Navy*).
- **Penyimpanan Lokal Persisten:** Menggunakan `shared_preferences` untuk menyimpan semua transaksi, dompet, nama pengguna, dan budget secara lokal tanpa server.
- **Reset Demo Data:** Pilihan reset cepat ke data sampel dari menu bar.

---

## 📂 Struktur Arsitektur Kode

```
lib/
├── main.dart                          # Inisialisasi aplikasi, theming M3 & routing
├── models/
│   ├── transaction_model.dart         # Model transaksi (id, nominal, kategori, dompet, tanggal, tipe)
│   └── wallet_model.dart              # Model dompet (nama, ikon, saldo)
├── screens/
│   ├── home_screen.dart               # Layar 1: Home Dashboard & Riwayat Transaksi
│   ├── analytics_screen.dart          # Layar 2: Analisis Keuangan & Donut Chart
│   ├── wallets_screen.dart            # Layar 3: Manajemen Dompet, Transfer, & Budget
│   └── main_navigation_screen.dart    # Shell navigasi & BottomAppBar notched
├── services/
│   └── data_service.dart              # State management (ChangeNotifier) & SharedPreferences
├── utils/
│   ├── constants.dart                 # Palet warna, ikon kategori & dompet
│   └── formatters.dart                # Formatter Rupiah & tanggal Indonesia
└── widgets/
    ├── budget_card.dart               # Kartu budget kategori dengan indikator warning
    ├── donut_chart.dart               # CustomPainter animated Donut Chart
    ├── quick_input_sheet.dart         # Modal input transaksi dengan custom numpad
    ├── transaction_card.dart          # Kartu transaksi dengan swipe-to-delete
    └── wallet_card.dart               # Kartu dompet dengan popup aksi
```

---

## 🚀 Cara Menjalankan Aplikasi

1. Pastikan Flutter SDK sudah terpasang di komputer Anda (`>= 3.2.0`).
2. Jalankan perintah instalasi dependency:
   ```bash
   flutter pub get
   ```
3. Hubungkan perangkat Android / Emulator, lalu jalankan:
   ```bash
   flutter run
   ```