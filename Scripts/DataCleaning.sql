SELECT *
FROM `NashvilleHousing`;

UPDATE NashvilleHousing
SET SaleDate = STR_TO_DATE(SaleDate, '%M %e, %Y');

-- Populate Property Address Data:
SELECT a.UniqueID, a.ParcelID, a.PropertyAddress, b.UniqueID, b.ParcelID, b.PropertyAddress, IF(a.PropertyAddress = '', b.PropertyAddress, a.PropertyAddress) as address
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

-- Breaking out Address Into Individual Columns (Address, City, State)
SELECT SUBSTRING(PropertyAddress, 1, LOCATE(',',PropertyAddress)-1) AS Address, 
SUBSTRING(PropertyAddress, LOCATE(',',PropertyAddress) + 1, length(PropertyAddress)) AS City
FROM `NashvilleHousing`;

ALTER TABLE `NashvilleHousing`
ADD PropertSplitAddress NVARCHAR(255);

UPDATE `NashvilleHousing`
SET PropertSplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',',PropertyAddress)-1);

ALTER TABLE `NashvilleHousing`
ADD PropertSplitCity NVARCHAR(255);

UPDATE `NashvilleHousing`
SET PropertSplitCity = SUBSTRING(PropertyAddress, LOCATE(',',PropertyAddress) + 1, length(PropertyAddress));

SELECT *
FROM `NashvilleHousing`;


SELECT OwnerAddress
FROM `NashvilleHousing`;

SELECT 
SUBSTRING_INDEX(OwnerAddress, ',', 1),
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
SUBSTRING_INDEX(OwnerAddress, ',', -1)
FROM `NashvilleHousing`;

ALTER TABLE `NashvilleHousing`
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE `NashvilleHousing`
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE `NashvilleHousing`
ADD OwnerSplitCity NVARCHAR(255);

UPDATE `NashvilleHousing`
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

ALTER TABLE `NashvilleHousing`
ADD OwnerSplitState NVARCHAR(255);

UPDATE `NashvilleHousing`
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

SELECT *
FROM `NashvilleHousing`;

-- Change Y & N to Yes & No in "Sold as vacant"

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM `NashvilleHousing`
GROUP BY 1;

WITH test AS (
    SELECT 
        SoldAsVacant,
        CASE 
            WHEN SoldAsVacant = 'Y' THEN 'Yes'
            WHEN SoldAsVacant = 'N' THEN 'No'
            ELSE SoldAsVacant
        END AS ModifiedSoldAsVacant
    FROM `NashvilleHousing`
)

SELECT DISTINCT(ModifiedSoldAsVacant), COUNT(ModifiedSoldAsVacant)
FROM test
GROUP BY 1;

UPDATE `NashvilleHousing`
SET SoldAsVacant = 
					CASE 
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END;

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM `NashvilleHousing`
GROUP BY 1;

-- Remove Duplicate(Carefully)

WITH row_num AS (
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

DROP TEMPORARY TABLE IF EXISTS row_num;

-- Delete Unused Columns

SELECT * 
FROM `NashvilleHousing`;

ALTER TABLE `NashvilleHousing`
DROP COLUMN PropertyAddress,
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict;





















