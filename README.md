# Nashville Housing Data Cleaning Project Detailed Explanation of Key SQL Techniques
By: Mahmoud Ghanem

## Introduction
The Nashville Housing Data Cleaning Project aims to ensure the quality and usability of a dataset containing housing information for Nashville. This document provides a detailed explanation of the key SQL techniques and methods used to clean and preprocess the data, showcasing the benefits of each step in preparing the data for analysis.
Objectives
1. Data Cleaning: Identify and correct inaccuracies and inconsistencies in the dataset to ensure it is accurate and reliable.
2. Data Transformation: Convert raw data into a structured format suitable for analysis.
3. Preparation for Analysis: Prepare the data for various analytical and machine learning models for future studies.

## Data Overview
The dataset contains housing information for Nashville and is provided in both CSV and Excel formats. The data includes fields such as property addresses, sale dates, prices, and other relevant details crucial for understanding the housing market.
Methodology and Code Explanation

1. Importing Data
To begin, we imported all records from the NashvilleHousing table to understand the data structure and its contents. This initial step is crucial for gaining insights into the data and planning subsequent cleaning operations.
```sql
SELECT *
FROM `NashvilleHousing`;
```

2. Formatting Dates
Standardizing date formats is essential for consistency. The following SQL snippet reformats the SaleDate field into a standard date format.
```sql
UPDATE NashvilleHousing
SET SaleDate = STR_TO_DATE(SaleDate, '%M %e, %Y');
```
![image](https://github.com/mmaghanem/sql_cleaning/assets/109820939/f4225ead-d453-46b2-930f-be1fb62067f7)


3. Populating Missing Addresses
Missing data, especially in critical fields like PropertyAddress, can lead to incomplete analysis. The SQL code below fills in missing addresses by leveraging existing data with the same ParcelID.
```sql
-- Identify and fill missing Property Address data
SELECT a.UniqueID, a.ParcelID, a.PropertyAddress, b.UniqueID, b.ParcelID, b.PropertyAddress,
       IF(a.PropertyAddress = '', b.PropertyAddress, a.PropertyAddress) as address
FROM `NashvilleHousing` a
JOIN `NashvilleHousing` b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress = '';

UPDATE `NashvilleHousing` a
JOIN `NashvilleHousing` b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IF(a.PropertyAddress = '', b.PropertyAddress, a.PropertyAddress)
WHERE a.PropertyAddress = '';
```
![image](https://github.com/mmaghanem/sql_cleaning/assets/109820939/4cbdd146-7f8d-4a95-91d2-34bde34e56c1)


4. Breaking Down Address Components
For more detailed analysis, it’s beneficial to break down composite fields like PropertyAddress into individual components. The SQL code below splits the address into separate parts such as street address and city.
```sql
-- Extracting individual parts of the address (Address, City)
SELECT SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
       SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress)) AS City
FROM `NashvilleHousing`;

ALTER TABLE `NashvilleHousing`
ADD PropertSplitAddress NVARCHAR(255);

UPDATE `NashvilleHousing`
SET PropertSplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);
```
![image](https://github.com/mmaghanem/sql_cleaning/assets/109820939/5b0cec5e-f2ac-4060-b120-fe4f384e6f6c)

5. Remove Duplicate
Removing duplicte data point (Carefully) to avoid inflate the numbers
```WITH row_num AS (
SELECT *,
		row_number() OVER (partition by 
        ParcelID,
        PropertyAddress,
        SalePrice,
        SaleDate,
        LegalReference
        ORDER BY UniqueID) as row_num
FROM `NashvilleHousing`
ORDER BY ParcelID DESC
)
SELECT COUNT(*)
FROM row_num
WHERE row_num > 1
ORDER BY ParcelID;

DROP TABLE IF EXISTS row_num;
CREATE TEMPORARY TABLE row_num AS
SELECT *,
    ROW_NUMBER() OVER (PARTITION BY 
        ParcelID,
        PropertyAddress,
        SalePrice,
        SaleDate,
        LegalReference
        ORDER BY UniqueID) AS row_num
FROM `NashvilleHousing`
ORDER BY ParcelID DESC;

DELETE t1
FROM `NashvilleHousing` t1
JOIN row_num t2 ON t1.UniqueID = t2.UniqueID
WHERE t2.row_num > 1;
![image](https://github.com/mmaghanem/sql_cleaning/assets/109820939/4c30df74-3bfc-41e7-90df-535966232c1b)


## Key Findings and Benefits
The cleaned dataset provides a reliable foundation for further analysis, uncovering patterns and trends in the Nashville housing market. The data cleaning process addressed issues such as missing values, inconsistent formats, and provided a structured format that supports accurate and insightful analysis.

## Conclusion
This project sets the foundation for deeper exploration and understanding of the Nashville housing market. By ensuring the data is clean and structured, subsequent analyses will be more accurate and insightful, driving better decision-making in the housing sector.

