/* =====================================================
   MYSQL DATA WAREHOUSE – DATA CLEANING SCRIPT
   Database : datawarehouseanalytics
   Purpose  : Prepare dimension and fact tables
              for analytical workloads
   Author   : Harikrishnan Bellan
   ===================================================== */


/* =====================================================
   CUSTOMERS DIMENSION – DATA CLEANING
   ===================================================== */

-- -----------------------------------------------------
-- Step 1: Inspect structure (documentation only)
-- -----------------------------------------------------
-- DESC customers;
-- SELECT * FROM customers LIMIT 10;


-- -----------------------------------------------------
-- Step 2: Convert create_date from VARCHAR → DATE
-- Rationale:
--   CSV loads often store dates as text.
--   Dates must be DATE type for analytics.
-- -----------------------------------------------------

-- Preview conversion (manual validation step)
-- SELECT create_date, STR_TO_DATE(create_date, '%d-%m-%Y')
-- FROM customers LIMIT 10;

ALTER TABLE customers
ADD create_date_dt DATE;

UPDATE customers
SET create_date_dt = STR_TO_DATE(create_date, '%d-%m-%Y')
WHERE customer_key >= 1;

ALTER TABLE customers DROP create_date;
ALTER TABLE customers
CHANGE create_date_dt create_date DATE;


-- -----------------------------------------------------
-- Step 3: Standardize missing values
-- Rationale:
--   Placeholder values such as 'N/A' or empty strings
--   must be converted to NULL for correct analytics.
-- -----------------------------------------------------

UPDATE customers
SET country = NULL
WHERE customer_key >= 1
  AND country = 'N/A';

UPDATE customers
SET gender = NULL
WHERE customer_key >= 1
  AND gender = 'N/A';


-- -----------------------------------------------------
-- Step 4: Normalize text values (non-destructive)
-- Rationale:
--   Remove formatting inconsistencies while
--   preserving business meaning.
-- -----------------------------------------------------

UPDATE customers
SET
    first_name = TRIM(first_name),
    last_name  = TRIM(last_name),
    country    = UPPER(TRIM(country)),
    marital_status = UPPER(TRIM(marital_status)),
    gender     = UPPER(TRIM(gender))
WHERE customer_key >= 1;


-- -----------------------------------------------------
-- Step 5: Standardize gender values
-- Target domain: M, F, NULL
-- -----------------------------------------------------

UPDATE customers
SET gender = 'M'
WHERE customer_key IS NOT NULL
  AND gender = 'MALE';

UPDATE customers
SET gender = 'F'
WHERE customer_key IS NOT NULL
  AND gender = 'FEMALE';

UPDATE customers
SET gender = NULL
WHERE customer_key IS NOT NULL
  AND gender NOT IN ('M', 'F');


-- -----------------------------------------------------
-- Step 6: Validate birthdate business rules
-- Rationale:
--   Ages < 0 or > 120 are analytically invalid.
-- -----------------------------------------------------

UPDATE customers
SET birthdate = NULL
WHERE customer_key IS NOT NULL
  AND (
        birthdate > CURDATE()
        OR birthdate < DATE_SUB(CURDATE(), INTERVAL 120 YEAR)
      );


/* =====================================================
   PRODUCTS DIMENSION – DATA CLEANING
   ===================================================== */

-- -----------------------------------------------------
-- Step 1: Convert start_date from VARCHAR → DATE
-- -----------------------------------------------------

-- Preview conversion
-- SELECT start_date, STR_TO_DATE(start_date, '%d-%m-%Y')
-- FROM products LIMIT 10;

ALTER TABLE products
ADD start_date_dt DATE;

UPDATE products
SET start_date_dt = STR_TO_DATE(start_date, '%d-%m-%Y')
WHERE product_key >= 1;

ALTER TABLE products DROP start_date;
ALTER TABLE products
CHANGE start_date_dt start_date DATE;


-- -----------------------------------------------------
-- Step 2: Standardize missing values
-- -----------------------------------------------------

UPDATE products
SET product_line = NULL
WHERE product_key >= 1
  AND product_line = 'N/A';

UPDATE products
SET subcategory = NULL
WHERE product_key >= 1
  AND subcategory = '';


-- -----------------------------------------------------
-- Step 3: Normalize categorical text fields
-- -----------------------------------------------------

UPDATE products
SET
    product_name = TRIM(product_name),
    category_id  = UPPER(TRIM(category_id)),
    product_line = UPPER(TRIM(product_line)),
    subcategory  = UPPER(TRIM(subcategory))
WHERE product_key >= 1;


/* =====================================================
   SALES FACT TABLE – DATA CLEANING
   ===================================================== */

-- -----------------------------------------------------
-- Step 1: Validate keys and measures
-- (No action required – data validated during inspection)
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Step 2: Handle missing order dates
-- Rationale:
--   Missing dates are acceptable; fabricated dates are not.
-- -----------------------------------------------------

-- No updates required


-- -----------------------------------------------------
-- Step 3: Derive revenue metric
-- Rationale:
--   Revenue must be explicit and reusable for analytics.
-- -----------------------------------------------------

ALTER TABLE sales
ADD revenue DECIMAL(12,2);

UPDATE sales
SET revenue = quantity * price
WHERE sales_key IS NOT NULL
  AND quantity IS NOT NULL
  AND price IS NOT NULL;


/* =====================================================
   END OF DATA CLEANING SCRIPT
   ===================================================== */
