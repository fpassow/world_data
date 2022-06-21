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

## REPORTED NEW CASES
Create a temp table with number of reported new cases vs population, monthly per country.

```
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

### Biggest Outbreaks
Top 50 reported numbers of new cases for a country in one month, relative to population.

```
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

### Biggest Outbreaks in Large Countries
Top 100 reported numbers of new cases for a country in one month, relative to population, but only for countries with at least ten million people.

```
SELECT TOP(100) 
  [Location] AS [Country],
  [Year],
  [MonthName],
  round([MonthlyNewCasesPerThousand],0) AS [NewCasesPer1000Pop],
  round(1000/[MonthlyNewCasesPerThousand], 2) AS [One_in_X_people_was_known_to_get_Covid]
FROM #monthly_cases
WHERE [MonthlyPopulation] > 10000000
ORDER BY [MonthlyNewCasesPerThousand] DESC;
```

|Country       |Year|MonthName|NewCasesPer1000Pop|One_in_X_people_was_known_to_get_Covid|
|--------------|----|---------|------------------|--------------------------------------|
|South Korea   |2022|March    |197               |5.08                                  |
|France        |2022|January  |136               |7.35                                  |
|Portugal      |2022|January  |128               |7.82                                  |
|Netherlands   |2022|February |106               |9.42                                  |
|Belgium       |2022|January  |90                |11.08                                 |
|Netherlands   |2022|March    |87                |11.47                                 |
|Australia     |2022|January  |85                |11.82                                 |
|Netherlands   |2022|January  |81                |12.32                                 |
|Italy         |2022|January  |80                |12.43                                 |
|Taiwan        |2022|May      |80                |12.44                                 |
|Germany       |2022|March    |79                |12.69                                 |
|Spain         |2022|January  |78                |12.75                                 |
|South Korea   |2022|April    |76                |13.16                                 |
|Sweden        |2022|January  |74                |13.45                                 |
|Greece        |2022|January  |70                |14.21                                 |
|Portugal      |2022|February |68                |14.68                                 |
|Portugal      |2022|May      |64                |15.52                                 |
|Vietnam       |2022|March    |62                |16.04                                 |
|United States |2022|January  |61                |16.43                                 |
|Argentina     |2022|January  |60                |16.74                                 |
|Germany       |2022|February |59                |17.02                                 |
|Greece        |2022|March    |59                |17.04                                 |
|Australia     |2022|April    |54                |18.69                                 |
|France        |2022|February |53                |18.94                                 |
|Australia     |2022|May      |53                |18.97                                 |
|Czechia       |2022|February |52                |19.12                                 |
|United Kingdom|2022|January  |52                |19.24                                 |
|Australia     |2022|March    |52                |19.27                                 |
|Czechia       |2022|January  |50                |19.94                                 |
|South Korea   |2022|February |47                |21.29                                 |
|Chile         |2022|February |47                |21.47                                 |
|Greece        |2022|February |46                |21.56                                 |
|France        |2022|April    |45                |22.24                                 |
|France        |2022|March    |43                |23.15                                 |
|Germany       |2022|April    |41                |24.3                                  |
|United Kingdom|2021|December |40                |25.09                                 |
|Jordan        |2022|February |40                |25.27                                 |
|Taiwan        |2022|June     |38                |26.38                                 |
|Sweden        |2022|February |36                |27.41                                 |
|Czechia       |2021|November |36                |27.7                                  |
|Portugal      |2022|March    |35                |28.46                                 |
|Belgium       |2021|November |35                |28.69                                 |
|Belgium       |2022|February |35                |28.93                                 |
|France        |2021|December |34                |29.34                                 |
|United Kingdom|2022|March    |33                |29.93                                 |
|Germany       |2022|January  |32                |31.48                                 |
|Italy         |2022|March    |31                |32.46                                 |
|Russia        |2022|February |31                |32.49                                 |
|Netherlands   |2021|November |30                |32.9                                  |
|Czechia       |2021|December |30                |32.93                                 |
|Portugal      |2021|January  |30                |33.14                                 |
|Italy         |2022|April    |30                |33.15                                 |
|Italy         |2022|February |30                |33.54                                 |
|Belgium       |2021|December |29                |34.28                                 |
|Turkey        |2022|February |29                |34.44                                 |
|Portugal      |2022|April    |28                |35.21                                 |
|Netherlands   |2021|December |28                |35.25                                 |
|Greece        |2022|April    |28                |35.34                                 |
|Czechia       |2021|March    |28                |35.86                                 |
|Peru          |2022|January  |28                |35.96                                 |
|Romania       |2022|February |27                |37                                    |
|Belgium       |2020|October  |27                |37.43                                 |
|Greece        |2021|December |26                |38.13                                 |
|Australia     |2022|February |25                |39.24                                 |
|Belgium       |2022|March    |25                |39.6                                  |
|Turkey        |2022|January  |25                |39.79                                 |
|Czechia       |2021|January  |25                |40.3                                  |
|Czechia       |2020|October  |25                |40.57                                 |
|Spain         |2021|December |24                |41.34                                 |
|Portugal      |2021|December |24                |41.95                                 |
|Cuba          |2021|August   |24                |42.19                                 |
|Czechia       |2021|February |23                |42.78                                 |
|Malaysia      |2022|March    |23                |43.17                                 |
|United Kingdom|2022|February |23                |43.18                                 |
|Czechia       |2022|March    |23                |43.3                                  |
|Portugal      |2022|June     |23                |43.43                                 |
|Canada        |2022|January  |22                |44.79                                 |
|Spain         |2022|February |22                |46                                    |
|Romania       |2021|October  |22                |46.16                                 |
|Bolivia       |2022|January  |22                |46.23                                 |
|Jordan        |2021|March    |21                |46.57                                 |
|Chile         |2022|March    |21                |46.87                                 |
|Romania       |2022|January  |21                |46.92                                 |
|Poland        |2022|February |21                |48.4                                  |
|Poland        |2022|January  |21                |48.59                                 |
|Cuba          |2021|September|20                |50.4                                  |
|United States |2020|December |20                |50.72                                 |
|United Kingdom|2021|January  |19                |51.32                                 |
|Malaysia      |2021|August   |19                |51.78                                 |
|Sweden        |2020|December |19                |52.3                                  |
|Greece        |2021|November |19                |52.71                                 |
|United States |2021|December |19                |53.25                                 |
|Chile         |2022|January  |19                |53.44                                 |
|Germany       |2022|May      |18                |54.09                                 |
|United States |2021|January  |18                |54.16                                 |
|United Kingdom|2021|October  |18                |54.47                                 |
|Czechia       |2020|December |18                |54.9                                  |
|Italy         |2021|December |18                |55.02                                 |
|Ukraine       |2022|February |18                |55.35                                 |
|Japan         |2022|February |18                |55.59                                 |

### Outbreaks Over Time
Next, we look at months in calendar order, noting countries and months where at least fifty people in every thousand 
were reported as getting Covid during that month.
```
SELECT
  [Location] AS [Country],
  [Year],
  [MonthName],
  round([MonthlyNewCasesPerThousand],0) AS [NewCasesPer1000Pop],
  round(1000/[MonthlyNewCasesPerThousand], 2) AS [One_in_X_people_was_known_to_get_Covid]
FROM #monthly_cases
WHERE [MonthlyNewCasesPerThousand] >= 50
ORDER BY [Year],[MonthNum], [MonthlyNewCasesPerThousand] DESC;
```

