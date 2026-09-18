*Detail Lapisan Utama (Architecture Layers)*

Presentation Layer

Komponen: Flutter UI / Material 3

Fungsi: Menangani antarmuka visual, tema warna terracotta, form input, dan komponen interaktif pengguna.

State & Logic Layer

Komponen: Dart / StreamBuilder

Fungsi: Mengelola state aplikasi secara real-time, validasi data, serta pemrosesan search & sorting di memori HP.

Authentication Layer

Komponen: Firebase Auth

Fungsi: Mengelola pendaftaran akun, verifikasi email/password, dan mengamankan token sesi login pengguna.

Database Layer

Komponen: Cloud Firestore

Fungsi: Penyimpanan data NoSQL terstruktur (real-time database) untuk menyimpan kueri dokumen barang.

Media Storage Layer

Komponen: Firebase Storage

Fungsi: Menyimpan file foto barang secara terkompresi dan menyediakan tautan URL publik HTTPS.

Integration Layer

Komponen: url_launcher

Fungsi: Menghubungkan pengguna langsung ke aplikasi WhatsApp pemilik laporan dengan template pesan otomatis.

Struktur Dokumen Database (items Collection)
id (String / Auto-ID): Identifier unik untuk setiap dokumen laporan.
userId (String): UID unik pengguna pembuat laporan (diambil dari Firebase Auth).
title (String): Judul/nama barang yang dilaporkan.
type (String): Status jenis laporan ('Hilang' atau 'Ditemukan').
description (String): Detail penjelasan fisik atau kronologi barang.
location (String): Lokasi ditemukannya atau hilangnya barang.
phoneNumber (String): Nomor telepon/WA penanggung jawab laporan.
imageUrl (String): Public URL lokasi gambar di Firebase Storage.
createdAt (Timestamp): Penanda waktu pembuatan laporan untuk urutan feed.
Alur Aliran Data Utama (Data Flow)
Lapor Barang Baru (Create): Pengguna input data & foto $\rightarrow$ ImagePicker ambil gambar $\rightarrow$ Upload gambar ke Firebase Storage $\rightarrow$ Storage kirim balik imageUrl $\rightarrow$ Simpan seluruh objek data ke Cloud Firestore.
Menerima Feed Barang (Read): Cloud Firestore menyalurkan aliran data (stream) $\rightarrow$ StreamBuilder di HomeScreen menangkap data $\rightarrow$ Dart melakukan filtering teks & pengurutan waktu $\rightarrow$ UI memperbarui tampilan secara otomatis (real-time).



