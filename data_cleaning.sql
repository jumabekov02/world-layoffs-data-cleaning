-- World Layoffs Data Cleaning Project
USE world_layoffs2;
SET SQL_SAFE_UPDATES = 0;

-- 1. Remove duplicates
-- 2. Standardize data
-- 3. Handle null and blank values
-- 4. Remove unnecessary rows and columns

-- 1. Create staging table
DROP TABLE IF EXISTS layoffs_staging;
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT * 
FROM layoffs;

-- 2. Identify and remove duplicates

WITH duplicate_cte AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

DROP TABLE IF EXISTS layoffs_cleaned;
CREATE TABLE `layoffs_cleaned` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_cleaned
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_cleaned
WHERE row_num > 1;

-- 3. Standardize data

UPDATE layoffs_cleaned
SET company = TRIM(company); 

UPDATE layoffs_cleaned
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_cleaned
SET country = 'United States'
WHERE country LIKE 'United States%';

UPDATE layoffs_cleaned
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_cleaned
MODIFY COLUMN `date` DATE;

SELECT t1.industry, t2.industry
FROM layoffs_cleaned AS t1
JOIN layoffs_cleaned AS t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '') 
AND t2.industry IS NOT NULL;

-- 4. Handle null and blank values

UPDATE layoffs_cleaned
SET industry = null
WHERE industry = '';

UPDATE layoffs_cleaned AS t1
JOIN layoffs_cleaned AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- 5. Remove unnecessary rows and helper columns

DELETE 
FROM layoffs_cleaned
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_cleaned
DROP COLUMN row_num;

-- 6. Final cleaned dataset
SELECT *
FROM layoffs_cleaned;

-- Data quality checks

SELECT COUNT(*) AS total_rows
FROM layoffs_cleaned;

SELECT COUNT(*) AS missing_industry
FROM layoffs_cleaned
WHERE industry IS NULL;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_cleaned;

SELECT DISTINCT country
FROM layoffs_cleaned
ORDER BY country;