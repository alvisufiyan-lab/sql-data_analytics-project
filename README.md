# 🏗️ SQL Data Warehouse Project

A end-to-end data warehouse built using MySQL following the **Medallion Architecture** (Bronze → Silver → Gold).
The project ingests raw data from two source systems (CRM and ERP), applies layered transformations, and produces clean dimensional models ready for analytics and reporting.

---

## 📐 Architecture

```
Source Systems
     │
     ├── CRM  (cust_info.csv, prd_info.csv, sales_details.csv)
     └── ERP  (CUST_AZ12.csv, LOC_A101.csv, PX_CAT_G1V2.csv)
     │
     ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   dw_bronze │────▶│   dw_silver │────▶│   dw_gold   │
│  Raw Layer  │     │ Clean Layer │     │  BI  Layer  │
└─────────────┘     └─────────────┘     └─────────────┘
```

| Layer | Database | Purpose |
|---|---|---|
| **Bronze** | `dw_bronze` | Raw data ingested as-is from source files. No transformations. |
| **Silver** | `dw_silver` | Cleaned, deduplicated, type-cast, and normalised data. |
| **Gold** | `dw_gold` | Star-schema dimensional model ready for BI and reporting. |

---

## 📁 Repository Structure

```
├── datasets/
│   ├── source_crm/
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   └── source_erp/
│       ├── CUST_AZ12.csv
│       ├── LOC_A101.csv
│       └── PX_CAT_G1V2.csv
│
├── scripts/
│   ├── create_database.sql
│   ├── bronze layer/
│   │   ├── create_table.sql          -- CREATE TABLE statements for bronze layer
│   │   └── load_data.sql         -- LOAD DATA INFILE script for all 6 tables
│   ├── silver/
│   │   ├── create_table.sql          -- CREATE TABLE statements for silver layer
│   │   └── load_data.sql    -- Stored procedure with all transformations
│   └── gold/
│       ├── creating_view.sql          -- dim_customers, dim_products, fact_sales
│
└── docs/
    └── DATA_CATALOG.md    -- Full column-level data catalog for gold tables
    └── Data flow    -- Data flow diagram
    └── Data integration   -- Diagram of how each column connect
    └── Data model    -- Schema of prepared gold layer
```

---

## 🗂️ Data Sources

### CRM Source
| File | Bronze Table | Description |
|---|---|---|
| `cust_info.csv` | `crm_customers` | Customer master records (~18,400 rows) |
| `prd_info.csv` | `crm_products` | Product catalogue with versioned pricing (~400 rows) |
| `sales_details.csv` | `crm_sales` | Sales order line transactions (~60,000 rows) |

### ERP Source
| File | Bronze Table | Description |
|---|---|---|
| `CUST_AZ12.csv` | `erp_cust_az12` | Customer demographics — birthdate and gender (~18,200 rows) |
| `LOC_A101.csv` | `erp_loc_a101` | Customer country of residence (~18,100 rows) |
| `PX_CAT_G1V2.csv` | `erp_px_cat_g1v2` | Product category and subcategory reference (38 rows) |

---

## 🔄 Silver Layer — Transformations Applied

| Table | Key Transformations |
|---|---|
| `crm_customers` | Deduplicated by `cst_key`, trimmed names, normalised gender & marital status, date cast from `dd/mm/yyyy` |
| `crm_products` | Deduplicated by `prd_key`, expanded product line codes, `prd_end_dt` derived via `LEAD()` window function |
| `crm_sales` | `YYYYMMDD` integers cast to `DATE`, sales recalculated as `qty × price`, negatives and zeros resolved |
| `erp_cust_az12` | `NAS` prefix stripped from CID, future birth dates nullified, gender variants normalised |
| `erp_loc_a101` | Hyphens removed from CID, country abbreviations expanded (`US` → `America`, `DE` → `Germany`) |
| `erp_px_cat_g1v2` | Whitespace trimmed, Windows carriage returns (`\r`) stripped from last column |

---

## ⭐ Gold Layer — Dimensional Model

```
          dim_customers
               │
               │ customer_id
               │
fact_sales ────┤
               │
               │ product_code
               │
          dim_products
```

| Table | Type | Grain |
|---|---|---|
| `dim_customers` | Dimension | One row per unique customer |
| `dim_products` | Dimension | One row per unique product (latest version) |
| `fact_sales` | Fact | One row per order line |

---

## 🚀 How to Run

### Prerequisites
- MySQL 8.0+
- MySQL Workbench (or any MySQL client)
- `local_infile` enabled on your MySQL server

### Step 1 — Create databases and tables
```sql
-- Run in order
source scripts/create_database.sql
source scripts/bronze layer/create_table.sql
source scripts/silver layer/create_table.sql
source scripts/gold layer/create_table.sql
```

### Step 2 — Load Bronze (raw data ingestion)
```sql
SET GLOBAL local_infile = 1;
source scripts/bronze layer/load_data.sql
```

### Step 3 — Load Silver (transformations)
```sql
CALL dw_silver.load_silver();
```

### Step 4 — Query Gold layer
Create view on gold layer
```sql
source scripts/gold layer/creating_view
```

---

## ⚠️ Known Data Quality Issues

| Table | Issue | Resolution |
|---|---|---|
| `crm_customers` | Duplicate `cst_key` rows (record updates) | Keep latest by `cst_create_date` using `ROW_NUMBER()` |
| `crm_customers` | Windows `\r\n` line endings in CSV | `LINES TERMINATED BY '\r\n'` in load script |
| `crm_customers` | Blank gender values | Fall back to ERP gender in Gold layer |
| `crm_products` | Missing `prd_end_dt` | Derived as `LEAD(prd_start_dt) - 1 day` |
| `crm_sales` | Dates stored as `YYYYMMDD` integers | `CAST(CAST(col AS CHAR) AS DATE)` |
| `crm_sales` | Zero and negative sales/price values | Recalculated as `ABS(qty × price)` |
| `erp_cust_az12` | Future birth dates (e.g. `2050-07-06`) | Set to `NULL` via `> CURDATE()` check |
| `erp_cust_az12` | Mixed gender formats (`Male`, `M`, `MALE`) | Normalised via `UPPER(TRIM(REPLACE(...'\r'...)))` |
| `erp_loc_a101` | Mixed country formats (`US`, `United States`) | Standardised via `CASE` mapping |

---

## 🛠️ Tech Stack

![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?logo=mysql)
![Architecture](https://img.shields.io/badge/Architecture-Medallion-orange)
![Layer](https://img.shields.io/badge/Layers-Bronze%20%7C%20Silver%20%7C%20Gold-yellow)
