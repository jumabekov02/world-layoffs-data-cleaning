-- Exploratory Data Analysis 
USE world_layoffs2;

SELECT *
FROM layoffs_cleaned;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_cleaned;

SELECT *
FROM layoffs_cleaned
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_cleaned
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_cleaned;

SELECT industry, SUM(total_laid_off)
FROM layoffs_cleaned
GROUP BY industry
ORDER BY 2 DESC;	

SELECT country, SUM(total_laid_off)
FROM layoffs_cleaned
GROUP BY country
ORDER BY 2 DESC;	

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_cleaned
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;		

WITH Rolling_total AS 
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_cleaned
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1
)
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_total;

SELECT company, SUM(total_laid_off)
FROM layoffs_cleaned
GROUP BY company
ORDER BY 2 DESC;

WITH Company_rolling AS 
(
SELECT company, SUM(total_laid_off) AS total_laid
FROM layoffs_cleaned
GROUP BY company
ORDER BY 2 DESC
)
SELECT company, total_laid, SUM(total_laid) OVER(ORDER BY company) AS rolling_laid
FROM Company_rolling;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_cleaned
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_Year (company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_cleaned
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERe years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;
