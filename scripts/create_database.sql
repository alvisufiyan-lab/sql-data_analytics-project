-- ============================================================
-- Script: Data Warehouse Initialization (Bronze, Silver, Gold)
-- Purpose:
--   This script creates a data warehouse database named `dw_bronze`, 'dw_silver', 'dw_gold'
--   following a medallion architecture approach.
--
-- WARNING:
--   This script will DROP the existing `datawarehouse` databases if it exists.
--   ALL DATA inside the database will be permanently deleted.
--   Use with caution in production environments.
-- ============================================================

DROP DATABASE IF EXISTS dw_bronze;
DROP DATABASE IF EXISTS dw_silver;
DROP DATABASE IF EXISTS dw_gold;
 
CREATE DATABASE IF NOT EXISTS dw_bronze
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
 
CREATE DATABASE IF NOT EXISTS dw_silver
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
 
CREATE DATABASE IF NOT EXISTS dw_gold
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