|Country                        |Year|MonthName|NewCasesPer1000Pop|One_in_X_people_was_known_to_get_Covid|
|-------------------------------|----|---------|------------------|--------------------------------------|
|Gibraltar                      |2021|January  |62                |16.24                                 |
|Bonaire Sint Eustatius and Saba|2021|April    |52                |19.42                                 |
|Maldives                       |2021|May      |64                |15.73                                 |
|Seychelles                     |2021|May      |57                |17.57                                 |
|British Virgin Islands         |2021|July     |72                |13.82                                 |
|French Polynesia               |2021|August   |71                |14.04                                 |
|Mongolia                       |2021|September|51                |19.76                                 |
|Mongolia                       |2021|October  |63                |15.98                                 |
|Cayman Islands                 |2021|November |82                |12.26                                 |
|Andorra                        |2021|December |86                |11.68                                 |
|San Marino                     |2021|December |64                |15.72                                 |
|Denmark                        |2021|December |54                |18.46                                 |
|Faeroe Islands                 |2022|January  |283               |3.54                                  |
|Israel                         |2022|January  |163               |6.13                                  |
|Denmark                        |2022|January  |162               |6.18                                  |
|Andorra                        |2022|January  |158               |6.33                                  |
|Greenland                      |2022|January  |142               |7.02                                  |
|San Marino                     |2022|January  |138               |7.26                                  |
|Saint Pierre and Miquelon      |2022|January  |137               |7.3                                   |
|France                         |2022|January  |136               |7.35                                  |
|Bonaire Sint Eustatius and Saba|2022|January  |136               |7.36                                  |
|Portugal                       |2022|January  |128               |7.82                                  |
|Gibraltar                      |2022|January  |126               |7.93                                  |
|Seychelles                     |2022|January  |125               |7.98                                  |
|Slovenia                       |2022|January  |119               |8.42                                  |
|Aruba                          |2022|January  |117               |8.55                                  |
|Iceland                        |2022|January  |110               |9.08                                  |
|Switzerland                    |2022|January  |102               |9.82                                  |
|Cyprus                         |2022|January  |100               |9.96                                  |
|Curacao                        |2022|January  |96                |10.43                                 |
|Isle of Man                    |2022|January  |93                |10.78                                 |
|Belgium                        |2022|January  |90                |11.08                                 |
|Palau                          |2022|January  |89                |11.2                                  |
|Luxembourg                     |2022|January  |85                |11.71                                 |
|Australia                      |2022|January  |85                |11.82                                 |
|Netherlands                    |2022|January  |81                |12.32                                 |
|Monaco                         |2022|January  |81                |12.36                                 |
|Italy                          |2022|January  |80                |12.43                                 |
|Maldives                       |2022|January  |79                |12.59                                 |
|Montenegro                     |2022|January  |79                |12.63                                 |
|Ireland                        |2022|January  |79                |12.63                                 |
|Spain                          |2022|January  |78                |12.75                                 |
|British Virgin Islands         |2022|January  |78                |12.77                                 |
|Cayman Islands                 |2022|January  |75                |13.38                                 |
|Sweden                         |2022|January  |74                |13.45                                 |
|Uruguay                        |2022|January  |73                |13.67                                 |
|Liechtenstein                  |2022|January  |73                |13.68                                 |
|Estonia                        |2022|January  |73                |13.78                                 |
|Norway                         |2022|January  |71                |14.13                                 |
|Bermuda                        |2022|January  |70                |14.2                                  |
|Greece                         |2022|January  |70                |14.21                                 |
|Austria                        |2022|January  |62                |16.01                                 |
|Turks and Caicos Islands       |2022|January  |62                |16.06                                 |
|Latvia                         |2022|January  |62                |16.08                                 |
|United States                  |2022|January  |61                |16.43                                 |
|Georgia                        |2022|January  |61                |16.5                                  |
|Argentina                      |2022|January  |60                |16.74                                 |
|Lithuania                      |2022|January  |59                |16.82                                 |
|Barbados                       |2022|January  |55                |18.13                                 |
|Serbia                         |2022|January  |55                |18.16                                 |
|Grenada                        |2022|January  |54                |18.36                                 |
|Croatia                        |2022|January  |54                |18.39                                 |
|Bahrain                        |2022|January  |53                |18.9                                  |
|United Kingdom                 |2022|January  |52                |19.24                                 |
|Czechia                        |2022|January  |50                |19.94                                 |
|Faeroe Islands                 |2022|February |298               |3.36                                  |
|Denmark                        |2022|February |176               |5.69                                  |
|Iceland                        |2022|February |169               |5.93                                  |
|Latvia                         |2022|February |139               |7.17                                  |
|Estonia                        |2022|February |118               |8.45                                  |
|Palau                          |2022|February |118               |8.46                                  |
|New Caledonia                  |2022|February |117               |8.55                                  |
|Georgia                        |2022|February |108               |9.27                                  |
|Brunei                         |2022|February |107               |9.38                                  |
|Netherlands                    |2022|February |106               |9.42                                  |
|Slovakia                       |2022|February |101               |9.91                                  |
|Austria                        |2022|February |92                |10.82                                 |
|Slovenia                       |2022|February |87                |11.43                                 |
|Norway                         |2022|February |84                |11.85                                 |
|Cayman Islands                 |2022|February |84                |11.91                                 |
|Lithuania                      |2022|February |83                |12.06                                 |
|Liechtenstein                  |2022|February |80                |12.45                                 |
|Bahrain                        |2022|February |80                |12.46                                 |
|Israel                         |2022|February |79                |12.66                                 |
|Gibraltar                      |2022|February |74                |13.6                                  |
|Cyprus                         |2022|February |73                |13.62                                 |
|Singapore                      |2022|February |68                |14.68                                 |
|Portugal                       |2022|February |68                |14.68                                 |
|Switzerland                    |2022|February |67                |14.99                                 |
|French Polynesia               |2022|February |65                |15.33                                 |
|Germany                        |2022|February |59                |17.02                                 |
|Maldives                       |2022|February |58                |17.36                                 |
|France                         |2022|February |53                |18.94                                 |
|Czechia                        |2022|February |52                |19.12                                 |
|South Korea                    |2022|March    |197               |5.08                                  |
|Brunei                         |2022|March    |161               |6.23                                  |
|Saint Pierre and Miquelon      |2022|March    |154               |6.51                                  |
|Iceland                        |2022|March    |140               |7.15                                  |
|Austria                        |2022|March    |129               |7.72                                  |
|Cyprus                         |2022|March    |121               |8.28                                  |
|Hong Kong                      |2022|March    |117               |8.57                                  |
|Liechtenstein                  |2022|March    |114               |8.74                                  |
|Cook Islands                   |2022|March    |112               |8.89                                  |
|New Zealand                    |2022|March    |108               |9.25                                  |
|Netherlands                    |2022|March    |87                |11.47                                 |
|Switzerland                    |2022|March    |80                |12.53                                 |
|Germany                        |2022|March    |79                |12.69                                 |
|Latvia                         |2022|March    |78                |12.81                                 |
|Singapore                      |2022|March    |68                |14.66                                 |
|Isle of Man                    |2022|March    |67                |14.87                                 |
|Vietnam                        |2022|March    |62                |16.04                                 |
|Slovakia                       |2022|March    |59                |16.83                                 |
|Greece                         |2022|March    |59                |17.04                                 |
|Tonga                          |2022|March    |57                |17.59                                 |
|Australia                      |2022|March    |52                |19.27                                 |
|Luxembourg                     |2022|March    |51                |19.44                                 |
|Denmark                        |2022|March    |51                |19.78                                 |
|Cook Islands                   |2022|April    |173               |5.77                                  |
|Saint Pierre and Miquelon      |2022|April    |129               |7.76                                  |
|South Korea                    |2022|April    |76                |13.16                                 |
|Cyprus                         |2022|April    |55                |18.1                                  |
|Australia                      |2022|April    |54                |18.69                                 |
|New Zealand                    |2022|April    |51                |19.42                                 |
|Falkland Islands               |2022|May      |428               |2.34                                  |
|Montserrat                     |2022|May      |148               |6.74                                  |
|Taiwan                         |2022|May      |80                |12.44                                 |
|Portugal                       |2022|May      |64                |15.52                                 |
|Australia                      |2022|May      |53                |18.97                                 |

### Outbreaks Over Time: Large Countries
Months in calendar order, noting countries and months where at least fifty people in every thousand 
were reported as getting Covid during that month, for countries with at least a ten million people.

```
SELECT
  [Location] AS [Country],
  [Year],
  [MonthName],
  round([MonthlyNewCasesPerThousand],0) AS [NewCasesPer1000Pop],
  round(1000/[MonthlyNewCasesPerThousand], 2) AS [One_in_X_people_was_known_to_get_Covid]
FROM #monthly_cases
WHERE ([MonthlyNewCasesPerThousand] >= 10) AND ([MonthlyPopulation] > 10000000)
ORDER BY [Year],[MonthNum], [MonthlyNewCasesPerThousand] DESC;
```

