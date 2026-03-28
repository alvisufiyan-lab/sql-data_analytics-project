SET GLOBAL local_infile = 1;
USE dw_bronze;

-- Load CRM tables
TRUNCATE TABLE crm_customers;
LOAD DATA LOCAL INFILE 'E:\\Data analytics project 2\\sql-data-warehouse-project\\datasets\\source_crm\\cust_info.csv'
INTO TABLE crm_customers
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
 
TRUNCATE TABLE crm_products;
LOAD DATA LOCAL INFILE 'E:\\Data analytics project 2\\sql-data-warehouse-project\\datasets\\source_crm\\prd_info.csv'
INTO TABLE crm_products
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
 
TRUNCATE TABLE crm_sales;
LOAD DATA LOCAL INFILE 'E:\\Data analytics project 2\\sql-data-warehouse-project\\datasets\\source_crm\\sales_details.csv'
INTO TABLE crm_sales
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Load ERP tables
TRUNCATE TABLE erp_cust_az12;
LOAD DATA LOCAL INFILE 'E:\\Data analytics project 2\\sql-data-warehouse-project\\datasets\\source_erp\\CUST_AZ12.csv'
INTO TABLE erp_cust_az12
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
 
TRUNCATE TABLE erp_loc_a101;
LOAD DATA LOCAL INFILE 'E:\\Data analytics project 2\\sql-data-warehouse-project\\datasets\\source_erp\\LOC_A101.csv'
INTO TABLE erp_loc_a101
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
 
TRUNCATE TABLE erp_px_cat_g1v2;
LOAD DATA LOCAL INFILE 'E:\\Data analytics project 2\\sql-data-warehouse-project\\datasets\\source_erp\\PX_CAT_G1V2.csv'
INTO TABLE erp_px_cat_g1v2
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
