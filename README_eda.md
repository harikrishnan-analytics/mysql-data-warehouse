
   PROJECT: SQL EXPLORATORY DATA ANALYSIS (EDA)
   FILE: 04_sql_eda.sql
   CONTEXT: Continuation of Data Cleaning Project

   DATABASE: datawarehouseanalytics
   



   PROJECT CONTEXT
   -----------------------------------------------------
   This Exploratory Data Analysis (EDA) is a direct
   continuation of the data cleaning phase documented
   in `03_data_cleaning.sql`.

   The data cleaning phase focused on:
   - Validating schema and data types
   - Handling missing and inconsistent values
   - Ensuring referential integrity
   - Preparing the dataset for analytical use

   With a clean and reliable dataset in place, this
   script focuses on understanding the structure,
   distribution, and behavior of the data



   OBJECTIVE
   -----------------------------------------------------
   The objective of this EDA is to:

   - Establish a strong analytical baseline
   - Understand key dimensions, dates, and measures
   - Identify distribution patterns and concentration
   - Surface early business insights
   - Validate analytical readiness before advanced
     analysis

   This analysis is intentionally scoped as
   FOUNDATIONAL EDA. Advanced analytics such as
   change-over-time, growth, and cumulative analysis
   will be handled in a separate follow-up project.




   EDA STRUCTURE
   



   1. DIMENSION EXPLORATION
   -----------------------------------------------------
   Focus:
   - Understanding categorical dimensions
   - Cardinality and distribution
   - Dominant and rare values
   - Completeness and NULL checks
   - Dimension × Measure relationships

   Key Questions Answered:
   - How many unique values exist per dimension?
   - Which dimension values dominate the dataset?
   - Are there rare or low-frequency values?
   - Are there missing values that could affect
     joins or aggregations?
   - How do measures (quantity, revenue) vary
     across dimensions?

   Key Observations:
   - A small number of dimension values dominate,
     indicating concentration effects
   - Several low-frequency values may require
     grouping or special handling
   - Minor missing values exist but do not
     materially impact analysis




   2. DATE EXPLORATION
   -----------------------------------------------------
   Focus:
   - Temporal coverage and continuity
   - Data span and recency
   - Distribution of activity over time

   Key Questions Answered:
   - What is the minimum and maximum date?
   - How many years of data are available?
   - Are there periods of sparse activity?
   - Is the data recent enough for analysis?

   Key Observations:
   - The dataset spans multiple years
   - Activity varies across time periods
   - Data recency supports further
     trend-based analysis




   3. MEASURES EXPLORATION
   -----------------------------------------------------
   Focus:
   - Understanding numerical measures
   - Scale, variability, and anomalies
   - Basic business metrics

   Key Questions Answered:
   - What is the total sales volume and revenue?
   - How many items were sold?
   - What is the average selling price?
   - How many orders, customers, and products
     exist?
   - Are there zero or negative values?

   Key Observations:
   - Sales values show noticeable variability
   - A small number of high-value transactions
     exist
   - Zero or negative values likely represent
     returns or special business cases




   SUMMARY & CONCLUSIONS
   -----------------------------------------------------
   This EDA confirms that the cleaned dataset is:

   - Structurally sound
   - Analytically reliable
   - Suitable for deeper analytical work

   The analysis highlights concentration patterns
   across dimensions and establishes a clear
   baseline for advanced analytics.
   



   NEXT STEPS
   -----------------------------------------------------
   Planned follow-up analysis includes:

   - Change-over-time analysis
   - Growth rate evaluation
   - Cumulative metrics
   - Advanced business insights using
     window functions

   These will be implemented in a separate
   advanced analytics script.


   ## Exploratory Data Analysis

The detailed Exploratory Data Analysis is documented here:
➡️ [EDA README](README_eda.md)

   

   RELATED FILES
   -----------------------------------------------------
   - 03_data_cleaning.sql  : Data cleaning and preparation
   - 04_sql_eda.sql        : Exploratory data analysis

