-- Housing dataset data cleaning
-- Author: Andy Shih
-- To execute each block, just select each block first and ctr+F9 to execute --
-- small trick: when there is a column name that has space in btw like "Unique ID", when selecting it, I can use SELECT "Unique ID" FROM ...

-- **** SaleDate **** --

-- Use UPDATE to change SaleDate to Date Format. In SQLite Studio, there is no Date data type, so I can only convert a certain form of dates to a date format
-- The column is in the format 'YYYY-MM-DD'
-- With this, I don't need to created a new column
UPDATE nashville
SET SaleDate = strftime('%Y-%m-%d', SaleDate);
-- To test
SELECT * FROM nashville
WHERE strftime('%Y', SaleDate) == '2013';

-----

-- **** PropertyAddress - missing values **** --

-- The problem is when I import the csv file to the sql table, it did not treat missing value as NULL (the default in SQL)
SELECT PropertyAddress
FROM nashville
WHERE PropertyAddress IS NULL;


/* I noticed there are nulls. Let's investigate. */
SELECT *
FROM nashville
ORDER BY ParcelID;
-- I notice the same ParcelID and PropertyAddress are listed for different UniqueIDs. 


-----
-- To know more about self-join, see the word file --
/* I want to find a ParcelID with a null PropertyAddress. Then populate the PropertyAddress from a different UniqueID with a matching ParcelID. */
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID AS ParcelID_b, b.PropertyAddress AS PropertyAddress_b
FROM nashville a
JOIN nashville b
	ON a.ParcelID = b.parcelID
	AND a.UniqueID <> b.UniqueID -- not equal to
WHERE a.PropertyAddress IS NULL;
-- Join where the ParcelIDs are the same but the UniqueIDs are different, and look where the PropertyAddress is null.

/* In SQLite, the ISNULL function is not used to check for null values. Instead, you can use the COALESCE function or simply the IS NULL condition
to reflect where a.Property was null and have it input b.PropertyAddress */
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress, b.PropertyAddress) AS MergedPropertyAddress
FROM nashville a
JOIN nashville b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


-- Update PropertyAddress column using alias.
UPDATE nashville
SET PropertyAddress = (
    SELECT b.PropertyAddress
    FROM nashville b
    WHERE nashville.ParcelID = b.ParcelID
        AND nashville.UniqueID <> b.UniqueID
        AND b.PropertyAddress IS NOT NULL
    LIMIT 1
)
WHERE PropertyAddress IS NULL;
--SELECT * FROM nashville;

-- Then rerun with WHERE clause to check it worked and there should be no nulls.
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM nashville a
JOIN nashville b
	ON a.ParcelID = b.parcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL; -- It worked!


-----
-- **** PropertyAddress - string separation **** --

Select PropertyAddress
FROM nashville;

/* Split PropertyAddress into separate columns for address and city Using SUBSTRING and CHARINDEX */
SELECT
    SUBSTR(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1) AS Address,
    SUBSTR(PropertyAddress, INSTR(PropertyAddress, ',') + 1) AS City
FROM
    nashville;

-- The INSTR function (or CHARINDEX in some databases) is used to find the position of a substring within a larger string.
-- Take the PropertyAddress at position 1 until the comma ',''s position. Then to remove the comma, -1. Name the column 'Address'
-- Take the PropertyAddress until the comma's position. Then to remove the comma, -1. Name the column 'City'
-- For the second SUBSTR, there is no length parameter given, so it is the rest of the string starting from the character after the comma
-- Run query to check accuracy

/* To alter the table -- add new columns */

ALTER TABLE nashville
ADD SplitPropertyAddress TEXT;
-- Add a column for the split address.
Update nashville
SET SplitPropertyAddress = SUBSTR(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1);
-- Input the data for the split address column.

ALTER TABLE nashville
ADD SplitPropertyCity TEXT; -- TEXT is the default data type for strings
-- Add a column for the split city.
UPDATE nashville
SET SplitPropertyCity = SUBSTR(PropertyAddress, INSTR(PropertyAddress, ',') + 1);
-- Input the data for the split city column.

SELECT *
FROM nashville;
-- Let's see the updated table.
-----

-- OwnerAddress -- 
/* Let's look at the OwnerAddress */
SELECT OwnerAddress
FROM nashville;

