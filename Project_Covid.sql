--Select Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
Where continent is not null
order by 1,2

--Total Cases vs Total Deaths
--shows the chance of dying in % if you contract covid in your country
select location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 as Death_Percentage
from coviddeaths
Where continent is not null
where location like '%Ukraine%'
order by 1,2

--Total Cases vs Population 
--Shows what percentage of population got Covid
select location, date, population, total_cases,
(total_cases/population)*100 as Percentage_That_Got_Covid
from coviddeaths
Where continent is not null
where location like '%Ukraine%'
order by 1,2

--Countries with Highest Infection Rates compared to Population
select location,population, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
from coviddeaths
Where continent is not null
Group by Location, population
order by PercentPopulationInfected desc

--Countries with Highest Death per Population
select location, MAX(total_deaths) as TotalDeathCount
from coviddeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Sorting by the continent
select location, MAX(total_deaths) as TotalDeathCount
from coviddeaths
Where continent is null
Group by location
order by TotalDeathCount desc

--Continents with the highest death count per population
select location, MAX(total_deaths) as TotalDeathCount
from coviddeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

--Global Numbers
select 
Sum(new_cases), SUM(new_deaths), Sum(new_deaths)/Sum(new_cases)*100 as DeathsPercentage
from coviddeaths
--Where continent is not null
order by 1,2

--Total Population vs Vaccinations
Select 
cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
from coviddeaths cd
join covidvaccinations cv
on cd.location = cv.location
and cd.date = cv.date
Where cd.continent is not null
order by 2,3


--How many people in certain country are vaccinated
--with CTE 

with PopvsVacc 
(Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated) as 
(
    Select 
        cd.continent, 
        cd.location, 
        cd.date, 
        cd.population, 
        cv.new_vaccinations,
        SUM(cv.new_vaccinations) over (partition by cd.location Order by cd.location, cd.date) as PeopleVaccinated
    from 
        coviddeaths cd
    join 
        covidvaccinations cv on cd.location = cv.location and cd.date = cv.date
    Where 
        cd.continent is not null
)
select *, (PeopleVaccinated/Population) * 100 as PercentageofVaccinatedPeople
from PopvsVacc

--Temp Table 
--Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) 
OVER (Partition by dea.Location 
Order by dea.location, dea.Date) as PeopleVaccinated
--, (PeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (PeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations)
OVER (Partition by dea.Location 
Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (PeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

