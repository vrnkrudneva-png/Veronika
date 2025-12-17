-- schema_sqlserver.sql
-- ForecastDB schema for retail turnover forecasting (SQL Server)

IF DB_ID(N'ForecastDB') IS NULL
BEGIN
  CREATE DATABASE ForecastDB;
END
GO
USE ForecastDB;
GO

IF OBJECT_ID('dbo.fact_sales', 'U') IS NOT NULL DROP TABLE dbo.fact_sales;
IF OBJECT_ID('dbo.dim_dc', 'U')      IS NOT NULL DROP TABLE dbo.dim_dc;
IF OBJECT_ID('dbo.dim_sku', 'U')     IS NOT NULL DROP TABLE dbo.dim_sku;
GO

CREATE TABLE dbo.dim_sku (
    sku_id VARCHAR(50) PRIMARY KEY,
    product_name NVARCHAR(255),
    category NVARCHAR(100),
    brand NVARCHAR(100),
    unit_size NVARCHAR(50)
);

CREATE TABLE dbo.dim_dc (
    dc_id INT PRIMARY KEY,
    dc_code VARCHAR(20),
    dc_name NVARCHAR(255),
    city NVARCHAR(100),
    region NVARCHAR(100)
);

CREATE TABLE dbo.fact_sales (
    sales_date DATE NOT NULL,
    sku_id VARCHAR(50) NOT NULL,
    dc_id INT NOT NULL,
    sales_count INT NOT NULL,
    weight DECIMAL(10,2),
    promo BIT DEFAULT 0,
    CONSTRAINT FK_fact_sales_sku FOREIGN KEY (sku_id) REFERENCES dbo.dim_sku(sku_id),
    CONSTRAINT FK_fact_sales_dc  FOREIGN KEY (dc_id)  REFERENCES dbo.dim_dc(dc_id)
);
GO

IF OBJECT_ID('dbo.vw_sales_joined', 'V') IS NOT NULL DROP VIEW dbo.vw_sales_joined;
GO
CREATE VIEW dbo.vw_sales_joined AS
SELECT 
    f.sales_date, f.sales_count, f.weight, f.promo,
    s.sku_id, s.product_name, s.category, s.brand, s.unit_size,
    d.dc_id, d.city, d.region
FROM dbo.fact_sales f
JOIN dbo.dim_sku s ON f.sku_id = s.sku_id
JOIN dbo.dim_dc  d ON f.dc_id  = d.dc_id;
GO