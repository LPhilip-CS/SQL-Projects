-- Housing portfolio project to showcase data cleaning in SQL queries
-- Lijo Philip (2/21/23)
-- Housing in Nashville Tennesee

SELECT *
FROM HousingProject..HousingDemographics


-- Standardize date format (removing time stamp)

SELECT SaleDateFormatted, CONVERT(DATE, SaleDate)
FROM HousingProject..HousingDemographics

--Update HousingDemographics
--Set SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE HousingDemographics
ADD SaleDateFormatted DATE;

Update HousingDemographics
SET SaleDateFormatted = CONVERT(DATE, SaleDate)

-- Filling missing property addresses that are Null

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL (A.PropertyAddress, B.PropertyAddress)
FROM HousingProject..HousingDemographics AS A
Join HousingProject..HousingDemographics AS B
ON A.ParcelID = B.ParcelID and A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null


Update A
SET PropertyAddress = ISNULL (A.PropertyAddress, B.PropertyAddress)
FROM HousingProject..HousingDemographics AS A
Join HousingProject..HousingDemographics AS B
ON A.ParcelID = B.ParcelID and A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

-- Separating PropertyAddress into individual columns (Address, City) using SUBSTRING

SELECT PropertyAddress
FROM HousingProject..HousingDemographics

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM HousingProject..HousingDemographics

ALTER TABLE HousingDemographics
ADD PropertySplitAddress NVARCHAR(50);

Update HousingDemographics
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE HousingDemographics
ADD PropertySplitCity NVARCHAR(50);

Update HousingDemographics
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- Separating OwnerAddress into individual columns (Address, City, State) using PARSING

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM HousingProject..HousingDemographics

ALTER TABLE HousingDemographics
ADD OwnerSplitAddress NVARCHAR(50);

Update HousingDemographics
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE HousingDemographics
ADD OwnerSplitCity NVARCHAR(50);

Update HousingDemographics
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE HousingDemographics
ADD OwnerSplitState NVARCHAR(50);

Update HousingDemographics
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

-- Changing SoldAsVacant column Y & N to Yes and No respectively

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM HousingProject..HousingDemographics
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant)

SELECT SoldAsVacant,
CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM HousingProject..HousingDemographics

Update HousingDemographics
SET SoldAsVacant = CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

-- Remove duplicates from HousingDemographics table

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS Row_Num
FROM HousingProject..HousingDemographics
)

DELETE
FROM RowNumCTE
WHERE Row_Num > 1


-- Delete unused or redundant columns

ALTER TABLE HousingDemographics
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate


SELECT *
FROM HousingProject..HousingDemographics