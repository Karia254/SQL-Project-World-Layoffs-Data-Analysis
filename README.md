# Worldwide Layoffs: Data Cleaning & EDA Using SQL
## Project Overview
This project involves cleaning and analyzing layoffs data to identify trends, patterns, and insights regarding layoffs in various companies, industries, and countries. The goal is to examine factors such as total layoffs, percentage of layoffs, and industry impact to help understand the dynamics of workforce reductions.

## Data Dictionary
Here is a list of the columns in the layoffs_copy2 table:

- **company (TEXT)**: The name of the company.
- **location (TEXT)**: The location of the company.
- **industry (TEXT)**: The industry of the company.
- **total_laid_off (INT)**: The total number of employees laid off.
- **percentage_laid_off (TEXT)**: The percentage of employees laid off.
- **date (DATE)**: The date when layoffs were reported.
- **stage (TEXT)**: The stage of the company (e.g., ongoing, completed).
- **country (TEXT)**: The country where the company is located.
- **funds_raised_millions (INT)**: The funds raised by the company (in millions).

 ## Data Cleaning Process
The data cleaning process was performed in the following steps:

1.**Removing Duplicates**

I identified and removed duplicate rows based on columns like company, location, industry, and others. A new column row_num was added to help with this identification and deletion.

```sql
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country) AS row_num
FROM layoffs_copy;
```

2.**Handling Null Values**

I identified and handled null or empty values, particularly in columns like industry, company, total_laid_off, and percentage_laid_off. Rows with missing critical data were deleted.
```sql
DELETE
FROM layoffs_copy2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
```

3.**Standardizing Data**
Data was standardized to ensure uniformity across different columns such as company, industry, and country. For instance, I replaced variations like 'United States' and 'United States.' with a single standard value, 'United States'.
```sql
SELECT DISTINCT country
FROM layoffs_copy2
ORDER BY 1;  #United States and United States. is same country but is recorded as different country
UPDATE layoffs_copy2
SET country = 'United States'
WHERE country LIKE 'United States%'; 
```
**Removing inconsistencies in industry column**
```sql
SELECT DISTINCT industry
FROM layoffs_copy2
ORDER BY 1;  #jsut to see if there is any issue do this on other columns, from these i saw an issue with country column as well
SELECT *
FROM layoffs_copy2
WHERE industry LIKE 'Crypto%';
UPDATE layoffs_copy2
SET industry = 'crypto'
WHERE industry LIKE 'crypto%';
```
**Trimming Whitespace for Data Consistency**
```sql
UPDATE layoffs_copy2
SET company = TRIM(company);
```

4.**Removing Unnecessary Columns**
After cleaning the data, we dropped the row_num column as it was no longer needed.
```sql
ALTER TABLE layoffs_copy2
DROP COLUMN row_num;
```


