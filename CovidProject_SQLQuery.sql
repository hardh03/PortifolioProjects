
Select *
from Portfolio..CovidDeaths
where continent is not null
order by 3,4

--Select *
--from Portfolio..CovidVaccinations
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeaths
where continent is not null

--Looking at Total Cases vs Total deaths
select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
where location like '%Zimbabwe%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

select Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From Portfolio..CovidDeaths
where location like '%States%'
and continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to population

select Location, Population, Max(total_cases)as HighestInfectionCount, Max((total_cases/ population))* 100 as PercentPopulationInfected
From Portfolio..CovidDeaths
--where location like '%States%'
Group by Location, Population
order by PercentPopulationInfected desc

--Showing Countries with Highest Detah Count per Population

select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
--where location like '%States%'
where continent is not null
Group by Location
order by TotalDeathCount desc

--Lets Break things down by continent

select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
--where location like '%States%'
where continent is null
Group by location
order by TotalDeathCount desc


--Showing the Continents with highest Death Count

select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
--where location like '%States%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
--where location like '%States%'
where continent is not null
--group by date
order by 1,2


Select *
from Portfolio ..CovidVaccinations

--Joining the Two Tables

Select *
from Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	on dea.location= vac.location
	and dea.date =vac.date

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	on dea.location= vac.location
	and dea.date =vac.date
where dea.continent is not null
order by 2,3

--Partitioning location

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date)
from Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	on dea.location= vac.location
	and dea.date =vac.date
where dea.continent is not null
order by 2,3



--Use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date)
from Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	on dea.location= vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date)
from Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	on dea.location= vac.location
	and dea.date =vac.date
where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Create View to store data later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	on dea.location= vac.location
	and dea.date =vac.date
where dea.continent is not null


Select *
From PercentPopulationVaccinated