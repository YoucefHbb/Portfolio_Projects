create database Portfolio_Project

select *
from[Portfolio_Project]..CovidDeaths
where continent is not null
order by 3,4

select *
from  [Portfolio_Project]..CovidVaccinations
order by 3,4


	-- Select the data that we are going to be using 

	Select location , date , total_cases , new_cases , total_deaths , population
	from [Portfolio_Project]..CovidDeaths
	where continent is not null
	order by 1,2

	-- Looking at Total cases vs Total Deaths 
	-- Shows likelihood of dying if you contract covid in your country

	select location , date , total_cases , total_deaths , (CAST(total_deaths as float)/ CAST(total_cases as float))*100 DeathPercentage
	from Portfolio_Project..CovidDeaths
	where continent is not null and location like 'algeria'
	order by 1,2


	-- Looking at total cases vs population
	-- Shows what percentage of population got covid

	select location , date , population, total_cases , (CAST(total_cases as float)/ CAST(population as float))*100 InfectionRate
	from Portfolio_Project..CovidDeaths
	where continent is not null and location like 'algeria'
	order by 1,2

	-- Looking at countries with highest infectoin rate	compared to population

	select location , population , SUM(new_cases) HighestInfectionCount , (CAST(SUM(new_cases) as float)/ CAST(population as float))*100 PercentPopulatoinInfected
	from Portfolio_Project..CovidDeaths
	where continent is not null 
	group by location , population
	order by 4 desc

	-- Showing countries with highest death count per population

	select continent, location , population , max(total_deaths) TotalDeathCount
	from Portfolio_Project..CovidDeaths
	where continent is not null
	group by continent, location , population
	order by 1 ,3 desc

	-- Let's break things down by continent
	-- Showing continents with the highest death count per population	

	select location, max(total_deaths) TotalDeathCount
	from Portfolio_Project..CovidDeaths
	where continent is null and location not in ('world' , 'Upper middle income' , 'European Union' , 'High income' , 'Lower middle income' , 'European Union' , 
	'Low income' )
	group by location
	order by 2 desc

	--this is for the sake of visualization in tableau and the drill down effect(although it's wrong) BUT I THINK I CORRECTED IT 

	select continent, sum(new_deaths) TotalDeathCount
	from Portfolio_Project..CovidDeaths
	where continent is not null 
	group by continent
	order by 2 desc


	-- GLOBAL NUMBERS 

	select date, sum(new_cases) Total_cases ,SUM(new_deaths) Totla_deaths,
	case
	when (sum(new_cases) = 0) then 0
	else
	(cast(SUM(new_deaths) as float)/cast(SUM(new_cases) as float))*100 
	end
	as DeathPercentage
	from Portfolio_Project..CovidDeaths
	where continent is not null 
	group by date
	order by 1


	select  sum(new_cases) Total_cases ,SUM(new_deaths) Totla_deaths,
	case
	when (sum(new_cases) = 0) then 0
	else
	(cast(SUM(new_deaths) as float)/cast(SUM(new_cases) as float))*100 
	end
	as DeathPercentage
	from Portfolio_Project..CovidDeaths
	where continent is not null 
	--group by date
	order by 1



	-- Looking at total vaccination vs population

	select cvdv.continent , cvdv.location , cvdv.date ,population , new_vaccinations, 
	sum(cvdv.new_vaccinations) over (partition by cvdd.location order by cvdd.location , cvdd.date) RollingPeopleVaccinated
	from Portfolio_Project..CovidDeaths cvdd
	join Portfolio_Project..CovidVaccinations cvdv
		on cvdd.continent = cvdv.continent
		and cvdd.location = cvdv.location
		and cvdd.date = cvdv.date
	where cvdd.continent is not null
	order by 2 ,3

	-- We are going to use a CTE 
	
	with PopvsVac as 
	(select cvdv.continent , cvdv.location , cvdv.date ,population , new_vaccinations,
	sum(cvdv.new_vaccinations) over (partition by cvdd.location order by cvdd.location , cvdd.date) RollingPeopleVaccinated
	from Portfolio_Project..CovidDeaths cvdd
	join Portfolio_Project..CovidVaccinations cvdv
		on cvdd.continent = cvdv.continent
		and cvdd.location = cvdv.location
		and cvdd.date = cvdv.date
	where cvdd.continent is not null
	)

	select * , (cast(RollingPeopleVaccinated as float)/cast(population as float))*100 PeopleVaccinated
	from PopvsVac


	-- Now let's use TEMP tables

	drop table if exists #PercentPopulationVaccinated
	create table #PercentPopulationVaccinated 
	(
	continent nvarchar(50) ,
	location nvarchar(50),
	date date ,
	population bigint ,
	new_vaccinations bigint,
	RollingPeopleVaccinated float
	);

	insert into #PercentPopulationVaccinated
	select cvdv.continent , cvdv.location , cvdv.date ,population , new_vaccinations, 
	sum(cvdv.new_vaccinations) over (partition by cvdd.location order by cvdd.location , cvdd.date) RollingPeopleVaccinated
	from Portfolio_Project..CovidDeaths cvdd
	join Portfolio_Project..CovidVaccinations cvdv
		on cvdd.continent = cvdv.continent
		and cvdd.location = cvdv.location
		and cvdd.date = cvdv.date
	where cvdd.continent is not null

	select * , (RollingPeopleVaccinated/population)*100 PeopleVaccinated
	from #PercentPopulationVaccinated
	order by 2, 3


	-- Creating view to store data for later visualizations 

	CREATE VIEW PercentPopulationVaccinated as
	select cvdv.continent , cvdv.location , cvdv.date ,population , new_vaccinations, 
	sum(cvdv.new_vaccinations) over (partition by cvdd.location order by cvdd.location , cvdd.date) RollingPeopleVaccinated
	from Portfolio_Project..CovidDeaths cvdd
	join Portfolio_Project..CovidVaccinations cvdv
		on cvdd.continent = cvdv.continent
		and cvdd.location = cvdv.location
		and cvdd.date = cvdv.date
	where cvdd.continent is not null


	SELECT *
	FROM PercentPopulationVaccinated
	order by 2 , 3
































