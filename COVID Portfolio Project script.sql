SELECT location,date,total_cases, new_cases, total_deaths, population 
FROM `portfolioproject-380621.CovidProject.covid_deaths`
WHERE continent is not null
ORDER BY 1,2

-- Looking at total cases vs total deaths
-- Shows liklihood of dying from covid if contracted in your country

SELECT location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM `portfolioproject-380621.CovidProject.covid_deaths`
WHERE location LIKE 'North_America'
ORDER BY 1,2


-- Looking at total cases vs population
-- Shows what percentage of population got covid

SELECT location,date,population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM `portfolioproject-380621.CovidProject.covid_deaths`
WHERE location LIKE 'North_America'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM `portfolioproject-380621.CovidProject.covid_deaths`
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing countries with highest death count per population

SELECT location,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM `portfolioproject-380621.CovidProject.covid_deaths`
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LETS BREAK THINGS DOWN BY CONTINENT
-- These are the correct numbers in this query -v
SELECT location,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM `portfolioproject-380621.CovidProject.covid_deaths`
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing continents with highest death count per population

SELECT continent,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM `portfolioproject-380621.CovidProject.covid_deaths`
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers

SELECT date,SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM `portfolioproject-380621.CovidProject.covid_deaths`
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM `portfolioproject-380621.CovidProject.covid_deaths`
WHERE continent IS NOT null
ORDER BY 1,2

-- Looking at total population vs vaccination

SELECT*
FROM `portfolioproject-380621.CovidProject.covid_deaths` AS dea
JOIN `portfolioproject-380621.CovidProject.covid_vaccin` AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM `portfolioproject-380621.CovidProject.covid_deaths` AS dea
JOIN `portfolioproject-380621.CovidProject.covid_vaccin` AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 2,3   


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `portfolioproject-380621.CovidProject.covid_deaths` AS dea
JOIN `portfolioproject-380621.CovidProject.covid_vaccin` AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
FROM `portfolioproject-380621.CovidProject.covid_deaths` AS dea
JOIN `portfolioproject-380621.CovidProject.covid_vaccin` AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 2,3

-- Error so need to make CTE or temp table
-- CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM `portfolioproject-380621.CovidProject.covid_deaths` AS dea
JOIN `portfolioproject-380621.CovidProject.covid_vaccin` AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT null
)
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PopvsVac

-- Temp table

CREATE TEMP TABLE #PercentPopulationVaccinanted 
  (
     Continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  RollingPeopleVaccinated numeric
  )

INSERT INTO #PercentPopulationVaccinanted
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM `portfolioproject-380621.CovidProject.covid_deaths` AS dea
JOIN `portfolioproject-380621.CovidProject.covid_vaccin` AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT null
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinanted

-- Create a View

CREATE VIEW PercentPopulationVaccinanted AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM `portfolioproject-380621.CovidProject.covid_deaths` AS dea
JOIN `portfolioproject-380621.CovidProject.covid_vaccin` AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT null
-- ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinanted