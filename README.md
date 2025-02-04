# Data Cleaning for 2022 Layoffs

**Author:** Buse Şimşek  
**Date:** November 27, 2024  
**Tools:** MySQL  

## Overview

This project focuses on cleaning and preparing a dataset of layoffs in 2022 for further analysis. The dataset, originally from Kaggle, was imported into MySQL, cleaned, and standardized to ensure consistency and accuracy for potential analysis.

### Dataset

- **Original Dataset:** [Layoffs 2022 Dataset on Kaggle](https://www.kaggle.com/datasets/swaptr/layoffs-2022)
- **Raw Data:** [layoffs.json](https://github.com/busesimsek/SQL-Data-Cleaning-Project/blob/main/Dataset/layoffs.json)(imported into MySQL)
- **Cleaned Data:** [final_cleaned_data.csv](https://github.com/busesimsek/SQL-Data-Cleaning-Project/blob/main/final_cleaned_data.csv) (final output after cleaning)

---

## Objectives

1. Handle missing or null values.
2. Remove duplicate records.
3. Ensure consistent formatting for dates, strings, and numerical values.
4. Standardize column values for better analysis.

---

## Data Cleaning Process

The data cleaning was done in multiple phases, as outlined below:

### 1. **Importing the Raw Data**
- The raw data was first imported into a MySQL table `layoffs` from [layoffs.json](https://github.com/busesimsek/SQL-Data-Cleaning-Project/blob/main/Dataset/layoffs.json). The original dataset contained 3887 rows.

### 2. **Removing Duplicates**
- A staging table `layoffs_staging` was created to preserve the original data. Using the `ROW_NUMBER()` function, duplicates were identified and removed based on specific columns (company, location, total laid off, etc.).
- Two duplicates were identified for 'Beyond Meat' and 'Cazoo' and were successfully removed.
- After removing duplicates, the dataset contained 3885 rows.

### 3. **Standardizing Data**
- **Whitespace Cleanup:** Removed extra spaces from text columns (e.g., `company`).
- **Misspelled Locations:** Corrected common misspellings in the `location` column (e.g., "Ferdericton" → "Fredericton").
- **Country Standardization:** Unified variations of country names (e.g., "UAE" → "United Arab Emirates").
- **Date Formatting:** Converted the `date` column from text to the proper `DATE` type.
- **Numeric Conversions:** Converted the `total_laid_off` and `funds_raised` columns from text to integers, rounding where necessary.

### 4. **Handling Null Values**
- Null values in key columns (`industry`, `total_laid_off`, `percentage_laid_off`) were handled by replacing empty strings with NULL values.
- Empty rows, where both `total_laid_off` and `percentage_laid_off` were NULL, were removed. This reduced the dataset size to 3248 rows.

### 5. **Final Cleaned Dataset**
- The final cleaned dataset, now with standardized data, was exported to [final_cleaned_data.csv](https://github.com/busesimsek/SQL-Data-Cleaning-Project/blob/main/final_cleaned_data.csv) for further use in analysis.

---

## How to Use

### Prerequisites
1. MySQL or any compatible database system.
2. The dataset files ([layoffs.json](https://github.com/busesimsek/SQL-Data-Cleaning-Project/blob/main/Dataset/layoffs.json), [layoffs.csv](https://github.com/busesimsek/SQL-Data-Cleaning-Project/blob/main/Dataset/layoffs.csv), [Data Cleaning for 2022 Layoffs.sql](https://github.com/busesimsek/SQL-Data-Cleaning-Project/blob/main/Data%20Cleaning%20for%202022%20Layoffs.sql), and [final_cleaned_data.csv](https://github.com/busesimsek/SQL-Data-Cleaning-Project/blob/main/final_cleaned_data.csv)).

### Steps to Run
1. **Set up the MySQL database:**
   - Import `layoffs.json` into the MySQL database using the provided SQL script.
   - Create necessary tables (`layoffs`, `layoffs_staging`, `layoffs_staging2`).

2. **Execute the Cleaning SQL Script:**
   - Run the `Data Cleaning for 2022 Layoffs.sql` script to perform the data cleaning steps. This script includes commands for:
     - Removing duplicates.
     - Standardizing data formats.
     - Handling missing values.
     - Dropping unnecessary columns.

3. **Output:**
   - After executing the SQL script, the cleaned dataset will be saved as `final_cleaned_data.csv`.

---

## Contributions

Feel free to fork the repository and contribute by suggesting improvements or submitting pull requests. This project is part of ongoing efforts to clean and analyze datasets for meaningful insights.

---

## Future Improvements

- Incorporating additional analysis to identify trends in layoffs across different industries or locations.
- Enhancing the data validation process to automatically detect and handle other potential anomalies in future datasets.

---

## Contact

For questions or feedback, feel free to reach out to me on GitHub or via email.
