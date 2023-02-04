Select*
From protofolioProject..CovidDeath
Where continent is not null
order by 3,4

--Select*
--From protofolioProject..CovidVaccination$
--order by 3,4

--select the data that was going to be working on it
Select location,date,total_cases,new_cases,total_deaths,population
From protofolioProject..CovidDeath
Where continent is not null
order by 1,2

--Looking at total cases VS total Deaths
--shows likelihood of dying if you contract covid in your country
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_percentage
From protofolioProject..CovidDeath
Where location LIKE '%EGYPT%' And continent is not null
order by 1,2


--Looking at  total cases vs population
-- shows what perscentage of population got covid

Select location,date,population,total_cases,(total_cases/population)*100 AS populationinfectedpercentage
From protofolioProject..CovidDeath
Where location LIKE '%EGYPT%'
order by 1,2

-- looking at countries with the Highest infection rate compared to population
Select location,population, MAX(total_cases) as Highest_infected_Count,
MAX((total_cases/population))*100 AS the_Highest_infection_rate
From protofolioProject..CovidDeath
Where continent is not null
Group by location,population
order by the_Highest_infection_rate desc

--Looking for countries with Death count per population
Select location,MAX(cast(total_deaths as int)) AS Total_death_count
From protofolioProject..CovidDeath
Where continent is not null
Group by location
order by Total_death_count desc

--Looking for continent with Death count per population
Select continent,MAX(cast(total_deaths as int)) AS Total_death_count
From protofolioProject..CovidDeath
Where continent is not null
Group by continent
order by Total_death_count desc

-- Showing contintents With the highest death count per population
Select continent,MAX(cast(total_deaths as int)) AS Total_death_count
From protofolioProject..CovidDeath
Where continent is not null
Group by continent
order by Total_death_count desc

--Global Number
Select SUM(new_cases) AS total_cases ,SUM(cast(new_deaths as int)) AS Total_deaths,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
From protofolioProject..CovidDeath
Where continent is not null
order by 1,2

--Looking at total population VS vaccinations
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
From protofolioProject..CovidDeath dea
Join protofolioProject..CovidVaccination$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--Looking at Total population VS Vaccinations
Select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location )
From protofolioProject..CovidDeath dea
Join protofolioProject..CovidVaccination$ vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is NOT null
ORDER BY 2,3

--USE CTE
with PopVac(Continent,Location,Date,population,new_vaccinations,RollingpeopleVaccinated )
as
(
Select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location
Order By dea.location, dea.Date) as RollingpeopleVaccinated
From protofolioProject..CovidDeath dea
Join protofolioProject..CovidVaccination$ vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is NOT null
--ORDER BY 2,3
)

Select*,(RollingpeopleVaccinated/population)*100
from PopVac


--teemp table
Create Table #percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingpeopleVaccinated numeric
)

Insert into #percentpopulationvaccinated
Select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location
Order By dea.location, dea.Date) as RollingpeopleVaccinated
From protofolioProject..CovidDeath dea
Join protofolioProject..CovidVaccination$ vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is NOT null
--ORDER BY 2,3

Select*,(RollingpeopleVaccinated/population)*100
from #percentpopulationvaccinated

create view percentpopulationvaccinated as
Select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location
Order By dea.location, dea.Date) as RollingpeopleVaccinated
From protofolioProject..CovidDeath dea
Join protofolioProject..CovidVaccination$ vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is NOT null
--ORDER BY 2,3