|Country           |Year|MonthName|NewCasesPer1000Pop|One_in_X_people_was_known_to_get_Covid|
|------------------|----|---------|------------------|--------------------------------------|
|Belgium           |2020|October  |27                |37.43                                 |
|Czechia           |2020|October  |25                |40.57                                 |
|Netherlands       |2020|October  |14                |72.79                                 |
|France            |2020|October  |12                |83.95                                 |
|Czechia           |2020|November |18                |56.99                                 |
|Poland            |2020|November |17                |60.18                                 |
|Portugal          |2020|November |15                |64.85                                 |
|Italy             |2020|November |15                |65.47                                 |
|Jordan            |2020|November |14                |69.94                                 |
|United States     |2020|November |13                |74.47                                 |
|France            |2020|November |13                |74.77                                 |
|Belgium           |2020|November |13                |78.54                                 |
|Romania           |2020|November |12                |81.73                                 |
|Sweden            |2020|November |12                |85.54                                 |
|United States     |2020|December |20                |50.72                                 |
|Sweden            |2020|December |19                |52.3                                  |
|Czechia           |2020|December |18                |54.9                                  |
|Netherlands       |2020|December |16                |61.77                                 |
|United Kingdom    |2020|December |13                |79.23                                 |
|Portugal          |2020|December |11                |87.94                                 |
|Portugal          |2021|January  |30                |33.14                                 |
|Czechia           |2021|January  |25                |40.3                                  |
|United Kingdom    |2021|January  |19                |51.32                                 |
|United States     |2021|January  |18                |54.16                                 |
|Spain             |2021|January  |17                |57.37                                 |
|Sweden            |2021|January  |13                |78.41                                 |
|Netherlands       |2021|January  |10                |97.08                                 |
|Czechia           |2021|February |23                |42.78                                 |
|Czechia           |2021|March    |28                |35.86                                 |
|Jordan            |2021|March    |21                |46.57                                 |
|Poland            |2021|March    |16                |61.49                                 |
|Sweden            |2021|March    |15                |68.85                                 |
|France            |2021|March    |13                |75.86                                 |
|Netherlands       |2021|March    |11                |91.31                                 |
|Italy             |2021|March    |11                |91.52                                 |
|Brazil            |2021|March    |10                |97.04                                 |
|Turkey            |2021|April    |18                |56.57                                 |
|Sweden            |2021|April    |17                |60.22                                 |
|France            |2021|April    |14                |69.33                                 |
|Argentina         |2021|April    |14                |72.56                                 |
|Netherlands       |2021|April    |13                |77.44                                 |
|Poland            |2021|April    |12                |80.35                                 |
|Chile             |2021|April    |11                |94.78                                 |
|Argentina         |2021|May      |18                |56.69                                 |
|Colombia          |2021|May      |11                |93.77                                 |
|Colombia          |2021|June     |16                |61.43                                 |
|Argentina         |2021|June     |15                |66.23                                 |
|Cuba              |2021|July     |17                |58.46                                 |
|United Kingdom    |2021|July     |16                |64.32                                 |
|Tunisia           |2021|July     |14                |70.43                                 |
|Spain             |2021|July     |14                |73.26                                 |
|Kazakhstan        |2021|July     |11                |90.38                                 |
|Malaysia          |2021|July     |11                |90.72                                 |
|Colombia          |2021|July     |11                |94.18                                 |
|Netherlands       |2021|July     |11                |94.28                                 |
|Argentina         |2021|July     |10                |99.27                                 |
|Cuba              |2021|August   |24                |42.19                                 |
|Malaysia          |2021|August   |19                |51.78                                 |
|United Kingdom    |2021|August   |14                |72.99                                 |
|Iran              |2021|August   |13                |75.85                                 |
|United States     |2021|August   |13                |77.73                                 |
|Kazakhstan        |2021|August   |12                |82.55                                 |
|Cuba              |2021|September|20                |50.4                                  |
|Malaysia          |2021|September|15                |65.63                                 |
|United Kingdom    |2021|September|15                |66.97                                 |
|United States     |2021|September|12                |80.35                                 |
|Romania           |2021|October  |22                |46.16                                 |
|United Kingdom    |2021|October  |18                |54.47                                 |
|Ukraine           |2021|October  |12                |82.82                                 |
|Turkey            |2021|October  |10                |96.76                                 |
|Czechia           |2021|November |36                |27.7                                  |
|Belgium           |2021|November |35                |28.69                                 |
|Netherlands       |2021|November |30                |32.9                                  |
|Greece            |2021|November |19                |52.71                                 |
|United Kingdom    |2021|November |17                |58.01                                 |
|Germany           |2021|November |15                |67.7                                  |
|Poland            |2021|November |14                |73.42                                 |
|Ukraine           |2021|November |13                |79.24                                 |
|United Kingdom    |2021|December |40                |25.09                                 |
|France            |2021|December |34                |29.34                                 |
|Czechia           |2021|December |30                |32.93                                 |
|Belgium           |2021|December |29                |34.28                                 |
|Netherlands       |2021|December |28                |35.25                                 |
|Greece            |2021|December |26                |38.13                                 |
|Spain             |2021|December |24                |41.34                                 |
|Portugal          |2021|December |24                |41.95                                 |
|United States     |2021|December |19                |53.25                                 |
|Italy             |2021|December |18                |55.02                                 |
|Germany           |2021|December |16                |63.87                                 |
|Poland            |2021|December |15                |66.53                                 |
|Canada            |2021|December |11                |89.46                                 |
|Sweden            |2021|December |11                |92.43                                 |
|Jordan            |2021|December |11                |93.81                                 |
|France            |2022|January  |136               |7.35                                  |
|Portugal          |2022|January  |128               |7.82                                  |
|Belgium           |2022|January  |90                |11.08                                 |
|Australia         |2022|January  |85                |11.82                                 |
|Netherlands       |2022|January  |81                |12.32                                 |
|Italy             |2022|January  |80                |12.43                                 |
|Spain             |2022|January  |78                |12.75                                 |
|Sweden            |2022|January  |74                |13.45                                 |
|Greece            |2022|January  |70                |14.21                                 |
|United States     |2022|January  |61                |16.43                                 |
|Argentina         |2022|January  |60                |16.74                                 |
|United Kingdom    |2022|January  |52                |19.24                                 |
|Czechia           |2022|January  |50                |19.94                                 |
|Germany           |2022|January  |32                |31.48                                 |
|Peru              |2022|January  |28                |35.96                                 |
|Turkey            |2022|January  |25                |39.79                                 |
|Canada            |2022|January  |22                |44.79                                 |
|Bolivia           |2022|January  |22                |46.23                                 |
|Romania           |2022|January  |21                |46.92                                 |
|Poland            |2022|January  |21                |48.59                                 |
|Chile             |2022|January  |19                |53.44                                 |
|Jordan            |2022|January  |16                |63.43                                 |
|Tunisia           |2022|January  |15                |65.18                                 |
|Brazil            |2022|January  |15                |67.47                                 |
|Colombia          |2022|January  |14                |70.24                                 |
|Kazakhstan        |2022|January  |13                |75.15                                 |
|Dominican Republic|2022|January  |12                |80.27                                 |
|Ecuador           |2022|January  |10                |97.95                                 |
|Netherlands       |2022|February |106               |9.42                                  |
|Portugal          |2022|February |68                |14.68                                 |
|Germany           |2022|February |59                |17.02                                 |
|France            |2022|February |53                |18.94                                 |
|Czechia           |2022|February |52                |19.12                                 |
|South Korea       |2022|February |47                |21.29                                 |
|Chile             |2022|February |47                |21.47                                 |
|Greece            |2022|February |46                |21.56                                 |
|Jordan            |2022|February |40                |25.27                                 |
|Sweden            |2022|February |36                |27.41                                 |
|Belgium           |2022|February |35                |28.93                                 |
|Russia            |2022|February |31                |32.49                                 |
|Italy             |2022|February |30                |33.54                                 |
|Turkey            |2022|February |29                |34.44                                 |
|Romania           |2022|February |27                |37                                    |
|Australia         |2022|February |25                |39.24                                 |
|United Kingdom    |2022|February |23                |43.18                                 |
|Spain             |2022|February |22                |46                                    |
|Poland            |2022|February |21                |48.4                                  |
|Ukraine           |2022|February |18                |55.35                                 |
|Japan             |2022|February |18                |55.59                                 |
|Malaysia          |2022|February |17                |57.3                                  |
|Brazil            |2022|February |16                |64.2                                  |
|Azerbaijan        |2022|February |12                |80.37                                 |
|Vietnam           |2022|February |12                |84.07                                 |
|United States     |2022|February |12                |84.16                                 |
|Argentina         |2022|February |11                |87.37                                 |
|South Korea       |2022|March    |197               |5.08                                  |
|Netherlands       |2022|March    |87                |11.47                                 |
|Germany           |2022|March    |79                |12.69                                 |
|Vietnam           |2022|March    |62                |16.04                                 |
|Greece            |2022|March    |59                |17.04                                 |
|Australia         |2022|March    |52                |19.27                                 |
|France            |2022|March    |43                |23.15                                 |
|Portugal          |2022|March    |35                |28.46                                 |
|United Kingdom    |2022|March    |33                |29.93                                 |
|Italy             |2022|March    |31                |32.46                                 |
|Belgium           |2022|March    |25                |39.6                                  |
|Malaysia          |2022|March    |23                |43.17                                 |
|Czechia           |2022|March    |23                |43.3                                  |
|Chile             |2022|March    |21                |46.87                                 |
|Japan             |2022|March    |12                |81.34                                 |
|Spain             |2022|March    |11                |88.07                                 |
|Thailand          |2022|March    |11                |91.46                                 |
|South Korea       |2022|April    |76                |13.16                                 |
|Australia         |2022|April    |54                |18.69                                 |
|France            |2022|April    |45                |22.24                                 |
|Germany           |2022|April    |41                |24.3                                  |
|Italy             |2022|April    |30                |33.15                                 |
|Portugal          |2022|April    |28                |35.21                                 |
|Greece            |2022|April    |28                |35.34                                 |
|Belgium           |2022|April    |18                |56.63                                 |
|United Kingdom    |2022|April    |13                |76.07                                 |
|Vietnam           |2022|April    |11                |90.46                                 |
|Netherlands       |2022|April    |11                |90.5                                  |
|Japan             |2022|April    |10                |95.81                                 |
|Taiwan            |2022|May      |80                |12.44                                 |
|Portugal          |2022|May      |64                |15.52                                 |
|Australia         |2022|May      |53                |18.97                                 |
|Germany           |2022|May      |18                |54.09                                 |
|South Korea       |2022|May      |16                |60.8                                  |
|Italy             |2022|May      |16                |63                                    |
|France            |2022|May      |13                |74.6                                  |
|Greece            |2022|May      |12                |80.2                                  |
|Taiwan            |2022|June     |38                |26.38                                 |
|Portugal          |2022|June     |23                |43.43                                 |
|Australia         |2022|June     |14                |74.03                                 |

### Outbreaks Over Time: Large Countries: Grouped by Country
Same as above, but group the rows for each country together.

```
SELECT
  [Location] AS [Country],
  [Year],
  [MonthName],
  round([MonthlyNewCasesPerThousand],0) AS [NewCasesPer1000Pop],
  round(1000/[MonthlyNewCasesPerThousand], 2) AS [One_in_X_people_was_known_to_get_Covid]
FROM #monthly_cases
WHERE ([MonthlyNewCasesPerThousand] >= 10) AND ([MonthlyPopulation] > 10000000)
ORDER BY [Country], [Year],[MonthNum], [MonthlyNewCasesPerThousand] DESC;
```

