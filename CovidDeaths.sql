CREATE DATABASE PortfolioProject;
Go

USE PortfolioProject;
Go

SELECT *
FROM dbo.CovidDeaths
ORDER BY 3,4;

SELECT *
FROM dbo.CovidVaccinations
ORDER BY 3,4;
--Go

-- Looking at Total Cases vs Total Deaths
-- Show Likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE location LIKE '%Indonesia%' AND continent IS NOT NULL
ORDER BY 1,2;
Go

-- Looking at Total Cases vs Population
-- Show what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE location LIKE '%Indonesia%'
ORDER BY 1,2;
Go

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
--WHERE location LIKE '%Indonesia%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;
Go

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM dbo.CovidDeaths
--WHERE location LIKE '%Indonesia%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;
Go

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM dbo.CovidDeaths
--WHERE location LIKE '%Indonesia%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;
Go

-- Showing continents with Highest Death Count per Population

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM dbo.CovidDeaths
--WHERE location LIKE '%Indonesia%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;
Go

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) total_cases, SUM(cast(new_deaths AS int)) total_deaths, SUM(cast(new_deaths AS int))/SUM(New_cases)*100 AS DeathPercentages
FROM dbo.CovidDeaths
--WHERE location LIKE '%Indonesia%' AND 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;
Go

-- joint two table on CovidDeaths and CovidVaccinations

SELECT *
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date;

-- Looking at Populations vs Vaccinations
-- USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.location LIKE '%Indonesia%'
)
--ORDER BY 2, 3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac;

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopuplationVaccinated
CREATE TABLE #PercentPopuplationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopuplationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopuplationVaccinated


CREATE VIEW PercentPopuplationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentPopuplationVaccinated;
