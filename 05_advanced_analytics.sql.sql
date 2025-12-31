-- CHANGE OVER TIME ANALYSIS
-- Yearly sales trend
SELECT
	YEAR(order_date) AS Year,
	SUM(sales_amount) AS Total_revenue
FROM sales 
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date) 
ORDER BY YEAR(order_date); 

-- Monthly sales trend 
-- Method 1
SELECT
    YEAR(order_date) AS year,
	MONTH(order_date) AS month,
	SUM(sales_amount) AS Total_revenue
FROM sales 
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date) , MONTH(order_date) 
ORDER BY YEAR(order_date) , MONTH(order_date);  

-- Method 2
SELECT
	DATE_FORMAT(order_date, '%Y-%m') AS Yr_Mnth,
	SUM(sales_amount) AS Total_revenue
FROM sales 
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date, '%Y-%m') 
ORDER BY DATE_FORMAT(order_date, '%Y-%m');  

-- Quarterly sales analysis 
SELECT
    YEAR(order_date) AS year,
	QUARTER(order_date) AS quarter,
	SUM(sales_amount) AS Total_revenue
FROM sales 
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date) , QUARTER(order_date) 
ORDER BY YEAR(order_date) , QUARTER(order_date);  

-- No of customers over the years
SELECT
	YEAR(order_date) AS Year,
	COUNT(DISTINCT customer_key) AS customer_count
FROM sales 
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

-- Total quantity of goods sold over the years
SELECT
	YEAR(order_date) AS Year,
	SUM(quantity) AS Goods_sold
FROM sales 
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);



/*
CUMULATIVE ANALYSIS: Monthly Sales and Running Total

Objective:
Calculating the total sales per month and the running total
of sales over time.
*/

SELECT
    yr_month,
    total_sales,
    SUM(total_sales) OVER (
        ORDER BY yr_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS yr_month,
        SUM(sales_amount) AS total_sales
    FROM sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
) t
ORDER BY yr_month;


/*
CUMULATIVE ANALYSIS: Revenue Growth by Product Category 

Objective:
Tracking how revenue accumulates over time within each product category.
*/

SELECT
    category,
    yr_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
        PARTITION BY category
        ORDER BY yr_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue
FROM (
    SELECT 
        p.category,
        DATE_FORMAT(s.order_date, '%Y-%m') AS yr_month,
        SUM(s.revenue) AS monthly_revenue
    FROM products p
    INNER JOIN sales s
        ON p.product_key = s.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY
        p.category,
        DATE_FORMAT(s.order_date, '%Y-%m')
) t
ORDER BY category, yr_month;



/*
Cumulative Analysis: Quantity Sold Over Time by Customer

Objective:
Tracking how the cumulative quantity purchased grows over time
for each individual customer.
*/

