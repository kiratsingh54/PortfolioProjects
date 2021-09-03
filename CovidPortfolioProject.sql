
-- COVID Data (Current Aug 2021)

--------------------------------------------------------------------------------------------------------

-- Shows the data ordered by column 3 and 4 

Select *
	From PortfolioProject..CovidDeaths
	Where continent is not null
	order by 3,4


--------------------------------------------------------------------------------------------------------
-- Shows the specified columns

Select location, date, total_cases, new_cases, total_deaths, population
	From PortfolioProject..CovidDeaths
	Where continent is not null
	order by 1,2


--------------------------------------------------------------------------------------------------------
-- Shows the likelihood of dying if you contract COVID in your Country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	From PortfolioProject..CovidDeaths
	Where location = 'United States'
	and continent is not null
	order by 1,2


--------------------------------------------------------------------------------------------------------
-- Shows what percentage of Population contracted COVID

Select location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
	From PortfolioProject..CovidDeaths
	Where location = 'United States'
	and continent is not null
	order by 1,2


--------------------------------------------------------------------------------------------------------
-- Shows the Total number of Cases, deaths, and Mortality Rate worldwide on each day

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as Total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as MortalityRate
	From PortfolioProject..CovidDeaths
	Where continent is not null
	Group by date
	order by 1,2


--------------------------------------------------------------------------------------------------------
-- Shows the Total World Population that has been Vaccinated seperated by Country w/ a rolling count
-- USING CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingCountOfVaccinations)
as
(
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
	, SUM(CONVERT(int, vacc.new_vaccinations)) OVER (Partition by death.location Order by death.location,
	death.date) as RollingCountOfVaccinations --Parition starts the count again with every new location
	From PortfolioProject..CovidDeaths death
	Join PortfolioProject..CovidVaccinations vacc
		On death.location = vacc.location
		and death.date = vacc.date
	Where death.continent is not null
)
Select *, (RollingCountOfVaccinations/Population)*100 as VaccinationRate
	From PopvsVac
	

--------------------------------------------------------------------------------------------------------
-- Shows the Total World Population that has been Vaccinated seperated by Country w/ a rolling count
-- USING TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingCountOfVaccinations numeric
)
Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
	, SUM(CONVERT(int, vacc.new_vaccinations)) OVER (Partition by death.location Order by death.location,
	death.date) as RollingCountOfVaccinations --Parition starts the count again with every new location
	From PortfolioProject..CovidDeaths death
	Join PortfolioProject..CovidVaccinations vacc
		On death.location = vacc.location
		and death.date = vacc.date
	Where death.continent is not null

Select *, (RollingCountOfVaccinations/Population)*100 as VaccinationRate
	From #PercentPopulationVaccinated


--------------------------------------------------------------------------------------------------------
-- Creating View to store data for visualization

Create View PercentPopulationVaccinated as
	Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
	, SUM(CONVERT(int, vacc.new_vaccinations)) OVER (Partition by death.location Order by death.location,
	death.date) as RollingCountOfVaccinations --Parition starts the count again with every new location
	From PortfolioProject..CovidDeaths death
	Join PortfolioProject..CovidVaccinations vacc
		On death.location = vacc.location
		and death.date = vacc.date
	Where death.continent is not null


--------------------------------------------------------------------------------------------------------
-- For Visualization
--------------------------------------------------------------------------------------------------------
--1.
-- Shows the Total number of Cases, Deaths, and Mortality Rate in the world 

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as Total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as MortalityRate
	From PortfolioProject..CovidDeaths
	Where continent is not null
	order by 1,2


--------------------------------------------------------------------------------------------------------
--2.
-- Shows Continents w/ sorted Total Death Count 

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
	From PortfolioProject..CovidDeaths
	Where continent is null
	and location not in ('World', 'European Union', 'International')
	Group by location
	order by TotalDeathCount desc


--------------------------------------------------------------------------------------------------------
--3.
-- Shows a sorted list of Countries w/ the Highest Infection Rate and the Total Cases they have had

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionRate
	From PortfolioProject..CovidDeaths
	Where continent is not null
	Group by location, population
	order by InfectionRate desc


--------------------------------------------------------------------------------------------------------
--4.
--Shows sorted list of Countries w/ the Highest Infection Rate and the Total Cases they have had on each given date

Select location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as InfectionRate
	From PortfolioProject..CovidDeaths
	Group by location, population, date
	order by InfectionRate desc