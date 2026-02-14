
---------------------------------------------------------------------
--Data Quality Checks in bronze.crm_cust_info table
---------------------------------------------------------------------

--Check for duplicates or nulls in Primary Key
SELECT cst_id, COUNT(*) as Count
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) >1 OR cst_id IS NULL

--Check for unwanted spaces
SELECT cst_lastname FROM bronze.crm_cust_info 
WHERE cst_lastname != TRIM(cst_lastname)

SELECT cst_firstname FROM bronze.crm_cust_info 
WHERE cst_firstname != TRIM(cst_firstname)

SELECT cst_gndr FROM bronze.crm_cust_info 
WHERE cst_gndr != TRIM(cst_gndr)

-- Data Standardization and consistency
SELECT DISTINCT(cst_material_status) 
FROM bronze.crm_cust_info

---------------------------------------------------------
--Data Quality Checks in bronze.crm_prd_info table
---------------------------------------------------------

-- Check for duplicates or nulls in primary key 
SELECT prd_id, COUNT(*) as Count 
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted spaces 
SELECT prd_nm FROM bronze.crm_prd_info
WHERE TRIM(prd_nm) != prd_nm

--Check for NULLS or negative numbers in price column 
SELECT prd_cost FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

--Data Standardization and consistency
SELECT distinct prd_line FROM bronze.crm_prd_info

--Check for invalid date orders
SELECT * FROM bronze.crm_prd_info
WHERE prd_start_dt > prd_end_dt

-------------------------------------------------------
--Data Quality Checks for bronze.crm_sales_details
-------------------------------------------------------

-- Check for unwanted spaces 
SELECT * FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)


--Checking Referential Integrity
SELECT * FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)

SELECT * FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)

--Check for invalid dates
SELECT sls_order_dt FROM bronze.crm_sales_details
WHERE sls_order_dt <=0 
OR len(sls_order_dt) != 8 
OR sls_order_dt > 20500101 
OR sls_order_dt < 19000101

SELECT sls_ship_dt FROM bronze.crm_sales_details
WHERE sls_ship_dt <=0 
OR len(sls_ship_dt) != 8 
OR sls_ship_dt > 20500101 
OR sls_ship_dt < 19000101

SELECT sls_due_dt FROM bronze.crm_sales_details
WHERE sls_due_dt <=0 
OR len(sls_due_dt) != 8 
OR sls_due_dt > 20500101 
OR sls_due_dt < 19000101

--Check for invalid date orders
SELECT *  FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_due_dt OR sls_order_dt > sls_ship_dt


--Check validity of sales calculaton 
SELECT sls_price,sls_quantity,sls_sales FROM bronze.crm_sales_details
WHERE sls_price * sls_quantity != sls_sales 
OR sls_sales IS NULL
OR sls_quantity IS NULL
OR sls_price IS NULL


SELECT DISTINCT
sls_price AS old_sls_price,
sls_quantity AS old_sls_quantity,
sls_sales AS old_sls_sales,
CASE 
	WHEN sls_price IS NULL OR sls_price < 0 
		THEN sls_sales/ NULLIF(sls_quantity,0)
	ELSE sls_price
END AS sls_price,
sls_quantity,
CASE 
	WHEN sls_sales < 0 OR sls_sales IS NULL OR sls_sales != sls_quantity* ABS(sls_price) 
		THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales

FROM bronze.crm_sales_details

-------------------------------------------------------
-- Data Quality Checks for bronze.erp_cust_az12
-------------------------------------------------------

-- Check if cid and cst_key are same 
SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
ELSE cid
END AS cid
FROM bronze.erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
ELSE cid
END NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info)

-- Check for bdate validity 
SELECT bdate FROM bronze.erp_cust_az12
WHERE bdate > GETDATE() OR bdate < '1920-01-01'

-- Check for data standardization and consistency in gender
SELECT DISTINCT gen,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
ELSE 'n/a'
END as new_gen
FROM bronze.erp_cust_az12

-- Check data standardization and consistency in country 

SELECT DISTINCT cntry,
CASE WHEN TRIM(cntry) IN ('US','USA','United States') THEN 'United States'
WHEN cntry = 'DE' THEN 'Germany'
WHEN cntry IS NULL OR cntry = '' THEN 'n/a'
ELSE TRIM(cntry)
END AS new_cntry
FROM bronze.erp_loc_a101
ORDER BY cntry

------------------------------------------------------
-- Data Quality Checks for bronze.erp_px_cat_g1v2
------------------------------------------------------

--Check for unwanted spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Data Standardization and Consistency
SELECT DISTINCT cat FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT maintenance FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT subcat FROM bronze.erp_px_cat_g1v2
