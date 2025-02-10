desc layoffs ;
SELECT* FROM layoffs
LIMIT 10;

--Creating a copy of the original table
CREATE TABLE layoffs_copy
LIKE layoffs;

--Insert data from orinal table to the copy table
INSERT layoffs_copy
SELECT *
FROM layoffs;

--Check at the new table
SELECT * FROM layoffs_copy;

--DATA CLEANING
	# 1. Removing duplicates
    SELECT*,
    ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country) AS row_num
    FROM layoffs_copy;
    
    #Using a CTE to identify duplicates
    WITH duplicate_cte AS 
    (
	SELECT*,
    ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num  #partion by every column to ensure it is a full row duplicate
    FROM layoffs_copy
    )
    SELECT *
    FROM duplicate_cte
    WHERE row_num>1;  

INSERT INTO layoffs_copy2
SELECT*,
    ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num  #partion by every column to ensure it is a full row duplicate
FROM layoffs_copy;

SELECT *
FROM layoffs_copy2
WHERE row_num>1;   

SET SQL_SAFE_UPDATES = 0; #Disable safe mode so that it can allow me to delete or update a table 

DELETE
FROM layoffs_copy2
WHERE row_num>1;   #It deletes the duplicates and retains only one



	-- 2. Standardizing Data
SELECT TRIM(company) AS Company_name
FROM layoffs_copy2;    #Removes white space from left and right side of the entry in that column
UPDATE layoffs_copy2
SET company = TRIM(Company); 

SELECT DISTINCT industry
FROM layoffs_copy2
ORDER BY 1; 
SELECT *
FROM layoffs_copy2
WHERE industry LIKE 'Crypto%';
UPDATE layoffs_copy2
SET industry = 'crypto'
WHERE industry LIKE 'crypto%'; 

SELECT DISTINCT country
FROM layoffs_copy2
ORDER BY 1;  
UPDATE layoffs_copy2
SET country = 'United States'
WHERE country LIKE 'United States%'; 

--Change date column datatype to date
SELECT `date`, 
STR_TO_DATE(`date`, '%m/%d/%Y') AS converted_date  
FROM layoffs_copy2;
UPDATE layoffs_copy2
SET `date`=  STR_TO_DATE(`date`, '%m/%d/%Y'); 


ALTER TABLE layoffs_copy2
MODIFY COLUMN `date`  DATE;

SELECT*
FROM layoffs_copy2;
 
	-- 3. Null values or blank values 
SELECT *
FROM layoffs_copy2
WHERE company IS NULL OR company=''
OR location IS NULL OR location=''  
OR industry IS NULL OR industry=''
OR total_laid_off IS NULL OR total_laid_off=''
OR percentage_laid_off IS NULL OR percentage_laid_off=''
OR  `date` IS NULL
OR stage IS NULL OR stage=''
OR country IS NULL OR country=''
OR funds_raised_millions IS NULL OR funds_raised_millions='';   #returned too many rows

SELECT *
FROM layoffs_copy2
WHERE industry IS NULL OR industry='';  #I saw that there were null and blanks for industry column i have to do something about it

SELECT *
FROM layoffs_copy2
WHERE company = 'Airbnb' 
   OR company = 'Bally''s Interactive' 
   OR company = 'Carvana' 
   OR company = 'Juul'; 
   
UPDATE layoffs_copy2
SET 
    industry = CASE 
        WHEN company = 'Airbnb' THEN 'Travel'
        WHEN company = 'Bally''s Interactive' THEN 'unknown'
        WHEN company = 'Carvana' THEN 'Transportation'
        WHEN company = 'Juul' THEN 'Consumer'
        ELSE industry
    END;

SELECT *
FROM layoffs_copy2
WHERE total_laid_off is NULL OR total_laid_off= ''
AND percentage_laid_off is NULL OR percentage_laid_off= ''
AND funds_raised_millions is NULL OR funds_raised_millions= '';


SELECT *
FROM layoffs_copy2
WHERE total_laid_off is NULL AND percentage_laid_off IS NULL AND funds_raised_millions IS NULL;  #we have to remove such rows because they dont make any sense

---having both total laid off and % laid off as null is not usefull to our analysis so we should just get rid of such rows
DELETE
FROM layoffs_copy2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

	# 4. Removing unnecessary columns
#We have to remove the row number column now 
ALTER TABLE layoffs_copy2
DROP COLUMN row_num;

SELECT *
FROM layoffs_copy2;

       --Explotary Data Analysis

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_copy2;


--which companies laid off all their employees ordered from the ones with the highest number of employees
SELECT *
FROM layoffs_copy2
WHERE percentage_laid_off=1
ORDER BY total_laid_off DESC;

--Which companies had the highest number of lay offs
SELECT company, SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY company
ORDER BY 2 DESC;

--I want to see the period or time within which the data was collected
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_copy2;

--which industry was most affected
SELECT industry, SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY industry
ORDER BY 2 DESC;

--which country was most affected
SELECT country, SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY country
ORDER BY 2 DESC;

--the stages of companies most affected
SELECT stage, SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY stage
ORDER BY 2 DESC;

SELECT MONTH(`date`) AS Month_column
FROM layoffs_copy2;

--I want to see the comanies and toatl layoffs for each year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY company, YEAR(`date`)
ORDER BY company;

--I want to rank based on the the number they laid off
WITH Company_Year(company,years,total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY company, YEAR(`date`)
)
SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL;


--I want to see the top 5 companies per year
WITH Company_Year(company,years,total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS          #I am adding  another CTE
(SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <=5;


