# MySQL Data Warehouse – Data Cleaning Project

## Overview
This project demonstrates structured, production-style data cleaning for a MySQL data warehouse.

The focus is on preparing raw CSV-loaded tables and making them analytics-ready using
careful inspection, business-rule validation, and non-destructive cleaning techniques.

## Tables Covered
- **customers** (dimension)
- **products** (dimension)
- **sales** (fact)

## Key Data Cleaning Steps
- Safe conversion of text-based dates to DATE datatype
- Standardization of missing values (`N/A`, empty strings → `NULL`)
- Text normalization without altering business meaning
- Validation of business rules (age ranges, dates, measures)
- Creation of derived metrics for analytics (revenue)

## File Description
- `03_data_cleaning.sql`  
  Contains the complete, well-documented SQL script used to clean and prepare the data.

## Skills Demonstrated
- SQL (MySQL)
- Data Cleaning & Validation
- Data Warehousing Fundamentals
- Analytical Thinking

---
This project is part of my data analytics learning journey.
