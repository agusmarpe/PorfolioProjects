/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select Data that we are going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in each country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location = 'Argentina'
ORDER BY 1,2 



-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS InfectedPopulationPerc
FROM CovidDeaths
WHERE location = 'Argentina'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)/population)*100 AS InfectedPopulationPerc
FROM CovidDeaths
--WHERE location = 'Argentina'
GROUP BY location, population
ORDER BY InfectedPopulationPerc DESC


-- Countries with Highest Death Count per Population

SELECT Location, population, MAX(cast(total_deaths as int)) AS TotalDeathsCount, (MAX(cast(total_deaths as int))/population)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location = 'Argentina'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY DeathPercentage DESC

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathsCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCount DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS FinalDeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentajePeopleVaccinated
FROM PopVsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentajePeopleVaccinated
FROM #PercentPopulationVaccinated


-- Creating Views to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3



CREATE VIEW DeathPercentagePopulation AS
SELECT Location, population, MAX(cast(total_deaths as int)) AS TotalDeathsCount, (MAX(cast(total_deaths as int))/population)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location = 'Argentina'
WHERE continent IS NOT NULL
GROUP BY location, population
--ORDER BY DeathPercentage DESC

CREATE VIEW TotalDeathByContinent AS
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathsCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY TotalDeathsCount DESC