/* =====================================================
   PROJECT: SQL EXPLORATORY DATA ANALYSIS (EDA)
   CONTEXT: Continuation of Data Cleaning Project
   DATABASE: datawarehouseanalytics

   OBJECTIVE:
   Perform foundational exploratory data analysis to
   understand data structure, distributions, and basic
   business behavior after data cleaning.
   ===================================================== */

USE datawarehouseanalytics;

/* =====================================================
   DATABASE OVERVIEW
   Objective:
   Understand available tables and schema structure.
   ===================================================== */

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'datawarehouseanalytics';

/* =====================================================
   DIMENSION EXPLORATION
   Objective:
   Understand cardinality, dominance, rarity, and
   completeness of categorical dimensions.
   ===================================================== */

-- Cardinality checks
SELECT COUNT(DISTINCT country) AS unique_countries
FROM customers;

SELECT COUNT(DISTINCT category) AS unique_categories
FROM products;

SELECT COUNT(DISTINCT subcategory) AS unique_subcategories
FROM products;

SELECT COUNT(DISTINCT product_name) AS unique_products
FROM products;

-- Dimension dominance: customers by country
SELECT
    country,
    COUNT(*) AS total_customers
FROM customers
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_customers DESC;

-- Rare dimension values: countries with few customers
SELECT
    country,
    COUNT(*) AS total_customers
FROM customers
WHERE country IS NOT NULL
GROUP BY country
HAVING COUNT(*) <= 10
ORDER BY total_customers DESC;

/* =====================================================
   DATE EXPLORATION
   Objective:
   Understand temporal coverage and data span.
   ===================================================== */

-- Overall date range of sales data
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    TIMESTAMPDIFF(YEAR, MIN(order_date), MAX(order_date)) AS years_of_sales
FROM sales;

-- Age distribution: youngest and oldest customers
SELECT
    MIN(TIMESTAMPDIFF(YEAR, birthdate, CURDATE())) AS youngest_customer_age,
    MAX(TIMESTAMPDIFF(YEAR, birthdate, CURDATE())) AS oldest_customer_age
FROM customers
WHERE birthdate IS NOT NULL;

/* =====================================================
   MEASURES EXPLORATION
   Objective:
   Understand scale, variability, and basic statistics
   of key numerical measures.
   ===================================================== */

-- Core business metrics
SELECT SUM(sales_amount) AS total_sales FROM sales;
SELECT SUM(quantity) AS total_items_sold FROM sales;
SELECT ROUND(AVG(price), 2) AS average_selling_price FROM sales;

SELECT COUNT(DISTINCT order_number) AS total_orders FROM sales;
SELECT COUNT(*) AS total_products FROM products;
SELECT COUNT(*) AS total_customers FROM customers;

SELECT COUNT(DISTINCT customer_key) AS customers_with_orders
FROM sales;

/* =====================================================
   MAGNITUDE ANALYSIS
   Objective:
   Compare measures across dimensions to identify
   concentration and performance differences.
   ===================================================== */

-- Revenue by product category
SELECT
    COALESCE(p.category, 'N/A') AS category,
    ROUND(SUM(s.revenue), 2) AS total_revenue
FROM products p
LEFT JOIN sales s
ON p.product_key = s.product_key
GROUP BY COALESCE(p.category, 'N/A')
ORDER BY total_revenue DESC;

-- Revenue by customer
SELECT
    c.customer_key,
    c.first_name,
    c.last_name,
    ROUND(SUM(s.revenue), 2) AS total_revenue
FROM customers c
LEFT JOIN sales s
ON c.customer_key = s.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC;

-- Top and bottom performing products
SELECT
    p.product_name,
    SUM(s.revenue) AS total_revenue
FROM products p
LEFT JOIN sales s
ON p.product_key = s.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 5;

SELECT
    p.product_name,
    SUM(s.revenue) AS total_revenue
FROM products p
LEFT JOIN sales s
ON p.product_key = s.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC
LIMIT 5;

/* =====================================================
   DIMENSION × MEASURE ANALYSIS
   Objective:
   Compare volume and value metrics across dimensions.
   ===================================================== */

-- Volume vs revenue by country
SELECT
    COALESCE(c.country, 'N/A') AS country,
    SUM(s.quantity) AS total_items_sold,
    ROUND(SUM(s.revenue), 2) AS total_revenue
FROM customers c
LEFT JOIN sales s
ON c.customer_key = s.customer_key
GROUP BY COALESCE(c.country, 'N/A')
ORDER BY total_items_sold DESC;