SELECT
    customer_key,
    first_name,
    last_name,
    yr_mnth,
    monthly_quantity,
    SUM(monthly_quantity) OVER (
        PARTITION BY customer_key
        ORDER BY yr_mnth
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_quantity
FROM (
    SELECT 
        c.customer_key,
        c.first_name,
        c.last_name,
        DATE_FORMAT(s.order_date, '%Y-%m') AS yr_mnth,
        SUM(s.quantity) AS monthly_quantity
    FROM customers c
    INNER JOIN sales s
        ON c.customer_key = s.customer_key 
    WHERE s.order_date IS NOT NULL
    GROUP BY
        c.customer_key,
        c.first_name,
        c.last_name,
        DATE_FORMAT(s.order_date, '%Y-%m')
) t
ORDER BY customer_key, yr_mnth;


-- PERFORMANCE ANALYSIS
/*
Performance Analysis: Yearly Product Performance

Objective:
Analyze yearly product performance by comparing each product’s
annual revenue to:
1. Its average yearly revenue
2. Its previous year’s revenue
*/

SELECT
    product_name,
    year,
    revenue_yearly,
    ROUND(AVG(revenue_yearly) OVER (PARTITION BY product_key), 2) AS avg_yearly_revenue,
    ROUND(
        revenue_yearly 
        - AVG(revenue_yearly) OVER (PARTITION BY product_key),
        2
    ) AS diff_from_avg,
    LAG(revenue_yearly) OVER (
        PARTITION BY product_key
        ORDER BY year
    ) AS prev_year_revenue,
    ROUND(
        revenue_yearly 
        - LAG(revenue_yearly) OVER (PARTITION BY product_key ORDER BY year),
        2
    ) AS diff_from_prev_year
FROM (
    SELECT
        p.product_key,
        p.product_name,
        YEAR(s.order_date) AS year,
        SUM(s.sales_amount) AS revenue_yearly
    FROM products p
    INNER JOIN sales s
        ON p.product_key = s.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY
        p.product_key,
        p.product_name,
        YEAR(s.order_date)
) t
ORDER BY product_name, year;


/*
Performance Analysis: Products Exceeding Typical Yearly Performance

Objective:
Identify product-year combinations where yearly revenue
exceeds the product’s own long-term average yearly revenue.
*/

SELECT 
    product_name,
    year,
    revenue_yearly,
    ROUND(avg_yearly_revenue) AS avg_yearly_revenue,
    ROUND(revenue_yearly - avg_yearly_revenue) AS diff_from_avg
FROM (
    SELECT
        product_key,
        product_name,
        year,
        revenue_yearly,
        AVG(revenue_yearly) OVER (PARTITION BY product_key) AS avg_yearly_revenue
    FROM (
        SELECT
            p.product_key,
            p.product_name,
            YEAR(s.order_date) AS year,
            SUM(s.sales_amount) AS revenue_yearly
        FROM products p
        INNER JOIN sales s
            ON p.product_key = s.product_key
        WHERE s.order_date IS NOT NULL
        GROUP BY
            p.product_key,
            p.product_name,
            YEAR(s.order_date)
    ) yearly_sales
) performance
WHERE revenue_yearly > avg_yearly_revenue
ORDER BY product_name, year;

/* =====================================================
   Performance Analysis: Product Trend (CTE Version)

   Objective:
   Classify products as Improving, Declining, or Stable
   based on year-over-year revenue performance.
   ===================================================== */

WITH yearly_product_sales AS (
    SELECT
        p.product_key,
        p.product_name,
        YEAR(s.order_date) AS year,
        SUM(s.sales_amount) AS revenue_yearly
    FROM products p
    INNER JOIN sales s
        ON p.product_key = s.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY
        p.product_key,
        p.product_name,
        YEAR(s.order_date)
),

product_trends AS (
    SELECT
        product_key,
        product_name,
        year,
        revenue_yearly,
        LAG(revenue_yearly) OVER (
            PARTITION BY product_key
            ORDER BY year
        ) AS prev_year_revenue
    FROM yearly_product_sales
)

SELECT
    product_name,
    year,
    revenue_yearly,
    prev_year_revenue,
    revenue_yearly - prev_year_revenue AS yoy_change,
    CASE
        WHEN prev_year_revenue IS NULL THEN 'No Prior Year'
        WHEN revenue_yearly > prev_year_revenue THEN 'Improving'
        WHEN revenue_yearly < prev_year_revenue THEN 'Declining'
        ELSE 'Stable'
    END AS performance_trend
FROM product_trends
ORDER BY product_name, year;


-- PART TO WHOLE ANALYSIS 
/*
Part-to-Whole Analysis: Sales Contribution by Category

Objective:
Identify which product categories contribute the most
to overall sales by calculating percentage contribution.
*/

WITH sales_category AS (
    SELECT 
        p.category,
        SUM(s.sales_amount) AS sales_per_category
    FROM products p
    INNER JOIN sales s
        ON p.product_key = s.product_key 
    GROUP BY p.category
)

SELECT 
    category,
    ROUND(sales_per_category, 2) AS sales_per_category,
    ROUND(SUM(sales_per_category) OVER (), 2) AS total_sales,
    ROUND(
        sales_per_category / SUM(sales_per_category) OVER () * 100,
        2
    ) AS percent_contribution
FROM sales_category
ORDER BY percent_contribution DESC;

/*
Part-to-Whole Analysis: Top 3 Subcategory Contribution to Total Sales

Objective:
Identify the top 3 product subcategories and determine
their contribution to overall sales.
*/

SELECT
    subcategory,
    sales_per_subcategory,
    total_sales,
    ROUND(percent_contribution, 2) AS percent_contribution
FROM (
    SELECT 
        p.subcategory,
        SUM(s.sales_amount) AS sales_per_subcategory,
        SUM(SUM(s.sales_amount)) OVER () AS total_sales,
        SUM(s.sales_amount)
            / SUM(SUM(s.sales_amount)) OVER () * 100 AS percent_contribution
    FROM products p
    INNER JOIN sales s
        ON p.product_key = s.product_key 
    GROUP BY p.subcategory
) t
ORDER BY percent_contribution DESC
LIMIT 3; 

/*
Part-to-Whole Analysis: Product Contribution to Total Sales

Objective:
Identify individual products that contribute the most
to overall sales.
*/

SELECT
    product_name,
    sales_per_product,
    total_sales,
    ROUND(percent_contribution, 2) AS percent_contribution,
    SUM(percent_contribution) OVER (
		ORDER BY percent_contribution DESC
		)AS cumulative_percent
FROM (
    SELECT 
        p.product_key,
        p.product_name,
        SUM(s.sales_amount) AS sales_per_product,
        SUM(SUM(s.sales_amount)) OVER () AS total_sales,
        SUM(s.sales_amount)
            / SUM(SUM(s.sales_amount)) OVER () * 100 AS percent_contribution
    FROM products p
    INNER JOIN sales s
        ON p.product_key = s.product_key 
    GROUP BY p.product_key, p.product_name
) t
ORDER BY percent_contribution DESC;

-- SEGMENT ANALYSIS
/*
Segment Analysis: Product Cost Bucketing

Objective:
Segment products into cost ranges and count the number
of products in each segment.
*/

WITH product_segment AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost IS NULL THEN 'Unknown'
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost >= 100 AND cost < 500 THEN '100 - 499'
            WHEN cost >= 500 AND cost < 1000 THEN '500 - 999'
            ELSE '1000 and above'
        END AS cost_range
    FROM products
)

SELECT
    cost_range,
    COUNT(product_key) AS product_count
FROM product_segment
GROUP BY cost_range
ORDER BY product_count DESC;

/*
Segment Analysis: Product Distribution by Cost Range and Category

Objective:
Understanding how products are distributed across predefined
cost segments within each product category.
*/

WITH product_segment AS (
    SELECT
        product_key,
        product_name,
        category,
        cost,
        CASE 
            WHEN cost IS NULL THEN 'Unknown'
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost >= 100 AND cost < 500 THEN '100 - 499'
            WHEN cost >= 500 AND cost < 1000 THEN '500 - 999'
            ELSE '1000 and above'
        END AS cost_range 
    FROM products
    WHERE category IS NOT NULL
)

SELECT
    category,
    cost_range,
    COUNT(product_key) AS product_count
FROM product_segment
GROUP BY category, cost_range
ORDER BY category, cost_range;

/*
Segment Analysis: Over- and Under-represented Cost Segments

Objective:
Evaluate how products are distributed across predefined cost
segments and identify segments that are overrepresented or
underrepresented in the overall product portfolio.
*/

WITH product_segment AS (
    SELECT
        product_key,
        CASE 
            WHEN cost IS NULL THEN 'Unknown'
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost >= 100 AND cost < 500 THEN '100 - 499'
            WHEN cost >= 500 AND cost < 1000 THEN '500 - 999'
            ELSE '1000 and above'
        END AS cost_range
    FROM products
),

segment_counts AS (
    SELECT
        cost_range,
        COUNT(product_key) AS product_count
    FROM product_segment
    GROUP BY cost_range
),

segment_distribution AS (
    SELECT
        cost_range,
        product_count,
        SUM(product_count) OVER () AS total_products,
        product_count
            / SUM(product_count) OVER () * 100 AS percent_of_portfolio
    FROM segment_counts
)

SELECT
    cost_range,
    product_count,
    ROUND(percent_of_portfolio, 2) AS percent_of_portfolio,
    CASE
        WHEN percent_of_portfolio >= 30 THEN 'Overrepresented'
        WHEN percent_of_portfolio <= 10 THEN 'Underrepresented'
        ELSE 'Balanced'
    END AS segment_status
FROM segment_distribution
ORDER BY percent_of_portfolio DESC;

