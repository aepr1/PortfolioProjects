SELECT *
FROM CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations$
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
--Shows likelihood of you dying in your contry if you contract covid

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths$
WHERE location = 'Spain'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS CovidPercentage
FROM CovidDeaths$
WHERE location = 'Spain'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Popultion

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentofPopulationInfected
FROM CovidDeaths$
GROUP BY Location, Population
ORDER BY PercentofPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_Deaths as int)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- LET'S BREAKDOWN THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population


SELECT location, MAX(cast(Total_Deaths as int)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS BY DATE

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths$
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2

--GLOBAL NUMBERS AS A TOTAL
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidVaccinations$ vac
JOIN CovidDeaths$ Dea ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



-- USE CTE
WITH popVSvac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidVaccinations$ vac
JOIN CovidDeaths$ Dea ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM popVSvac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidVaccinations$ vac
JOIN CovidDeaths$ Dea ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

--Using PercentPopulationVaccinated view

SELECT *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
FROM PercentPopulationVaccinated





