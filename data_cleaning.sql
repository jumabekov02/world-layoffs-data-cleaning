-- Data Cleaning 
USE world_layoffs2;
SET SQL_SAFE_UPDATES = 0;

-- 1. Remove duplicates 
-- 2. Standardize data 
-- 3. Null values and blank values 
-- 4. Remove any columns 

CREATE TABLE layoffs_staging
LIKE layoffs;

Insert layoffs_staging
SELECT * 
FROM layoffs;

WITH duplicate_cte AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_staging3` (
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

INSERT layoffs_staging3
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging3
WHERE row_num > 1;

-- Standardizing data 

UPDATE layoffs_staging3
SET company = TRIM(company); 

UPDATE layoffs_staging3
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging3
SET country = 'United States'
WHERE country LIKE 'United States%';

UPDATE layoffs_staging3
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging3
MODIFY COLUMN `date` DATE;

-- 3. Null values and blank values 

UPDATE layoffs_staging3
SET industry = 'Travel'
WHERE industry = '';

SELECT t1.industry, t2.industry
FROM layoffs_staging3 AS t1
JOIN layoffs_staging3 AS t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '') 
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging3
SET industry = null
WHERE industry = '';

UPDATE layoffs_staging3 AS t1
JOIN layoffs_staging3 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- 4. Remove any columns or rows

DELETE 
FROM layoffs_staging3
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging3
DROP COLUMN row_num;





 
