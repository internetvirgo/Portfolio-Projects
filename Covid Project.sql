USE PortfolioProject

SELECT * FROM dbo.CovidDeaths
WHERE continent is NOT NULL
order by 3,4

--SELECT * FROM dbo.CovidVaccinations
--order by 3,4

SELECT location, date, population , total_cases, new_cases, total_deaths
FROM dbo.CovidDeaths
order by 1,2

--Looking at total cases vs total deaths 
--Shows likelyhood of dying if you contract Covid-19 in your country


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM dbo.CovidDeaths
Where location like '%states'
order by 1,2

-- Looking at Total Cases vs Total Population
-- Shows percentage of population who contracted Covid-19

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentageWithCovidInUSA
FROM dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at countries with highest infection rate vs population

SELECT location, population, MAX(total_cases) as HighestInfectionRate, MAX((total_cases/population))*100 as PercentageWithCovid
FROM dbo.CovidDeaths
-- WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY PercentageWithCovid DESC

-- Looking at countries with highest count per population

SELECT location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
-- WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC

-- Breaking highest death count down based on continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
-- WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage --total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM dbo.CovidDeaths
--Where location like '%states'
where continent is not null
--Group by date
order by 1,2


--Looking at total population vs vaccinations

--USING CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationCount)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,new_vaccinations)) OVER 
(Partition By dea.location Order by dea.location, dea.date) as RollingVaccinationCount --(RollingVaccinationCount/population)*100
FROM dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
--order by 1,2,3 
)
SELECT *, (RollingVaccinationCount/population)*100 FROM PopvsVac 
Order by 2,3

-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated

Create table #PercentPopulationVaccinated (
Continent nvarchar(255),
Location nvarchar (255),
date datetime, 
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,new_vaccinations)) OVER 
(Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated --(RollingVaccinationCount/population)*100
FROM dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent = 'North America'

SELECT *, (RollingPeopleVaccinated /population)*100 FROM #PercentPopulationVaccinated


-- Creating views to store data for later visualization

Create View RollingPeopleVaccinated as SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,new_vaccinations)) OVER 
(Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated --(RollingVaccinationCount/population)*100
FROM dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3 

Create View TotalDeathCount as SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
-- WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY continent
--ORDER BY TotalDeathCount DESC

Create View PercentageWithCovidInUSA as SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentageWithCovidInUSA
FROM dbo.CovidDeaths
WHERE location like '%states%'
--ORDER BY 1,2