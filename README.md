# 🚀 End-to-End Retail Data Warehouse & SSIS ETL Pipeline Project

Sistem pipa data ETL (*Extract, Transform, Load*) berskala enterprise yang dirancang khusus untuk melakukan otomatisasi migrasi, pembersihan, dan penyelarasan metadata dari data transaksi mentah (*Unstructured Transactional Data*) menjadi skema basis data analitis (*Data Warehouse Schema*). Proyek ini memindahkan data historis transaksi retail sebanyak 9.800 baris ke dalam lingkungan Microsoft SQL Server menggunakan SQL Server Integration Services (SSIS).

---

## 1. Pengenalan Project 📌

### Latar Belakang

Perusahaan retail skala nasional memiliki tumpukan data transaksi mentah berformat `.csv` dari sistem operasional kasir (POS). Data mentah ini memiliki berbagai macam kendala khas data lapangan: format tanggal yang tidak seragam (mengikuti standar regional tertentu), karakter teks nama produk yang sangat panjang, serta karakter penanda baris (*row delimiter*) bawaan sistem Linux yang pecah saat dibaca di lingkungan server berbasis Windows.

Manajemen membutuhkan data ini segera bermigrasi ke dalam **Data Warehouse (Nusantara_Retail_DW)** agar siap dikonsumsi oleh tim analis untuk membuat visualisasi performa dan model semantik bisnis. Proyek ETL ini hadir sebagai jembatan utama untuk menjamin data mentah tersebut bersih, utuh, dan masuk 100% tanpa ada kegagalan transformasi data.

### Tujuan Utama

* **Otomatisasi Pipeline Migrasi:** Membangun jalur pipa data (*Data Flow Task*) otomatis yang menghubungkan file flat file csv langsung ke relational database server.
* **Standarisasi & Validasi Tipe Data:** Melakukan konversi tipe data implisit (teks string) menjadi tipe data eksplisit yang siap diolah secara analitis seperti format `DATE` dan angka desimal `DECIMAL(18,2)`.
* **Improvisasi Skala Enterprise:** Mengatasi galat struktural seperti *Truncation Error* (pemotongan teks), pembatasan tanda kutip (*Text Qualifier*), dan ketidakcocokan *code page* driver database secara metodis.

---

## 2. Arsitektur Sistem 🏗️

Sistem ETL ini dibangun menggunakan pendekatan **Direct Optimized Ingestion Pipeline** di dalam lingkungan Microsoft Visual Studio dengan SQL Server Integration Services (SSIS) Extension:

```text
       ┌────────────────────────────────────────────────────────┐
       │             Flat File Source Connection                │
       │       (Nusantara_Jaya_Retail.csv - Linux LF)           │
       └──────────────────────────┬─────────────────────────────┘
                                  │
                                  ▼
       ┌────────────────────────────────────────────────────────┐
       │             Advanced Connection Ingestion              │
       │   - Text Qualifier: [ " ]                              │
       │   - Row Delimiter:  [ \n (LF) ]                        │
       │   - Encoding Locale: English (United Kingdom)          │
       └──────────────────────────┬─────────────────────────────┘
                                  │
                                  ▼ (Panah Aliran Data Flow)
       ┌────────────────────────────────────────────────────────┐
       │                OLE DB Destination                      │
       │          (SQL Server Fast Load Engine)                 │
       ├────────────────────────────────────────────────────────┤
       │   - Target Table: [dbo].[FactSales]                    │
       │   - Target Columns: Identik Metrik & Panjang Kolom     │
       └────────────────────────────────────────────────────────┘

```

### Teknologi & Perkakas yang Digunakan

* **Microsoft SQL Server 2022+:** Sebagai mesin repositori Data Warehouse utama penampung tabel fakta.
* **SQL Server Management Studio (SSMS):** Media eksekusi kueri DDL (*Data Definition Language*) dan verifikasi data pasca-ETL.
* **SQL Server Integration Services (SSIS):** Engine ETL utama penanggung jawab kontrol data flow (*DtsDebugHost*).
* **Microsoft Visual Studio 2022:** Lingkungan kerja (*IDE*) utama untuk merakit paket kompilasi `Package.dtsx`.

---

## 3. Struktur Repositori 📁

```text
.
├── Raw Data/
│   └── Nusantara_Jaya_Retail.csv       # Dataset transaksi mentah 9.800 baris (Input)
├── ETL_Nusantara_Retail/
│   ├── ETL_Nusantara_Retail.sln         # File Solusi Utama Visual Studio Proyek SSIS
│   └── ETL_Nusantara_Retail/
│       ├── Package.dtsx                 # File Kompilasi Utama Aliran Pipa ETL (XML XML)
│       └── Project.params               # Parameterisasi Proyek
├── DDL_Data_Warehouse.sql               # Script SQL pembuatan database dan struktur tabel
└── README.md                            # Laporan & Dokumentasi Teknis Resmi

```