|Country           |Year|MonthName|NewCasesPer1000Pop|One_in_X_people_was_known_to_get_Covid|
|------------------|----|---------|------------------|--------------------------------------|
|Argentina         |2021|April    |14                |72.56                                 |
|Argentina         |2021|May      |18                |56.69                                 |
|Argentina         |2021|June     |15                |66.23                                 |
|Argentina         |2021|July     |10                |99.27                                 |
|Argentina         |2022|January  |60                |16.74                                 |
|Argentina         |2022|February |11                |87.37                                 |
|Australia         |2022|January  |85                |11.82                                 |
|Australia         |2022|February |25                |39.24                                 |
|Australia         |2022|March    |52                |19.27                                 |
|Australia         |2022|April    |54                |18.69                                 |
|Australia         |2022|May      |53                |18.97                                 |
|Australia         |2022|June     |14                |74.03                                 |
|Azerbaijan        |2022|February |12                |80.37                                 |
|Belgium           |2020|October  |27                |37.43                                 |
|Belgium           |2020|November |13                |78.54                                 |
|Belgium           |2021|November |35                |28.69                                 |
|Belgium           |2021|December |29                |34.28                                 |
|Belgium           |2022|January  |90                |11.08                                 |
|Belgium           |2022|February |35                |28.93                                 |
|Belgium           |2022|March    |25                |39.6                                  |
|Belgium           |2022|April    |18                |56.63                                 |
|Bolivia           |2022|January  |22                |46.23                                 |
|Brazil            |2021|March    |10                |97.04                                 |
|Brazil            |2022|January  |15                |67.47                                 |
|Brazil            |2022|February |16                |64.2                                  |
|Canada            |2021|December |11                |89.46                                 |
|Canada            |2022|January  |22                |44.79                                 |
|Chile             |2021|April    |11                |94.78                                 |
|Chile             |2022|January  |19                |53.44                                 |
|Chile             |2022|February |47                |21.47                                 |
|Chile             |2022|March    |21                |46.87                                 |
|Colombia          |2021|May      |11                |93.77                                 |
|Colombia          |2021|June     |16                |61.43                                 |
|Colombia          |2021|July     |11                |94.18                                 |
|Colombia          |2022|January  |14                |70.24                                 |
|Cuba              |2021|July     |17                |58.46                                 |
|Cuba              |2021|August   |24                |42.19                                 |
|Cuba              |2021|September|20                |50.4                                  |
|Czechia           |2020|October  |25                |40.57                                 |
|Czechia           |2020|November |18                |56.99                                 |
|Czechia           |2020|December |18                |54.9                                  |
|Czechia           |2021|January  |25                |40.3                                  |
|Czechia           |2021|February |23                |42.78                                 |
|Czechia           |2021|March    |28                |35.86                                 |
|Czechia           |2021|November |36                |27.7                                  |
|Czechia           |2021|December |30                |32.93                                 |
|Czechia           |2022|January  |50                |19.94                                 |
|Czechia           |2022|February |52                |19.12                                 |
|Czechia           |2022|March    |23                |43.3                                  |
|Dominican Republic|2022|January  |12                |80.27                                 |
|Ecuador           |2022|January  |10                |97.95                                 |
|France            |2020|October  |12                |83.95                                 |
|France            |2020|November |13                |74.77                                 |
|France            |2021|March    |13                |75.86                                 |
|France            |2021|April    |14                |69.33                                 |
|France            |2021|December |34                |29.34                                 |
|France            |2022|January  |136               |7.35                                  |
|France            |2022|February |53                |18.94                                 |
|France            |2022|March    |43                |23.15                                 |
|France            |2022|April    |45                |22.24                                 |
|France            |2022|May      |13                |74.6                                  |
|Germany           |2021|November |15                |67.7                                  |
|Germany           |2021|December |16                |63.87                                 |
|Germany           |2022|January  |32                |31.48                                 |
|Germany           |2022|February |59                |17.02                                 |
|Germany           |2022|March    |79                |12.69                                 |
|Germany           |2022|April    |41                |24.3                                  |
|Germany           |2022|May      |18                |54.09                                 |
|Greece            |2021|November |19                |52.71                                 |
|Greece            |2021|December |26                |38.13                                 |
|Greece            |2022|January  |70                |14.21                                 |
|Greece            |2022|February |46                |21.56                                 |
|Greece            |2022|March    |59                |17.04                                 |
|Greece            |2022|April    |28                |35.34                                 |
|Greece            |2022|May      |12                |80.2                                  |
|Iran              |2021|August   |13                |75.85                                 |
|Italy             |2020|November |15                |65.47                                 |
|Italy             |2021|March    |11                |91.52                                 |
|Italy             |2021|December |18                |55.02                                 |
|Italy             |2022|January  |80                |12.43                                 |
|Italy             |2022|February |30                |33.54                                 |
|Italy             |2022|March    |31                |32.46                                 |
|Italy             |2022|April    |30                |33.15                                 |
|Italy             |2022|May      |16                |63                                    |
|Japan             |2022|February |18                |55.59                                 |
|Japan             |2022|March    |12                |81.34                                 |
|Japan             |2022|April    |10                |95.81                                 |
|Jordan            |2020|November |14                |69.94                                 |
|Jordan            |2021|March    |21                |46.57                                 |
|Jordan            |2021|December |11                |93.81                                 |
|Jordan            |2022|January  |16                |63.43                                 |
|Jordan            |2022|February |40                |25.27                                 |
|Kazakhstan        |2021|July     |11                |90.38                                 |
|Kazakhstan        |2021|August   |12                |82.55                                 |
|Kazakhstan        |2022|January  |13                |75.15                                 |
|Malaysia          |2021|July     |11                |90.72                                 |
|Malaysia          |2021|August   |19                |51.78                                 |
|Malaysia          |2021|September|15                |65.63                                 |
|Malaysia          |2022|February |17                |57.3                                  |
|Malaysia          |2022|March    |23                |43.17                                 |
|Netherlands       |2020|October  |14                |72.79                                 |
|Netherlands       |2020|December |16                |61.77                                 |
|Netherlands       |2021|January  |10                |97.08                                 |
|Netherlands       |2021|March    |11                |91.31                                 |
|Netherlands       |2021|April    |13                |77.44                                 |
|Netherlands       |2021|July     |11                |94.28                                 |
|Netherlands       |2021|November |30                |32.9                                  |
|Netherlands       |2021|December |28                |35.25                                 |
|Netherlands       |2022|January  |81                |12.32                                 |
|Netherlands       |2022|February |106               |9.42                                  |
|Netherlands       |2022|March    |87                |11.47                                 |
|Netherlands       |2022|April    |11                |90.5                                  |
|Peru              |2022|January  |28                |35.96                                 |
|Poland            |2020|November |17                |60.18                                 |
|Poland            |2021|March    |16                |61.49                                 |
|Poland            |2021|April    |12                |80.35                                 |
|Poland            |2021|November |14                |73.42                                 |
|Poland            |2021|December |15                |66.53                                 |
|Poland            |2022|January  |21                |48.59                                 |
|Poland            |2022|February |21                |48.4                                  |
|Portugal          |2020|November |15                |64.85                                 |
|Portugal          |2020|December |11                |87.94                                 |
|Portugal          |2021|January  |30                |33.14                                 |
|Portugal          |2021|December |24                |41.95                                 |
|Portugal          |2022|January  |128               |7.82                                  |
|Portugal          |2022|February |68                |14.68                                 |
|Portugal          |2022|March    |35                |28.46                                 |
|Portugal          |2022|April    |28                |35.21                                 |
|Portugal          |2022|May      |64                |15.52                                 |
|Portugal          |2022|June     |23                |43.43                                 |
|Romania           |2020|November |12                |81.73                                 |
|Romania           |2021|October  |22                |46.16                                 |
|Romania           |2022|January  |21                |46.92                                 |
|Romania           |2022|February |27                |37                                    |
|Russia            |2022|February |31                |32.49                                 |
|South Korea       |2022|February |47                |21.29                                 |
|South Korea       |2022|March    |197               |5.08                                  |
|South Korea       |2022|April    |76                |13.16                                 |
|South Korea       |2022|May      |16                |60.8                                  |
|Spain             |2021|January  |17                |57.37                                 |
|Spain             |2021|July     |14                |73.26                                 |
|Spain             |2021|December |24                |41.34                                 |
|Spain             |2022|January  |78                |12.75                                 |
|Spain             |2022|February |22                |46                                    |
|Spain             |2022|March    |11                |88.07                                 |
|Sweden            |2020|November |12                |85.54                                 |
|Sweden            |2020|December |19                |52.3                                  |
|Sweden            |2021|January  |13                |78.41                                 |
|Sweden            |2021|March    |15                |68.85                                 |
|Sweden            |2021|April    |17                |60.22                                 |
|Sweden            |2021|December |11                |92.43                                 |
|Sweden            |2022|January  |74                |13.45                                 |
|Sweden            |2022|February |36                |27.41                                 |
|Taiwan            |2022|May      |80                |12.44                                 |
|Taiwan            |2022|June     |38                |26.38                                 |
|Thailand          |2022|March    |11                |91.46                                 |
|Tunisia           |2021|July     |14                |70.43                                 |
|Tunisia           |2022|January  |15                |65.18                                 |
|Turkey            |2021|April    |18                |56.57                                 |
|Turkey            |2021|October  |10                |96.76                                 |
|Turkey            |2022|January  |25                |39.79                                 |
|Turkey            |2022|February |29                |34.44                                 |
|Ukraine           |2021|October  |12                |82.82                                 |
|Ukraine           |2021|November |13                |79.24                                 |
|Ukraine           |2022|February |18                |55.35                                 |
|United Kingdom    |2020|December |13                |79.23                                 |
|United Kingdom    |2021|January  |19                |51.32                                 |
|United Kingdom    |2021|July     |16                |64.32                                 |
|United Kingdom    |2021|August   |14                |72.99                                 |
|United Kingdom    |2021|September|15                |66.97                                 |
|United Kingdom    |2021|October  |18                |54.47                                 |
|United Kingdom    |2021|November |17                |58.01                                 |
|United Kingdom    |2021|December |40                |25.09                                 |
|United Kingdom    |2022|January  |52                |19.24                                 |
|United Kingdom    |2022|February |23                |43.18                                 |
|United Kingdom    |2022|March    |33                |29.93                                 |
|United Kingdom    |2022|April    |13                |76.07                                 |
|United States     |2020|November |13                |74.47                                 |
|United States     |2020|December |20                |50.72                                 |
|United States     |2021|January  |18                |54.16                                 |
|United States     |2021|August   |13                |77.73                                 |
|United States     |2021|September|12                |80.35                                 |
|United States     |2021|December |19                |53.25                                 |
|United States     |2022|January  |61                |16.43                                 |
|United States     |2022|February |12                |84.16                                 |
|Vietnam           |2022|February |12                |84.07                                 |
|Vietnam           |2022|March    |62                |16.04                                 |
|Vietnam           |2022|April    |11                |90.46                                 |

### Countries with the Most "High Covid" Months
Find countries with the most months during which more than 10 new cases were reported per thousand people

```
SELECT [Location], count(*) as [Months]
FROM #monthly_cases
WHERE [MonthlyNewCasesPerThousand] >= 10
GROUP BY [Location]
HAVING count(*) > 5
ORDER BY [Months] DESC, [Location];
```

|Location                       |Months|
|-------------------------------|------|
|Andorra                        |15    |
|Seychelles                     |15    |
|Slovenia                       |15    |
|Estonia                        |13    |
|Gibraltar                      |13    |
|Lithuania                      |13    |
|Montenegro                     |13    |
|Cyprus                         |12    |
|Netherlands                    |12    |
|San Marino                     |12    |
|Slovakia                       |12    |
|United Kingdom                 |12    |
|Czechia                        |11    |
|Georgia                        |11    |
|Isle of Man                    |11    |
|Luxembourg                     |11    |
|Aruba                          |10    |
|Bonaire Sint Eustatius and Saba|10    |
|France                         |10    |
|Latvia                         |10    |
|Portugal                       |10    |
|Bahrain                        |9     |
|Barbados                       |9     |
|Bermuda                        |9     |
|Croatia                        |9     |
|Dominica                       |9     |
|Ireland                        |9     |
|Israel                         |9     |
|Liechtenstein                  |9     |
|Serbia                         |9     |
|Switzerland                    |9     |
|Anguilla                       |8     |
|Austria                        |8     |
|Belgium                        |8     |
|Cayman Islands                 |8     |
|Curacao                        |8     |
|Hungary                        |8     |
|Italy                          |8     |
|Monaco                         |8     |
|Mongolia                       |8     |
|Sweden                         |8     |
|United States                  |8     |
|Germany                        |7     |
|Greece                         |7     |
|Poland                         |7     |
|Singapore                      |7     |
|Uruguay                        |7     |
|Argentina                      |6     |
|Australia                      |6     |
|Brunei                         |6     |
|Bulgaria                       |6     |
|Denmark                        |6     |
|Finland                        |6     |
|French Polynesia               |6     |
|Iceland                        |6     |
|Maldives                       |6     |
|North Macedonia                |6     |
|Palestine                      |6     |
|Spain                          |6     |

### Large Countries with the Most "High Covid" Months
Find countries with the most months during which more than 10 new cases were reported per thousand people
, for populations of at least ten million.

```
SELECT [Location], count(*) as [Months]
FROM #monthly_cases
WHERE ([MonthlyNewCasesPerThousand] >= 10) AND ([MonthlyPopulation] > 10000000)
GROUP BY [Location]
HAVING count(*) > 5
ORDER BY [Months] DESC, [Location];
```

|Location      |Months|
|--------------|------|
|Netherlands   |12    |
|United Kingdom|12    |
|Czechia       |11    |
|France        |10    |
|Portugal      |10    |
|Belgium       |8     |
|Italy         |8     |
|Sweden        |8     |
|United States |8     |
|Germany       |7     |
|Greece        |7     |
|Poland        |7     |
|Argentina     |6     |
|Australia     |6     |
|Spain         |6     |

