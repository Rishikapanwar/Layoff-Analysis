-- Layoffs data cleaning
-- Todos: removing duplicates, standardising, removing nulls, remove unncessary columns
SELECT * 
FROM layoff;

-- shouldn't work with raw data directly, creating a duplicate
CREATE TABLE layoffs_staging
LIKE layoff;

INSERT layoffs_staging
SELECT * 
FROM layoff;

SELECT * 
FROM layoffs_staging;
-- identifying duplicates 
-- Since we don't have any primary key in the data, let's create row number first
WITH duplicate_cte AS 
(
SELECT * ,
ROW_NUMBER() 
OVER (PARTITION BY company, location, funds_raised, stage, country, industry, total_laid_off, percentage_laid_off, `date`) as row_num
FROM layoffs_staging 
) 
SELECT *  
FROM duplicate_cte
WHERE row_num>1;
-- FOUND 2915 duplicate entries, now deleting those
-- creating a new table and then deleting row_nums>2 since we cant delete directly from ctes
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` double DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs_staging2;

INSERT INTO layoffs_staging2 
SELECT * ,
ROW_NUMBER() 
OVER (PARTITION BY company, location, funds_raised, stage, country, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging ;

-- Here, our duplicate values are:
SELECT * 
FROM layoffs_staging2 
WHERE row_num>1;
-- Deleting them
DELETE FROM layoffs_staging2 
WHERE row_num>1;

-- Standardizing data
SELECT company, TRIM(company)
FROM layoffs_staging2 ;
-- updating table
UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2 
ORDER BY 1;
-- found 1 null value, we'll remove it later
SELECT DISTINCT location
FROM layoffs_staging2 
ORDER BY 1;
-- seems fine
SELECT DISTINCT country
FROM layoffs_staging2 
ORDER BY 1;
-- seems fine as well
-- the date column is well-formatted in our dataset so we won't change it. If we had to change it, we'd do it like this (just a note)
-- SELECT `date`,
 -- str_to_date(`date`, '%m/%d/%Y')
-- from layoffs_staging2;
-- changing datatype to date 
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- removing nulls now:
-- we have missing blanks 
UPDATE layoffs_staging2
SET total_laid_off = NULL 
WHERE total_laid_off  = '';

UPDATE layoffs_staging2
SET percentage_laid_off = NULL 
WHERE percentage_laid_off  = ''; 
UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry  = ''; 


SELECT * 
FROM layoffs_staging2 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2 
WHERE industry IS NULL;

SELECT *
FROM layoffs_staging2 
WHERE company= 'Appsmith';
-- seems like we dont have any info about Appsmith since we dont have any other data related to it, safe to say we can remove it instead of manually adding the values
-- Also, there is no way to manually put in data for the rest of columns since we don't know the total number of employees so it makes sense to remove them as well

--
SELECT * 
FROM layoffs_staging2 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2 ;

-- let's drop the row_num col as well, its not needed anymore

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


-- Let's perform some EDA on the cleaned data now:
SELECT COUNT(DISTINCT(company)) FROM layoffs_staging2;

-- We're dealing with 1757 different companies
-- Let's look at the total number of employees laid off across the companies:
SELECT DISTINCT(company), country, SUM(total_laid_off) AS total_employees_laidoff, COUNT(company) AS company_count
FROM layoffs_staging2 
GROUP BY company, country
ORDER BY total_employees_laidoff DESC;

-- The maximum number of people laid off across time periods are from Amazon, Meta, Intel, Microsoft and Tesla. The first 8 companies who laid off the highest number of 
-- employees are all from USA

-- Let's look if there is any common funding pattern across these companies
SELECT DISTINCT(company),SUM(total_laid_off) AS total_employees_laidoff, COUNT(company) AS company_count, stage
FROM layoffs_staging2 
GROUP BY company, stage
ORDER BY total_employees_laidoff DESC;


-- All these companies are Post-IPO

-- Let's look if there is any other correlation between stage and lay offs
ALTER table layoffs_staging2 
MODIFY COLUMN `total_laid_off` INT;

SELECT total_laid_off, company, stage FROM layoffs_staging2 
ORDER BY total_laid_off DESC;

SELECT stage, SUM(total_laid_off) as employees_fired_across_different_companies 
FROM layoffs_staging2 
GROUP BY stage
ORDER BY employees_fired_across_different_companies DESC;

-- Even at individual firing level, the POST-IPO companies have the highest number of lay offs. Probably because their work force is also much larger in comparison to other companies
-- Overall, different post-ipo companies fired a total of 311196 employees whereas the other staging companies fired 36886 (almost 10x smaller) number of employees.


-- Let's look at the lay offs scenario across different locations:
SELECT country, SUM(total_laid_off) AS total_employees_laidoff
FROM layoffs_staging2 
GROUP BY  country
ORDER BY total_employees_laidoff DESC;

-- Countries like USA, India, Germany and UK are most affected by lay-offs. USA being the top one where the toal people fired are 10x more than the second i,e. India
-- This could also be because most companies in our dataset are based in USA, let's look at that too:

SELECT COUNT(DISTINCT(company)) AS total_companies, country
FROM layoffs_staging2 
GROUP BY country
ORDER BY total_companies DESC;


-- Yep, USA has 1101 companies, which is almost 10x more than the number of companies based in India (147). So, it makes sense that USA had the highest number of layoffs. 

-- Interestingly, Canada has the third highest number of companies (71) yet the lay offs, similar case goes for Israel. These countries aren't affected by layoffs as much 
-- as others compared with the companies based there

-- Let's look at the lay offs individually as well:

SELECT MAX(total_laid_off)
FROM layoffs_staging2;
-- The max number of employees fired at any day was 15000
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Seems like there is a company that fired all of its employees since the max percentage laid off is 1, let's look at it in more detail
SELECT DISTINCT(company), percentage_laid_off 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
group by company ;

-- There are 196 companies in this category, let's see if they fired all the employees in a single day or periodically
SELECT percentage_laid_off, company, industry
FROM layoffs_staging2
WHERE percentage_laid_off = 1;
-- There is 1 extra entry in the case where company name is not distinct, the rest all companies fired all their employees on a single day
SELECT COUNT(company), company,percentage_laid_off
FROM layoffs_staging2
WHERE percentage_laid_off = 1 
GROUP BY company
HAVING COUNT(company)>1;
-- This company is Joonko:
SELECT * FROM layoffs_staging2 
WHERE company= 'Joonko';
-- This company fired all of their employees in HR in 2024 and in Recruiting in 2023

-- Let's also look at the industries and lay offs
SELECT distinct(industry), SUM(total_laid_off)
FROM layoffs_staging2 
GROUP BY industry
ORDER BY SUM(total_laid_off) DESC;

-- The retail, consumer, transportation and food industry was affected by the lay offs the most

-- Lets also look at the time period
SELECT  MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- We're looking at the time period from January 2022 to Feb 2025
SELECT YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY SUM(total_laid_off) DESC;

-- The max number of employees were fired in 2023, followed by 2022 and 2024
-- Lets dig into 2023 
SELECT SUBSTRING(`date`, 6,2) AS `month`, YEAR(`date`) AS `year`,  SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `month`, `year`
HAVING `year` = 2023
ORDER BY SUM(total_laid_off) DESC;

-- The initial 6 months of 2023 experienced the maximum number of layoffs
-- Let's compare it with other years as well to see if it is a general trend:
SELECT SUBSTRING(`date`, 6,2) AS `month`, YEAR(`date`) AS `year`,  SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `month`, `year`
ORDER BY SUM(total_laid_off) DESC;

-- There is not a generalised trend between the months and lay offs, but more employees were fired in the first 6 months for 2023 and 2024 whereas the opposite was 
-- seen in 2022

WITH rolling_total AS 
(
SELECT SUBSTRING(`date`, 1,7) AS `month`,   SUM(total_laid_off) as total_off
FROM layoffs_staging2
GROUP BY `month`
ORDER BY `month` ASC)
SELECT `month`, total_off, SUM(total_off) OVER (ORDER BY `month`) as rolling_total
FROM rolling_total ;

-- Overall, 504269 were laid off over the last 3 years. The highest were through January 2023 to April 2023
-- Lastly, let's look at how the companies were laying off across the years

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2 
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH company_year  (company, years, total_laid_off,company_count) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off), COUNT(*)  
FROM layoffs_staging2 
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
),
company_year_rank AS
(
SELECT * , DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS `rank`
FROM company_year ORDER BY `rank`)
SELECT * 
FROM company_year_rank
WHERE `rank`<=5;

-- Here, we have the top 5 companies with highest lay offs every year and Meta fired the highest number of employees in 2022 as well as 2025. 
-- Interestingly, Amazon laid off their employees 4 times in 2023 while Meta did it all at once every year.
-- Microsoft, Amazon and Google laid off their employees at different months throughout the year (mostly around 3-4 times a year)
CREATE TABLE layoffs_staging_final
LIKE layoffs_staging2;

INSERT layoffs_staging_final
SELECT * 
FROM layoffs_staging2;

WITH duplicate_cte AS 
(
SELECT * ,
ROW_NUMBER() 
OVER (PARTITION BY company, location, funds_raised, stage, country, industry, total_laid_off, percentage_laid_off, `date`) as row_num
FROM layoffs_staging_final 
) 
SELECT *  
FROM duplicate_cte
WHERE row_num>1;