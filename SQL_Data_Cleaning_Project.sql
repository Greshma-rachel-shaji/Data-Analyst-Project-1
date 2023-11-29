/*

Cleaning Data in SQL Queries

*/
select * from portfolio_project.dbo.NashvilleHousing order by [UniqueID ]
-------------------------------------------------------------------------------------------------------------------------------------------

--Standartize Data Format

select SaleDateConverted,CONVERT(date,SaleDate) from portfolio_project.dbo.NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted Date

update portfolio_project.dbo.NashvilleHousing
set SaleDateConverted=CONVERT(DATE,SaleDate)

---------------------------------------------------------------------------------------------------------------------------------------------

---Populate Property Address Data
select a.[UniqueID ],b.[UniqueID ],a.PropertyAddress,b.PropertyAddress,a.ParcelID,b.ParcelID,ISNULL(a.PropertyAddress,b.PropertyAddress) from portfolio_project.dbo.NashvilleHousing a
join
portfolio_project.dbo.NashvilleHousing b
on
--where PropertyAddress is null
a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolio_project.dbo.NashvilleHousing a
join
portfolio_project.dbo.NashvilleHousing b
on
--where PropertyAddress is null
a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------------------------------------------

----Breaking out Address into Individual Columns(Address,City,State)

select propertyaddress,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress,CHARINDEX(',',propertyaddress)+1,len(PropertyAddress))
from NashvilleHousing

Alter Table NashvilleHousing
add  PropertySplitAddress Varchar(max)

Alter Table NashvilleHousing
add  PropertyCity Varchar(max)

update NashvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


update NashvilleHousing
set PropertyCity=SUBSTRING(PropertyAddress,CHARINDEX(',',propertyaddress)+1,len(PropertyAddress))

select PropertyCity,PropertySplitAddress,propertyaddress from [dbo].[NashvilleHousing]
------------------------------------------------------------------------------------------------------------------------------------------
----Breaking out owner Address into Individual Columns(Address,City,State)[using parsename funtion]

select PARSENAME(replace(owneraddress,',','.'),3) ,
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1) 
from portfolio_project.dbo.NashvilleHousing


Alter Table NashvilleHousing
add  OwnerSplitAddress Varchar(max)

Alter Table NashvilleHousing
add   OwnerSplitCity Varchar(max)


Alter Table NashvilleHousing
add   OwnerSplitstate Varchar(max)

update portfolio_project.dbo.NashvilleHousing
set OwnerSplitAddress=PARSENAME(replace(owneraddress,',','.'),3)


update portfolio_project.dbo.NashvilleHousing
set OwnerSplitCity=PARSENAME(replace(owneraddress,',','.'),2)


update portfolio_project.dbo.NashvilleHousing
set OwnerSplitstate=PARSENAME(replace(owneraddress,',','.'),1)


select OwnerSplitAddress,OwnerSplitCity,OwnerSplitstate from portfolio_project.dbo.NashvilleHousing
----------------------------------------------------------------------------------------------------------------------------------------------
--- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant),COUNT(SoldAsVacant) 
from portfolio_project.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from portfolio_project.dbo.NashvilleHousing

update portfolio_project.dbo.NashvilleHousing
set SoldAsVacant=case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
-------------------------------------------------------------------------------------------------------------------------------------------------
--Removing Duplicates(using CTE)

with RownoCTE as( 
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference 
				order by
				UniqueID
				) as row_num
from portfolio_project.dbo.NashvilleHousing
)
--select * from RownoCTE
delete from RownoCTE
where row_num > 1
--order by PropertyAddress

--------------------------------------------------------------------------------------------------------------------------------------------------
--Delete unused columns

alter table portfolio_project.dbo.NashvilleHousing
drop column PropertyAddress,SaleDate,OwnerAddress,TaxDistrict
 
