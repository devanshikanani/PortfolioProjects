select *
From PortfolioProject..CovidDeaths
order by 3,4 

/*
select *
From PortfolioProject..CovidVaccinations
order by 3,4 
*/

select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2

--looking at total cases vs population

select Location, date, total_cases, population, (cast (total_cases as int)/population)*100 as CasePercentage
From PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2

--looking at countries with highest infection rate

select Location, MAX(total_cases) as HighestInfectionCount, population, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected DESC

--looking at countries with highest death count per population

select Location, MAX(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount DESC


--break down by continent



--showing continents with highest death count per population

select [location], MAX(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is null
group by [location]
order by TotalDeathCount DESC

--global numbers

select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

--looking at total population vs vaccination

select dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations, 
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac 
on dea.[location] = vac.[location]
and dea.[date] = vac.[date]
where dea.continent is not null
order by 2,3

--Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations, 
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac 
on dea.[location] = vac.[location]
and dea.[date] = vac.[date]
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/population)*100 as PercentPopVaccinated
from PopvsVac


--temp table

drop TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    LOCATION NVARCHAR(255),
    date datetime,
    population NUMERIC,
    new_Vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations, 
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac 
on dea.[location] = vac.[location]
and dea.[date] = vac.[date]
where dea.continent is not null
order by 2,3
select * , (RollingPeopleVaccinated/population)*100 as PercentPopVaccinated
from #PercentPopulationVaccinated