SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM CovidVaccination
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
Order by 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you get COVID19 in a country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'Argentina'
Order by 1,2;

-- Looking at Total Cases vs Population
-- Shoiws what percentage of the population got Covid19

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationWithCovid
FROM CovidDeaths
WHERE location = 'Argentina'
Order by 1,2;


-- Looking at countries with highest infection rate compared to population

SELECT location, MAX(total_cases) AS HighestInfection, population, MAX((total_cases/population))*100 AS PopulationInfected
FROM CovidDeaths
GROUP BY location,population
Order by PopulationInfected DESC;

-- Showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
Order by TotalDeathCount DESC;

-- Showing continents with highest death counts

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
Order by TotalDeathCount DESC;




--GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as INT)) AS TotalDeaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
Order by 1,2;

--Day with most death by cases worldwide
SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as INT)) AS TotalDeaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
Order by DeathPercentage DESC;


SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as INT)) AS TotalDeaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
Order by 1,2;


-- Looking at Total Population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
, -- (RollingPeopleVaccinated/Population)
FROM CovidDeaths dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

WITH PopuVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/Population)*100
FROM CovidDeaths dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopuVsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/Population)*100
FROM CovidDeaths dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/Population)*100
FROM CovidDeaths dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated