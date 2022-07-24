

/*
Exploratory Data Analysis using Covid-19 Dataset
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

--selecting complete data from both datasets.
Select *
From PortfolioProject..Covid_Deaths

Select *
From PortfolioProject..Covid_vaccinations


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..Covid_Deaths
Where continent is not null 
order by location,date


-- Total Cases vs Total Deaths
-- Shows the possibility of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, round((total_deaths/total_cases)*100,2) as Death_Percentage
From PortfolioProject..Covid_Deaths
where continent is not null 
order by location, date


-- Total Cases vs Population
-- Percentage of individual country's population infected with Covid

Select Location, date, Population, total_cases, round((total_cases/population)*100,4) as PercentPopulationInfected
From PortfolioProject..Covid_Deaths
order by location, date


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as Highest_Infection_Count,  Max(round((total_cases/population)*100,2)) as PercentPopulationInfected
From PortfolioProject..Covid_Deaths
where continent is not null 
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as Total_Death_Count
From PortfolioProject..Covid_Deaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- Categorizing result by continent 

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as Total_Death_Count
From PortfolioProject..Covid_Deaths
Where continent is not null 
Group by continent
order by Total_Death_Count desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..Covid_Deaths
where continent is not null 
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as Percent_People_vaccinated
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

