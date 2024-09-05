-- Data Cleaning

SELECT *
FROM world_layoffs.layoffs;

-- STEP -1 -> Removing Duplicataes
-- STEP -2 -> Standardize the Data
-- STEP -3 -> Null/Blank Values
-- STEP -4 -> Remove Any columns

-- Creating a new table, so that we do not change the original data
CREATE TABLE world_layoffs.layoffs_stagging
LIKE world_layoffs.layoffs;
-- Inserting thde data
INSERT world_layoffs.layoffs_stagging
SELECT *
FROM world_layoffs.layoffs;

SELECT *
FROM world_layoffs.layoffs_stagging;

-- Checking for duplicate values
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM world_layoffs.layoffs_stagging;
-- Creating a CTTE
WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM world_layoffs.layoffs_stagging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Creating a new table with an additional column `row_num`
CREATE TABLE `layoffs_stagging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO world_layoffs.layoffs_stagging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM world_layoffs.layoffs_stagging;

SELECT *
FROM world_layoffs.layoffs_stagging2
WHERE row_num > 1;
-- Deleting the duplicated rows
DELETE
FROM world_layoffs.layoffs_stagging2
WHERE row_num > 1;

-- Standarding the data

-- Checking the Typos in the data
SELECT company, TRIM(company)
FROM world_layoffs.layoffs_stagging2;

UPDATE world_layoffs.layoffs_stagging2
SET company = TRIM(company);

SELECT DISTINCT(industry)
FROM world_layoffs.layoffs_stagging2
ORDER BY 1;
SELECT *
FROM world_layoffs.layoffs_stagging2
WHERE industry LIKE "Crypto%";

UPDATE world_layoffs.layoffs_stagging2
SET industry = "Crypto"
WHERE industry LIKE "Crypto%";

SELECT DISTINCT(country)
FROM world_layoffs.layoffs_stagging2
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM world_layoffs.layoffs_stagging2
ORDER BY 1;

UPDATE world_layoffs.layoffs_stagging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';
SELECT *
FROM world_layoffs.layoffs_stagging2;

-- Changing the date column from str to DateTime
SELECT `date`,
STR_TO_DATE(`date`, "%m/%d/%Y")
FROM world_layoffs.layoffs_stagging2;

UPDATE world_layoffs.layoffs_stagging2
SET `date` = STR_TO_DATE(`date`, "%m/%d/%Y");

ALTER TABLE world_layoffs.layoffs_stagging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM world_layoffs.layoffs_stagging2;

-- Romving or Populating the NULL / Blank values
SELECT *
FROM world_layoffs.layoffs_stagging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE world_layoffs.layoffs_stagging2
SET industry = null
WHERE industry = "";

SELECT *
FROM world_layoffs.layoffs_stagging2
WHERE industry IS NULL
OR industry = "";

SELECT *
FROM world_layoffs.layoffs_stagging2
WHERE company = "Airbnb";

SELECT t1.industry, t2.industry
FROM world_layoffs.layoffs_stagging2 t1
JOIN world_layoffs.layoffs_stagging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = "")
AND t2.industry IS NOT NULL;

UPDATE world_layoffs.layoffs_stagging2 t1
JOIN world_layoffs.layoffs_stagging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM world_layoffs.layoffs_stagging2
WHERE industry IS NULL
OR industry = "";

SELECT *
FROM world_layoffs.layoffs_stagging2
WHERE company LIKE "Bally%";

SELECT *
FROM world_layoffs.layoffs_stagging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Removing the Rows, as they do not have any value
DELETE
FROM world_layoffs.layoffs_stagging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Removing the unnecessary Column
ALTER TABLE world_layoffs.layoffs_stagging2
DROP COLUMN row_num;

SELECT *
FROM world_layoffs.layoffs_stagging2;