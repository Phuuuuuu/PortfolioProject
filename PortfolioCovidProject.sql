-- SELECT DATA TO TABLE 'CovidDeaths' AND SORT COLUMN 3, 4
SELECT *
FROM [PortfolioProject]..CovidDeaths
WHERE continent is not  null
ORDER BY 3, 4 

--SELECT DATA THAT TO BE USING 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [PortfolioProject]..CovidDeaths
ORDER BY 3, 4 

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths,  (cast(total_deaths as float) / cast(total_cases as float))*100 AS DeathPercentage
FROM [PortfolioProject]..CovidDeaths
WHERE Location like '%Vietnam%'
--WHERE continent is not  null
ORDER BY 1, 2

-- Looking at Total Cases with Population
-- Show what percentage of population got Covid
SELECT Location, date,population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM [PortfolioProject]..CovidDeaths
--WHERE Location like '%Vietnam%'
ORDER BY 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [PortfolioProject]..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC




--Showing Countries with Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [PortfolioProject]..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Let's break thing down by continent
-- Showing contintents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [PortfolioProject]..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers 
SELECT  SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int)) / SUM(cast(new_cases as int))*100 AS DeathPercentage 
FROM [PortfolioProject]..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY  1, 2

--Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as PeopleVaccinated 
FROM [PortfolioProject]..CovidDeaths dea
JOIN [PortfolioProject]..CovidVaccinNations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3


-- USE CTE
WITH PopvsVac ( continent, location, date, population, new_vaccinations , PeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as PeopleVaccinated 
FROM [PortfolioProject]..CovidDeaths dea
JOIN [PortfolioProject]..CovidVaccinNations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (PeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as PeopleVaccinated 
FROM [PortfolioProject]..CovidDeaths dea
JOIN [PortfolioProject]..CovidVaccinNations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *, (PeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as PeopleVaccinated 
FROM [PortfolioProject]..CovidDeaths dea
JOIN [PortfolioProject]..CovidVaccinNations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3


SELECT *
FROM PercentPopulationVaccinated