# Worldwide Layoffs: Data Cleaning & EDA Using SQL

## Project Overview
This project involves cleaning and analyzing layoffs data to identify trends, patterns, and insights regarding workforce reductions across companies, industries, and countries. The goal is to examine factors such as total layoffs, percentage of layoffs, and industry impact to better understand the dynamics of workforce reductions.

## Data Dictionary
The dataset contains the following columns:

| Column               | Description                                                                      |
|----------------------|----------------------------------------------------------------------------------|
| **company**             | Name of the company.                                                              |
| **location**            | Location of the company.                                                          |
| **industry**           | Industry of the company.                                                           |
| **total_laid_off**      | Total number of employees laid off.                                                |
| **percentage_laid_off** | Percentage of employees laid off.                                                  |
| **date**               | Date when layoffs were reported.                                                    |
| **stage**              | Stage of the company (e.g., Post-IPO, Seed).                                        |
| **country**            | Country where the company is located.                                               |
| **funds_raised_millions** | Funds raised by the company (in millions).                                       |

## Data Cleaning Process
The data cleaning process involved the following steps:

### 1. Removing Duplicates
Duplicate rows were identified and removed based on columns like company, location, industry, and others. A `row_num` column was added to assist in identifying duplicates.

```sql
WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY company, location, industry, total_laid_off, 
                            percentage_laid_off, `date`, stage, country, funds_raised_millions
           ) AS row_num  
    FROM layoffs_copy
)
DELETE FROM layoffs_copy 
WHERE (company, location, industry, total_laid_off, 
       percentage_laid_off, `date`, stage, country, funds_raised_millions) 
      IN (
          SELECT company, location, industry, total_laid_off, 
                 percentage_laid_off, `date`, stage, country, funds_raised_millions
          FROM duplicate_cte
          WHERE row_num > 1
      );
;
```

### 2. Handling Null Values
Null or empty values were addressed, particularly in columns like industry, company, total_laid_off, and percentage_laid_off. Rows with missing critical data were deleted.

```sql
-- Remove rows with missing critical data
DELETE
FROM layoffs_copy2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
```

### 3. Standardizing Data
Data was standardized to ensure uniformity across columns like company, industry, and country.

```sql
-- Standardize country names
UPDATE layoffs_copy2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Standardize industry names
UPDATE layoffs_copy2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Trim whitespace for consistency
UPDATE layoffs_copy2
SET company = TRIM(company);
```

### 4. Removing Unnecessary Columns
After cleaning, the `row_num` column was dropped as it was no longer needed.

```sql
ALTER TABLE layoffs_copy2
DROP COLUMN row_num;
```

## Exploratory Data Analysis (EDA)
The analysis focused on understanding the distribution of layoffs and identifying trends across companies, industries, and countries.

### 1. Total Layoffs and Percentage
```sql
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_copy2;
```
**Results:** The maximum total layoffs recorded is **12,000**, and the highest percentage laid off is **100%**.

### 2. Companies with the Highest Number of Layoffs
```sql
SELECT company, SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY company
ORDER BY 2 DESC;
```
**Results:** The top 3 companies with the highest layoffs are:
- **Amazon**: 18,150 layoffs
- **Google**: 12,000 layoffs
- **Meta**: 11,000 layoffs

### 3. Companies That Laid Off All Employees
```sql
SELECT *
FROM layoffs_copy2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;
```
**Results:** Companies like **Katerra, Butler Hospitality, and Deliv** laid off 100% of their employees.

### 4. Stages of Companies Most Affected
```sql
SELECT stage, SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY stage
ORDER BY 2 DESC;
```
**Results:** Companies at the **Post-IPO** stage were the most affected, with **204,132 layoffs**, while **Subsidiary** companies were the least affected, with **1,094 layoffs**.

### 5. Industries Most Affected by Layoffs
```sql
SELECT industry, SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY industry
ORDER BY 2 DESC;
```
**Results:** The **Consumer** industry was the most affected, with **45,182 layoffs**, followed by **Retail** with **43,613 layoffs**. The least affected was **Manufacturing**, with only **20 layoffs**.

### 6. Countries Most Affected by Layoffs
```sql
SELECT country, SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY country
ORDER BY 2 DESC;
```
**Results:** The **United States** was the most affected, with **256,559 layoffs**, while **Poland** was the least affected, with only **25 layoffs**.

## Key Insights
- **Top Companies:** Amazon, Google, and Meta had the highest number of layoffs, contributing significantly to the total layoffs.
- **Industries:** The **Consumer** and **Retail** industries were the most impacted, while **Manufacturing** was the least affected.
- **Stages:** Companies at the **Post-IPO** stage experienced the highest layoffs, indicating challenges in sustaining growth after going public.
- **Countries:** The **United States** had the highest number of layoffs, reflecting its large workforce and economic scale.
- **100% Layoffs:** Several companies, such as **Katerra** and **Butler Hospitality**, laid off 100% of their employees.

## Conclusion
This project highlights the significant impact of layoffs across companies, industries, and countries. The analysis reveals that **Post-IPO companies, the Consumer industry, and the United States** were the most affected. These insights can help stakeholders understand workforce reduction trends and make informed decisions to mitigate future layoffs.
