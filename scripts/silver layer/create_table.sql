-- -----------------------------------------------------------------------------
-- Step 1: Switch context to the silver layer database.
-- -----------------------------------------------------------------------------

USE dw_silver;

-- -----------------------------------------------------------------------------
-- STEP 2 : Create the raw customer table.
-- -----------------------------------------------------------------------------
DROP TABLE crm_customers;
CREATE TABLE crm_customers (

    cst_id              INT             NULL
                                        COMMENT 'Customer numeric ID from CRM source; nullable – some rows arrive without a value',

    cst_key             VARCHAR(20)     NULL
                                        COMMENT 'Customer business key from CRM (e.g. AW00011000); sized 20 to absorb non-standard values seen in source',

    cst_firstname       VARCHAR(50)     NULL
                                        COMMENT 'Customer first name as-received; may contain leading / trailing whitespace',

    cst_lastname        VARCHAR(50)     NULL
                                        COMMENT 'Customer last name as-received; may contain leading / trailing whitespace',

    cst_marital_status  CHAR(10)         NULL
                                        COMMENT 'Marital status code from CRM: M = Married, S = Single; nullable – blank in source for some rows',

    cst_gndr            CHAR(10)         NULL
                                        COMMENT 'Gender code from CRM: M = Male, F = Female; nullable – blank in source for many rows',

    cst_create_date     DATE            NULL
                                        COMMENT 'Record creation date as received (YYYY-MM-DD string); stored as VARCHAR to prevent row rejection on any malformed value; cast to DATE in Silver',
    dw_create_date      DATETIME
);

-- -----------------------------------------------------------------------------
-- STEP 3 : Create the raw products table.
-- -----------------------------------------------------------------------------
DROP TABLE crm_products;
CREATE TABLE IF NOT EXISTS crm_products (
    prd_id          INT             NULL
                                    COMMENT 'Product numeric ID from source; always populated in observed data',
    prd_key         VARCHAR(50)     NULL
                                    COMMENT 'Product business key from source (e.g. CO-RF-FR-R92B-58); sized 50 to absorb any extended variants',
    prd_key2        VARCHAR(50)     NULL
                                    COMMENT 'New column generated from prd_key',     
    cat_key         VARCHAR(50)     NULL
                                    COMMENT 'New column generated from prd_key',   
    prd_nm          VARCHAR(255)    NULL
                                    COMMENT 'Product name as-received from source',
    prd_cost        INT             NULL
                                    COMMENT 'Product cost as integer; nullable – some rows arrive without a cost value',
    prd_line        CHAR(15)         NULL
                                    COMMENT 'Product line code from source: R = Road, M = Mountain, S = Standard, T = Touring; nullable – some rows arrive blank',
    prd_start_dt    VARCHAR(10)     NULL
                                    COMMENT 'Product validity start date as received (YYYY-MM-DD string); stored as VARCHAR to prevent row rejection on malformed values; cast to DATE in Silver',
    prd_end_dt      VARCHAR(10)     NULL
                                    COMMENT 'Product validity end date as received (YYYY-MM-DD string); nullable – open-ended records have no end date; cast to DATE in Silver',
    dw_create_date  DATETIME                           
);
 
-- -----------------------------------------------------------------------------
-- STEP 4 : Create the raw sales table.
-- -----------------------------------------------------------------------------
DROP TABLE crm_sales;
CREATE TABLE IF NOT EXISTS crm_sales (
    sls_ord_num     VARCHAR(15)     NULL
                                    COMMENT 'Sales order number from source (e.g. SO43697); alphanumeric business key',
    sls_prd_key     VARCHAR(50)     NULL
                                    COMMENT 'Product key referenced on the order line (e.g. BK-R93R-62); links to crm_products.prd_key in Silver',
    sls_cust_id     INT             NULL
                                    COMMENT 'Customer numeric ID on the order; links to crm_customers.cst_id in Silver',
    sls_order_dt    DATE            NULL
                                    COMMENT 'Order date as received from source in YYYYMMDD integer format; stored as INT to match source system representation; cast to DATE in Silver',
    sls_ship_dt     DATE            NULL
                                    COMMENT 'Shipment date in YYYYMMDD integer format; nullable – not set until order is shipped; cast to DATE in Silver',
    sls_due_dt      DATE            NULL
                                    COMMENT 'Due date in YYYYMMDD integer format; cast to DATE in Silver',
    sls_sales       INT             NULL
                                    COMMENT 'Total sales amount for the order line as integer; cast to DECIMAL in Silver',
    sls_quantity    INT             NULL
                                    COMMENT 'Quantity of units sold on the order line',
    sls_price       INT             NULL
                                    COMMENT 'Unit price at time of sale as integer; cast to DECIMAL in Silver',
	dw_create_date  DATETIME
);

-- -----------------------------------------------------------------------------
-- STEP 5 : Create the raw ERP customer details table.
-- -----------------------------------------------------------------------------
DROP TABLE erp_cust_az12;
CREATE TABLE IF NOT EXISTS erp_cust_az12 (
    cid             VARCHAR(20)     NULL
                                    COMMENT 'Customer ID from ERP; two formats observed: prefixed (e.g. NASAW00011000) and unprefixed (e.g. AW00029221); sized 20 to absorb both variants',
    bdate           DATE            NULL
                                    COMMENT 'Customer birth date as received (YYYY-MM-DD string); stored as VARCHAR to prevent row rejection on malformed or out-of-range values (e.g. 2050-07-06 seen in source); cast to DATE in Silver',
    gen             VARCHAR(10)     NULL
                                    COMMENT 'Customer gender as received; inconsistent values observed: Male, Female, M, F, and blank; sized 10 to absorb full-word values; normalised in Silver'
);
 
-- -----------------------------------------------------------------------------
-- STEP 6 : Create the raw ERP customer location table.
-- -----------------------------------------------------------------------------
DROP TABLE erp_loc_a101;
CREATE TABLE IF NOT EXISTS erp_loc_a101 (
    cid             VARCHAR(20)     NULL
                                    COMMENT 'Customer ID from ERP location source; format AW-00011000 (hyphenated, 12 chars); sized 20 for safety',
    cntry           VARCHAR(50)     NULL
                                    COMMENT 'Country as received; inconsistent representations observed: full names (e.g. United States, United Kingdom, Germany, France, Australia), abbreviations (US, DE), and blank/whitespace-only values; sized 50 to absorb longest full-name values; normalised in Silver'
);
 
-- -----------------------------------------------------------------------------
-- STEP 7 : Create the raw ERP product category table.
-- -----------------------------------------------------------------------------
DROP TABLE erp_px_cat_g1v2;
CREATE TABLE IF NOT EXISTS erp_px_cat_g1v2 (
    id              VARCHAR(10)     NULL
                                    COMMENT 'Category code from ERP (e.g. AC_BR, BI_MB); underscore-separated 5-character code',
    cat             VARCHAR(50)     NULL
                                    COMMENT 'Top-level product category (e.g. Accessories, Bikes, Clothing, Components)',
    subcat          VARCHAR(50)     NULL
                                    COMMENT 'Product sub-category (e.g. Mountain Bikes, Tires and Tubes)',
    maintenance     VARCHAR(3)      NULL
                                    COMMENT 'Maintenance flag as received from source: Yes or No'
);