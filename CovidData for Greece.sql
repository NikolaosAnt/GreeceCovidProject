--Testing to check if tables are successfully imported
Select *
From PortfolioProject1.dbo.CovidDeaths
where continent is not null
Order by 3,4

Select *
From PortfolioProject1.dbo.Vacci
where continent is not null
Order by 3,4

--Decide with which data to work with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1.dbo.CovidDeaths
where continent is not null
Order by 1,2

--Considering Greece as the location, I calculate the DeathPercent (Total Deaths/Total Cases)

Select Location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathPercent
From PortfolioProject1.dbo.CovidDeaths
Where location='Greece' and continent is not null
Order by 1,2

--Greece's Total Cases vs Population

Select Location, date, total_cases, population, (total_cases/population)*100 as PopulationCovidPercent
From PortfolioProject1.dbo.CovidDeaths
Where location='Greece' and continent is not null
Order by 1,2

--Greece Total_cases, Total_deaths & DeathPercent
Select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercent
From PortfolioProject1.dbo.CovidDeaths
Where continent is not null and location='Greece'
--group by date
order by 1,2

--Globally: The percent of each country's Covid infections

Select Location, population, MAX(total_cases) as HighestInfections, MAX(total_cases/population)*100 As PopulationCovidPercent
From PortfolioProject1.dbo.CovidDeaths
where continent is not null
Group by population, location
Order by PopulationCovidPercent Desc

--DeathSum per continent

Select location, Sum(cast(new_deaths as int)) as DeathSum
From PortfolioProject1.dbo.CovidDeaths
Where continent is null and location not in ('world','International','upper middle income','high income','lower middle income','low income','European Union')
Group by location
Order by DeathSum desc

--Global DeathPercent per day

Select date, SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercent
From PortfolioProject1.dbo.CovidDeaths
Where continent is not null
group by date
order by 2,3

----DeathSum in rest of the world
Select location,Sum(cast(new_deaths as int)) as DeathSum
From PortfolioProject1.dbo.CovidDeaths
Where continent is not null and location not like 'Greece'
Group by location
Order by DeathSum desc


--Joining the two tables (Covid.Deaths vs Covid.Vacc 
--RunningSum of vaccinations in Greece per day

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as VaccinationRunningSum
--, (VaccinationRunningSum/population)*100
From PortfolioProject1.dbo.CovidDeaths dea
Join PortfolioProject1.dbo.Vacci vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null and dea.location='Greece'
Order by 2,3 

------------------------------------------------------------------------------------------------
/*Create a Common Table Expression to extract VaccinationRunningSum 
(writing a SELECT query which will give you a result to use within another query)
in order to find VaccinationRunningPercent
First, we consider only Greece*/

With Population_vs_Vaccinations 
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as VaccinationRunningSum
--, (VaccinationRunningSum/population)*100--(cannot use a column that is just created)--
From PortfolioProject1.dbo.CovidDeaths dea
Join PortfolioProject1.dbo.Vacci vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null and dea.location='Greece'
--Order by 2,3
)

Select *, (VaccinationRunningSum/population)*100 as VaccinationRunningSumPercent
From Population_vs_Vaccinations



--Create a temp table for PercentageofGreeksVaccinated
--Also using a Drop table statement, in case we need to alter anything in the table--
--Table was stored in Databases/System Databases/master/table of SQL management studio--

DROP TABLE IF EXISTS PercentofGreeksVaccinated
CREATE TABLE PercentofGreeksVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric(18,0),
new_vaccinations numeric(18,0),
VaccinationRunningSum numeric(18,0)
)

Insert into PercentofGreeksVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as VaccinationRunningSum
--, (VaccinationRunningSum/population)*100--(cannot use a column that is just created)--
From PortfolioProject1.dbo.CovidDeaths dea
Join PortfolioProject1.dbo.Vacci vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null and dea.location='Greece'
Order by 2,3

Select *, (VaccinationRunningSum/population)*100 as VaccinationRunningSumPercent
From PercentofGreeksVaccinated

----Create view to store data for later vizualization---
--Location stays as Greece!--
--Tableau Public does not allow users to import data from SQL databases, so I cannot import the dataset to Tableau :(--

Create View VaccinationRunningSum as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as VaccinationRunningSum
--, (VaccinationRunningSum/population)*100--(cannot use a column that is just created)--
From PortfolioProject1.dbo.CovidDeaths dea
Join PortfolioProject1.dbo.Vacci vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null and dea.location='Greece'
--Order by 2,3

Select *
From VaccinationRunningSum
