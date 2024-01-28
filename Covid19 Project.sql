-- Covid19 portfolio project to showcase data exploration in SQL
-- Lijo Philip (2/21/23)
-- Coronavirus (COVID-19) Deaths (https://ourworldindata.org/covid-deaths)

SELECT *
FROM CovidProject..CovidDeaths$
WHERE continent is not null

-- Select data being used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths$
WHERE continent is not null
ORDER BY location, date

-- Total cases vs. Total deaths
-- Probability of dying if one has Covid in the U.S.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathRate
FROM CovidProject..CovidDeaths$
WHERE location like '%united states%'
ORDER BY location, date

-- Total cases vs. Population
-- What portion of the U.S. population that contracted Covid

SELECT location, date, total_cases, population, (total_cases/population) * 100 AS InfectionRate
FROM CovidProject..CovidDeaths$
WHERE location like '%united states%'
ORDER BY location, date

-- Showcasing countries with highest infection rate relative to its poulation

SELECT location, population, MAX(total_cases) AS TotalCases, MAX(total_cases/population) * 100 AS InfectionRate
FROM CovidProject..CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY InfectionRate DESC

-- Showcasing countries with highest death rate relative to its poulation

SELECT location, population, MAX(cast(total_deaths AS int)) AS TotalDeaths
FROM CovidProject..CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeaths DESC

-- Showcasing continents with highest death rates

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeaths
FROM CovidProject..CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY TotalDeaths DESC

-- Showcasing death rate globaly

SELECT SUM(new_cases) AS GlobalCases, SUM(cast(new_deaths AS int)) AS GlobalDeaths, SUM(cast(new_deaths AS int))/SUM(new_cases) * 100 AS GlobalDeathRate
FROM CovidProject..CovidDeaths$
WHERE continent is not null
ORDER BY GlobalCases

-- Popluation vs. Vaccinations
-- Showcases a rolling count of people recieveing the Covid vaccination

SELECT Death.continent, Death.location, Death.date, Death.population, Vaccine.new_vaccinations, SUM(Cast(Vaccine.new_vaccinations AS int)) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.Date) AS PeopleVaccinated
FROM CovidProject..CovidDeaths$ AS Death
Join CovidProject..CovidVaccinations$ AS Vaccine
ON Death.location = Vaccine.location and Death.date = Vaccine.date
WHERE Death.continent is not null
ORDER BY Death.location, Death.date

-- Using CTEs to showcase a rolling vaccination rate in each counrty

WITH PopVaccinated (Contitnent,Location, Date, Population, New_Vacciantions,PeopleVaccinated)
AS
(
SELECT Death.continent, Death.location, Death.date, Death.population, Vaccine.new_vaccinations, SUM(Cast(Vaccine.new_vaccinations AS int)) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.Date) AS PeopleVaccinated
FROM CovidProject..CovidDeaths$ AS Death
Join CovidProject..CovidVaccinations$ AS Vaccine
ON Death.location = Vaccine.location and Death.date = Vaccine.date
WHERE Death.continent is not null
)

SELECT *, (PeopleVaccinated / Population) * 100 AS VaccinationRate
FROM PopVaccinated

-- Using a temp table to showcase a rolling vaccination rate in each counrty

--DROP TABLE if exists #PopVaccinated
--Create Table #PopVaccinated
--(
--Continent nvarchar(50),
--Location nvarchar(50),
--Date datetime,
--Population int,
--New_vaccinations int,
--PeopleVaccinated int
--)

--Insert into #PopVaccinated
--Select Death.continent, Death.location, Death.date, Death.population, Vaccine.new_vaccinations, SUM(Cast(Vaccine.new_vaccinations as int)) OVER (Partition By Death.location Order by Death.location, Death.Date) as PeopleVaccinated
--From CovidProject..CovidDeaths$ as Death
--Join CovidProject..CovidVaccinations$ as Vaccine
--On Death.location = Vaccine.location and Death.date = Vaccine.date

--Select *, (PeopleVaccinated / Population) * 100 as VaccinationRate
--From #PopVaccinated

-- Creating a view

--Create View PopVaccinated as
--Select Death.continent, Death.location, Death.date, Death.population, Vaccine.new_vaccinations, SUM(Cast(Vaccine.new_vaccinations as int)) OVER (Partition By Death.location Order by Death.location, Death.Date) as PeopleVaccinated
--From CovidProject..CovidDeaths$ as Death
--Join CovidProject..CovidVaccinations$ as Vaccine
--On Death.location = Vaccine.location and Death.date = Vaccine.date
--Where Death.continent is not null

--Select *
--From PopVaccinated
