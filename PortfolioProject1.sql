select * 
from CovidDeaths
where continent is not null
order by 3,4

--Select * from CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- shows the likelyhood of dying if you contract COVID in your country 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%states%'
order by 1,2


-- Looking at the total cases VS the Population
--Shows what percentage of the population was infected by COVID

select location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from CovidDeaths
--where location like '%states%'
order by 1,2


-- Looking at countries with the highest infection rates compared to population

select location, population, MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 as PercentofPopulationInfected
from CovidDeaths
--where location like '%states%'
Group by location,population
order by PercentofPopulationInfected desc


--Showing countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--LEts break this down by CONTINENT

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc
-- CODE above is the corect way to display the data 


--Showing countries with highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc



-- Global Numbers

select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage -- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2



--COVID VACCINATION TABLE w/ a join

--Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)  as RollingPeopleVaccinated
, 
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)  as RollingPeopleVaccinated 
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 (Will throw an error)
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentofVaccination
from PopvsVac



--Temp Table
DROP Table if exists #PercentPopulationVaccianted
Create Table #PercentPopulationVaccianted
(
Continent nvarchar (255),
Location nvarchar(255),
date datetime, 
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccianted
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)  as RollingPeopleVaccinated 
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3 (Will throw an error)


select *, (RollingPeopleVaccinated/Population)*100 as PercentofVaccination
from #PercentPopulationVaccianted


--Creating View to store data for later visuals

Create View PercentPopulationVaccianted as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)  as RollingPeopleVaccinated 
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 (Will throw an error)


Create View PercentPopulationDeceased as
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location is not null

Create View PercentPopulationInfected as
select location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from CovidDeaths
where location is not null