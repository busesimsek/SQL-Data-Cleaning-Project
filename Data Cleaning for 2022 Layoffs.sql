-- ==============================================
-- Project Title: Data Cleaning for 2022 Layoffs
-- Author: Buse Şimşek
-- Date: 27 November 2024
-- Description: This project performs data cleaning to prepare the dataset for analysis.
-- Tools: MySQL
-- ==============================================

/* 
Details: 
- Dataset: https://www.kaggle.com/datasets/swaptr/layoffs-2022
- Objectives: 
  1. Handle missing or null values.
  2. Remove duplicate records.
  3. Ensure consistent formatting for dates, strings, etc.
  4. Standardize column values.
- Outputs: A clean and standardized dataset ready for analysis.
*/

-- Let's get started!

-- Firstly, I imported the raw data into the table `layoffs`
SELECT *
FROM layoffs; -- The dataset originally has 3887 rows


-- Part 1: Remove Duplicates:
-- - I created a staging table to work with the data
-- - I copied all data from the original `layoffs` table into `layoffs_staging`

-- I created a staging table to preserve the original dataset and avoid modifying raw data directly
CREATE TABLE layoffs_staging
LIKE layoffs; -- Created a structure identical to the original table

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs; -- I copied all data into the staging table

-- I identified duplicates as follows:

-- I used ROW_NUMBER() to assign a unique identifier to duplicate rows
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
FROM layoffs_staging;

-- I checked for duplicate rows (row numbers greater than 1)
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1; -- This query identified duplicates in the dataset

-- I found two duplicates for 'Beyond Meat' and 'Cazoo'

-- Here, I found duplicates for a specific company 'Beyond Meat'
SELECT *
FROM layoffs_staging
WHERE company = 'Beyond Meat'; -- Beyond Meat had 4 rows for what should have been 3 unique rows

-- Here, I found duplicates for a specific company 'Cazoo'
SELECT *
FROM layoffs_staging
WHERE company = 'Cazoo'; -- Cazoo had 3 rows for what should have been 2 unique rows

-- I removed duplicates as follows:

-- I created a table to hold cleaned data
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2; -- Now I have an empty table

-- I inserted data into the new table, including a row number for duplicates
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
FROM layoffs_staging;

-- I checked for duplicates in the new table
SELECT *
FROM layoffs_staging2
WHERE row_num > 1; -- This identified all duplicate rows in the new table

-- I deleted duplicates (rows with row_num > 1)
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- I verified that duplicates were removed
SELECT *
FROM layoffs_staging2
WHERE row_num > 1; -- We have no data shown because we deleted all duplicates!

-- After removing duplicates, 3885 rows remained in the dataset


-- Part 2: Standardize Data
-- I identified and fixed issues in the dataset

-- I checked for extra spaces in the 'company' column and removed them
SELECT company, TRIM(company)
FROM layoffs_staging2; -- There was no visible error but I standardized it just in case 

UPDATE layoffs_staging2
SET company = TRIM(company); -- Fixed possible extra spaces between words in the 'company' column

-- I checked for blank values in the 'industry' column
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1; -- Found blank values, but no similar values to merge, so they remained unique

-- I checked the 'location' column
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1; -- Found blank values. Also, some locations are misspelled

UPDATE layoffs_staging2
SET location = 'Fredericton'
WHERE location = 'Ferdericton'; -- Corrected the misspelled location for "Fredericton"

UPDATE layoffs_staging2
SET location = 'Gdynia'
WHERE location = 'Gydnia'; -- Corrected the misspelled location for "Gdynia"

UPDATE layoffs_staging2
SET location = 'Ra\'anana'
WHERE location = 'Ra\'anan'; -- Corrected the misspelled location for "Ra'anana"

UPDATE layoffs_staging2
SET location = 'Shenzhen'
WHERE location = 'Shenzen'; -- Corrected the misspelled location for "Shenzhen"

-- I checked the 'country' column
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1; -- Found two country names to be standardized: "UAE" and "United Arab Emirates"

-- I checked related columns to see the most used version of the country name
SELECT *
FROM layoffs_staging2
WHERE country = 'UAE' OR country = 'United Arab Emirates'; -- It is mostly used as "United Arab Emirates"

UPDATE layoffs_staging2
SET country = 'United Arab Emirates'
WHERE country = 'UAE'; -- Standardized the country name for "United Arab Emirates"

