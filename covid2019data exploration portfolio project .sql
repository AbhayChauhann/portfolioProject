select * from portfolioproject..CovidDeaths
order by 3,4

--select * from portfolioproject..CovidVaccinations
--order by 3,4 

select location,date,total_cases,new_cases,total_deaths,population from portfolioproject..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathPercentage from portfolioproject..CovidDeaths
where location like '%state%'
order by 1,2


--looking at Total cases vs Total Population
--Shows what Percentage of Population got Covid

select location,date,population,total_cases,(total_cases/population)*100 as Percentagepopulationinfected from portfolioproject..CovidDeaths
where location like '%state%'
--where location like '%states%'
order by 1,2


--Looking at countries  with the highest infection rate compared to the population
select location,population,MAX(total_cases) as HighestInfectionCount ,Max((total_cases/population))*100 as Percentpopulationinfected from portfolioproject..CovidDeaths
--where location like '%state%'
where continent is not null
group by location,population
order by Percentpopulationinfected desc

--Showing countries with the heighest death count per population

select location , MAX(cast(total_deaths as int ))as totaldeathcount from portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by totaldeathcount desc

--LETS BREAK THING DOWN BY CONTINENT


select location , MAX(cast(total_deaths as int ))as totaldeathcount from portfolioproject..CovidDeaths
--where location like '%states%'
where continent is  null
group by location
order by totaldeathcount desc


--showing the continents with highest no of death counts

select continent , MAX(cast(total_deaths as int ))as totaldeathcount from portfolioproject..CovidDeaths
--where location like '%states%'
where continent is  not null
group by continent
order by totaldeathcount desc


--Global numbers

select date, sum(new_cases)as NumofCases, sum(cast(new_deaths as int ))as NumofNewdeaths,sum(cast(new_deaths as int ))/sum(new_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

--total cases ,total deaths and death percentage globally
select  sum(new_cases)as NumofCases, sum(cast(new_deaths as int ))as NumofNewdeaths,sum(cast(new_deaths as int ))/sum(new_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--total population vs total vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
from portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
    on  dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null
order by 2,3

--use cte 

with popvsvac(continent,location,date,population,new_vaccinations,rollingPeopleVaccinated)
 as 
(
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
from portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
    on  dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null
--order by 2,3
)
select *,(rollingPeopleVaccinated/population)*100  from popvsvac

--temp table
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100  from #percentpopulationvaccinated

--CREATIG VIEW TO STORE DATA FOR LATER VISUALIZATION
USE PortfolioProject
GO
CREATE VIEW PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
    --order by 2,3

	select*from PercentPopulationVaccinated