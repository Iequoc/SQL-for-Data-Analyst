-- DATA CLEANING -- Personal Project - Data Analyst

USE PortfolioProject

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format
SELECT SaleDate, CONVERT(DATE, SaleDate) AS SaleDateConverted
FROM PortfolioProject.dbo.NashvilleHousing
---------
UPDATE PortfolioProject.dbo.NashvilleHousing 
SET SaleDate = CONVERT(DATE, SaleDate)
---------
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate) 

SELECT SaleDateConverted, SaleDate
FROM NashvilleHousing

----------------------------

-- Populate Property Address Data
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY 1,2


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a 
JOIN NashvilleHousing b 
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a 
JOIN NashvilleHousing b 
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing


SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD Address NVARCHAR(255)

UPDATE NashvilleHousing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);


ALTER TABLE NashvilleHousing
ADD City NVARCHAR (255)

UPDATE NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

SELECT PropertyAddress, Address, City
FROM PortfolioProject.dbo.NashvilleHousing

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.' ), 3) AS OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress,',','.' ), 2) AS OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress,',','.' ), 1) AS OwnerSplitState
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR (255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.' ), 3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR (255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.' ), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR (255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.' ), 1)

SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM PortfolioProject.dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) as CountSoldAsVacant
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END
AS SoldAsVacantConverted
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END

-- Remove Duplicates

WITH RowNumberCTE AS (
    SELECT *, 
        ROW_NUMBER() OVER(
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SaleDate,
                         SalePrice,
                         LegalReference
                         
                         ORDER BY UniqueID
        )  Row_num
    FROM PortfolioProject.dbo.NashvilleHousing
    
)

-- DELETE
-- FROM RowNumberCTE
-- WHERE Row_num > 1


SELECT *
FROM RowNumberCTE
WHERE Row_num > 1

-- Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN  OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


