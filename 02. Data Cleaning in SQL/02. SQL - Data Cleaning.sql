/*
Cleaning Data in SQL Queries
*/

Select *
From Data_Cleaning;

use Portfolio_Project;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDate, convert(Date,SaleDate) 
from Data_Cleaning;

update Data_Cleaning
set SaleDate = convert(Date,SaleDate);

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select *
from Data_Cleaning
where PropertyAddress  is null;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Data_Cleaning a
join Data_Cleaning b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Data_Cleaning a
join Data_Cleaning b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from Data_Cleaning;
--where PropertyAddress is null
--order by ParcelID;

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1 ) as Address
, substring(PropertyAddress, charindex(',', PropertyAddress) + 1 , len(PropertyAddress)) as Address
from Data_Cleaning;

alter table Data_Cleaning
Add PropertySplitAddress Nvarchar(255);

Update Data_Cleaning
SET PropertySplitAddress = Substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1 );

alter table Data_Cleaning
Add PropertySplitCity Nvarchar(255);

update Data_Cleaning
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) + 1 , len(PropertyAddress));

select * from Data_Cleaning;

select OwnerAddress
from Data_Cleaning;

select
parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from Data_Cleaning;

alter table Data_Cleaning
add OwnerSplitAddress Nvarchar(250);

update Data_Cleaning
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3);

alter table Data_Cleaning
add OwnerSplitCity Nvarchar(250);

update Data_Cleaning
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2);

alter table Data_Cleaning
add OwnerSplitState Nvarchar(250);

update Data_Cleaning
set OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1);

select * from Data_Cleaning;

--------------------------------------------------------------------------------------------------------------------------

-- Change '1' and '0' to 'Yes' and 'No' in "Sold as Vacant" field

select distinct(SoldAsVacant)
from Data_Cleaning;

alter table Data_Cleaning
alter column SoldAsVacant varchar(250);

select SoldAsVacant
, case when SoldAsVacant = '1' then 'Yes'
	   when SoldAsVacant = '0' then 'No'
	   else SoldAsVacant
	   end
from Data_Cleaning;


update Data_Cleaning
set SoldAsVacant = case when SoldAsVacant = '1' then 'Yes'
	   when SoldAsVacant = '0' then 'No'
	   else SoldAsVacant
	   end

select SoldAsVacant
from Data_Cleaning;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE as(
select *,
	row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
					) row_num
From Data_Cleaning
--order by ParcelID
)
select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress;

select * from Data_Cleaning;

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From Data_Cleaning;

alter table Data_Cleaning
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

Select *
From Data_Cleaning;