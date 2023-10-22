-- I first import the data from the csv file to this SQL database. Specifically, I only add a table to this database
-- Import csv file to SQLite Studio: go see the Word file in the folder
/* First, I specify all the col names and data type to create a table (the same cols as in the csv file with 
the data type set by me) */

CREATE TABLE nashville (
    UniqueID INTEGER,	
    ParcelID REAL,	
    LandUse TEXT,	
    PropertyAddress TEXT,	
    SaleDate TEXT,	
    SalePrice REAL,	
    LegalReference TEXT,	
    SoldAsVacant TEXT,	
    OwnerName TEXT,	
    OwnerAddress TEXT,	
    Acreage REAL,	
    TaxDistrict TEXT,	
    LandValue REAL,	
    BuildingValue REAL,	
    TotalValue REAL,	
    YearBuilt TEXT,	
    Bedrooms INTEGER,	
    FullBath INTEGER,	
    HalfBath INTEGER
);

-- To import the csv file to the pre-defined SQL table, click the import icon on the bar above, and adjsut necessary csv features
SELECT * FROM nashville -- successful
LIMIT 10;

