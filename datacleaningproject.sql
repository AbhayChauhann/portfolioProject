-- cleaning data in sql queries--

select*from  portfolioproject.dbo.NashevilleHousing

--Standardize Date Format
select saledate,CONVERT(Date,SaleDate)  as saleDateConverted
from  portfolioproject.dbo.NashevilleHousing

alter table NashevilleHousing
add saleDateConverted DATE;

update NashevilleHousing
SET saleDateConverted=CONVERT(Date,SaleDate)
select  saleDateConverted from portfolioproject.dbo.NashevilleHousing


---populate Property Address Data---

select*from  portfolioproject.dbo.NashevilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID ,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from  portfolioproject.dbo.NashevilleHousing a
join portfolioproject.dbo.NashevilleHousing b
on a.ParcelID= b.ParcelID
and a .[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from  portfolioproject.dbo.NashevilleHousing a
join portfolioproject.dbo.NashevilleHousing b
on a.ParcelID= b.ParcelID
and a .[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------------------------------------------------------------------------------------------------------

--BREAKING OUT ADDRESS  INTO INDIVIDUAL COLUMNS(ADDRESS,CITY,STATE)

SELECT PropertyAddress from portfolioproject.dbo.NashevilleHousing

SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as address 
,  SUBSTRING(PropertyAddress, CHARINDEX('',PropertyAddress)+1 ,LEN(PropertyAddress)) as address

 from portfolioproject.dbo.NashevilleHousing


 from portfolioproject.dbo.NashevilleHousing
alter table NashevilleHousing
add PropertySplitAddress Nvarchar(255);

update NashevilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)  

alter table NashevilleHousing
add PropertySplitCity Nvarchar(255);

update NashevilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 ,LEN(PropertyAddress)) 


alter table NashevilleHousing
add PropertySplitState Nvarchar(255);

update NashevilleHousing
SET saleDateConverted=CONVERT(Date,SaleDate)



select OwnerAddress 
from portfolioproject.dbo.NashevilleHousing

select parsename (replace(OwnerAddress,',','.'),3)
, parsename (replace(OwnerAddress,',','.'),2)
, parsename (replace(OwnerAddress,',','.'),1)
from portfolioproject.dbo.NashevilleHousing

alter table NashevilleHousing
add OwnerSplitAddress Nvarchar(255);

update NashevilleHousing
SET OwnerSplitAddress=parsename (replace(OwnerAddress,',','.'),3)  

alter table NashevilleHousing
add OwnerSplitCity Nvarchar(255);

update NashevilleHousing
SET OwnerSplitCity=parsename (replace(OwnerAddress,',','.'),2) 


alter table NashevilleHousing
add OwnerSplitState Nvarchar(255);

update NashevilleHousing
SET OwnerSplitState=parsename (replace(OwnerAddress,',','.'),1)

 select* from portfolioproject.dbo.NashevilleHousing


 ---change Y and N to YES and NO in 'SOLD AS VECANT' FIELD---

 SELECT DISTINCT (SoldAsVacant),count (SoldAsVacant)
 from portfolioproject.dbo.NashevilleHousing
Group by SoldAsVacant
 order by 2
 
 select SoldAsVacant
 ,case when   SoldAsVacant ='Y' THEN 'YES'
 WHEN SoldAsVacant='N' THEN 'NO'
 ELSE SoldAsVacant
 END
 from portfolioproject.dbo.NashevilleHousing

 UPDATE NashevilleHousing
 SET SoldAsVacant=case when   SoldAsVacant ='Y' THEN 'YES'
 WHEN SoldAsVacant='N' THEN 'NO'
 ELSE SoldAsVacant
 END

 select SoldAsVacant FROM portfolioproject.dbo.NashevilleHousing

 --REMOVE DUPLICATES--

WITH RowNumCTE AS(
 select * ,
     ROW_NUMBER() OVER(
 PARTITION BY ParcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  order by 
			  UniqueID
			  ) row_num
			  from portfolioproject.dbo.NashevilleHousing )
			  select*  from RowNumCTE
			  where row_num>1
			   order by PropertyAddress
			   

------------REMOVE UNWANTED COLUMNS-------------------------------------------------------
SELECT * 
FROM portfolioproject.dbo.NashevilleHousing
ALTER TABLE portfolioproject.dbo.NashevilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE portfolioproject.dbo.NashevilleHousing
DROP COLUMN SaleDate