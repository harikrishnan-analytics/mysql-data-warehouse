# Advanced Analytics using SQL

## 📌 Overview
This document describes the Advanced Analytics phase of my SQL analytics project.  
It builds on the cleaned and explored data from earlier stages and focuses on applying analytical SQL patterns to answer real business questions.

The analysis is performed using pure SQL on a transactional data model consisting of:
- `customers`
- `products`
- `sales`

---

## 🎯 Objectives
The goal of this phase is to move beyond descriptive analysis and apply:
- Time-based analysis
- Cumulative metrics
- Performance benchmarking
- Contribution analysis
- Segmentation techniques

All insights are derived directly in SQL, without relying on external tools.

---

## 📊 Analyses Covered

### 🔹 Change Over Time Analysis
- Yearly, quarterly, and monthly sales trends
- Customer growth over time
- Quantity sold trends across years

**Purpose:**  
Identify growth patterns, seasonality, and long-term changes in business activity.

---

### 🔹 Cumulative Analysis
- Running total of monthly sales
- Cumulative revenue by product category
- Cumulative quantity purchased by customer

**Purpose:**  
Understand momentum, long-term contribution, and customer purchasing behavior.

---

### 🔹 Performance Analysis
- Yearly product revenue vs historical average
- Year-over-year (YoY) performance comparison
- Product trend classification:
  - Improving
  - Declining
  - Stable

**Purpose:**  
Evaluate whether products are performing above expectations and identify early warning signals.

---

### 🔹 Part-to-Whole Analysis
- Sales contribution by category
- Top subcategory contribution to total sales
- Product-level contribution with cumulative percentage

**Purpose:**  
Identify key revenue drivers and assess revenue concentration.

---

### 🔹 Segment Analysis
- Product segmentation by cost ranges
- Cost segment distribution across categories
- Identification of overrepresented and underrepresented cost segments

**Purpose:**  
Evaluate product portfolio balance and pricing strategy coverage.

---

## 🛠️ SQL Techniques Used
- Window functions (`SUM() OVER`, `AVG() OVER`, `LAG()`)
- Common Table Expressions (CTEs)
- Aggregations and grouping
- Conditional logic (`CASE WHEN`)
- Analytical query design

---

## 📂 Relevant File
- `05_advanced_analytics.sql`  
  Contains all SQL queries used for the analyses described above, with clear comments and logical sectioning.



## 👤 Author
**Harikrishnan Bellan**

This Advanced Analytics module is a continuation of a larger SQL analytics project.
