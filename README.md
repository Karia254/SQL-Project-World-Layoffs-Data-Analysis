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
We identified and removed duplicate rows based on columns like company, location, industry, and others. A new column row_num was added to help with this identification and deletion.

```sql
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country) AS row_num
FROM layoffs_copy;
