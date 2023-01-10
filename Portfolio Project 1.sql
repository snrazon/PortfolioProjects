--Select Data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from [Portfolio Project 1]..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths

select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project 1]..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at the Total Cases vs Population

select location,date,population,total_cases,(total_cases/population)*100 as IncidenceRate
from [Portfolio Project 1]..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at countries with highest incidence rate

select location,population,max(total_cases) as MaxIncidenceRate,max((total_cases/population))*100 as IncidenceRate
from [Portfolio Project 1]..CovidDeaths
group by location,population
order by IncidenceRate desc

--Showing the countries with the highest death count per population

select location,max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project 1]..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Showing continents with the highest death count per population

select location,max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project 1]..CovidDeaths
where continent is null
and location not like '%income%'
group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as CaseFatalityRate
from [Portfolio Project 1]..CovidDeaths
where continent is not NULL
group by date
order by 1,2



WITH PopVsVaxxed (Continent, location, date, population, New_Vaccinations,RollingPplVaxxed) as
(
select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, sum(convert(int,new_vaccinations)) over (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as RollingPplVaxxed
from [Portfolio Project 1]..CovidDeaths
join [Portfolio Project 1]..CovidVaccinations
on CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
and CovidDeaths.location = 'Canada'
--order by 2,3
)

Select *,(RollingPplVaxxed/population)*100 as RollingTotal
from PopVsVaxxed

--Looking at Total Population vs Total Vaccinations using temptable

DROP table if exists PercentPopVax
CREATE table PercentPopVax
(
Continent nvarchar(255),
location NVARCHAR(255),
date DATETIME,
population numeric,
New_Vaccinations numeric,
RollingPplVaxxed numeric
)
Insert into PercentPopVax
select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, sum(convert(int,new_vaccinations)) over (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as RollingPplVaxxed
from [Portfolio Project 1]..CovidDeaths
join [Portfolio Project 1]..CovidVaccinations
on CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
and CovidDeaths.location = 'Canada'
--order by 2,3

Select *,(RollingPplVaxxed/population)*100 as RollingTotal
from PercentPopVax

--Creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as
select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, sum(convert(int,new_vaccinations)) over (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as RollingPplVaxxed
from [Portfolio Project 1]..CovidDeaths
join [Portfolio Project 1]..CovidVaccinations
on CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null