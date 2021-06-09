/*


Cleaning Data in SQL Queries


*/
USE PortfolioProject;
Go

SELECT *
FROM dbo.NashvilleHousing;
Go

-- Standardize Date Format
SELECT SaleDateConverted, CONVERT(Date,SaleDate) SaleDate2
FROM dbo.NashvilleHousing;
Go

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)
Go

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;
Go

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)
Go

-- Populate Property Address data
SELECT *
FROM dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;
Go

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;
Go

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;
Go

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM dbo.NashvilleHousing;
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID;
Go

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) Address
FROM dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);
Go

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )
Go

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);
Go

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))
Go

SELECT *
FROM NashvilleHousing;
Go

SELECT OwnerAddress
FROM NashvilleHousing;
Go

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing;
Go

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);
Go

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
Go

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);
Go

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
Go

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);
Go

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
Go

SELECT *
FROM NashvilleHousing
--WHERE OwnerAddress IS NOT NULL;
Go

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;
Go

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing;
Go

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
					    WHEN SoldAsVacant = 'N' THEN 'NO'
	                    ELSE SoldAsVacant
						END
Go

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From dbo.NashvilleHousing
--order by ParcelID
)
SELECT *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;
Go

Select *
From dbo.NashvilleHousing;
Go

-- Delete Unused Columns

Select *
From dbo.NashvilleHousing;
Go

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

