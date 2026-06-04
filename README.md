# 🚀 End-to-End Retail Data Warehouse & SSIS ETL Pipeline Project

Sistem pipa data ETL (*Extract, Transform, Load*) dan pemodelan semantik analitis berskala enterprise yang dirancang khusus untuk melakukan otomatisasi migrasi, pembersihan, penataan arsitektur skema bintang (*Star Schema*), hingga rekayasa metrik bisnis (*Business Intelligence Measures*). Proyek ini memproses data historis transaksi milik **Nusantara Jaya Retail** sebanyak 9.800 baris ke dalam lingkungan Microsoft SQL Server dan mentransformasikannya menjadi model data siap saji (*Production-Ready Semantic Model*).

---

## 1. Pengenalan Project 📌

### Latar Belakang

Nusantara Jaya Retail adalah perusahaan retail skala nasional yang memiliki tumpukan data transaksi mentah berformat `.csv` dari sistem operasional kasir (POS). Data mentah ini memiliki berbagai macam kendala khas data lapangan: format tanggal yang tidak seragam (mengikuti standar regional tertentu), karakter teks nama produk yang sangat panjang, serta karakter penanda baris (*row delimiter*) bawaan sistem Linux yang pecah saat dibaca di lingkungan server berbasis Windows.

Manajemen membutuhkan standardisasi data terpusat ke dalam **Data Warehouse (Nusantara_Retail_DW)** agar siap dikonsumsi oleh tim analis. Proyek ini hadir sebagai solusi *end-to-end* untuk menjamin pipa data mengalir 100% tanpa ada kegagalan transformasi data (*Zero-Data-Loss Pipeline*), sekaligus menyusun kecerdasan bisnis (*Business Intelligence*) di atas fondasi model data yang kokoh.

### Tujuan Utama

* **Otomatisasi Pipeline Migrasi:** Membangun jalur pipa data (*Data Flow Task*) otomatis yang menghubungkan file flat file csv langsung ke relational database server.
* **Normalisasi Arsitektur Star Schema:** Memecah redundansi data operasional kasir menjadi skema bintang yang terbagi atas tabel fakta (*Fact Table*) dan tabel dimensi (*Dimension Tables*).
* **Rekayasa Metrik Bisnis Komplex:** Menginjeksikan formula kalkulasi analitis berbasis DAX (*Data Analysis Expressions*) tingkat lanjut seperti *Time Intelligence* dan *Dynamic Ranking Iterator* untuk kebutuhan dashboard eksekutif.

---

## 2. Arsitektur Sistem 🏗️

Sistem ini mengadopsi arsitektur **Hybrid Enterprise Data Modeling**, memadukan ketangguhan penyimpanan relasional SQL Server dengan kecepatan komputasi in-memory *VertiPaq Engine* melalui Power BI:

```text
  [ Sumber Data Mentah: Nusantara_Jaya_Retail.csv ]
                         │
                         ▼ (Pipa Penyaringan SSIS ETL)
  ┌────────────────────────────────────────────────────────┐
  │              SQL Server Database Server                │
  │            - Database Name: Nusantara_Retail_DW        │
  │            - Target Staging Table: [dbo].[FactSales]   │
  └──────────────────────┬─────────────────────────────────┘
                         │
                         ▼ (Ingestion & Normalisasi Data Flow)
  ┌────────────────────────────────────────────────────────┐
  │                 Power Query In-Memory Engine           │
  │   - FactTable Ingestion: Direct Connection via SQL     │
  │   - Dimension Extraction: Deduplication ID (Many-to-1) │
  └──────────────────────┬─────────────────────────────────┘
                         │
                         ▼ (Semantic Model Hub)
  ┌────────────────────────────────────────────────────────┐
  │                 Star Schema Relationship               │
  │   - DimCustomer (1)  ──────►  (*) FactSales            │
  │   - DimProduct  (1)  ──────►  (*) FactSales            │
  └────────────────────────────────────────────────────────┘

```

### Teknologi & Perkakas yang Digunakan

