USE HousingData;
SELECT * FROM sheet1;
-- cleaning data in sql


-- standardize date format
SELECT SaleDate , CONVERT(DATE, SaleDate) as DateOfSale
FROM sheet1;

UPDATE sheet1
SET SaleDate = CONVERT(DATE, SaleDate);

ALTER TABLE sheet1
ADD SaleDateConverted DATE;
UPDATE sheet1
SET SaleDateConverted = CONVERT(DATE, SaleDate);

SELECT SaleDate , SaleDateConverted
FROM sheet1;



-- populate Property address data
SELECT * FROM sheet1
WHERE PropertyAddress is null;

SELECT a.[UniqueID ],a.ParcelID, a.PropertyAddress,b.[UniqueID ],b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM sheet1 a
JOIN sheet1 b
ON a.ParcelID = b.ParcelID
AND  a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM sheet1 a
JOIN sheet1 b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null





-- Breaking out address into individual columns (Address, City, State)
SELECT *
FROM sheet1;

SELECT SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress) -1) as AddressDoorNo,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as AddressCity
FROM sheet1

ALTER TABLE sheet1
ADD AddressDoorNO NVARCHAR(255)

UPDATE sheet1
SET AddressDoorNO = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress) -1);


ALTER TABLE sheet1
ADD AddressCity NVARCHAR(255)

UPDATE sheet1
SET AddressCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) ;





-- owners address parsing

SELECT OwnerAddress
FROM sheet1


SELECT
PARSENAME (REPLACE(OwnerAddress,',','.'),3),
PARSENAME (REPLACE(OwnerAddress,',','.'),2),
PARSENAME (REPLACE(OwnerAddress,',','.'),1)
FROM sheet1

ALTER TABLE sheet1
ADD ownersplitaddress NVARCHAR(255)
UPDATE sheet1
SET ownersplitaddress = PARSENAME (REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE sheet1
ADD ownersplicity NVARCHAR(255)
UPDATE sheet1
SET  ownersplicity = PARSENAME (REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE sheet1
ADD ownersplitstate NVARCHAR(255)
UPDATE sheet1
SET ownersplitstate = PARSENAME (REPLACE(OwnerAddress,',','.'),1)

SELECT * 
FROM sheet1;





-- Change Y and N to YES and NO in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM sheet1
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM sheet1

UPDATE sheet1
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM sheet1






--Remove Duplicates , proceed with caution, not necessary to delete data always
WITH RowNumCTE AS (
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			PropertyAddress,
			SaleDate,
			SalePrice
			ORDER BY 
			UniqueId
) row_num
FROM sheet1
--ORDER BY ParcelId
)
SELECT *  -- replace select * with DELETE to delete the duplicate data
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress
;


-- delete unused columns

ALTER TABLE sheet1
DROP COLUMN PropertyAddress, OwnerAddress;

SELECT * FROM sheet1;
