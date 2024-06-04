/*
COVID-19 Data Exploration 

SKILLS USED: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT * 
FROM PortfolioProjects..CovidDeaths
ORDER BY 3,4

SELECT * 
FROM PortfolioProjects..CovidVaccinations
ORDER BY 3,4

-- Select Data to start with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of death for contracting Covid in respective country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount DESC

-- BY CONTINENT
-- Showing continents with the highest death count per population

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent is null 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS
-- Death Percentage 

SELECT SUM(new_cases) as global_cases, SUM(cast(new_deaths as int)) as global_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent	is not null
--GROUP BY date
ORDER BY 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid vaccine

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations, SUM(cast(vaccs.new_vaccinations as int)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths deaths
JOIN PortfolioProjects..CovidVaccinations vaccs
	ON deaths.location = vaccs.location
	AND deaths.date = vaccs.date
WHERE deaths.continent is not null
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopVSVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations, SUM(cast(vaccs.new_vaccinations as int)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths deaths
JOIN PortfolioProjects..CovidVaccinations vaccs
	ON deaths.location = vaccs.location
	AND deaths.date = vaccs.date
WHERE deaths.continent is not null
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVSVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE if EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations, SUM(cast(vaccs.new_vaccinations as int)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths deaths
JOIN PortfolioProjects..CovidVaccinations vaccs
	ON deaths.location = vaccs.location
	AND deaths.date = vaccs.date
WHERE deaths.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating Views to store data for later visualizations (Tableau)

CREATE VIEW GlobalDeathPercentage as 
SELECT SUM(new_cases) as global_cases, SUM(cast(new_deaths as int)) as global_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent	is not null
--GROUP BY date
--ORDER BY 1,2

CREATE VIEW TotalDeathCount as
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent is null 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
--ORDER BY TotalDeathCount DESC

CREATE VIEW HighestInfectionRateByCountry as 
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
--ORDER BY PercentPopulationInfected DESC

CREATE VIEW HighestInfectionRateByCountryWithDate as 
SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population, date
--ORDER BY PercentPopulationInfected DESC