## VACCINATIONS
Create a temp table with monthly data per country,
  and number of vaccinations vs population

```
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
```

### Biggest Vaccination Drives:
Top 50 country+month with the largest number of vaccinations, relative to population.

```
SELECT TOP(50) 
  [Location] AS [Country],
  [Year],
  [MonthName],
  round([MonthlyNewVacPerThousand],0) AS [NewVacPer1000Pop]
FROM #monthly_vac
ORDER BY [MonthlyNewVacPerThousand] DESC;
```

|Country           |Year|MonthName|NewVacPer1000Pop|
|------------------|----|---------|----------------|
|Gibraltar         |2021|February |698             |
|Gibraltar         |2021|March    |688             |
|Mongolia          |2021|May      |571             |
|Cuba              |2021|September|562             |
|Bhutan            |2021|March    |506             |
|Bhutan            |2021|July     |484             |
|Malaysia          |2021|August   |440             |
|Ecuador           |2021|July     |428             |
|Israel            |2021|January  |428             |
|Cambodia          |2021|August   |413             |
|China             |2021|June     |404             |
|Cuba              |2021|October  |398             |
|Denmark           |2021|December |398             |
|Malaysia          |2021|July     |391             |
|Ecuador           |2021|August   |390             |
|Singapore         |2021|July     |387             |
|South Korea       |2021|September|385             |
|Cuba              |2021|August   |373             |
|Chile             |2021|March    |371             |
|Japan             |2021|July     |367             |
|Cuba              |2021|June     |362             |
|Sri Lanka         |2021|July     |361             |
|Denmark           |2021|July     |360             |
|Belgium           |2021|June     |359             |
|South Korea       |2021|August   |359             |
|Canada            |2021|June     |357             |
|Malta             |2021|May      |357             |
|South Korea       |2021|December |356             |
|Curacao           |2021|May      |345             |
|Israel            |2021|February |341             |
|Uruguay           |2021|April    |341             |
|New Zealand       |2021|September|334             |
|Curacao           |2021|April    |327             |
|Australia         |2021|September|325             |
|Dominican Republic|2021|June     |322             |
|New Zealand       |2021|October  |321             |
|Uruguay           |2021|June     |317             |
|Qatar             |2021|May      |317             |
|Denmark           |2021|June     |314             |
|Germany           |2021|December |313             |
|Canada            |2021|July     |312             |
|Belgium           |2021|July     |311             |
|New Zealand       |2021|August   |310             |
|Ireland           |2021|July     |309             |
|Cambodia          |2021|September|306             |
|Aruba             |2021|May      |304             |
|Gibraltar         |2021|January  |304             |
|Aruba             |2021|April    |303             |
|Cuba              |2022|January  |303             |
|Germany           |2021|June     |302             |

### Vaccination Drives Over Time
In calendar order, display all countries+months with at least one person in every five getting a vaccination during that month.

```
SELECT [Location], [Year], [MonthName], round([MonthlyNewVacPerThousand], 0) AS [JabsPerThousandPeople]
FROM #monthly_vac
WHERE [MonthlyNewVacPerThousand] >= 200
ORDER BY [Year], [MonthNum], [Location];
```

|Location            |Year|MonthName|JabsPerThousandPeople|
|--------------------|----|---------|---------------------|
|Gibraltar           |2021|January  |304                  |
|Israel              |2021|January  |428                  |
|United Arab Emirates|2021|January  |251                  |
|Gibraltar           |2021|February |698                  |
|Israel              |2021|February |341                  |
|United Arab Emirates|2021|February |269                  |
|Bhutan              |2021|March    |506                  |
|Chile               |2021|March    |371                  |
|Gibraltar           |2021|March    |688                  |
|Israel              |2021|March    |209                  |
|Maldives            |2021|March    |232                  |
|Malta               |2021|March    |228                  |
|San Marino          |2021|March    |258                  |
|United Arab Emirates|2021|March    |229                  |
|United Kingdom      |2021|March    |214                  |
|United States       |2021|March    |253                  |
|Aruba               |2021|April    |303                  |
|Bahrain             |2021|April    |268                  |
|Canada              |2021|April    |204                  |
|Chile               |2021|April    |231                  |
|Curacao             |2021|April    |327                  |
|Hungary             |2021|April    |286                  |
|Isle of Man         |2021|April    |246                  |
|Maldives            |2021|April    |258                  |
|Malta               |2021|April    |268                  |
|Qatar               |2021|April    |252                  |
|San Marino          |2021|April    |247                  |
|Singapore           |2021|April    |237                  |
|United Kingdom      |2021|April    |200                  |
|United States       |2021|April    |272                  |
|Uruguay             |2021|April    |341                  |
|Aruba               |2021|May      |304                  |
|Bahrain             |2021|May      |285                  |
|Barbados            |2021|May      |226                  |
|Belgium             |2021|May      |252                  |
|Canada              |2021|May      |276                  |
|Chile               |2021|May      |200                  |
|China               |2021|May      |274                  |
|Curacao             |2021|May      |345                  |
|Czechia             |2021|May      |203                  |
|Denmark             |2021|May      |248                  |
|France              |2021|May      |221                  |
|Germany             |2021|May      |255                  |
|Hungary             |2021|May      |283                  |
|Ireland             |2021|May      |264                  |
|Italy               |2021|May      |250                  |
|Latvia              |2021|May      |237                  |
|Lithuania           |2021|May      |232                  |
|Luxembourg          |2021|May      |213                  |
|Malta               |2021|May      |357                  |
|Mongolia            |2021|May      |571                  |
|Montenegro          |2021|May      |202                  |
|Qatar               |2021|May      |317                  |
|Singapore           |2021|May      |230                  |
|Slovenia            |2021|May      |204                  |
|Switzerland         |2021|May      |250                  |
|United Kingdom      |2021|May      |233                  |
|Uruguay             |2021|May      |279                  |
|Bahrain             |2021|June     |223                  |
|Belgium             |2021|June     |359                  |
|Canada              |2021|June     |357                  |
|Chile               |2021|June     |224                  |
|China               |2021|June     |404                  |
|Cuba                |2021|June     |362                  |
|Czechia             |2021|June     |273                  |
|Denmark             |2021|June     |314                  |
|Dominican Republic  |2021|June     |322                  |
|France              |2021|June     |263                  |
|Germany             |2021|June     |302                  |
|Greece              |2021|June     |269                  |
|Greenland           |2021|June     |260                  |
|Iceland             |2021|June     |226                  |
|Ireland             |2021|June     |296                  |
|Italy               |2021|June     |277                  |
|Japan               |2021|June     |289                  |
|Liechtenstein       |2021|June     |241                  |
|Lithuania           |2021|June     |235                  |
|Luxembourg          |2021|June     |279                  |
|Macao               |2021|June     |254                  |
|Malta               |2021|June     |292                  |
|Norway              |2021|June     |282                  |
|Poland              |2021|June     |202                  |
|Qatar               |2021|June     |205                  |
|Singapore           |2021|June     |265                  |
|South Korea         |2021|June     |222                  |
|Spain               |2021|June     |228                  |
|Switzerland         |2021|June     |291                  |
|Turkey              |2021|June     |252                  |
|United Arab Emirates|2021|June     |216                  |
|Uruguay             |2021|June     |317                  |
|Argentina           |2021|July     |247                  |
|Belgium             |2021|July     |311                  |
|Bhutan              |2021|July     |484                  |
|Cambodia            |2021|July     |285                  |
|Canada              |2021|July     |312                  |
|China               |2021|July     |283                  |
|Cuba                |2021|July     |290                  |
|Denmark             |2021|July     |360                  |
|Ecuador             |2021|July     |428                  |
|France              |2021|July     |289                  |
|Germany             |2021|July     |209                  |
|Greece              |2021|July     |207                  |
|Greenland           |2021|July     |292                  |
|Hong Kong           |2021|July     |256                  |
|Ireland             |2021|July     |309                  |
|Italy               |2021|July     |277                  |
|Japan               |2021|July     |367                  |
|Luxembourg          |2021|July     |240                  |
|Macao               |2021|July     |257                  |
|Malaysia            |2021|July     |391                  |
|Norway              |2021|July     |220                  |
|Paraguay            |2021|July     |233                  |
|Qatar               |2021|July     |202                  |
|Saudi Arabia        |2021|July     |254                  |
|Singapore           |2021|July     |387                  |
|Spain               |2021|July     |214                  |
|Sri Lanka           |2021|July     |361                  |
|Taiwan              |2021|July     |209                  |
|Turkey              |2021|July     |267                  |
|Uruguay             |2021|July     |248                  |
|Argentina           |2021|August   |240                  |
|Australia           |2021|August   |284                  |
|Brazil              |2021|August   |242                  |
|Cambodia            |2021|August   |413                  |
|China               |2021|August   |287                  |
|Cuba                |2021|August   |373                  |
|Denmark             |2021|August   |211                  |
|Ecuador             |2021|August   |390                  |
|El Salvador         |2021|August   |200                  |
|France              |2021|August   |207                  |
|Hong Kong           |2021|August   |255                  |
|Israel              |2021|August   |278                  |
|Japan               |2021|August   |294                  |
|Malaysia            |2021|August   |440                  |
|Morocco             |2021|August   |206                  |
|New Zealand         |2021|August   |310                  |
|Norway              |2021|August   |282                  |
|Qatar               |2021|August   |206                  |
|Saudi Arabia        |2021|August   |290                  |
|Singapore           |2021|August   |207                  |
|South Korea         |2021|August   |359                  |
|Sri Lanka           |2021|August   |260                  |
|Trinidad and Tobago |2021|August   |232                  |
|Turkey              |2021|August   |246                  |
|Uruguay             |2021|August   |228                  |
|Australia           |2021|September|325                  |
|Brazil              |2021|September|210                  |
|Cambodia            |2021|September|306                  |
|Cuba                |2021|September|562                  |
|Japan               |2021|September|264                  |
|Kosovo              |2021|September|273                  |
|Malaysia            |2021|September|287                  |
|New Zealand         |2021|September|334                  |
|Peru                |2021|September|260                  |
|South Korea         |2021|September|385                  |
|Sri Lanka           |2021|September|284                  |
|Vietnam             |2021|September|231                  |
|Australia           |2021|October  |293                  |
|Chile               |2021|October  |235                  |
|Cuba                |2021|October  |398                  |
|Gibraltar           |2021|October  |250                  |
|New Zealand         |2021|October  |321                  |
|Peru                |2021|October  |229                  |
|South Korea         |2021|October  |288                  |
|Taiwan              |2021|October  |294                  |
|Thailand            |2021|October  |278                  |
|Vietnam             |2021|October  |265                  |
|Brunei              |2021|November |254                  |
|Chile               |2021|November |214                  |
|Cuba                |2021|November |201                  |
|Peru                |2021|November |223                  |
|Taiwan              |2021|November |227                  |
|Thailand            |2021|November |222                  |
|Vietnam             |2021|November |292                  |
|Belgium             |2021|December |238                  |
|Canada              |2021|December |212                  |
|China               |2021|December |227                  |
|Denmark             |2021|December |398                  |
|France              |2021|December |262                  |
|Germany             |2021|December |313                  |
|Greece              |2021|December |285                  |
|Ireland             |2021|December |293                  |
|Italy               |2021|December |243                  |
|Liechtenstein       |2021|December |300                  |
|Luxembourg          |2021|December |255                  |
|Malta               |2021|December |218                  |
|Mongolia            |2021|December |261                  |
|Peru                |2021|December |240                  |
|South Korea         |2021|December |356                  |
|Switzerland         |2021|December |216                  |
|United Kingdom      |2021|December |254                  |
|Argentina           |2022|January  |232                  |
|Australia           |2022|January  |275                  |
|Belgium             |2022|January  |214                  |
|Canada              |2022|January  |242                  |
|Cuba                |2022|January  |303                  |
|Italy               |2022|January  |283                  |
|Luxembourg          |2022|January  |236                  |
|Malta               |2022|January  |273                  |
|New Zealand         |2022|January  |249                  |
|Norway              |2022|January  |226                  |
|Singapore           |2022|January  |225                  |
|South Korea         |2022|January  |207                  |
|Hong Kong           |2022|February |263                  |
|New Zealand         |2022|February |228                  |
|Hong Kong           |2022|March    |267                  |
|Japan               |2022|March    |212                  |
|Chile               |2022|May      |208                  |

