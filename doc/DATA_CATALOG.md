# 📦 Data Catalog — Gold Layer


> **Database:** `dw_gold` | **Architecture:** Medallion | **Layer:** Gold

---

## 📋 Table of Contents
- [dim\_customers](#dim_customers)
- [dim\_products](#dim_products)
- [fact\_sales](#fact_sales)

---

## dim_customers

**Type:** Dimension Table
**Grain:** One row per unique customer
**Source:** `dw_silver.crm_customers` ⬅ `dw_silver.erp_cust_az12` ⬅ `dw_silver.erp_loc_a101`

| Column Name | Data Type | Constraints | Source | Description |
|---|---|---|---|---|
| `customer_id` | INT | PK, NOT NULL | CRM | Numeric customer identifier from CRM source system |
| `customer_code` | VARCHAR(20) | NOT NULL | CRM | Business key (e.g. `AW00011000`) used to join across source systems |
| `first_name` | VARCHAR(50) | NULLABLE | CRM | Customer first name, trimmed of leading and trailing whitespace |
| `last_name` | VARCHAR(50) | NULLABLE | CRM | Customer last name, trimmed of leading and trailing whitespace |
| `marital_status` | VARCHAR(10) | NOT NULL | CRM | Standardised marital status — `Married`, `Single`, or `N/A` |
| `gender` | VARCHAR(10) | NOT NULL | CRM / ERP | Gender from CRM; falls back to ERP when CRM is `N/A` — values: `Male`, `Female`, `N/A` |
| `birth_date` | DATE | NULLABLE | ERP | Customer date of birth. Future dates are set to `NULL`. |
| `country` | VARCHAR(50) | NULLABLE | ERP | Country of residence. Abbreviations expanded (`US` → `America`, `DE` → `Germany`). |
| `create_date` | DATE | NULLABLE | CRM | Date the customer record was first created in the CRM system |
| `dw_create_date` | DATETIME | NOT NULL | DWH | Timestamp when this row was loaded into the data warehouse |

---

## dim_products

**Type:** Dimension Table
**Grain:** One row per unique product (latest active version)
**Source:** `dw_silver.crm_products` ⬅ `dw_silver.erp_px_cat_g1v2`

| Column Name | Data Type | Constraints | Source | Description |
|---|---|---|---|---|
| `product_id` | INT | PK, NOT NULL | CRM | Numeric product identifier from CRM source system |
| `product_code` | VARCHAR(50) | NOT NULL | CRM | Full product business key (e.g. `CO-RF-FR-R92B-58`) |
| `product_name` | VARCHAR(255) | NOT NULL | CRM | Full product name. Empty values replaced with `N/A`. |
| `category` | VARCHAR(50) | NULLABLE | ERP | Top-level category from ERP — `Bikes`, `Components`, `Clothing`, `Accessories` |
| `subcategory` | VARCHAR(50) | NULLABLE | ERP | Product subcategory (e.g. `Mountain Bikes`, `Tires and Tubes`) |
| `product_cost` | INT | NOT NULL | CRM | Product cost as whole number. `NULL` values defaulted to `0`. |
| `product_line` | VARCHAR(20) | NOT NULL | CRM | Expanded product line — `Road`, `Mountain`, `Touring`, `Other Sales`, `N/A` |
| `maintenance_required` | VARCHAR(3) | NULLABLE | ERP | Whether product requires maintenance — `Yes` or `No` |
| `start_date` | DATE | NULLABLE | CRM | Date from which this product version became effective |
| `end_date` | DATE | NULLABLE | CRM | Date this version was superseded. `NULL` = currently active product. |
| `dw_create_date` | DATETIME | NOT NULL | DWH | Timestamp when this row was loaded into the data warehouse |

---

## fact_sales

**Type:** Fact Table
**Grain:** One row per order line (one product per order)
**Source:** `dw_silver.crm_sales`

| Column Name | Data Type | Constraints | Source | Description |
|---|---|---|---|---|
| `order_number` | VARCHAR(15) | NOT NULL | CRM | Sales order number (e.g. `SO43697`). Multiple rows share an order when it has multiple products. |
| `customer_id` | INT | FK, NOT NULL | CRM | Foreign key → `dim_customers.customer_id` |
| `product_code` | VARCHAR(50) | FK, NOT NULL | CRM | Foreign key → `dim_products.product_code` |
| `order_date` | DATE | NULLABLE | CRM | Date the order was placed. Invalid integers (`0` or `< 8` digits) set to `NULL`. |
| `ship_date` | DATE | NULLABLE | CRM | Date the order was physically dispatched |
| `due_date` | DATE | NULLABLE | CRM | Expected delivery date |
| `quantity` | INT | NOT NULL | CRM | Number of units sold on the order line |
| `unit_price` | INT | NOT NULL | CRM | Unit price at time of sale. Derived from `total_sales / quantity` when zero or negative. |
| `total_sales` | INT | NOT NULL | CRM | Total line amount = `quantity × unit_price`. Recalculated to fix nulls, zeros, and negatives. |
| `dw_create_date` | DATETIME | NOT NULL | DWH | Timestamp when this row was loaded into the data warehouse |

---

## 🗃️ Source to Gold Lineage

| Gold Table | Silver Tables Used | Bronze Tables Used |
|---|---|---|
| `dim_customers` | `crm_customers`, `erp_cust_az12`, `erp_loc_a101` | `crm_customers`, `erp_cust_az12`, `erp_loc_a101` |
| `dim_products` | `crm_products`, `erp_px_cat_g1v2` | `crm_products`, `erp_px_cat_g1v2` |
| `fact_sales` | `crm_sales` | `crm_sales` |

