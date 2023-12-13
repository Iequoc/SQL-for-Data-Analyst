-- USE DATABASE PortfolioProject

SELECT * 
FROM CovidDeaths
ORDER BY 3,4

-- SELECT * 
-- FROM CovidVaccinations
-- ORDER BY 3,4

-- Select Data that we are going to be using
SELECT [location], [date], total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
FROM CovidDeaths
-- WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionRate, MAX((total_cases/population))*100 as PercentagePopulationInfections
FROM CovidDeaths
GROUP BY location, population
ORDER BY HighestInfectionRate DESC

SELECT location, population, MAX(total_cases) as HighestInfectionRate, MAX((total_cases/population))*100 as PercentagePopulationInfections
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentagePopulationInfections DESC

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast (total_deaths as INT)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL  -- *** Because the data us have slight issue. 
                             -- When the continent is null that means the location is actually an entire continent.***
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing Continent with Highest Death Count per Population

SELECT continent, MAX(cast (total_deaths as INT)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL  -- *** Because the data us have slight issue. 
                             -- When the continent is null that means the location is actually an entire continent.***
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT  SUM(cast(new_cases AS FLOAT)) AS Total_cases, SUM(cast(new_deaths AS FLOAT)) AS Total_deaths,(SUM(cast(new_deaths AS FLOAT))/SUM(cast(new_cases AS FLOAT))) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL and cast(new_cases AS FLOAT) != 0
-- GROUP BY [date]
ORDER BY DeathPercentage



-- Looking at Total Population vs Vaccinations
-- USE CTE

WITH PopvsVaci(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT death.continent, death.[location], death.[date], death.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations  vac
    ON death.[location] = vac.[location]
    AND death.[date] = vac.[date]
WHERE death.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/population) * 100 AS PercentPopulationVaccinated
FROM PopvsVaci


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.[location], death.[date], death.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations  vac
    ON death.[location] = vac.[location]
    AND death.[date] = vac.[date]
WHERE death.continent IS NOT NULL
-- ORDER BY 2,3

SELECT * , (RollingPeopleVaccinated/population) * 100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT death.continent, death.[location], death.[date], death.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations  vac
    ON death.[location] = vac.[location]
    AND death.[date] = vac.[date]
WHERE death.continent IS NOT NULL

SELECT * 
FROM PercentPopulationVaccinated



