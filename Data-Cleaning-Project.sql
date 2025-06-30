DBCC FREEPROCCACHE;
DBCC FREEPROCCACHE;


use PortfolioProjects;
--===========================================================================
-- Data Cleaning Portfolio Project Nashville Housing 
select * 
from NashvilleHousing;


-----------------------------------------------------------------------------
--standerize data format 
--convert SaleDate data type to make sure it is date datatype, then rename it to 
select sale_date_converted, convert(date,SaleDate) 
from NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date,SaleDate)  --  SaleDate بدل sale_Date_Convertedعشان أعمل كلمن جديد بإسم 

alter table NashvilleHousing
add sale_date_converted date;

update NashvilleHousing 
set sale_date_converted = CONVERT(date, SaleDate);

--result
select * 
from NashvilleHousing;

----------------------------------------------------------------------------------------------
-- populate property address data 

select 
ParcelID, PropertyAddress
from 
NashvilleHousing;

------

select 
a.ParcelID, 
a.PropertyAddress, 
b.ParcelID, 
b.PropertyAddress,
isnull(a.PropertyAddress,b.PropertyAddress)
from 
NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;
 
------

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from 
NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

--result
select * 
from NashvilleHousing;

-----------------------------------------------------------------------------------------
--breaking out address into individual columns (Address, City, State)
select PropertyAddress
from NashvilleHousing;  

------

select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, 
--usin -1 to back one step and show data without comma 
substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) as Address

from NashvilleHousing;

------

ALTER TABLE NashvilleHousing
Add property_split_address nvarchar(255);

update NashvilleHousing 
set property_split_address = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);


ALTER TABLE NashvilleHousing
Add property_split_city nvarchar(255);

update NashvilleHousing 
set property_split_city = substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress));

--result 
select * 
from NashvilleHousing;

----------------------------------------------------------------------------------
--owner address 
select OwnerAddress
from NashvilleHousing;
---------
select 
PARSENAME(replace(OwnerAddress,',','.'), 3),
PARSENAME(replace(OwnerAddress,',','.'), 2),
PARSENAME(replace(OwnerAddress,',','.'), 1)
from NashvilleHousing;

--------

ALTER TABLE NashvilleHousing
Add owner_split_address nvarchar(255);

update NashvilleHousing 
set owner_split_address = PARSENAME(replace(OwnerAddress,',','.'), 3);


ALTER TABLE NashvilleHousing
Add owner_split_city nvarchar(255);

update NashvilleHousing 
set owner_split_city = PARSENAME(replace(OwnerAddress,',','.'), 2);

ALTER TABLE NashvilleHousing
Add owner_split_state nvarchar(255);

update NashvilleHousing 
set owner_split_state = PARSENAME(replace(OwnerAddress,',','.'), 1);
--------
--result in the end of table looks better than before 
select * 
from NashvilleHousing;

-----------------------------------------------------------------------------------------
--change all Y and N to be a Yes and No

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2;

------

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant 
	 end 
from NashvilleHousing;

------

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant 
	 end

------
--to check the proporties of this column faster, run this again
select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2;

------
--result, table looks better than before 

select * 
from NashvilleHousing;

------------------------------------------------------------------------------------------
--remove dublicates 
with row_num_CTE as (
select *, 
	ROW_NUMBER() over (
	partition by 
	ParcelID,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference
	order by 
		UniqueID) 
		row_num
from NashvilleHousing
--order by ParcelID
)
delete 
from row_num_CTE
where row_num > 1
--order by PropertyAddress;

------
--result

with row_num_CTE as (
select *, 
	ROW_NUMBER() over (
	partition by 
	ParcelID,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference
	order by 
		UniqueID) 
		row_num
from NashvilleHousing
--order by ParcelID
)
select * 
from row_num_CTE
where row_num > 1
order by PropertyAddress;

-----------------------------------------------------------------------------------
--delete unused columns 
select * 
from NashvilleHousing;

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table NashvilleHousing
drop column SaleDate
