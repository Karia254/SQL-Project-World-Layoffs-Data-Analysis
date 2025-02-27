## Worldwide Layoffs: Data Cleaning & EDA Using SQL
### Project Overview
This project involves cleaning and analyzing layoffs data to identify trends, patterns, and insights regarding layoffs in various companies, industries and countries. The goal is to examine factors such as total layoffs, percentage of layoffs, and industry impact to help understand the dynamics of workforce reductions.

### Data Dictionary
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

 ### Data Cleaning Process
The data cleaning process was performed in the following steps:

1.**Removing Duplicates**

I identified and removed duplicate rows based on columns like company, location, industry, and others. A new column row_num was added to help with this identification and deletion.

```sql
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country) AS row_num
FROM layoffs_copy;
DELETE
FROM layoffs_copy2
WHERE row_num>1;   #It deletes the duplicates and retains only one

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
After cleaning the data, I dropped the row_num column as it was no longer needed.
```sql
ALTER TABLE layoffs_copy2
DROP COLUMN row_num;
```

### Exploratory Data Analysis (EDA)
The analysis focused on understanding the data distribution and identifying trends in layoffs across companies, industries, and countries.

1.**Total Layoffs and Percentage**
I calculated the maximum values for both total_laid_off and percentage_laid_off.
```sql
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_copy2;
```
**Results**: The maximum total layoffs recorded is 12,000 and the highest percentage laid off is 100%.

2.**Companies with the Highest Number of Layoffs**
I identified the companies that laid off the highest number of employees.
```sql
SELECT company, SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY company
ORDER BY 2 DESC;
```
**Results**: The top 3 companies with highest number of layoffs were;
- Amazon: 18,150 layoffs
- Google: 12,000 layoffs
- Meta: 11,000 layoffs

3.**Companies that Laid Off All Employees**
I queried for companies that laid off all their employees, ordering by the total number of layoffs.
```sql
SELECT *
FROM layoffs_copy2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;
```
**Results**: This companies made 100% layoffs; Katerra, Butler Hospitality, Deliv, Jump, SEND, HOOQ, Stoqo and Stay Alfred


4.**The stages of the companies most affected**
```sql
SELECT stage, SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY stage
ORDER BY 2 DESC;
```
**Results**:The most affected companies are at **Post-IPO** stage with **204,132 layoffs** while the least affected companies are at **Subsidiary** stage with a total of **1,094 layoffs**

5.**Industry most affected by layoffs**
```sql
SELECT industry, SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY industry
ORDER BY 2 DESC;
```

**Results**: **Consumer** industry was the most affected with **45,182 layoffs** followed by retail industry with 43,613 and the least affected is **manufacturing** industry with **20 layoffs**.

6.**Country most affected by layoffs**
```sql
SELECT country, SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY country
ORDER BY 2 DESC;
```

**Results**: The **United states** is the most affected with a total of **256,559 layoffs** while the least affected country was **Poland** with **25 layoffs**


