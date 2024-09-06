-- Retrieve all data from the layoffs_stagging2 table
SELECT *
FROM world_layoffs.layoffs_stagging2;

-- Find the maximum number of total laid off employees and the maximum percentage laid off
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM world_layoffs.layoffs_stagging2;

-- Retrieve companies where 100% of the employees were laid off, ordered by the highest funds raised
SELECT *
FROM world_layoffs.layoffs_stagging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Summarize total layoffs by company, ordered by the highest total layoffs
SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_stagging2
GROUP BY company
ORDER BY 2 DESC;

-- Find the minimum and maximum layoff dates
SELECT MIN(`date`), MAX(`date`)
FROM world_layoffs.layoffs_stagging2;

-- Summarize total layoffs by industry, ordered by the highest total layoffs
SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs_stagging2
GROUP BY industry
ORDER BY 2 DESC;

-- Summarize total layoffs by country, ordered by the highest total layoffs
SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs_stagging2
GROUP BY country
ORDER BY 2 DESC;

-- Summarize total layoffs by year, ordered from most recent to oldest
SELECT YEAR(`date`), SUM(total_laid_off)
FROM world_layoffs.layoffs_stagging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Summarize total layoffs by company stage, ordered alphabetically
SELECT stage, SUM(total_laid_off)
FROM world_layoffs.layoffs_stagging2
GROUP BY stage
ORDER BY 1;

-- Calculate the average percentage laid off by company, ordered by the highest average percentage
SELECT company, AVG(percentage_laid_off)
FROM world_layoffs.layoffs_stagging2
GROUP BY company
ORDER BY 2 DESC;

-- Summarize total layoffs by month (YYYY-MM format), ordered chronologically
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM world_layoffs.layoffs_stagging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1;

-- Calculate a rolling total of layoffs by month
WITH Rolling_total AS 
(
  SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) total_off
  FROM world_layoffs.layoffs_stagging2
  WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
  GROUP BY `MONTH`
  ORDER BY 1
)
SELECT 
  `MONTH`, 
  total_off,
  SUM(total_off) OVER(ORDER BY `MONTH`) rolling_total
FROM Rolling_total;

-- Summarize total layoffs by year, ordered chronologically
SELECT 
  YEAR(`date`) `Year`,
  SUM(total_laid_off)
FROM world_layoffs.layoffs_stagging2
WHERE YEAR(`date`) IS NOT NULL
GROUP BY `Year`
ORDER BY `Year`;

-- Summarize total layoffs by company and year, ordered by the highest total layoffs
SELECT 
  company, 
  YEAR(`date`),
  SUM(total_laid_off)
FROM world_layoffs.layoffs_stagging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Rank the top 5 companies by total layoffs for each year
WITH company_year (company, years, total_laid_off) AS
(
  SELECT 
    company, 
    YEAR(`date`),
    SUM(total_laid_off)
  FROM world_layoffs.layoffs_stagging2
  GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
  SELECT 
    *, 
    DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) Ranking
  FROM company_year
  WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;