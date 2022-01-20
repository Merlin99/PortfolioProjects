select *from PortfolioProject..[Nashvill Housing]

-- Standardize Date Format


Alter table [Nashvill Housing]
add convertdate date;

update [Nashvill Housing]
set convertdate=CONVERT(date,SaleDate)

select convertdate,CONVERT(date,SaleDate)
from PortfolioProject..[Nashvill Housing]

-- Populate Property Address data

select ParcelID ,PropertyAddress
from PortfolioProject..[Nashvill Housing]
where PropertyAddress is null
order by ParcelID 

Select first.ParcelID,first.PropertyAddress,second.ParcelID,second.PropertyAddress, ISNULL(first.PropertyAddress,second.PropertyAddress)
from PortfolioProject..[Nashvill Housing] first
join PortfolioProject..[Nashvill Housing] second
on first.ParcelID=second.ParcelID
and first.[UniqueID ] <> second.[UniqueID ]
where first.PropertyAddress is null

update first
set PropertyAddress=ISNULL(first.PropertyAddress,second.PropertyAddress)
from PortfolioProject..[Nashvill Housing] first
join PortfolioProject..[Nashvill Housing] second
on first.ParcelID=second.ParcelID
and first.[UniqueID ] <> second.[UniqueID ]
where first.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProject..[Nashvill Housing]



SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.[Nashvill Housing]

Alter table [Nashvill Housing]
add ProperetysplitAdd nvarchar(255);

update [Nashvill Housing]
set ProperetysplitAdd=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter table [Nashvill Housing]
add Properetysplitcity nvarchar(255);

update [Nashvill Housing]
set Properetysplitcity=SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select *from PortfolioProject..[Nashvill Housing]

select 
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from PortfolioProject..[Nashvill Housing]

alter table [Nashvill Housing]
add ownersplitAdd nvarchar(255);

update [Nashvill Housing]
set ownersplitAdd=PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter table [Nashvill Housing]
add ownersplitcity nvarchar(255);

update [Nashvill Housing]
set ownersplitcity=PARSENAME(Replace(OwnerAddress,',','.'),2)

alter table [Nashvill Housing]
add ownersplitstate nvarchar(255);

update [Nashvill Housing]
set ownersplitstate=PARSENAME(Replace(OwnerAddress,',','.'),1)

select *from PortfolioProject..[Nashvill Housing]

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant),count(SoldAsVacant)
from PortfolioProject..[Nashvill Housing]
group by SoldAsVacant
order by 2  

select SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end
from PortfolioProject..[Nashvill Housing]

update [Nashvill Housing]
set SoldAsVacant= case when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end

-- Remove Duplicates

with CTE AS(
select*,
ROW_NUMBER()over
(partition by ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				order by UniqueID) Rownum
from PortfolioProject..[Nashvill Housing]
)
Delete--select *
from CTE
where Rownum>1
--order by PropertyAddress

select *from PortfolioProject..[Nashvill Housing]

-- Delete Unused Columns

ALTER TABLE PortfolioProject..[Nashvill Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate