-- Which countries have data for 2020 or after
SELECT DISTINCT CountryOrArea
FROM [world_data].[dbo].[city_population]
WHERE Year >= 2020 AND Sex = 'Both Sexes'

-- Try 2018... Still not enough countries
SELECT DISTINCT CountryOrArea
FROM [world_data].[dbo].[city_population]
WHERE Year >= 2018 AND Sex = 'Both Sexes'

-- Let's just get the most recent population number for each city.
WITH numbered_cte AS (
    SELECT CountryOrArea, City, Year, Value, 
        row_number() OVER (PARTITION BY CountryOrArea, City ORDER BY Year DESC) AS RowNumber
    FROM [world_data].[dbo].[city_population]
	WHERE Sex = 'Both Sexes'
)
SELECT CountryOrArea, City, Year, Value
FROM numbered_cte
WHERE RowNumber = 1

-- Move the logic for looking at only the latest year into a CTE
-- Add another CTE to number the rows according to population of cities within their country
-- And select each country's most populous city.
WITH year_number_cte AS (
    SELECT CountryOrArea, City, Year, Value, 
        row_number() OVER (PARTITION BY CountryOrArea, City ORDER BY Year DESC) AS YearRowNumber
    FROM [world_data].[dbo].[city_population]
	WHERE Sex = 'Both Sexes'
),
latest_year_cte AS (
    SELECT CountryOrArea, City, Year, Value
    FROM year_number_cte
    WHERE YearRowNumber = 1
),
pop_number_cte AS (
    SELECT CountryOrArea, City, Value, 
        row_number() OVER (PARTITION BY CountryOrArea ORDER BY Value DESC) AS PopRowNumber
	FROM latest_year_cte
)
SELECT CountryOrArea, City, Value
FROM pop_number_cte
WHERE PopRowNumber = 1



-- That's enough complexity. 
-- Let's make a temp table of the most populous city in each country, based on latest available data
DROP TABLE IF EXISTS #city_populations_nocodes;
WITH year_number_cte AS (
    SELECT CountryOrArea, City, Year, Value, 
        row_number() OVER (PARTITION BY CountryOrArea, City ORDER BY Year DESC) AS YearRowNumber
    FROM [world_data].[dbo].[city_population]
	WHERE Sex = 'Both Sexes'
),
latest_year_cte AS (
    SELECT CountryOrArea, City, Year, Value
    FROM year_number_cte
    WHERE YearRowNumber = 1
),
pop_number_cte AS (
    SELECT CountryOrArea, City, Value, 
        row_number() OVER (PARTITION BY CountryOrArea ORDER BY Value DESC) AS PopRowNumber
	FROM latest_year_cte
)
SELECT CountryOrArea, City, Value
INTO #city_populations_nocodes
FROM pop_number_cte
WHERE PopRowNumber = 1

-- Check our temp table
SELECT * FROM #city_populations_nocodes;

-- Make another temp table, this time with country codes,
-- Use our table mapping country names to ISO codes
DROP TABLE IF EXISTS #city_populations;
SELECT city_pops.CountryOrArea, City, Value AS CityPop, ISOalpha3
INTO #city_populations
FROM #city_populations_nocodes AS city_pops
JOIN [world_data].[dbo].[country_codes] AS codes
ON city_pops.CountryOrArea = codes.CountryOrArea;

-- Check our final temp table of each countries largest city, with ISO country codes
SELECT * FROM #city_populations;



-- NOW WE CAN ADD POPULATIONS OF COUNTRIES' LARGEST CITIES TO SOME OF OUR COVID RESULTS

-- Create a temp table with number of reported new cases vs population
--  monthly per country.
-- And this time we include the iso_code column.
DROP TABLE IF EXISTS #monthly_cases;
SELECT 
  [location],
  [iso_code],
  year([date]) AS [Year],
  month([date]) AS [MonthNum],
  datename(month, [date]) AS [MonthName],
  max([population]) as [MonthlyPopulation], 
  1000 * sum([new_cases])/max([population]) AS [MonthlyNewCasesPerThousand]
INTO #monthly_cases
FROM [world_data].[dbo].[owid_covid]
WHERE [continent] IS NOT NULL   -- Eliminates non-countries like "Asia" or "High income"
GROUP BY [location], [iso_code], year([date]), month([date]), datename(month, [date]);


-- Find countries with the most months during which more than 10 new cases were reported per thousand people
-- and make it a CTE
-- then JOIN with the city population data above, using the ISO country codes
-- and display in descending order of city population
WITH covid_months_cte AS (
SELECT [Location], iso_code, count(*) as [Months]
FROM #monthly_cases
WHERE ([MonthlyNewCasesPerThousand] >= 10) 
GROUP BY [Location], iso_code
HAVING count(*) > 0
)
SELECT covid_months_cte.Location AS Location, 
       covid_months_cte.iso_code AS CountryCode, 
	   covid_months_cte.Months AS Months, 
	   #city_populations.City AS LargestCity, 
	   #city_populations.CityPop As CityPopulation
FROM covid_months_cte
JOIN #city_populations
ON covid_months_cte.iso_code = #city_populations.ISOalpha3
ORDER BY CityPopulation DESC

-- Conclusion: This query does not show more "outbreaks" for countries with large cities.
-- However, the source of the covid data mentions that numbers are for *reported* cases,
-- which is influenced by the fraction of actual covid cases identified by a countries medical system.
-- TODO: Look at population of largest city vs percentage of positive tests
          or adjust cases by a countries "testing rate" (tests/population).


