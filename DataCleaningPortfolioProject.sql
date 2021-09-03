--
-- Cleaning data from Excel Sheet (Nashville Housing Data)
--

Select *
	From PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------
-- Standardize Date Format

Select SaleDate, CONVERT(Date, SaleDate)
	From PortfolioProject..NashvilleHousing

	ALTER TABLE NashvilleHousing
	Add SaleDateConverted Date;

	UPDATE NashvilleHousing
	SET SaleDateConverted = CONVERT(Date, SaleDate)


--------------------------------------------------------------------------------------------------------
-- Populate Property Address Data (Fix the NULLS)

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
	From PortfolioProject..NashvilleHousing a
	JOIN PortfolioProject..NashvilleHousing b
		on a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is null

	UPDATE a
	SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
	From PortfolioProject..NashvilleHousing a
	JOIN PortfolioProject..NashvilleHousing b
		on a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is null
	

--------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
	From PortfolioProject..NashvilleHousing

Select
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
	From PortfolioProject..NashvilleHousing

	ALTER TABLE NashVilleHousing
	Add PropertySplitAddress NVARCHAR(255);

	UPDATE NashvilleHousing
	SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

	ALTER TABLE NashVilleHousing
	Add PropertySplitCity NVARCHAR(255)
	
	UPDATE NashvilleHousing
	Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
	
-- Owner Address Parsing 
-- Example of Owner Address 2004  CEDAR LN, NASHVILLE, TN

Select OwnerAddress
	From PortfolioProject..NashvilleHousing

Select
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) as Address,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) as City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) as State
	From PortfolioProject..NashvilleHousing

	ALTER TABLE NashVilleHousing
	Add OwnerSplitAddress NVARCHAR(255);

	UPDATE NashvilleHousing
	SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

	ALTER TABLE NashVilleHousing
	Add OwnerSplitCity NVARCHAR(255)
	
	UPDATE NashvilleHousing
	Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

	ALTER TABLE NashVilleHousing
	Add OwnerSplitState NVARCHAR(255)
	
	UPDATE NashvilleHousing
	Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
		

--------------------------------------------------------------------------------------------------------
-- Change Yes and No to Y and N in "Sold as Vacant" field
-- The column currently has 4 distinct entries (Yes, No, Y, and N)

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
	From PortfolioProject..NashvilleHousing
	Group by SoldAsVacant
	order by 2

Select SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Yes' THEN 'Y'
		 WHEN SoldAsVacant = 'No' THEN 'N'
		 ELSE SoldAsVacant
		 END
	From PortfolioProject..NashvilleHousing
	
	UPDATE NashvilleHousing
	SET SoldAsVacant =
	CASE WHEN SoldAsVacant = 'Yes' THEN 'Y'
		 WHEN SoldAsVacant = 'No' THEN 'N'
		 ELSE SoldAsVacant
		 END
	From PortfolioProject..NashvilleHousing
			

--------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS 
(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) row_num
	From PortfolioProject..NashvilleHousing
)
DELETE
	From RowNumCTE
	Where row_num > 1
				

--------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

Select *
	From PortfolioProject..NashvilleHousing

	ALTER TABLE NashvilleHousing
	DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

	ALTER TABLE NashvilleHousing
	DROP COLUMN SaleDate


--------------------------------------------------------------------------------------------------------
-- For Visualization
--------------------------------------------------------------------------------------------------------
-- Looking at Average Sale Price on a given Date

--1.
Select SaleDateConverted, AVG(SalePrice)
	From PortfolioProject..NashvilleHousing
	Group by SaleDateConverted
	order by 1


--------------------------------------------------------------------------------------------------------
-- Looking at the number of houses built each year

--2.
Select YearBuilt, COUNT(YearBuilt) as NumberBuilt
	From PortfolioProject..NashvilleHousing
	Where YearBuilt is not null
	Group by YearBuilt
	order by YearBuilt

Select *
	From PortfolioProject..NashvilleHousing