### Vaccination Drives Over Time: Large Countries
In calendar order, display all countries+months with at least one person in every five getting a vaccination during that month,
but only showing countries with population of ten million or more.

```
SELECT [Location], [Year], [MonthName], round([MonthlyNewVacPerThousand], 0) AS [JabsPerThousandPeople]
FROM #monthly_vac
WHERE ([MonthlyNewVacPerThousand] >= 200) AND ([MonthlyPopulation] > 10000000)
ORDER BY [Year], [MonthNum], [Location];
```

|Location          |Year|MonthName|JabsPerThousandPeople|
|------------------|----|---------|---------------------|
|Chile             |2021|March    |371                  |
|United Kingdom    |2021|March    |214                  |
|United States     |2021|March    |253                  |
|Canada            |2021|April    |204                  |
|Chile             |2021|April    |231                  |
|United Kingdom    |2021|April    |200                  |
|United States     |2021|April    |272                  |
|Belgium           |2021|May      |252                  |
|Canada            |2021|May      |276                  |
|Chile             |2021|May      |200                  |
|China             |2021|May      |274                  |
|Czechia           |2021|May      |203                  |
|France            |2021|May      |221                  |
|Germany           |2021|May      |255                  |
|Italy             |2021|May      |250                  |
|United Kingdom    |2021|May      |233                  |
|Belgium           |2021|June     |359                  |
|Canada            |2021|June     |357                  |
|Chile             |2021|June     |224                  |
|China             |2021|June     |404                  |
|Cuba              |2021|June     |362                  |
|Czechia           |2021|June     |273                  |
|Dominican Republic|2021|June     |322                  |
|France            |2021|June     |263                  |
|Germany           |2021|June     |302                  |
|Greece            |2021|June     |269                  |
|Italy             |2021|June     |277                  |
|Japan             |2021|June     |289                  |
|Poland            |2021|June     |202                  |
|South Korea       |2021|June     |222                  |
|Spain             |2021|June     |228                  |
|Turkey            |2021|June     |252                  |
|Argentina         |2021|July     |247                  |
|Belgium           |2021|July     |311                  |
|Cambodia          |2021|July     |285                  |
|Canada            |2021|July     |312                  |
|China             |2021|July     |283                  |
|Cuba              |2021|July     |290                  |
|Ecuador           |2021|July     |428                  |
|France            |2021|July     |289                  |
|Germany           |2021|July     |209                  |
|Greece            |2021|July     |207                  |
|Italy             |2021|July     |277                  |
|Japan             |2021|July     |367                  |
|Malaysia          |2021|July     |391                  |
|Saudi Arabia      |2021|July     |254                  |
|Spain             |2021|July     |214                  |
|Sri Lanka         |2021|July     |361                  |
|Taiwan            |2021|July     |209                  |
|Turkey            |2021|July     |267                  |
|Argentina         |2021|August   |240                  |
|Australia         |2021|August   |284                  |
|Brazil            |2021|August   |242                  |
|Cambodia          |2021|August   |413                  |
|China             |2021|August   |287                  |
|Cuba              |2021|August   |373                  |
|Ecuador           |2021|August   |390                  |
|France            |2021|August   |207                  |
|Japan             |2021|August   |294                  |
|Malaysia          |2021|August   |440                  |
|Morocco           |2021|August   |206                  |
|Saudi Arabia      |2021|August   |290                  |
|South Korea       |2021|August   |359                  |
|Sri Lanka         |2021|August   |260                  |
|Turkey            |2021|August   |246                  |
|Australia         |2021|September|325                  |
|Brazil            |2021|September|210                  |
|Cambodia          |2021|September|306                  |
|Cuba              |2021|September|562                  |
|Japan             |2021|September|264                  |
|Malaysia          |2021|September|287                  |
|Peru              |2021|September|260                  |
|South Korea       |2021|September|385                  |
|Sri Lanka         |2021|September|284                  |
|Vietnam           |2021|September|231                  |
|Australia         |2021|October  |293                  |
|Chile             |2021|October  |235                  |
|Cuba              |2021|October  |398                  |
|Peru              |2021|October  |229                  |
|South Korea       |2021|October  |288                  |
|Taiwan            |2021|October  |294                  |
|Thailand          |2021|October  |278                  |
|Vietnam           |2021|October  |265                  |
|Chile             |2021|November |214                  |
|Cuba              |2021|November |201                  |
|Peru              |2021|November |223                  |
|Taiwan            |2021|November |227                  |
|Thailand          |2021|November |222                  |
|Vietnam           |2021|November |292                  |
|Belgium           |2021|December |238                  |
|Canada            |2021|December |212                  |
|China             |2021|December |227                  |
|France            |2021|December |262                  |
|Germany           |2021|December |313                  |
|Greece            |2021|December |285                  |
|Italy             |2021|December |243                  |
|Peru              |2021|December |240                  |
|South Korea       |2021|December |356                  |
|United Kingdom    |2021|December |254                  |
|Argentina         |2022|January  |232                  |
|Australia         |2022|January  |275                  |
|Belgium           |2022|January  |214                  |
|Canada            |2022|January  |242                  |
|Cuba              |2022|January  |303                  |
|Italy             |2022|January  |283                  |
|South Korea       |2022|January  |207                  |
|Japan             |2022|March    |212                  |
|Chile             |2022|May      |208                  |

### Most Heavily Vaccinated Countries
Top 50 countries by average vaccinations per person over all time, 
rounded to 3 decimal places, for countries where data is available.

```
SELECT TOP(50) [location], round(sum([MonthlyNewVacPerThousand])/1000, 3) AS [AverageJabsPerPerson]
FROM #monthly_vac
GROUP BY [location]
HAVING sum([MonthlyNewVacPerThousand]) IS NOT NULL
ORDER BY sum([MonthlyNewVacPerThousand]) DESC;
```

|location            |AverageJabsPerPerson|
|--------------------|--------------------|
|Chile               |3.014               |
|Cuba                |2.902               |
|Gibraltar           |2.738               |
|Singapore           |2.594               |
|Malta               |2.468               |
|South Korea         |2.45                |
|Uruguay             |2.435               |
|China               |2.292               |
|Argentina           |2.287               |
|Italy               |2.286               |
|Peru                |2.283               |
|Hong Kong           |2.281               |
|Denmark             |2.275               |
|Canada              |2.255               |
|Japan               |2.239               |
|Australia           |2.226               |
|Belgium             |2.194               |
|Ireland             |2.188               |
|Malaysia            |2.168               |
|New Zealand         |2.164               |
|Cambodia            |2.153               |
|Germany             |2.15                |
|France              |2.149               |
|United Kingdom      |2.141               |
|Norway              |2.075               |
|Brazil              |2.042               |
|United Arab Emirates|2.022               |
|Israel              |1.955               |
|Greece              |1.942               |
|Ecuador             |1.93                |
|Luxembourg          |1.904               |
|Qatar               |1.868               |
|Taiwan              |1.841               |
|Switzerland         |1.804               |
|United States       |1.775               |
|Thailand            |1.751               |
|Turkey              |1.708               |
|Bahrain             |1.677               |
|Lithuania           |1.667               |
|Czechia             |1.646               |
|Saudi Arabia        |1.643               |
|Sri Lanka           |1.562               |
|Latvia              |1.549               |
|Liechtenstein       |1.538               |
|Estonia             |1.502               |
|Slovenia            |1.433               |
|Maldives            |1.421               |
|Vietnam             |1.384               |
|Spain               |1.347               |
|India               |1.343               |

### Most Heavily Vaccinated Large Countries
Top 50 countries by average vaccinations per person over all time, 
rounded to 3 decimal places, for countries where data is available.
Only look at countries with ten million people or more.

```
SELECT TOP(50) [location], round(sum([MonthlyNewVacPerThousand])/1000, 3) AS [AverageJabsPerPerson]
FROM #monthly_vac
WHERE [MonthlyPopulation] >= 10000000
GROUP BY [location]
HAVING sum([MonthlyNewVacPerThousand]) IS NOT NULL
ORDER BY sum([MonthlyNewVacPerThousand]) DESC;
```

|location          |AverageJabsPerPerson|
|------------------|--------------------|
|Chile             |3.014               |
|Cuba              |2.902               |
|South Korea       |2.45                |
|China             |2.292               |
|Argentina         |2.287               |
|Italy             |2.286               |
|Peru              |2.283               |
|Canada            |2.255               |
|Japan             |2.239               |
|Australia         |2.226               |
|Belgium           |2.194               |
|Malaysia          |2.168               |
|Cambodia          |2.153               |
|Germany           |2.15                |
|France            |2.149               |
|United Kingdom    |2.141               |
|Brazil            |2.042               |
|Greece            |1.942               |
|Ecuador           |1.93                |
|Taiwan            |1.841               |
|United States     |1.775               |
|Thailand          |1.751               |
|Turkey            |1.708               |
|Czechia           |1.646               |
|Saudi Arabia      |1.643               |
|Sri Lanka         |1.562               |
|Vietnam           |1.384               |
|Spain             |1.347               |
|India             |1.343               |
|Dominican Republic|1.246               |
|Indonesia         |1.196               |
|Mexico            |1.157               |
|Bolivia           |1.153               |
|Azerbaijan        |1.043               |
|Russia            |1.013               |
|Poland            |1.011               |
|Kazakhstan        |0.982               |
|Colombia          |0.981               |
|Romania           |0.878               |
|Guatemala         |0.735               |
|Morocco           |0.734               |
|Bangladesh        |0.729               |
|Ukraine           |0.726               |
|Tunisia           |0.716               |
|Zimbabwe          |0.701               |
|Philippines       |0.499               |
|Nepal             |0.482               |
|Uzbekistan        |0.446               |
|Pakistan          |0.43                |
|Jordan            |0.415               |

## REPORTED NEW DEATHS
Create a temp table with monthly data per country,
  and count of deaths vs population

```
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
```

### Countries with Largest Numbers of Deaths in a Month, vs Population
What were the largest number of covid deaths in one month and one country, relative to population?

```
SELECT TOP(50) 
  [Location] AS [Country],
  [Year],
  [MonthName],
  round([MonthlyNewDeathsPerMillion], 0) AS [NewDeathsPerMillionPop]
FROM #monthly_deaths
ORDER BY [MonthlyNewDeathsPerMillion] DESC;
```

|Country               |Year|MonthName|NewDeathsPerMillionPop|
|----------------------|----|---------|----------------------|
|Gibraltar             |2021|January  |2078                  |
|Grenada               |2021|September|1230                  |
|French Polynesia      |2021|August   |1016                  |
|British Virgin Islands|2021|July     |986                   |
|Hong Kong             |2022|March    |938                   |
|Montserrat            |2022|May      |803                   |
|San Marino            |2020|March    |735                   |
|Hungary               |2021|April    |706                   |
|Liechtenstein         |2020|December |706                   |
|Peru                  |2021|April    |698                   |
|French Polynesia      |2021|September|655                   |
|Bulgaria              |2021|November |646                   |
|Peru                  |2021|March    |627                   |
|Bermuda               |2021|September|612                   |
|Slovenia              |2020|December |607                   |
|Hungary               |2021|March    |598                   |
|Bosnia and Herzegovina|2021|April    |598                   |
|Belgium               |2020|April    |592                   |
|Namibia               |2021|July     |589                   |
|Czechia               |2021|March    |567                   |
|Peru                  |2021|February |560                   |
|Romania               |2021|October  |560                   |
|Aruba                 |2022|April    |550                   |
|Portugal              |2021|January  |548                   |
|Peru                  |2020|July     |542                   |
|Peru                  |2020|August   |528                   |
|Slovenia              |2020|November |528                   |
|Saint Lucia           |2021|September|526                   |
|Croatia               |2020|December |523                   |
|North Macedonia       |2021|April    |516                   |
|Peru                  |2020|June     |515                   |
|Paraguay              |2021|June     |514                   |
|Bulgaria              |2020|December |513                   |
|Peru                  |2021|May      |512                   |
|Trinidad and Tobago   |2021|December |507                   |
|New Caledonia         |2021|October  |507                   |
|Georgia               |2021|November |505                   |
|Grenada               |2021|October  |504                   |
|Latvia                |2021|November |496                   |
|Hungary               |2020|December |489                   |
|Hungary               |2021|December |484                   |
|United Kingdom        |2021|January  |479                   |
|Peru                  |2020|May      |477                   |
|Uruguay               |2021|May      |476                   |
|Gibraltar             |2021|February |475                   |
|Uruguay               |2021|April    |471                   |
|Czechia               |2020|November |470                   |
|Bosnia and Herzegovina|2021|March    |468                   |
|Slovakia              |2021|February |467                   |
|Bermuda               |2021|October  |467                   |

### Months with High Death Rates
In calendar order, show when a country had at least 300 deaths per million population. (Or at least one death per 3333 people.)

```
SELECT [Location], [Year], [MonthName], round([MonthlyNewDeathsPerMillion], 0) AS [DeathsPerMillionPeople]
FROM #monthly_deaths
WHERE [MonthlyNewDeathsPerMillion] >= 300
ORDER BY [Year], [MonthNum], [Location];
```

|Location                        |Year|MonthName|DeathsPerMillionPeople|
|--------------------------------|----|---------|----------------------|
|San Marino                      |2020|March    |735                   |
|Andorra                         |2020|April    |388                   |
|Belgium                         |2020|April    |592                   |
|France                          |2020|April    |309                   |
|San Marino                      |2020|April    |441                   |
|Spain                           |2020|April    |344                   |
|United Kingdom                  |2020|April    |356                   |
|Peru                            |2020|May      |477                   |
|Peru                            |2020|June     |515                   |
|Peru                            |2020|July     |542                   |
|Peru                            |2020|August   |528                   |
|Argentina                       |2020|October  |308                   |
|Belgium                         |2020|November |432                   |
|Bosnia and Herzegovina          |2020|November |443                   |
|Bulgaria                        |2020|November |400                   |
|Croatia                         |2020|November |304                   |
|Czechia                         |2020|November |470                   |
|Hungary                         |2020|November |319                   |
|Liechtenstein                   |2020|November |366                   |
|Montenegro                      |2020|November |315                   |
|North Macedonia                 |2020|November |369                   |
|Poland                          |2020|November |305                   |
|Slovenia                        |2020|November |528                   |
|Switzerland                     |2020|November |307                   |
|Austria                         |2020|December |376                   |
|Bosnia and Herzegovina          |2020|December |423                   |
|Bulgaria                        |2020|December |513                   |
|Croatia                         |2020|December |523                   |
|Czechia                         |2020|December |306                   |
|Georgia                         |2020|December |311                   |
|Hungary                         |2020|December |489                   |
|Italy                           |2020|December |308                   |
|Liechtenstein                   |2020|December |706                   |
|Lithuania                       |2020|December |437                   |
|North Macedonia                 |2020|December |355                   |
|Poland                          |2020|December |302                   |
|San Marino                      |2020|December |412                   |
|Slovenia                        |2020|December |607                   |
|Switzerland                     |2020|December |324                   |
|Czechia                         |2021|January  |441                   |
|Eswatini                        |2021|January  |307                   |
|Gibraltar                       |2021|January  |2078                  |
|Hungary                         |2021|January  |310                   |
|Lithuania                       |2021|January  |376                   |
|Peru                            |2021|January  |322                   |
|Portugal                        |2021|January  |548                   |
|Slovakia                        |2021|January  |460                   |
|Slovenia                        |2021|January  |388                   |
|United Kingdom                  |2021|January  |479                   |
|Czechia                         |2021|February |376                   |
|Gibraltar                       |2021|February |475                   |
|Montenegro                      |2021|February |315                   |
|Peru                            |2021|February |560                   |
|Portugal                        |2021|February |377                   |
|Slovakia                        |2021|February |467                   |
|Bosnia and Herzegovina          |2021|March    |468                   |
|Brazil                          |2021|March    |313                   |
|Bulgaria                        |2021|March    |436                   |
|Czechia                         |2021|March    |567                   |
|Hungary                         |2021|March    |598                   |
|Montenegro                      |2021|March    |431                   |
|North Macedonia                 |2021|March    |309                   |
|Peru                            |2021|March    |627                   |
|Slovakia                        |2021|March    |464                   |
|Wallis and Futuna               |2021|March    |361                   |
|Bonaire Sint Eustatius and Saba |2021|April    |454                   |
|Bosnia and Herzegovina          |2021|April    |598                   |
|Brazil                          |2021|April    |385                   |
|Bulgaria                        |2021|April    |464                   |
|Curacao                         |2021|April    |449                   |
|Hungary                         |2021|April    |706                   |
|Montenegro                      |2021|April    |352                   |
|North Macedonia                 |2021|April    |516                   |
|Paraguay                        |2021|April    |302                   |
|Peru                            |2021|April    |698                   |
|Poland                          |2021|April    |382                   |
|Slovakia                        |2021|April    |361                   |
|Uruguay                         |2021|April    |471                   |
|Argentina                       |2021|May      |312                   |
|Paraguay                        |2021|May      |388                   |
|Peru                            |2021|May      |512                   |
|Uruguay                         |2021|May      |476                   |
|Argentina                       |2021|June     |355                   |
|Colombia                        |2021|June     |347                   |
|Paraguay                        |2021|June     |514                   |
|Suriname                        |2021|June     |372                   |
|Uruguay                         |2021|June     |378                   |
|British Virgin Islands          |2021|July     |986                   |
|Namibia                         |2021|July     |589                   |
|Tunisia                         |2021|July     |396                   |
|Aruba                           |2021|August   |336                   |
|French Polynesia                |2021|August   |1016                  |
|Georgia                         |2021|August   |399                   |
|Tunisia                         |2021|August   |315                   |
|Antigua and Barbuda             |2021|September|355                   |
|Bahamas                         |2021|September|446                   |
|Bermuda                         |2021|September|612                   |
|French Polynesia                |2021|September|655                   |
|Georgia                         |2021|September|386                   |
|Grenada                         |2021|September|1230                  |
|Montenegro                      |2021|September|317                   |
|New Caledonia                   |2021|September|413                   |
|North Macedonia                 |2021|September|351                   |
|Saint Lucia                     |2021|September|526                   |
|Armenia                         |2021|October  |340                   |
|Bermuda                         |2021|October  |467                   |
|Bulgaria                        |2021|October  |452                   |
|Grenada                         |2021|October  |504                   |
|Lithuania                       |2021|October  |327                   |
|New Caledonia                   |2021|October  |507                   |
|Romania                         |2021|October  |560                   |
|Saint Vincent and the Grenadines|2021|October  |422                   |
|Suriname                        |2021|October  |351                   |
|Armenia                         |2021|November |417                   |
|Bosnia and Herzegovina          |2021|November |334                   |
|Bulgaria                        |2021|November |646                   |
|Croatia                         |2021|November |411                   |
|Georgia                         |2021|November |505                   |
|Hungary                         |2021|November |394                   |
|Latvia                          |2021|November |496                   |
|Lithuania                       |2021|November |321                   |
|Moldova                         |2021|November |330                   |
|Montenegro                      |2021|November |325                   |
|Romania                         |2021|November |459                   |
|Trinidad and Tobago             |2021|November |329                   |
|Ukraine                         |2021|November |442                   |
|Bulgaria                        |2021|December |363                   |
|Croatia                         |2021|December |402                   |
|Georgia                         |2021|December |439                   |
|Hungary                         |2021|December |484                   |
|Poland                          |2021|December |356                   |
|Slovakia                        |2021|December |407                   |
|Trinidad and Tobago             |2021|December |507                   |
|Bosnia and Herzegovina          |2022|January  |308                   |
|British Virgin Islands          |2022|January  |329                   |
|Bulgaria                        |2022|January  |343                   |
|Croatia                         |2022|January  |316                   |
|Trinidad and Tobago             |2022|January  |381                   |
|Bosnia and Herzegovina          |2022|February |310                   |
|British Virgin Islands          |2022|February |427                   |
|Bulgaria                        |2022|February |328                   |
|Croatia                         |2022|February |304                   |
|Palau                           |2022|February |330                   |
|Hong Kong                       |2022|March    |938                   |
|Aruba                           |2022|April    |550                   |
|Montserrat                      |2022|May      |803                   |
|Montserrat                      |2022|June     |402                   |


