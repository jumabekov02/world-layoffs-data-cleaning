# World Layoffs Data Cleaning in MySQL

SQL data cleaning project using the world layoffs dataset.

## Project Goal
Clean raw layoff data in MySQL and prepare it for exploratory data analysis.

## Dataset
- Source file: `layoffs.csv`

## Cleaning Tasks
- Removed duplicates
- Standardized text values
- Converted date column to proper DATE format
- Handled null and blank values
- Removed unnecessary rows and helper columns

## Why is it important?
- duplicated records can distort analysis
- inconsistent text values break grouping
- blank and null values reduce data quality
- date conversion is needed for time-based analysis

## SQL Techniques Used
- `ROW_NUMBER()`
- `CTE`
- `JOIN`
- `UPDATE`
- `DELETE`
- `ALTER TABLE`
- `STR_TO_DATE()`
- `TRIM()`

## Files
- `data_cleaning.sql` — full SQL cleaning workflow
- `layoffs.csv` — raw dataset

## Next Step
Exploratory Data Analysis (EDA) on the cleaned dataset
