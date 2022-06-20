# Explore Covid Data with SQL

## Data and Setup

This data is a snapshot from [https://ourworldindata.org/covid-deaths](https://ourworldindata.org/covid-deaths) 
at [ourworldindata.org](https://ourworldindata.org).

Direct link to the current data:
[https://covid.ourworldindata.org/data/owid-covid-data.csv](https://covid.ourworldindata.org/data/owid-covid-data.csv)

I'm grabbing the data with:
```
curl https://covid.ourworldindata.org/data/owid-covid-data.csv > owid-covid-data.csv
```

I'm using SQL Server Management Studio.

Here is the downloaded data [owid-covid-data.csv](https://fpassow.github.io/world_data/owid_covid/owid-covid-data.csv)
 and my script for updating it in SQL Server [](https://fpassow.github.io/world_data/owid_covid/reload_from_csv.sql)

## Exploration
Visualizations are great. But let's see what we can do with just SQL queries.

We will look for interesting things happening in a country in a specific month. The queries are in-line here. And the actual code is at
[here](https://fpassow.github.io/world_data/owid_covid/queries.csv)

```
USE [world_data]
```
### REPORTED NEW CASES
```
-- Create a temp table with number of reported new cases vs population
--  monthly per country.
--  (Note: "Null value is eliminated by an aggregate or other SET operation." 
--   is what we want to happen. And I think turning warnings off would be bad.)
DROP TABLE IF EXISTS #monthly_cases;
SELECT 
  [location],
  year([date]) AS [Year],
  month([date]) AS [MonthNum],
  datename(month, [date]) AS [MonthName],
  max([population]) as [MonthlyPopulation], 
  1000 * sum([new_cases])/max([population]) AS [MonthlyNewCasesPerThousand]
INTO #monthly_cases
FROM [world_data].[dbo].[owid_covid]
WHERE [continent] IS NOT NULL   -- Eliminates non-countries like "Asia" or "High income"
GROUP BY [location], year([date]), month([date]), datename(month, [date]);
```

```
-- "Biggest Outbreaks"
-- Top 50 reported numbers of new cases for a country in one month, relative to population,
SELECT TOP(50) 
  [Location] AS [Country],
  [Year],
  [MonthName],
  round([MonthlyNewCasesPerThousand],0) AS [NewCasesPer1000Pop],
  round(1000/[MonthlyNewCasesPerThousand], 2) AS [One_in_X_people_was_known_to_get_Covid]
FROM #monthly_cases
ORDER BY [MonthlyNewCasesPerThousand] DESC;
```

|Country                        |Year|MonthName|NewCasesPer1000Pop|One_in_X_people_was_known_to_get_Covid|
|-------------------------------|----|---------|------------------|--------------------------------------|
|Falkland Islands               |2022|May      |428               |2.34                                  |
|Faeroe Islands                 |2022|February |298               |3.36                                  |
|Faeroe Islands                 |2022|January  |283               |3.54                                  |
|South Korea                    |2022|March    |197               |5.08                                  |
|Denmark                        |2022|February |176               |5.69                                  |
|Cook Islands                   |2022|April    |173               |5.77                                  |
|Iceland                        |2022|February |169               |5.93                                  |
|Israel                         |2022|January  |163               |6.13                                  |
|Denmark                        |2022|January  |162               |6.18                                  |
|Brunei                         |2022|March    |161               |6.23                                  |
|Andorra                        |2022|January  |158               |6.33                                  |
|Saint Pierre and Miquelon      |2022|March    |154               |6.51                                  |
|Montserrat                     |2022|May      |148               |6.74                                  |
|Greenland                      |2022|January  |142               |7.02                                  |
|Iceland                        |2022|March    |140               |7.15                                  |
|Latvia                         |2022|February |139               |7.17                                  |
|San Marino                     |2022|January  |138               |7.26                                  |
|Saint Pierre and Miquelon      |2022|January  |137               |7.3                                   |
|France                         |2022|January  |136               |7.35                                  |
|Bonaire Sint Eustatius and Saba|2022|January  |136               |7.36                                  |
|Austria                        |2022|March    |129               |7.72                                  |
|Saint Pierre and Miquelon      |2022|April    |129               |7.76                                  |
|Portugal                       |2022|January  |128               |7.82                                  |
|Gibraltar                      |2022|January  |126               |7.93                                  |
|Seychelles                     |2022|January  |125               |7.98                                  |
|Cyprus                         |2022|March    |121               |8.28                                  |
|Slovenia                       |2022|January  |119               |8.42                                  |
|Estonia                        |2022|February |118               |8.45                                  |
|Palau                          |2022|February |118               |8.46                                  |
|Aruba                          |2022|January  |117               |8.55                                  |
|New Caledonia                  |2022|February |117               |8.55                                  |
|Hong Kong                      |2022|March    |117               |8.57                                  |
|Liechtenstein                  |2022|March    |114               |8.74                                  |
|Cook Islands                   |2022|March    |112               |8.89                                  |
|Iceland                        |2022|January  |110               |9.08                                  |
|New Zealand                    |2022|March    |108               |9.25                                  |
|Georgia                        |2022|February |108               |9.27                                  |
|Brunei                         |2022|February |107               |9.38                                  |
|Netherlands                    |2022|February |106               |9.42                                  |
|Switzerland                    |2022|January  |102               |9.82                                  |
|Slovakia                       |2022|February |101               |9.91                                  |
|Cyprus                         |2022|January  |100               |9.96                                  |
|Curacao                        |2022|January  |96                |10.43                                 |
|Isle of Man                    |2022|January  |93                |10.78                                 |
|Austria                        |2022|February |92                |10.82                                 |
|Belgium                        |2022|January  |90                |11.08                                 |
|Palau                          |2022|January  |89                |11.2                                  |
|Slovenia                       |2022|February |87                |11.43                                 |
|Netherlands                    |2022|March    |87                |11.47                                 |
|Andorra                        |2021|December |86                |11.68                                 |


-- Top 100 as above, but only for countries with at least ten million people
SELECT TOP(100) 
  [Location] AS [Country],
  [Year],
  [MonthName],
  round([MonthlyNewCasesPerThousand],0) AS [NewCasesPer1000Pop],
  round(1000/[MonthlyNewCasesPerThousand], 2) AS [One_in_X_people_was_known_to_get_Covid]
FROM #monthly_cases
WHERE [MonthlyPopulation] > 10000000
ORDER BY [MonthlyNewCasesPerThousand] DESC;


-- Next, look at months in calendar order, noting countries and months where at least fifty people in every thousand 
-- were reported as getting Covid during that month.
SELECT
  [Location] AS [Country],
  [Year],
  [MonthName],
  round([MonthlyNewCasesPerThousand],0) AS [NewCasesPer1000Pop],
  round(1000/[MonthlyNewCasesPerThousand], 2) AS [One_in_X_people_was_known_to_get_Covid]
FROM #monthly_cases
WHERE [MonthlyNewCasesPerThousand] >= 50
ORDER BY [Year],[MonthNum], [MonthlyNewCasesPerThousand] DESC;


-- As above, for countries with at least a ten million people.
SELECT
  [Location] AS [Country],
  [Year],
  [MonthName],
  round([MonthlyNewCasesPerThousand],0) AS [NewCasesPer1000Pop],
  round(1000/[MonthlyNewCasesPerThousand], 2) AS [One_in_X_people_was_known_to_get_Covid]
FROM #monthly_cases
WHERE ([MonthlyNewCasesPerThousand] >= 10) AND ([MonthlyPopulation] > 10000000)
ORDER BY [Year],[MonthNum], [MonthlyNewCasesPerThousand] DESC;


-- Same as above, but group the rows for each country together.
SELECT
  [Location] AS [Country],
  [Year],
  [MonthName],
  round([MonthlyNewCasesPerThousand],0) AS [NewCasesPer1000Pop],
  round(1000/[MonthlyNewCasesPerThousand], 2) AS [One_in_X_people_was_known_to_get_Covid]
FROM #monthly_cases
WHERE ([MonthlyNewCasesPerThousand] >= 10) AND ([MonthlyPopulation] > 10000000)
ORDER BY [Country], [Year],[MonthNum], [MonthlyNewCasesPerThousand] DESC;


-- Find countries with the most months during which more than 10 new cases were reported per thousand people
SELECT [Location], count(*) as [Months]
FROM #monthly_cases
WHERE [MonthlyNewCasesPerThousand] >= 10
GROUP BY [Location]
HAVING count(*) > 5
ORDER BY [Months] DESC, [Location];


-- As above, for populations of at least ten million
SELECT [Location], count(*) as [Months]
FROM #monthly_cases
WHERE ([MonthlyNewCasesPerThousand] >= 10) AND ([MonthlyPopulation] > 10000000)
GROUP BY [Location]
HAVING count(*) > 5
ORDER BY [Months] DESC, [Location];


-- VACCINATIONS --

-- Create a temp table with monthly data per country,
--   and number of vaccinations vs population
DROP TABLE IF EXISTS #monthly_vac;
SELECT 
  [location],
  year([date]) AS [Year],
  month([date]) AS [MonthNum],
  datename(month, [date]) AS [MonthName],
  max([population]) as [MonthlyPopulation], 
  1000 * sum([new_vaccinations])/max([population]) AS [MonthlyNewVacPerThousand]
INTO #monthly_vac
FROM [world_data].[dbo].[owid_covid]
WHERE [continent] IS NOT NULL   -- Eliminates non-countries like "Asia" or "High income"
GROUP BY [location], year([date]), month([date]), datename(month, [date]);


-- Biggest Vaccination Drives:
-- Top 50 country+month with the largest number of vaccinations, relative to population
SELECT TOP(50) 
  [Location] AS [Country],
  [Year],
  [MonthName],
  round([MonthlyNewVacPerThousand],0) AS [NewVacPer1000Pop]
FROM #monthly_vac
ORDER BY [MonthlyNewVacPerThousand] DESC;


-- Vaccination Drives Over Time:
-- In calendar order, display all countries+months with at least one person in every five getting a vaccination during that month.
SELECT [Location], [Year], [MonthName], round([MonthlyNewVacPerThousand], 0) AS [JabsPerThousandPeople]
FROM #monthly_vac
WHERE [MonthlyNewVacPerThousand] >= 200
ORDER BY [Year], [MonthNum], [Location];


-- As above, only showing countries with population of ten million or more.
SELECT [Location], [Year], [MonthName], round([MonthlyNewVacPerThousand], 0) AS [JabsPerThousandPeople]
FROM #monthly_vac
WHERE ([MonthlyNewVacPerThousand] >= 200) AND ([MonthlyPopulation] > 10000000)
ORDER BY [Year], [MonthNum], [Location];


-- "Most Heavily Vaccinated Countries"
-- Top 50 countries by average vaccinations per person over all time, 
--   rounded to 3 decimal places, for countries where data is available.
SELECT TOP(50) [location], round(sum([MonthlyNewVacPerThousand])/1000, 3) AS [AverageJabsPerPerson]
FROM #monthly_vac
GROUP BY [location]
HAVING sum([MonthlyNewVacPerThousand]) IS NOT NULL
ORDER BY sum([MonthlyNewVacPerThousand]) DESC;


-- As above, for countries with ten million people or more
SELECT TOP(50) [location], round(sum([MonthlyNewVacPerThousand])/1000, 3) AS [AverageJabsPerPerson]
FROM #monthly_vac
WHERE [MonthlyPopulation] >= 10000000
GROUP BY [location]
HAVING sum([MonthlyNewVacPerThousand]) IS NOT NULL
ORDER BY sum([MonthlyNewVacPerThousand]) DESC;


-- REPORTED NEW DEATHS --

-- Create a temp table with monthly data per country,
--   and count of deaths vs population
DROP TABLE IF EXISTS #monthly_deaths;
SELECT 
  [location],
  year([date]) AS [Year],
  month([date]) AS [MonthNum],
  datename(month, [date]) AS [MonthName],
  max([population]) as [MonthlyPopulation], 
  1000000 * sum([new_deaths])/max([population]) AS [MonthlyNewDeathsPerMillion]
INTO #monthly_deaths
FROM [world_data].[dbo].[owid_covid]
WHERE [continent] IS NOT NULL   -- Eliminates non-countries like "Asia" or "High income"
GROUP BY [location], year([date]), month([date]), datename(month, [date]);


-- What were the largest number of covid deaths in one month and one country, relative to population?
SELECT TOP(50) 
  [Location] AS [Country],
  [Year],
  [MonthName],
  round([MonthlyNewDeathsPerMillion], 0) AS [NewDeathsPerMillionPop]
FROM #monthly_deaths
ORDER BY [MonthlyNewDeathsPerMillion] DESC;


-- Months with High Death Rates:
-- In calendar order, show when a country had at least 300 deaths per million population. (Or at least one death per 3333 people.)
SELECT [Location], [Year], [MonthName], round([MonthlyNewDeathsPerMillion], 0) AS [DeathsPerMillionPeople]
FROM #monthly_deaths
WHERE [MonthlyNewDeathsPerMillion] >= 300
ORDER BY [Year], [MonthNum], [Location];

-- As above, for countries with more than ten million people.
-- In this case the threshold is 200 deaths per million population. (Or at least one death per 5000 people.)
SELECT [Location], [Year], [MonthName], round([MonthlyNewDeathsPerMillion], 0) AS [DeathsPerMillionPeople]
FROM #monthly_deaths
WHERE ([MonthlyNewDeathsPerMillion] >= 200) AND ([MonthlyPopulation] > 10000000)
ORDER BY [Year], [MonthNum], [Location];


-- Top 50 countries in terms of total deaths vs population
SELECT TOP(50) [location], round(sum([MonthlyNewDeathsPerMillion]), 0) AS [TotalDeathsPerMillionPop]
FROM #monthly_deaths
GROUP BY [location]
HAVING sum([MonthlyNewDeathsPerMillion]) IS NOT NULL
ORDER BY sum([MonthlyNewDeathsPerMillion]) DESC;

-- As above, for countries with ten million people or more
SELECT TOP(50) [location], round(sum([MonthlyNewDeathsPerMillion]), 0) AS [TotalDeathsPerMillionPop]
FROM #monthly_deaths
WHERE [MonthlyPopulation] >= 10000000
GROUP BY [location]
HAVING sum([MonthlyNewDeathsPerMillion]) IS NOT NULL
ORDER BY sum([MonthlyNewDeathsPerMillion]) DESC;

