
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--DATA FOR UNITED STATES:

--Running Death Rate of Covid in the United States:
SELECT location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS DeathRate
FROM CovidDeaths
WHERE location like 'United States'
ORDER BY date

--Running Percentage of the Population that has been infected by Covid in United States:
SELECT location, date, population, total_cases,(total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE location like 'United States'
ORDER BY date


--DATA BY COUNTRY

--Total percent of the population that has been infected by Covid by Country:
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Total death count by Country:
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC


--DATA BY CONTINENT:

--Total percent of the population that has been infected by Covid by Continent:
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NULL AND location NOT LIKE '%income' AND location NOT LIKE 'World' and location NOT LIKE 'European Union'
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

--Total death count by Continent:
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL AND location NOT LIKE '%income' AND location NOT LIKE 'World' and location NOT LIKE 'European Union'
GROUP BY location
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

--Running Death Rate of Covid in the World:
SELECT location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS DeathRate
FROM CovidDeaths
WHERE location = 'World'
ORDER BY date

--Overall Death Rate of Covid in the World:
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathRate
FROM CovidDeaths
WHERE location = 'World'


--Total Vaccinated People by Country and Date
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as TotalNewVaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY location, date

--Create CTE for Total Percent of Population Vaccinated
WITH PopvsVacc (continent, location, date, population, new_vaccinations, TotalNewVaccinations)
AS 
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as TotalNewVaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (TotalNewVaccinations/population)*100 AS PercentofPopVaccinated
FROM PopvsVacc
ORDER BY location, date


--Creating Views for Visulations
CREATE VIEW PercentPopVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as TotalNewVaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopVaccinated
ORDER BY location, date