/* Split OwnerAddress into separate columns for address, city, and state. */
-- I use nested SUBSTR and INSTR functions to find the second comma within the substring between the first and second commas.
SELECT
    TRIM(SUBSTR(OwnerAddress, 1, INSTR(OwnerAddress, ',') - 1)) AS ThirdComponent,
    TRIM(SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + 1, 
                INSTR(SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + 1), ',') - 1)) AS SecondComponent,
    TRIM(SUBSTR(SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + 1), 
                INSTR(SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + 1), ',') + 1)) AS FirstComponent
FROM
    nashville;

/* To alter the table */
ALTER TABLE nashville
ADD SplitOwnerAddress TEXT;
-- Add a column for SplitOwnerAddress.
Update nashville
SET SplitOwnerAddress = TRIM(SUBSTR(OwnerAddress, 1, INSTR(OwnerAddress, ',') - 1));
-- Input the data for SplitOwnerAddress column.

ALTER TABLE nashville
ADD SplitOwnerCity TEXT;
-- Add a column for SplitOwnerCity.
Update nashville
SET SplitOwnerCity = TRIM(SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + 1, 
                INSTR(SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + 1), ',') - 1));
-- Input the data for SplitOwnerCity column.

ALTER TABLE nashville
ADD SplitOwnerState TEXT;
-- Add a column for SplitOwnerState.
Update nashville
SET SplitOwnerState = TRIM(SUBSTR(SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + 1), 
                INSTR(SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + 1), ',') + 1));
-- Input the data for SplitOwnerState column.

SELECT *
FROM nashville;


-----
-- SoldAsVacant --
-- Data update -- 

/* Let's look at the SoldAsVacant column. */
SELECT DISTINCT(SoldAsVacant), COUNT (SoldAsVacant) -- Actually, having DISTINCT or not doesn't affect the results
FROM nashville
GROUP BY SoldAsVacant
ORDER BY 2; -- ordered by COUNT (SoldAsVacant)


/* Update the Y/N to show as Yes/No in the Sold as Vacant field. */
SELECT SoldAsVacant
, CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM nashville;

-- Since query works, we can update accordingly.
UPDATE nashville
SET SoldAsVacant = 
    CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
     END;

-- Rerun our SoldAsVacant column to check completion.
SELECT DISTINCT(SoldAsVacant), COUNT (SoldAsVacant)
FROM nashville
GROUP BY SoldAsVacant
ORDER BY 2;


-----

/* Check for duplicates. */
SELECT *, -- From here, you can know ofc you can select more than * (all col). Like here, you select (want sql to return) one more col called row_num
	ROW_NUMBER() OVER ( -- This is the window function part of the query
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) AS row_num
FROM nashville
ORDER BY ParcelID;
-- In the column row_num, I can identify the 2's. Upon investigation, I see the 2 rows have all the same data but different UniqueId's. 


/* USE CTE to view all the duplicates (row_num 2's) */
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) AS row_num
FROM nashville
-- ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE 
WHERE row_num > 1 -- In this case, the maximum row_num is 2 because there is only at most 1 duplicate of each instance
ORDER BY PropertyAddress;
-- There are 104 duplicates. 


/* Remove Duplicates */
/*The issue here is that you are attempting to use a Common Table Expression (CTE) in a DELETE statement. 
In SQLite, you cannot directly use a CTE in a DELETE statement like that. 
The DELETE statement in SQLite doesn't support the use of CTEs. */
/*WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) AS row_num
FROM nashville
)

DELETE
FROM RowNumCTE 
WHERE row_num > 1; */

-- Instead, I should use a subquery within the DELETE statement --
DELETE FROM nashville
WHERE UniqueID NOT IN (
    SELECT MIN(UniqueID)  -- Keep the row with the lowest UniqueID in each partition
    FROM nashville
    GROUP BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
); -- successfully deleted 104 duplicated rows





/* Rerun query to check if leftover duplicates. */
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) AS row_num
FROM nashville
-- ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE 
WHERE row_num > 1
ORDER BY PropertyAddress; -- No duplicates anymore

-- Alternatively:
SELECT * FROM nashville
WHERE UniqueID NOT IN (
    SELECT MIN(UniqueID)  -- Keep the row with the lowest UniqueID in each partition
    FROM nashville
    GROUP BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
);

-----

/* Delete unused columns. */
/* I can do it manually from the left dashboard here, which I did, or you create a new table and insert the data
from the original table without the columns I don't want, and then delete the original table with the new
table left*/
SELECT * FROM nashville; -- done!