### Months with High Death Rates in Large Countries
In calendar order, show when a country had at least 200 deaths per million population. (Or at least one death per 5000 people.), for countries with more than ten million people. Note that the threshold used here is lower than when smaller countries where included.

```
SELECT [Location], [Year], [MonthName], round([MonthlyNewDeathsPerMillion], 0) AS [DeathsPerMillionPeople]
FROM #monthly_deaths
WHERE ([MonthlyNewDeathsPerMillion] >= 200) AND ([MonthlyPopulation] > 10000000)
ORDER BY [Year], [MonthNum], [Location];
```

|Location      |Year|MonthName|DeathsPerMillionPeople|
|--------------|----|---------|----------------------|
|Italy         |2020|March    |205                   |
|Belgium       |2020|April    |592                   |
|France        |2020|April    |309                   |
|Italy         |2020|April    |257                   |
|Netherlands   |2020|April    |219                   |
|Spain         |2020|April    |344                   |
|Sweden        |2020|April    |239                   |
|United Kingdom|2020|April    |356                   |
|Peru          |2020|May      |477                   |
|Chile         |2020|June     |241                   |
|Peru          |2020|June     |515                   |
|Peru          |2020|July     |542                   |
|Peru          |2020|August   |528                   |
|Bolivia       |2020|September|248                   |
|Peru          |2020|September|255                   |
|Argentina     |2020|October  |308                   |
|Czechia       |2020|October  |242                   |
|Belgium       |2020|November |432                   |
|Czechia       |2020|November |470                   |
|France        |2020|November |237                   |
|Italy         |2020|November |281                   |
|Poland        |2020|November |305                   |
|Romania       |2020|November |228                   |
|Belgium       |2020|December |248                   |
|Czechia       |2020|December |306                   |
|Germany       |2020|December |201                   |
|Greece        |2020|December |235                   |
|Italy         |2020|December |308                   |
|Poland        |2020|December |302                   |
|Portugal      |2020|December |236                   |
|Romania       |2020|December |232                   |
|Sweden        |2020|December |201                   |
|United Kingdom|2020|December |221                   |
|United States |2020|December |244                   |
|Colombia      |2021|January  |210                   |
|Czechia       |2021|January  |441                   |
|Germany       |2021|January  |285                   |
|Italy         |2021|January  |238                   |
|Mexico        |2021|January  |251                   |
|Peru          |2021|January  |322                   |
|Poland        |2021|January  |228                   |
|Portugal      |2021|January  |548                   |
|South Africa  |2021|January  |261                   |
|Sweden        |2021|January  |282                   |
|United Kingdom|2021|January  |479                   |
|United States |2021|January  |290                   |
|Czechia       |2021|February |376                   |
|Mexico        |2021|February |209                   |
|Peru          |2021|February |560                   |
|Portugal      |2021|February |377                   |
|Spain         |2021|February |232                   |
|United Kingdom|2021|February |245                   |
|Brazil        |2021|March    |313                   |
|Czechia       |2021|March    |567                   |
|Jordan        |2021|March    |210                   |
|Peru          |2021|March    |627                   |
|Poland        |2021|March    |245                   |
|Brazil        |2021|April    |385                   |
|Colombia      |2021|April    |201                   |
|Czechia       |2021|April    |265                   |
|Greece        |2021|April    |221                   |
|Peru          |2021|April    |698                   |
|Poland        |2021|April    |382                   |
|Romania       |2021|April    |239                   |
|Ukraine       |2021|April    |264                   |
|Argentina     |2021|May      |312                   |
|Brazil        |2021|May      |274                   |
|Colombia      |2021|May      |294                   |
|Peru          |2021|May      |512                   |
|Argentina     |2021|June     |355                   |
|Brazil        |2021|June     |258                   |
|Colombia      |2021|June     |347                   |
|Peru          |2021|June     |256                   |
|Argentina     |2021|July     |250                   |
|Colombia      |2021|July     |277                   |
|Tunisia       |2021|July     |396                   |
|Cuba          |2021|August   |225                   |
|Iran          |2021|August   |202                   |
|Kazakhstan    |2021|August   |203                   |
|Malaysia      |2021|August   |233                   |
|Sri Lanka     |2021|August   |221                   |
|Tunisia       |2021|August   |315                   |
|Malaysia      |2021|September|295                   |
|Romania       |2021|October  |560                   |
|Russia        |2021|October  |210                   |
|Ukraine       |2021|October  |278                   |
|Czechia       |2021|November |216                   |
|Greece        |2021|November |214                   |
|Romania       |2021|November |459                   |
|Russia        |2021|November |245                   |
|Ukraine       |2021|November |442                   |
|Czechia       |2021|December |285                   |
|Greece        |2021|December |254                   |
|Poland        |2021|December |356                   |
|Russia        |2021|December |225                   |
|Ukraine       |2021|December |249                   |
|Greece        |2022|January  |261                   |
|Poland        |2022|January  |215                   |
|Greece        |2022|February |228                   |

### Top 50 countries in terms of total deaths vs population

```
SELECT TOP(50) [location], round(sum([MonthlyNewDeathsPerMillion]), 0) AS [TotalDeathsPerMillionPop]
FROM #monthly_deaths
GROUP BY [location]
HAVING sum([MonthlyNewDeathsPerMillion]) IS NOT NULL
ORDER BY sum([MonthlyNewDeathsPerMillion]) DESC;
```

|location              |TotalDeathsPerMillionPop|
|----------------------|------------------------|
|Peru                  |6416                    |
|Bulgaria              |5394                    |
|Bosnia and Herzegovina|4846                    |
|Hungary               |4834                    |
|North Macedonia       |4473                    |
|Montenegro            |4336                    |
|Georgia               |4224                    |
|Croatia               |3925                    |
|Czechia               |3761                    |
|Slovakia              |3692                    |
|Romania               |3436                    |
|Lithuania             |3415                    |
|San Marino            |3381                    |
|Slovenia              |3196                    |
|Latvia                |3131                    |
|Brazil                |3123                    |
|Poland                |3079                    |
|United States         |3038                    |
|Gibraltar             |3028                    |
|Armenia               |2908                    |
|Greece                |2895                    |
|Argentina             |2828                    |
|Trinidad and Tobago   |2825                    |
|Italy                 |2774                    |
|Belgium               |2747                    |
|Colombia              |2729                    |
|Moldova               |2726                    |
|Paraguay              |2622                    |
|Ukraine               |2587                    |
|Aruba                 |2575                    |
|United Kingdom        |2571                    |
|Russia                |2552                    |
|Mexico                |2442                    |
|Tunisia               |2401                    |
|Chile                 |2385                    |
|Serbia                |2344                    |
|Portugal              |2314                    |
|Spain                 |2311                    |
|French Polynesia      |2297                    |
|Suriname              |2285                    |
|Liechtenstein         |2248                    |
|Bermuda               |2223                    |
|France                |2213                    |
|Austria               |2205                    |
|Uruguay               |2092                    |
|British Virgin Islands|2071                    |
|Bahamas               |2046                    |
|Grenada               |2044                    |
|Saint Lucia           |2039                    |
|Andorra               |2004                    |

### Top 50 large countries in terms of total deaths vs population
As above, for countries with ten million people or more.

```
SELECT TOP(50) [location], round(sum([MonthlyNewDeathsPerMillion]), 0) AS [TotalDeathsPerMillionPop]
FROM #monthly_deaths
WHERE [MonthlyPopulation] >= 10000000
GROUP BY [location]
HAVING sum([MonthlyNewDeathsPerMillion]) IS NOT NULL
ORDER BY sum([MonthlyNewDeathsPerMillion]) DESC;
```

|location          |TotalDeathsPerMillionPop|
|------------------|------------------------|
|Peru              |6416                    |
|Czechia           |3761                    |
|Romania           |3436                    |
|Brazil            |3123                    |
|Poland            |3079                    |
|United States     |3038                    |
|Greece            |2895                    |
|Argentina         |2828                    |
|Italy             |2774                    |
|Belgium           |2747                    |
|Colombia          |2729                    |
|Ukraine           |2587                    |
|United Kingdom    |2571                    |
|Russia            |2552                    |
|Mexico            |2442                    |
|Tunisia           |2401                    |
|Chile             |2385                    |
|Portugal          |2314                    |
|Spain             |2311                    |
|France            |2213                    |
|Sweden            |1900                    |
|Bolivia           |1855                    |
|South Africa      |1685                    |
|Germany           |1668                    |
|Iran              |1662                    |
|Jordan            |1370                    |
|Netherlands       |1307                    |
|Ecuador           |1287                    |
|Turkey            |1164                    |
|Canada            |1101                    |
|Honduras          |1093                    |
|Malaysia          |1090                    |
|Kazakhstan        |1016                    |
|Guatemala         |1003                    |
|Azerbaijan        |950                     |
|Sri Lanka         |768                     |
|Cuba              |754                     |
|Iraq              |613                     |
|Indonesia         |567                     |
|Philippines       |545                     |
|South Korea       |475                     |
|Vietnam           |441                     |
|Thailand          |434                     |
|Morocco           |431                     |
|Nepal             |403                     |
|Dominican Republic|400                     |
|India             |371                     |
|Zimbabwe          |366                     |
|Myanmar           |355                     |
|Australia         |353                     |