---

## 4. Dataset & Fitur 📊

Sistem membaca data historis transaksi retail langsung dari file **`Nusantara_Jaya_Retail.csv`**. Format struktur dataset asli terdiri dari fitur-fitur penting berikut:

| Fitur Utama CSV | Tipe Target Database | Deskripsi Data |
| --- | --- | --- |
| `Row ID` | `INT` | ID Urutan baris transaksi (Primary Key) |
| `Order ID` | `VARCHAR(50)` | Kode struk pesanan unik dari pelanggan |
| `Order Date` | `DATE` | Tanggal terjadinya transaksi pembelian |
| `Ship Date` | `DATE` | Tanggal pengiriman barang dari gudang |
| `Ship Mode` | `VARCHAR(50)` | Metode logistik pengiriman barang |
| `Customer ID` | `VARCHAR(50)` | Kode pengenal unik untuk tiap pelanggan |
| `Product ID` | `VARCHAR(50)` | Kode SKU unit barang yang terjual |
| `Sales` | `DECIMAL(18,2)` | Nominal rupiah nilai penjualan barang per baris |

---

## 5. Metodologi Analisis & Penanganan Tantangan Engineering 🧠

Selama proses perakitan pipeline dari awal hingga titik sukses sekarang, ditemukan 3 tantangan besar (*Engineering Blockers*) yang berhasil diselesaikan secara metodis:

### A. Masalah Pemisah Baris (Row Delimiter Linux LF)

* **Karakteristik Masalah:** File CSV berasal dari sistem eksternal berbasis Linux yang melahirkan karakter penanda baris baru berupa `\n` (LF), sementara komponen penampung Windows secara default mencari `\r\n` (CRLF). Hal ini menyebabkan kolom paling akhir (`Sales`) membaca seluruh data di bawahnya tanpa putus dan memicu kegagalan sistem parsing.
* **Solusi Finansial:** Mengatur properti properti `Row Delimiter` pada halaman *General* Flat File Connection Manager secara manual ke nilai **`{LF}`** (atau `\n`).

### B. Koma di dalam Tanda Kutip (Text Qualifier)

* **Karakteristik Masalah:** Pada baris data ke-3, terdapat nama produk `"Hon Deluxe Fabric Upholstered Stacking Chairs, Rounded Back"`. Karakter koma di dalam tanda kutip ini mengecoh sistem SSIS sehingga memotong kolom secara salah. Akibatnya, teks alfabet `" Rounded Back"` bergeser masuk ke kolom `Sales`, memicu *crash* fatal akibat benturan konversi string ke angka desimal (`DT_NUMERIC`).
* **Solusi Finansial:** Mengaktifkan parameter **`Text Qualifier`** dengan mengetikkan karakter tanda kutip dua (**`"`**) pada jendela konfigurasi utama pintu masuk data.

### C. Sinkronisasi Caching Lebar Kolom (Truncation Error)

* **Karakteristik Masalah:** Kolom `Product Name` memiliki panjang data riil mencapai 61 karakter. Secara default SSIS mengunci lebar pembacaan awal sebesar 50 karakter. Jeda ini memunculkan peringatan *Out of Synchronization* dan langsung menggagalkan jalannya seluruh paket data flow.
* **Solusi Finansial:** Membuka fitur **Advanced Editor** pada komponen Flat File Source, masuk ke tab *Input and Output Properties*, lalu menaikkan nilai properti **`Length`** pada *Output Columns* dan *External Columns* secara seragam menjadi **`255`**.

---

## 6. Implementasi Tahap Proyek (Phase Execution) 🚀

### PHASE 1: Desain Arsitektur Data Warehouse (DDL Skema)

Langkah awal proyek dimulai dengan mengeksekusi script SQL untuk membangun fondasi struktur penyimpanan database pada SQL Server Management Studio (SSMS). Skema tabel fakta dirancang dengan melonggarkan hubungan constraint asing terlebih dahulu guna melancarkan proses penyerapan data (*staging ingestion*):

