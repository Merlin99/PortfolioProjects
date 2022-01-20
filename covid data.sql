
select * from PortfolioProject..['Covid Vaccinations$'] order by 3,4

-- Select Data that we are going to be starting with

select *
from PortfolioProject..['Covid Death$'] 
where continent is not null
order by 3,4
-- Total Cases vs Total Deaths

select location,date,total_cases,new_cases,total_deaths,population 
from PortfolioProject..['Covid Death$'] 
order by 1,2

-- Shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercent 
from PortfolioProject..['Covid Death$'] 
where location like '%germany%'
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select 
location,date,total_cases,population,(total_cases/population)*100 as populationPercentInfected 
from PortfolioProject..['Covid Death$'] 
where location like '%germany%'
order by 1,2

--Countries with Highest Infection Rate compared to Population

select 
location,population,MAX(total_cases) as HighestInfectionCount ,Max((total_cases/population))*100 as populationPercentInfected 
from PortfolioProject..['Covid Death$'] 
where continent is not null
group by location,population
order by 1,2

-- Countries with Highest Death Count per Population

select 
location,MAX(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject..['Covid Death$'] 
where continent is not null
group by location
order by totalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population


select 
continent,MAX(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject..['Covid Death$'] 
where continent is not null
group by continent
order by totalDeathCount desc


-- GLOBAL NUMBERS

--select 
--date,SUM(cast(new_deaths as int)),SUM(new_cases), sUM(convert(int,new_deaths )/SUM(new_cases)
--from PortfolioProject..['Covid Death$'] 
--where continent is not null
--group by date
--order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.Location order by death.date,death.location ) as PeopleVaccinated
From PortfolioProject..['Covid Death$'] death
Join PortfolioProject..['Covid Vaccinations$'] vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

with percentvac( continent,location,date,population,new_vaccinations,PeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.Location order by death.date,death.location  ) as PeopleVaccinated
From PortfolioProject..['Covid Death$'] death
Join PortfolioProject..['Covid Vaccinations$'] vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null 
)
select*,(PeopleVaccinated/population)*100
from percentvac


-- Using Temp Table to perform Calculation on Partition By in previous query


DROP Table if exists #vacpoppercent
Create table #vacpoppercent
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
New_Vaccinations numeric,
PeopleVaccinated  numeric)

Insert into #vacpoppercent
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.Location order by death.date,death.location  ) as PeopleVaccinated
From PortfolioProject..['Covid Death$'] death
Join PortfolioProject..['Covid Vaccinations$'] vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null 

select*,(PeopleVaccinated/population)*100
from #vacpoppercent


-- Creating View to store data for later visualizations

create view totalDeathCount as
select 
continent,MAX(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject..['Covid Death$'] 
where continent is not null
group by continent
--order by totalDeathCount desc
