--Excel files properly loaded
Select *
From Covid_Project.dbo.CovidDeaths
Where continent is not null
order by 3,4

Select *
From Covid_Project.dbo.CovidVaccinations
Where continent is not null
order by 3,4


Select location, date, total_cases,new_cases,total_deaths,population
From Covid_Project.dbo.CovidDeaths
Where continent is not null
order by 1,2


Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covid_Project.dbo.CovidDeaths
Where continent is not null /*and location='Greece'*/
order by 1,2


Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covid_Project.dbo.CovidDeaths
Where continent is not null and location='Greece' 
order by 1,2


Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected 
From Covid_Project.dbo.CovidDeaths
Where continent is not null /*and location='Greece'*/
order by 1,2


Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected 
From Covid_Project.dbo.CovidDeaths
Where continent is not null and location='Greece' 
order by 1,2


Select location,continent,population, MAX(total_cases) as MostCovidCases, MAX((total_cases/population))*100 as MostInfections
From Covid_Project.dbo.CovidDeaths
Where continent is not null /*and location='Greece'*/
group by location,population
order by MostInfections desc


Select location, Max(cast(total_deaths as int)) as MostCovidDeaths 
From Covid_Project.dbo.CovidDeaths
Where continent is not null /*and location='Greece'*/
group by location 
order by MostCovidDeaths DESC


Select continent, Max(cast(total_deaths as int)) as MostCovidDeaths 
From Covid_Project.dbo.CovidDeaths
Where continent is not null /*and location='Greece'*/
group by continent
order by MostCovidDeaths DESC



--Comparing Population and Vaccinations done
Select de.continent,de.location,de.date,de.population,va.new_vaccinations
, SUM(cast(va.new_vaccinations as int)) over (partition by de.location order by de.location,de.date) as RunningTotalofPeopleVaccinated
--, (RunningTotalofPeopleVaccinated/population)*100
From Covid_Project.dbo.CovidDeaths as De
join Covid_Project.dbo.CovidVaccinations as Va
	On de.location=Va.location
	and de.date=va.date
Where de.continent is not null
--order by 2,3



--Using a Common Table Expression to perform aggregations with RunningTotalofPeopleVaccinated column multiple times
WITH Population_vs_Vaccinations (continent,location,date,population,new_vaccinations,RunningTotalofPeopleVaccinated)
as 
(
Select de.continent,de.location,de.date,de.population,va.new_vaccinations
, SUM(cast(va.new_vaccinations as int)) over (partition by de.location order by de.location,de.date) as RunningTotalofPeopleVaccinated
--, (RunningTotalofPeopleVaccinated/population)*100
From Covid_Project.dbo.CovidDeaths as De
join Covid_Project.dbo.CovidVaccinations as Va
	On de.location=Va.location
	and de.date=va.date
Where de.continent is not null
--order by 2,3
)
Select*,(RunningTotalofPeopleVaccinated/population)*100
From Population_vs_Vaccinations



--Creating a Temp Table to perform calculation on Partition By in previous query
Drop table if exists #VaccinationsPercent
Create Table #VaccinationsPercent
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RunningTotalofPeopleVaccinated numeric
)

Insert into #VaccinationsPercent
Select de.continent,de.location,de.date,de.population,va.new_vaccinations
, SUM(cast(va.new_vaccinations as int)) over (partition by de.location order by de.location,de.date) as RunningTotalofPeopleVaccinated
--, (RunningTotalofPeopleVaccinated/population)*100
From Covid_Project.dbo.CovidDeaths as De
join Covid_Project.dbo.CovidVaccinations as Va
	On de.location=Va.location
	and de.date=va.date
Where de.continent is not null
--order by 2,3

Select*,(RunningTotalofPeopleVaccinated/population)*100 as PercentageRunningTotalofPeopleVaccinated
From #VaccinationsPercent



--View for Tableau
Create view PercentVaccinations as 
Select de.continent,de.location,de.date,de.population,va.new_vaccinations
, SUM(cast(va.new_vaccinations as int)) over (partition by de.location order by de.location,de.date) as RunningTotalofPeopleVaccinated
--, (RunningTotalofPeopleVaccinated/population)*100
From Covid_Project.dbo.CovidDeaths as De
join Covid_Project.dbo.CovidVaccinations as Va
	On de.location=Va.location
	and de.date=va.date
Where de.continent is not null
--order by 2,3