-- The 'date' column was in text format, so I standardized it
SELECT `date`,
STR_TO_DATE(`date`, '%Y-%m-%d')
FROM layoffs_staging2;

-- I updated the 'date' column to standardize the format
UPDATE layoffs_staging2
SET `date`= STR_TO_DATE(`date`, '%Y-%m-%d');

-- I modified the 'date' column to change its data type from text to date
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE; -- Changed the 'date' column from string to date format

-- The 'total_laid_off' column was in text format, so I converted it to an integer
SELECT total_laid_off, 
CAST(total_laid_off AS UNSIGNED) 
FROM layoffs_staging2;

-- I updated the 'total_laid_off' column to store numeric values properly
UPDATE layoffs_staging2 
SET total_laid_off = CAST(total_laid_off AS UNSIGNED);

-- I modified the 'total_laid_off' column to change its data type from text to integer
ALTER TABLE layoffs_staging2 
MODIFY COLUMN total_laid_off INT; -- Changed the 'total_laid_off' column from string to integer format

-- I checked for empty strings in the 'funds_raised' column
UPDATE layoffs_staging2
SET funds_raised = NULL
WHERE funds_raised = ''; -- Replaced empty strings with NULL in the 'funds_raised' column

-- I rounded the values in the 'funds_raised' column to the nearest integer
UPDATE layoffs_staging2
SET funds_raised = ROUND(CAST(funds_raised AS DECIMAL(10,2))); -- Rounded the 'funds_raised' column to the nearest integer

-- I converted the 'funds_raised' column to integer
UPDATE layoffs_staging2
SET funds_raised = CAST(funds_raised AS UNSIGNED); -- Converted the 'funds_raised' column to integer

-- I modified the 'funds_raised' column to change its data type to integer
ALTER TABLE layoffs_staging2 
MODIFY COLUMN funds_raised INT; -- Changed the 'funds_raised' column from string to integer format

-- I verified the cleaned data
SELECT *
FROM layoffs_staging2; -- All changes should now be applied, with the data standardized


-- Part 3: Look at Null Values
-- I identified and handled null values in the 'industry', 'total_laid_off', and 'percentage_laid_off' columns
-- The null values were not found using IS NULL because they appeared as empty strings (''), so I updated '' to NULL for each column.

-- I checked for null or empty string values in the 'industry' column
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ''; -- Found null or empty value for 'Appsmith'

-- I checked for records with a null or empty 'industry' value for the company 'Appsmith'
SELECT *
FROM layoffs_staging2
WHERE company = 'Appsmith'; -- Found no other records besides the null industry for 'Appsmith', so I couldn't update it

-- I checked for null or empty string values in the 'total_laid_off' column
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL OR total_laid_off = ''; -- Found null or empty values

-- I updated the 'total_laid_off' column, replacing empty strings with NULL
UPDATE layoffs_staging2
SET total_laid_off = NULL
WHERE total_laid_off = '';

-- I checked for null or empty string values in the 'percentage_laid_off' column
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off IS NULL
OR percentage_laid_off = ''; -- Found null or empty values 

-- I updated the 'percentage_laid_off' column, replacing empty strings with NULL
UPDATE layoffs_staging2
SET percentage_laid_off = NULL
WHERE percentage_laid_off = '';

-- I verified that all empty strings were replaced with NULL
SELECT *
FROM layoffs_staging2; -- Now, all values appear as NULL where applicable


-- Part 4: Remove Any Columns or Rows
-- I removed rows where both 'total_laid_off' and 'percentage_laid_off' were NULL 
-- and dropped the 'row_num' column used for detecting duplicates.

-- I identified rows where both 'total_laid_off' and 'percentage_laid_off' were NULL
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; -- 637 rows returned

-- I deleted the identified rows where both 'total_laid_off' and 'percentage_laid_off' were NULL
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- I verified that the rows were removed
SELECT *
FROM layoffs_staging2;

-- After deleting the identified rows, 3248 rows remained in the dataset

-- I dropped the 'row_num' column that was created earlier to identify duplicates
ALTER TABLE layoffs_staging2
DROP COLUMN row_num; -- I deleted the 'row_num' column that was used for detecting duplicates in the first place

-- Final check: I ensured that all necessary columns and rows were properly removed and the dataset was cleaned up!
SELECT *
FROM layoffs_staging2;