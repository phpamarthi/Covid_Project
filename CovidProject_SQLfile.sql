Select *
From PortfolioProject..Covid_deaths
Order by 3,4

--Select *
--From PortfolioProject..Covid_vaccinations
--Order by 3,4

-- Selection of data
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..Covid_deaths
Order by 1,2

-- Summarising total cases vs total deaths with deathpercentage
Select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
From PortfolioProject..Covid_deaths
where location like '%states%'
Order by 1,2

-- Summarising total cases vs Population with deathpercentage
Select location, date, total_cases, population, (total_cases / population) * 100 as CasesPercentagetoTotalpopulation
From PortfolioProject..Covid_deaths
where location like '%India%'
Order by 1,2

-- Analysing country with highest infection rate
Select location, Max(total_cases) as HighestInfectioncount, population, Max((total_cases / population)) * 100 as PercentageofPopulationInfected
From PortfolioProject..Covid_deaths
--where location like '%India%'
Group by location, population
Order by PercentageofPopulationInfected desc

-- Analysing countries with highest death rates to population
Select location, Max(cast(total_deaths as int)) as TotalDeathcount
From PortfolioProject..Covid_deaths
Where location is not null
Group by location
Order by TotalDeathcount desc

-- Analysing continents with highest death rates to population
Select location, Max(cast(total_deaths as int)) as TotalDeathcount
From PortfolioProject..Covid_deaths
Where continent is null
Group by location
Order by TotalDeathcount desc

-- Analysing global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int)) / SUM(new_cases) ) * 100 as GlobalDeathpercentage
From PortfolioProject..Covid_deaths
where continent is not null

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..Covid_deaths dea
Join PortfolioProject..Covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION by dea.location ORDER by dea.location, dea.date) as RollingPeoplevaccinated

From PortfolioProject..Covid_deaths dea
Join PortfolioProject..Covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *
From PopvsVac

-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION by dea.location ORDER by dea.location, dea.date) as RollingPeoplevaccinated

From PortfolioProject..Covid_deaths dea
Join PortfolioProject..Covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeoplevaccinated/Population)*100
From #PercentPopulationVaccinated
where New_vaccinations is Not Null

--Ranking

WITH INF_Rank as
(
Select continent, Location, date,SUM(new_cases) OVER (Partition by location Order by location, date) as Calculated_totalcases
From PortfolioProject..Covid_deaths
)
Select Continent, Location, MAX(Calculated_totalcases) as Highestcasesrecorded,
DENSE_RANK() OVER(ORDER BY MAX(Calculated_totalcases) DESC) Rank
FROM INF_Rank
Where continent is not null
Group by Continent, Location
Order by Highestcasesrecorded desc

--Creating view to store data for visualisations

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION by dea.location ORDER by dea.location, dea.date) as RollingPeoplevaccinated

From PortfolioProject..Covid_deaths dea
Join PortfolioProject..Covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null