* **Microsoft SQL Server 2022+:** Sebagai mesin repositori Data Warehouse utama penampung tabel fakta.
* **SQL Server Management Studio (SSMS):** Media eksekusi kueri DDL dan verifikasi kuantitas data pasca-ETL.
* **SQL Server Integration Services (SSIS):** Engine ETL utama penanggung jawab manajemen aliran data flow.
* **Power BI Desktop & Power Query:** Mesin perakitan *Semantic Model*, hubungan relasi, dan komputasi DAX.
* **Microsoft Visual Studio 2022:** Lingkungan kerja (*IDE*) utama untuk merakit paket kompilasi pipeline `Package.dtsx`.

---

## 3. Struktur Repositori 📁

```text
.
├── Raw Data/
│   └── Nusantara_Jaya_Retail.csv       # Dataset transaksi mentah 9.800 baris (Input Utama)
├── Query/
│   └── DDL_Data_Warehouse.sql          # Script SQL pembuatan database dan skema tabel fakta
├── ETL_Nusantara_Retail/
│   ├── ETL_Nusantara_Retail.sln        # File Solusi Utama Visual Studio Proyek SSIS
│   └── ETL_Nusantara_Retail/
│       ├── Package.dtsx                # File Kompilasi Utama Aliran Pipa ETL (XML)
│       └── Project.params              # Parameterisasi Proyek
├── Link Dataset.txt                     # Tautan referensi repositori eksternal dataset
└── README.md                            # Laporan & Dokumentasi Teknis Resmi Resmi

```

---

## 4. Skema Basis Data & Distribusi Kolom 📊

Untuk menjaga performa kalkulasi tetap berada di efisiensi tertinggi, data hasil pemecahan sistem didistribusikan secara proporsional berdasarkan fungsi tabelnya:

### A. Tabel Fakta (`FactSales` - Bersumber dari SQL Server)

Menampung data transaksi berukuran kurus yang dominan berisi ID kunci hubungan dan indeks angka metrik penjualan.

* Kolom: `RowID` (PK), `OrderID`, `OrderDate`, `ShipDate`, `ShipMode`, `CustomerID`, `ProductID`, `SalesAmount`

### B. Tabel Dimensi Pelanggan (`DimCustomer` - Diekstrak via Power Query)

Menampung atribut tekstual deskriptif identitas konsumen yang telah dibersihkan dari nilai duplikat (*Deduplicated*).

* Kolom: `Customer ID` (PK), `Customer Name`, `Segment`, `Country`, `City`, `State`, `Postal Code`, `Region`

### C. Tabel Dimensi Produk (`DimProduct` - Diekstrak via Power Query)

Menampung detail spesifikasi penamaan item produk dagang Nusantara Jaya Retail.

* Kolom: `Product ID` (PK), `Category`, `Sub-Category`, `Product Name`

---

## 5. Metodologi Analisis & Penanganan Tantangan Engineering 🧠

Selama proses pengerjaan pipeline, ditemukan tantangan besar (*Engineering Blockers*) lapangan yang berhasil diselesaikan secara metodis:

* **Pemisah Baris Linux (`\n` LF):** File CSV bawaan sistem Linux memicu jebolnya pembacaan batas baris pada sistem operasi Windows. Diselesaikan dengan mengubah properti konfigurasi *Flat File Connection Manager* menjadi **`{LF}`**.
* **Koma di dalam Tanda Kutip (Text Qualifier):** Nama deskripsi produk yang mengandung karakter koma mengecoh pembatas kolom sehingga data bergeser secara acak. Masalah ini diredam dengan mengaktifkan properti **`Text Qualifier`** menggunakan karakter tanda kutip dua (**`"`**).
* **Truncation Error (Metadata Out of Sync):** Panjang karakter kolom `Product Name` melebihi batasan default 50 karakter milik SSIS. Masalah diselesaikan melalui *Advanced Editor* dengan menaikkan *Output Column Width* secara seragam ke panjang **`255`**.

---

