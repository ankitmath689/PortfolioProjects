-- This is to verify all data from our deaths CSV

--SELECT *
--FROM COVIDDeaths
--ORDER BY 3, 4


-- This is to verify all data from our vaccinations CSV

--SELECT *
--FROM COVIDVaccinations
--ORDER BY 3, 4


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of death should you contract COVID-19 by Country

--SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
--FROM COVIDDeaths
--ORDER BY 1, 2


-- Looking at Total Cases vs Population in United State
-- Shows what percentage of population contracts COVID-19

--SELECT location, date, population, total_cases, (total_cases/population) * 100 AS InfectionRate
--FROM COVIDDeaths
--WHERE location = 'United States'
--ORDER BY 1, 2


-- Looking at Countries with Highest Infection Rate by Population

--SELECT location, population, MAX(CAST(total_cases AS int)) AS PeakInfectionCount, MAX((total_cases/population)) * 100 AS PeakInfectionRate
--FROM COVIDDeaths
--WHERE continent IS NOT null
--GROUP BY location, population
--ORDER BY 2 DESC


-- Total deaths broken down by country

--SELECT date, location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
--FROM COVIDDeaths
--WHERE continent IS NOT null
--GROUP BY location, date
--ORDER BY date ASC

--CREATE VIEW TotalDeathsPerCountryByDate AS 
--	SELECT date, location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
--	FROM COVIDDeaths
--	WHERE continent IS NOT null
--	GROUP BY location, date
--	--ORDER BY date ASC

-- Global Numbers

--SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage
--FROM COVIDDeaths
--WHERE continent IS NOT NULL
--ORDER BY 1, 2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
	(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated--, (RollingPeopleVaccinated/population) * 100
FROM COVIDDeaths dea
JOIN COVIDVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

---- USE CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
	(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
		(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated--, (RollingPeopleVaccinated/population) * 100
	FROM COVIDDeaths dea
	JOIN COVIDVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	)

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PopVsVac

---- TEMP TABLE

DROP table IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_Vaccinations numeric, RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
		(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated--, (RollingPeopleVaccinated/population) * 100
	FROM COVIDDeaths dea
	JOIN COVIDVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
	--WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM #PercentPopulationVaccinated

-- Creating View to store for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
		(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated--, (RollingPeopleVaccinated/population) * 100
	FROM COVIDDeaths dea
	JOIN COVIDVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date