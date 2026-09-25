# Architecture.md: Membangun Aplikasi Mobile Flutter & Firebase bernama **LoFo (Lost & Found)**.

Tujuan:
Membantu pengguna melaporkan, mencari, dan mengelola laporan barang hilang atau ditemukan secara real-time. Aplikasi ini mengumpulkan data laporan barang beserta foto, menyimpannya di Cloud Firestore, dan memungkinkan komunikasi langsung antar pengguna melalui integrasi WhatsApp.

Gunakan tech stack ini:

* Frontend: Flutter (Dart) + Material 3 UI
* Layanan Backend: Firebase Authentication, Cloud Firestore, Firebase Storage
* Integrasi Eksternal: url_launcher (Integrasi WhatsApp)
* Package Media: image_picker

Aturan kode:

* Jangan tambahkan komentar kecuali sangat diperlukan.
* Gunakan PascalCase untuk kelas Widget, nama Layar (Screen), Model, dan Enum.
* Variabel lokal dan field boleh menggunakan camelCase.
* Jaga agar komponen UI tetap modular dan terisolasi di dalam direktori `widgets`.
* Gunakan struktur folder Flutter yang bersih dan sederhana.
* Gunakan StreamBuilder untuk pembaruan data real-time pada feed utama.

Entitas utama:

1. User

* Uid
* Email
* DisplayName
* CreatedAt

2. Item

* Id
* UserId
* Title
* Type ('Hilang' | 'Ditemukan')
* Description
* Location
* PhoneNumber
* ImageUrl
* CreatedAt

Aturan database:

* Semua laporan barang disimpan di dalam koleksi `items` pada Cloud Firestore.
* Kueri stream real-time harus mengurutkan barang berdasarkan `createdAt` dari yang terbaru (descending) secara otomatis.
* Foto barang harus diunggah ke Firebase Storage pada jalur `items/{userId}_{timestamp}.jpg` sebelum dokumen Firestore dibuat.
* Menghapus laporan barang wajib menghapus dokumen di Firestore sekaligus berkas gambarnya di Firebase Storage.
* Pengguna hanya dapat mengubah atau menghapus dokumen barang apabila `userId` sesuai dengan UID akun mereka yang sedang login.

Fitur Backend & Firebase:

1. Layanan Autentikasi

* Registrasi dan masuk akun menggunakan Email & Password.
* Penggunaan auth state listener untuk menjaga sesi login tetap aktif secara otomatis.

2. Operasi CRUD Barang

* Create (Tambah): Mengunggah gambar ke Firebase Storage, kemudian menyimpan detail barang ke Firestore.
* Read (Baca): Mengalirkan (stream) daftar laporan secara real-time untuk tampilan feed.
* Update (Ubah): Memperbarui detail laporan yang dimiliki oleh pengguna yang sedang login.
* Delete (Hapus): Menghapus data dokumen beserta berkas foto dari penyimpanan.

3. Sistem Pencarian & Filter

* Pencarian berdasarkan judul barang secara langsung pada aliran data (stream) Firestore.
* Filter laporan berdasarkan tipe: 'Semua', 'Hilang', atau 'Ditemukan'.
* Pengurutan laporan berdasarkan tanggal: 'Terbaru' dan 'Terlama'.

4. Peluncur WhatsApp Eksternal

* Membuka obrolan WhatsApp secara langsung menggunakan `url_launcher` dengan draf pesan otomatis.

Halaman & Widget Frontend:

1. LoginScreen & RegisterScreen

* Formulir autentikasi lengkap dengan validasi input.
* Header identitas visual menggunakan widget kustom `LofoLogo`.

2. HomeScreen (Feed Utama)

* Tampilan daftar laporan real-time menggunakan `StreamBuilder`.
* Bilah pencarian di bagian atas serta tombol aksi filter kategori.
* Floating Action Button (FAB) untuk menuju halaman tambah laporan.

3. AddItemScreen

* Area pilih foto dari galeri/kamera lengkap dengan pratinjau interaktif.
* Input formulir untuk Judul, Pilihan Tipe ('Hilang'/'Ditemukan'), Lokasi, Nomor HP/WA, dan Deskripsi.
* Indikator proses pengunggahan saat formulir dikirim.

4. Komponen Kustom

* `LofoLogo`: Widget kombinasi kustom yang menggabungkan ikon pin lokasi dan kaca pembesar.
* `ItemCard`: Kartu tampilan barang pada feed yang berisi foto, lencana status, judul, lokasi, waktu, dan tombol panggil WA.
* `FilterBottomSheet`: Dialog lembaran bawah (bottom sheet) untuk mengatur filter kategori dan pengurutan data.

Persyaratan UI:

* Gunakan bahasa Indonesia untuk seluruh teks UI, label, tombol, dialog, dan pesan validasi.
* Estetika tema: Palet Terracotta / Warm Earthy (`#C85A32`) dengan latar belakang terang yang bersih.
* Warna lencana status:
  * Hilang: Terracotta / Merah Tua
  * Ditemukan: Hijau Hutan
* Tampilan kartu responsif berstandar Material 3, bottom sheet, serta dialog konfirmasi sebelum menghapus laporan.

Struktur proyek:

```text
lofo_app/
assets/
  images/
lib/
  firebase_options.dart
  main.dart
  models/
    item_model.dart
    user_model.dart
  screens/
    add_item_screen.dart
    home_screen.dart
    login_screen.dart
    register_screen.dart
  services/
    auth_service.dart
    firestore_service.dart
  widgets/
    filter_bottom_sheet.dart
    item_card.dart
    lofo_logo.dart
pubspec.yaml
