SELECT *
FROM portfolio..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM portfolio..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio..CovidDeaths
ORDER BY 1,2

-- total cases vs total deaths
-- likelyhood of dying with covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolio..CovidDeaths
WHERE location like '%india%'
and continent is not null
ORDER BY 1,2

--Total cases vs population
--Shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationinfected
FROM portfolio..CovidDeaths
--WHERE location like '%india%'
ORDER BY 1,2

--Looking at Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationinfected
FROM portfolio..CovidDeaths
--WHERE location like '%india%'
GROUP BY location, population
ORDER BY PercentPopulationinfected desc

--Showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portfolio..CovidDeaths
--WHERE location like '%india%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continets with highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portfolio..CovidDeaths
--WHERE location like '%india%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--Global Numbers

SELECT SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM portfolio..CovidDeaths
--WHERE location like '%india%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2  

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM portfolio..CovidDeaths dea
JOIN portfolio..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--CTE

with PopvsVac (continent,location,date,population,new_vaccinations,RollingPopulationVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM portfolio..CovidDeaths dea
JOIN portfolio..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPopulationVaccinated/population)*100 as PercentageOfRolling
FROM PopvsVac

--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM portfolio..CovidDeaths dea
JOIN portfolio..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualizations


CREATE VIEW PercentPopulationVaccinated as 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM portfolio..CovidDeaths dea
JOIN portfolio..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated