select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

-- Select Data that we are going to be using

Select location, date, total_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2


-- Lookng at Total Cases vs Total Deaths in the Philippines
-- Shows likelihood of dying if you contract COVID in PH
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
location = 'Philippines'
order by 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID in PH

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location = 'Philippines'
order by 1, 2


-- Looking at Countries with Highest Infection Rate compared to population
Select location, population, MAX(total_cases) as HighesInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc



-- LET'S BREAK THINGS DOWN BY CONTINENT

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc


-- Showing continents with the  highet death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global daily cases and deaths
Select date, SUM(new_cases) as DailyCases, SUM(cast(new_deaths as int)) as DailyDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


-- Global number or cases and deaths
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccinations
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, SUM(CONVERT(int, vacc.new_vaccinations)) OVER(Partition by death.location Order by death.location, death.date) as CumulativePeopleVaccinated
From PortfolioProject..CovidDeaths as death
Join PortfolioProject..CovidVaccinations as vacc
	On death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
order by 2,3



-- Use CTE to get percent of vaccinated people over total population
With PopvVac (continent,location, date, population, new_vaccinations, CumulativePeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, SUM(CONVERT(int, vacc.new_vaccinations)) OVER(Partition by death.location Order by death.location, death.date) as CumulativePeopleVaccinated
From PortfolioProject..CovidDeaths as death
Join PortfolioProject..CovidVaccinations as vacc
	On death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
--order by 2,3
)

Select *, (CumulativePeopleVaccinated/population)*100 as PercentPeopleVaccinated
from PopvVac



-- Use TEMP TABLE to get percent of vaccinated people over total population

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinantions numeric,
CumulativePeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, SUM(CONVERT(int, vacc.new_vaccinations)) OVER(Partition by death.location Order by death.location, death.date) as CumulativePeopleVaccinated
From PortfolioProject..CovidDeaths as death
Join PortfolioProject..CovidVaccinations as vacc
	On death.location = vacc.location
	and death.date = vacc.date
--where death.continent is not null
--order by 2,3

Select *, (CumulativePeopleVaccinated/population)*100 as PercentPeopleVaccinated
from #PercentPopulationVaccinated



-- Create View to store data for later visualtizations

Create View PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, SUM(CONVERT(int, vacc.new_vaccinations)) OVER(Partition by death.location Order by death.location, death.date) as CumulativePeopleVaccinated
From PortfolioProject..CovidDeaths as death
Join PortfolioProject..CovidVaccinations as vacc
	On death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null

Select *
From PercentPopulationVaccinated