## 6. Implementasi Tahap Proyek (Phase Execution) 🚀

### PHASE 1: Desain Arsitektur Data Warehouse (DDL Skema)

Pembangunan fondasi fisik repositori penyimpanan pada server database lokal menggunakan kueri struktural:

```sql
CREATE DATABASE Nusantara_Retail_DW;
GO
USE Nusantara_Retail_DW;
GO

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

Jalur pipa dirancang seringkas mungkin (*Direct Ingestion*) tanpa komponen penengah guna menghemat penggunaan memori RAM. Sinkronisasi konversi tipe data otomatis dari format teks menuju format penanggalan `DATE` memanfaatkan konfigurasi driver **Locale: English (United Kingdom)**.

### PHASE 3: Semantic Modeling & Advanced DAX Engine

Fase ini berfokus pada pembangunan kecerdasan model data di atas hubungan relasi *Many-to-One* ($* \rightarrow 1$) satu arah. Seluruh rumus bisnis dikelompokkan ke dalam satu tabel khusus (*Measures Bank*) bernama **`_Metrik_Penjualan`**.

Berikut adalah barisan kueri formula DAX tingkat lanjut (*Advanced BI Measures*) yang berhasil diinjeksikan ke dalam sistem:

#### Kelompok Metrik Finansial Utama

```dax
Total Sales = SUM(FactSales[SalesAmount])

```

```dax
Total Orders = DISTINCTCOUNT(FactSales[OrderID])

```

```dax
Average Transaction Value = DIVIDE([Total Sales], [Total Orders], 0)

```

#### Kelompok Analisis Komparasi Waktu (Time Intelligence)

```dax
Sales Last Month = 
CALCULATE(
    [Total Sales],
    PREVIOUSMONTH(FactSales[OrderDate])
)

```

```dax
MoM Sales Growth % = 
DIVIDE(
    [Total Sales] - [Sales Last Month],
    [Sales Last Month],
    0
)

```

```dax
Sales YTD = 
TOTALYTD(
    [Total Sales],
    FactSales[OrderDate]
)

```

#### Kelompok Analisis Klasifikasi & Iteration Ranking

```dax
Product Revenue Rank = 
IF(
    ISINSCOPE(DimProduct[Product Name]),
    RANKX(
        ALLSELECTED(DimProduct[Product Name]),
        [Total Sales],
        ,
        DESC
    ),
    BLANK()
)

```

```dax
Customer Value Rank = 
IF(
    ISINSCOPE(DimCustomer[Customer Name]),
    RANKX(
        ALLSELECTED(DimCustomer[Customer Name]),
        [Total Sales],
        ,
        DESC
    ),
    BLANK()
)

```

---

## 7. Hasil Akhir Eksekusi Proyek 🏁

Pipa data berhasil dieksekusi 100% sempurna dengan status **Success (Exit Code 0)**, serta validasi hubungan relasi *Star Schema* terkunci aktif di dalam *Model View*.

* Total data diproses dari berkas CSV: **9.801 baris (Termasuk header)**
* Total data sukses termigrasi ke SQL Server: **9.800 baris**

### Pembuktian Kuantitas Data Riil pada SSMS

```sql
USE Nusantara_Retail_DW;
GO
SELECT COUNT(*) AS Total_Baris_Masuk FROM FactSales;
GO

```

**Hasil Konsol Database:**

```text
┌────────────────────┐
│ Total_Baris_Masuk  │
├────────────────────┤
│ 9800               │
└────────────────────┘

```

---

## 8. Identitas Pengembang / Peneliti 👤

* **Nama Pengembang:** Al Fitra Nur Ramadhani
* **Peran/Posisi:** Data Engineer & Analytics Architect
* **Kontak GitHub:** [@alfitranurr](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2Falfitranurr)
* **Afiliasi Proyek:** Informatics Engineering - Data Analytics Focus Portfolio

---

*Dokumentasi komprehensif ini dikunci dan disahkan sebagai panduan standar reproduksibilitas arsitektur pipeline ETL 2026.*

---
