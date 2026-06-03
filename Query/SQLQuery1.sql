USE master;
GO

-- Buat Database Baru dengan Slate Bersih
CREATE DATABASE Nusantara_Retail_DW;
GO

USE Nusantara_Retail_DW;
GO

-- Membuat Tabel Fakta Penjualan (FactSales) yang Dioptimalkan untuk ETL
CREATE TABLE FactSales (
    RowID INT PRIMARY KEY,
    OrderID VARCHAR(50),
    OrderDate DATE,
    ShipDate DATE,
    ShipMode VARCHAR(50),
    CustomerID VARCHAR(50), -- Dilonggarkan tanpa FK dahulu agar data CSV masuk lancar
    ProductID VARCHAR(50),  -- Dilonggarkan tanpa FK dahulu agar data CSV masuk lancar
    SalesAmount DECIMAL(18,2)
);
GO