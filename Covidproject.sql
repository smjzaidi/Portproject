Select *
From coviddeaths
order by 3,4;

-- Select *
-- From covidvaccinations
-- where continent is not null
-- order by 3,4;

-- Selection Data
Select Location, date, total_cases, new_cases, total_deaths, population
From coviddeaths
order by 1,2;

-- Total Cases vs Total Deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From coviddeaths
Where location like '%canada%'
order by 1,2; 

-- Total Cases vs Population
Select Location, date, population, total_cases, (total_cases/population)*100 as Pop_Perc
From coviddeaths
Where location like '%canada%'
order by 1,2;

-- Countries with highest infection rate by population
Select Location, population, MAX(total_cases) as HIghest_InfecCount, MAX((total_cases/population)*100) as Pop_Perc
From coviddeaths
group by location, population
order by Pop_Perc desc;


-- Countries with highest death count per population
Select Location, MAX(cast(total_deaths as signed)) as TotalDeathCount
From coviddeaths
where continent is not null
	and continent != ''
group by Location
order by TotalDeathCount desc;

-- Continet with highest death count per population 
Select location, MAX(cast(total_deaths as signed)) as TotalDeathCount
From coviddeaths
where continent = ''
group by location
order by TotalDeathCount desc;

Select continent, MAX(cast(total_deaths as signed)) as TotalDeathCount
From coviddeaths
where continent != ''
group by continent
order by TotalDeathCount desc;

-- Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(cast(new_deaths as signed))/SUM(new_cases) * 100 as Death_Percentage
From coviddeaths
where continent != ''
order by 1,2; 

-- Total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) 
	as RollingPeopleVaccinated
From coviddeaths dea
Join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
order by 2,3;

-- CTE
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) 
	as RollingPeopleVaccinated
From coviddeaths dea
Join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;


Select *
From covidvaccinations
Where new_vaccinations = '';

Set SQL_SAFE_UPDATES = 0;
update covidvaccinations
set new_vaccinations = NULL
where new_vaccinations = '';
Set SQL_SAFE_UPDATES = 1;


-- Temp Table
DROP TEMPORARY TABLE IF EXISTS PercentPopVaccinated;
Create temporary table PercentPopVaccinated (
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
);

Insert into PercentPopVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) 
	as RollingPeopleVaccinated
From coviddeaths dea
Join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date;

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopVaccinated;

-- View for data visualisation 
DROP VIEW IF EXISTS PercentPopVaccinated;
Create view PercentPopVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) 
	as RollingPeopleVaccinated
From coviddeaths dea
Join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
    where dea.continent != '';
     
Select *
From percentpopvaccinated;