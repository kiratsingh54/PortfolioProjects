
-- DOG ADOPTION DATA FROM 2017

--------------------------------------------------------------------------------------------------------

Select *
	From PortfolioProject..DogAdoptionData


--------------------------------------------------------------------------------------------------------
-- Cleaning up Data (Deleting unneeded columns)

ALTER TABLE PortfolioProject..DogAdoptionData
DROP COLUMN BREED1_Mis,
		    BREED2,
			BREED2_Mis,
			BREEDTYP,
			COLOR


--------------------------------------------------------------------------------------------------------
-- Deleting rows with incorrect data regarding Owner Age

DELETE FROM DogAdoptionData
WHERE OWNER_AGE = '20-Nov'


--------------------------------------------------------------------------------------------------------
-- Calculating AGE of dogs in the year 2017

Select DOG_BIRTH_YEAR, (2017 - DOG_BIRTH_YEAR) as DogAge
	From PortfolioProject..DogAdoptionData
	
	ALTER TABLE DogAdoptionData
	ADD DogAge INT;

	UPDATE DogAdoptionData
	SET DogAge = (2017 - DOG_BIRTH_YEAR)


--------------------------------------------------------------------------------------------------------
-- Shows how many dogs were adopted by each age group

Select OWNER_AGE, COUNT(OWNER_AGE) NumOfPeople
	From PortfolioProject..DogAdoptionData
	Where OWNER_AGE is not null
	Group by OWNER_AGE
	order by OWNER_AGE


--------------------------------------------------------------------------------------------------------
-- Shows number of unique dog owners in each District

Select DISTRICT, COUNT(DISTINCT(HALTER_ID))
	From PortfolioProject..DogAdoptionData
	Group by DISTRICT
	order by DISTRICT


--------------------------------------------------------------------------------------------------------
-- Shows how many dogs were adopted with their specified breed

Select BREED1, COUNT(BREED1) as NumOfDogs,
	   COUNT(BREED1) * 100.0 / (Select COUNT(*)
						From PortfolioProject..DogAdoptionData) as PercentOfTotal
	From PortfolioProject..DogAdoptionData
	Group by BREED1
	Order by PercentOfTotal desc
	

--------------------------------------------------------------------------------------------------------
-- Shows which breed was most popular each year

DROP Table if exists #DogTable
Create Table #DogTable
(
BirthYear numeric,
Breed nvarchar(255),
BreedCount numeric
)
Insert into #DogTable
	SELECT DOG_BIRTH_YEAR, BREED1, COUNT(BREED1) as BreedCount
		FROM PortfolioProject..DogAdoptionData 
		GROUP BY DOG_BIRTH_YEAR, BREED1
		Order by BreedCount desc, DOG_BIRTH_YEAR

select t1.BirthYear, t1.Breed AS PopularBreed, BreedCount
from #DogTable t1
inner join
(
  select BirthYear, max(BreedCount) max_count
  from #DogTable
  group by BirthYear
) t2
  on t1.BirthYear = t2.BirthYear
  and t1.BreedCount = t2.max_count
 

--------------------------------------------------------------------------------------------------------
-- For Visualization
--------------------------------------------------------------------------------------------------------
--1.
-- Shows number of dogs adopted at each age

Select DogAge, COUNT(DogAge) as NumberAdopted
	From PortfolioProject..DogAdoptionData
	Group by DogAge
	order by DogAge


--------------------------------------------------------------------------------------------------------
--2.
-- Shows Average age of dog adopted by each Age range of Owners

Select OWNER_AGE, AVG(DogAge) as AvgDogAge
	From PortfolioProject..DogAdoptionData
	Where OWNER_AGE is not null
	Group by OWNER_AGE
	order by 1


--------------------------------------------------------------------------------------------------------
--3.
-- Shows the top 5 most adopted Dog Breeds

Select TOP 5 BREED1, COUNT(BREED1) as NumOfDogs
	From PortfolioProject..DogAdoptionData
	Group by BREED1
	Order by 2 desc