```sql
USE master;
GO

-- 1. Inisialisasi Database Data Warehouse Baru
CREATE DATABASE Nusantara_Retail_DW;
GO

USE Nusantara_Retail_DW;
GO

-- 2. Membuat Tabel Fakta Penjualan (FactSales) 
CREATE TABLE FactSales (
    RowID INT PRIMARY KEY,
    OrderID VARCHAR(50),
    OrderDate DATE,
    ShipDate DATE,
    ShipMode VARCHAR(50),
    CustomerID VARCHAR(50),
    ProductID VARCHAR(50),
    SalesAmount DECIMAL(18,2)
);
GO

```

### PHASE 2: Konstruksi Pipeline ETL pada SSIS

Pada fase ini, jalur pipa dirancang seringkas mungkin (*High-Performance Minimalist Flow*) tanpa menggunakan transformasi penengah untuk menghemat memori runtime komputer. Trik utamanya adalah memanfaatkan **Locale: English (United Kingdom)** agar format tanggal `DD/MM/YYYY` langsung otomatis diterjemahkan menjadi tipe data `DATE` SQL Server secara aman.

1. **Konfigurasi Source:** Flat File Connection Manager disetel mengarah ke berkas data mentah dengan Text Qualifier `"` dan Row Delimiter `\n`. Tipe data `Order Date` dan `Ship Date` disetel langsung ke **`database date [DT_DBDATE]`**, dan kolom `Sales` disetel ke **`numeric [DT_NUMERIC]` (18,2)**.
2. **Sinkronisasi Metadata:** Melakukan pembaruan massal metadata dengan menekan opsi *Yes* saat muncul jendela konfirmasi ketidaksinkronan kolom eksternal.
3. **Pemetaan (Mappings):** Menghubungkan panah aliran data dari sumber langsung menancap ke OLE DB Destination. Di dalam editor tujuan, tabel diatur menggunakan metode **Table or View - Fast Load** (untuk mengaktifkan fitur transfer data kecepatan tinggi), lalu menyamakan seluruh kolom masukan ke kolom tujuan database.

---

## 7. Hasil Akhir Eksekusi Proyek 🏁

Proses eksekusi paket `Package.dtsx` berhasil berjalan dengan sukses gemilang 100% tanpa ada sisa galat ataupun peringatan struktural yang merusak data.

Berikut adalah log bukti eksekusi sukses (*Execution Stack Results*) langsung dari mesin runtime debug:

```text
Information: 0x402090DC at Data Flow Task, Flat File Source [2]: The processing of file "D:\AL FITRA\POWER BI\Nusantara Jaya Retail\Raw Data\Nusantara_Jaya_Retail.csv" has started.
Information: 0x4004300C at Data Flow Task, SSIS.Pipeline: Execute phase is beginning.
Information: 0x402090DE at Data Flow Task, Flat File Source [2]: The total number of data rows processed for file "D:\AL FITRA\POWER BI\Nusantara Jaya Retail\Raw Data\Nusantara_Jaya_Retail.csv" is 9801.
Information: 0x402090DF at Data Flow Task, OLE DB Destination [83]: The final commit for the data insertion in "OLE DB Destination" has started.
Information: 0x402090E0 at Data Flow Task, OLE DB Destination [83]: The final commit for the data insertion in "OLE DB Destination" has ended.
Information: 0x4004300B at Data Flow Task, SSIS.Pipeline: "OLE DB Destination" wrote 9800 rows.
SSIS package "D:\AL FITRA\POWER BI\Nusantara Jaya Retail\ETL_Nusantara_Retail\ETL_Nusantara_Retail\Package.dtsx" finished: Success.

```

### Verifikasi Kuantitas Data Riil pada SSMS

Untuk membuktikan integritas keaslian data, dilakukan pengujian kueri agregasi penghitungan baris pada SSMS:

```sql
USE Nusantara_Retail_DW;
GO

SELECT COUNT(*) AS Total_Baris_Masuk FROM FactSales;
GO

```

**Hasil Keluaran Konsol Database:**

```text
┌────────────────────┐
│ Total_Baris_Masuk  │
├────────────────────┤
│ 9800               │
└────────────────────┘

```

Seluruh data sebanyak **9.800 baris** transaksi telah sukses bermigrasi dan tertata rapi di dalam tabel target database, menandai keberhasilan penuh Phase 2 proyek data engineering ini.

---

## 8. Identitas Pengembang / Peneliti 👤

* **Nama Pengembang:** Al Fitra Nur Ramadhani
* **Peran/Posisi:** Data Engineer & Core Pipeline Architect
* **Kontak GitHub:** [@alfitranurr](https://github.com/alfitranurr)
* **Afiliasi Proyek:** Informatics Engineering - Data Analytics Focus Portfolio

---

*Dokumentasi komprehensif ini dikunci dan disahkan sebagai panduan standar reproduksibilitas arsitektur pipeline ETL 2026.*