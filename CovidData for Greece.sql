Select *
From dbo.CovidDeaths
where continent is not null
Order by 3,4

Select *
From dbo.Vacci
Order by 3,4

--Data to be used

Select Location, date, total_cases, new_cases, total_deaths, population
From dbo.CovidDeaths
where continent is not null
Order by 1,2

--DeathPercent in Greece= Total Deaths/Total Cases

Select Location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathPercent
From dbo.CovidDeaths
Where location='Greece' and continent is not null
Order by 1,2

--Total Cases vs Population
--Meaning the % of total population that got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PopulationCovidPercent
From dbo.CovidDeaths
Where location='Greece' and continent is not null
Order by 1,2

--Countries with highest infection Rate to Population

Select Location, population, MAX(total_cases) as HighestInfections, MAX(total_cases/population)*100 As PopulationCovidPercent
From dbo.CovidDeaths
where continent is not null
Group by population, location
Order by PopulationCovidPercent Desc

--Countries with Most Deaths to Population per Location

Select location, Max(cast(total_deaths as int)) as MostDeaths
From dbo.CovidDeaths
where continent is null
Group by location
Order by MostDeaths Desc 

---Same search for Continents
 

--Continents with the highest death rate (total_deaths/population)
Select continent, Max(cast (total_deaths as int)) as MostDeaths
From dbo.CovidDeaths
where continent is not null
group by continent
order by MostDeaths desc

---Broader Picture
--DeathPercent daily

Select date, SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercent
From dbo.CovidDeaths
Where continent is not null
group by date
order by 1,2


--JOINING 
--TOTAL POP VS VACCI IN GREECE

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as VaccinationRunningSum
--, (VaccinationRunningSum/population)*100
From dbo.CovidDeaths dea
Join dbo.Vacci vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null and dea.location='Greece'
Order by 2,3 

-----Create a Common Table Expression---------
--------This is how to define the temporary VIEW's name--------
With Population_vs_Vaccinations(Continent,location,date,population, new_vaccinations, VaccinationRunningSum)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as VaccinationRunningSum
--, (VaccinationRunningSum/population)*100--(cannot use a column that is just created)--
From dbo.CovidDeaths dea
Join dbo.Vacci vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null and dea.location='Greece'
--Order by 2,3
)

Select *, (VaccinationRunningSum/population)*100 as VaccinationRunningSumPercent
From Population_vs_Vaccinations

--temp table--
Create table PercentageofPopulationVaccinated
(
continent nvarchar(255)
location nvarchar(255)
Date datetime,
population int,
new_vaccinations int,


Insert into
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as VaccinationRunningSum
--, (VaccinationRunningSum/population)*100--(cannot use a column that is just created)--
From dbo.CovidDeaths dea
Join dbo.Vacci vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null and dea.location='Greece'
--Order by 2,3


----Create view to store data for later vizualization---
--Location stays as Greece!--
Create View VaccinationRunningSum as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as VaccinationRunningSum
--, (VaccinationRunningSum/population)*100--(cannot use a column that is just created)--
From dbo.CovidDeaths dea
Join dbo.Vacci vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null and dea.location='Greece'
--Order by 2,3

Select *
From VaccinationRunningSum