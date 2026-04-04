-- Dimension CUSTOMERS

CREATE VIEW dim_customers AS
SELECT
	ROW_NUMBER() OVER (ORDER BY ci.cst_create_date) AS customer_num,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_key,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    CASE
        WHEN ci.cst_gndr = 'N/A' THEN ca.gen
        ELSE ci.cst_gndr
    END AS gender,
    ci.cst_marital_status AS marital_status,
    ca.bdate AS birth_date,
    lo.cntry AS country,
    ci.cst_create_date AS created_date

FROM dw_silver.crm_customers   ci
LEFT JOIN dw_silver.erp_cust_az12  ca  ON ci.cst_key = ca.cid
LEFT JOIN dw_silver.erp_loc_a101   lo  ON ci.cst_key = lo.cid;

-- Dimension PRODUCTS

CREATE VIEW dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY pr.prd_start_dt) AS product_number,
    pr.prd_id           AS product_id,
    pr.prd_key          AS product_code,
    pr.prd_nm           AS product_name,
    pr.cat_key          AS category_key,
    pc.cat              AS category,
    pc.subcat           AS subcategory,
    pr.prd_cost         AS product_cost,
    pr.prd_line         AS product_line,
    pc.maintenance      AS maintenance_required,
    pr.prd_start_dt     AS product_start_date
FROM dw_silver.crm_products          pr
LEFT JOIN dw_silver.erp_px_cat_g1v2   pc  ON pr.prd_key2 = pc.id WHERE pr.prd_end_dt IS NULL;


-- Fact SALES

CREATE VIEW fact_sales AS
SELECT
    sa.sls_ord_num      AS order_number,
    sa.sls_cust_id      AS customer_id,
    sa.sls_prd_key      AS product_code,
    sa.sls_order_dt     AS order_date,
    sa.sls_ship_dt      AS ship_date,
    sa.sls_due_dt       AS due_date,
    sa.sls_quantity     AS quantity,
    sa.sls_price        AS unit_price,
    sa.sls_sales        AS total_sales
FROM      dw_silver.crm_sales          sa
LEFT JOIN dw_gold.dim_customers      ci  ON sa.sls_cust_id = ci.customer_id
LEFT JOIN dw_gold.dim_products       pr  ON sa.sls_prd_key = pr.category_key;
