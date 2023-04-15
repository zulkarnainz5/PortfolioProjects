Select * 
From PortfolioProject..CovidDeaths
order by 3,4

Select * 
From PortfolioProject..CovidVaccinations
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population  
From PortfolioProject..CovidDeaths
order by 3,4

-- Total Cases VS Total  Death
 Select Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage  
From PortfolioProject..CovidDeaths
where location = 'India'
order by 1,2

-- New Cases VS New Deaths

Update PortfolioProject..CovidDeaths
Set new_cases = NULL where new_cases = 0

 Select Location, date, new_cases,  cast(new_deaths as int) as NewDeaths, (cast(new_deaths as int)/new_cases)*100 as DeathPercentageEveryDay  
From PortfolioProject..CovidDeaths

order by 1,2

-- Total Cases VS Population
 Select Location, date, total_cases,  population, (total_cases/population)*100 as CasesPercentage  
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Countries with highest infection rate

Select Location,  Max(total_cases) as MaxTotalCases,  population, (Max(total_cases)/population)*100 as MaxInfectionRate  
From PortfolioProject..CovidDeaths
where continent is not null
group by Location, population
order by 4 desc
--OR

Select Location,  Max(total_cases) as MaxTotalCases,  population, Max((total_cases/population)*100) as MaxInfectionRate  
From PortfolioProject..CovidDeaths
where continent is not null
group by Location, population
order by 4 desc

-- Countries with highest death count per population
Select Location, Population,  Max(cast(total_deaths as int))as MaxDeaths, (Max(total_deaths)/population)*100 as MaxDeathPercentage  
From PortfolioProject..CovidDeaths
where continent is not null
Group by  location, population
order by 4 desc

Select Location, Population,  Max(cast(total_deaths as int))as MaxDeaths, Max((cast(total_deaths as int)/population))*100 as MaxDeathPercentage  
From PortfolioProject..CovidDeaths
where continent is not null
Group by  location, population
order by 4 desc

--Break down into continents

-- continents with highest infection rate

Select continent,  Max(total_cases) as MaxTotalCases,  Max(population), (Max(total_cases)/Max(population))*100 as MaxInfectionRate  
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 4 desc

--Global nos.

 Select  date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage   
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 4 desc

 Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage   
From PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

-- Total population vs vaccination
Select dea.location, dea.date, vac.total_vaccinations, population, (vac.total_vaccinations)/(population) * 100 as VaccinationPercentage 
From PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 5 desc

 Select vac.location, vac.date, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int)) OVER(Partition By vac.location order by vac.date) as TotalVaccinations,population
From PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 1,2

 --Use CTE for Using TotalVaccinations

 WITH PopVsVac ( Location, date, new_vaccinations, TotalVaccinations,population)
 as
 ( Select vac.location, vac.date, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int)) OVER(Partition By vac.location order by vac.date) as TotalVaccinations,population
From PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null)
 --order by 1,2 

 Select *, ( TotalVaccinations/population) * 100 As VacPercentage
 From PopVsVac
 order by 6 desc

 --Use TempTable for Using TotalVaccinations
 
 DROP TABLE IF EXISTS #VaccinationPercantage
 CREATE TABLE #VaccinationPercantage(
 Location varchar(50),
 date datetime,
 new_vaccinations numeric,
 TotalVaccinations numeric,
 population numeric)

 INSERT INTO #VaccinationPercantage
 Select vac.location, vac.date, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int)) OVER(Partition By vac.location order by vac.date) as TotalVaccinations,population
From PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null

  Select *, ( TotalVaccinations/population) * 100  As VacPercentage
 From #VaccinationPercantage
 order by 6 desc

 -- Creating a View 
USE PortfolioProject
GO
 Create View VaccinationPercantage as
  Select vac.location, vac.date, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int)) OVER(Partition By vac.location order by vac.date) as TotalVaccinations,population
From PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 1,2

 select * 
 from VaccinationPercantage
