# Load Data on City Populations and Combine With Covid Data Using SQL

## Data and Setup

The raw data is downloaded from [data.un.org](https://data.un.org/Data.aspx?d=POP&f=tableCode%3A240).

The downloaded file is zipped and has a date in the name. So the name will probably change.
It has footnotes at the bottom.
And the Reliability column is quoted and contains commas.
Therefore, we open it in Excel, manually remove the footnotes 
and save the result as tab-separated values
in world_data\city_populations\import_me.txt.
Then load the data using SQL Server Management Studio and [this code](https://github.com/fpassow/world_data/blob/main/city_populations/reload_city_populations_from_csv.sql).

Or you can see all of the scripts and files in [this github repo](https://github.com/fpassow/world_data)

## Exploration
```
USE [world_data]
```

How many unique countries do we have in the data?
```
SELECT count(DISTINCT CountryOrArea)
FROM [world_data].[dbo].[city_population]
WHERE Sex = 'Both Sexes'
```

|(No column name)|
|----------------|
|216             |

How many countries have data for 2020 or after?
```
SELECT count(DISTINCT CountryOrArea)
FROM [world_data].[dbo].[city_population]
WHERE Year >= 2020 AND Sex = 'Both Sexes'
```

|(No column name)|
|----------------|
|41              |

Try 2018.
```
SELECT DISTINCT count(DISTINCT CountryOrArea)
FROM [world_data].[dbo].[city_population]
WHERE Year >= 2018 AND Sex = 'Both Sexes'
```

|(No column name)|
|----------------|
|70              |

Still not enough countries.
Let's just get the most recent population number for each city.
```
WITH numbered_cte AS (
    SELECT CountryOrArea, City, Year, Value, 
        row_number() OVER (PARTITION BY CountryOrArea, City ORDER BY Year DESC) AS RowNumber
    FROM [world_data].[dbo].[city_population]
	WHERE Sex = 'Both Sexes'
)
SELECT CountryOrArea, City, Year, Value
FROM numbered_cte
WHERE RowNumber = 1
ORDER BY Value DESC
```

|CountryOrArea                                       |City                                              |Year|Value      |
|----------------------------------------------------|--------------------------------------------------|----|-----------|
|China                                               |Shanghai                                          |2010|23019196   |
|Mexico                                              |MEXICO, CIUDAD DE                                 |2021|21804515   |
|China                                               |BEIJING (PEKING)                                  |2010|19612368   |
|Argentina                                           |BUENOS AIRES                                      |2021|15567820.28|
|Pakistan                                            |Karachi                                           |2017|14910352   |
|India                                               |Greater Mumbai                                    |2011|12442373   |
|India                                               |Mumbai (Bombay)                                   |2001|11978450   |
|Russian Federation                                  |MOSKVA                                            |2012|11918057   |
|Pakistan                                            |Lahore                                            |2017|11126285   |
|India                                               |Delhi Municipal Corporation (DMC)                 |2011|11034555   |
|Indonesia                                           |JAKARTA                                           |2020|10562088   |
|India                                               |Delhi                                             |2001|9879172    |
|Japan                                               |TOKYO                                             |2020|9744534    |
|China                                               |Chongqing                                         |2000|9691901    |
|Republic of Korea                                   |SEOUL                                             |2019|9662041    |
|Peru                                                |LIMA                                              |2017|9562280    |
|Egypt                                               |CAIRO                                             |2017|9539673    |
|Bangladesh                                          |DHAKA                                             |2011|8906035    |
|United States of America                            |New York (NY)                                     |2020|8804190    |
|Iran (Islamic Republic of)                          |TEHRAN                                            |2016|8693706    |
|China                                               |Guangzhou                                         |2000|8524826    |
|India                                               |Bruhat Bengaluru Mahanagara Palike (BBMP)         |2011|8495492    |
|...                                               |...                                         |...|...    |


## Data About Each Country's Most Populous City.

Make a temp table of the most populous city in each country, based on latest available data
```
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
```

Make another temp table, this time with ISO three-letter country codes.
We will use our table mapping country names to ISO codes, which was 
[created with this data and code](https://github.com/fpassow/world_data/tree/main/country_codes).
```
DROP TABLE IF EXISTS #city_populations;
SELECT city_pops.CountryOrArea, City, Value AS CityPop, ISOalpha3
INTO #city_populations
FROM #city_populations_nocodes AS city_pops
JOIN [world_data].[dbo].[country_codes] AS codes
ON city_pops.CountryOrArea = codes.CountryOrArea;

-- Check our final temp table of each countries largest city, with ISO country codes
SELECT * FROM #city_populations order by CityPop desc;
```

|CountryOrArea                                       |City                |CityPop    |ISOalpha3|
|----------------------------------------------------|--------------------|-----------|---------|
|China                                               |Shanghai            |23019196   |CHN      |
|Mexico                                              |MEXICO, CIUDAD DE   |21804515   |MEX      |
|Argentina                                           |BUENOS AIRES        |15567820.28|ARG      |
|Pakistan                                            |Karachi             |14910352   |PAK      |
|India                                               |Greater Mumbai      |12442373   |IND      |
|Russian Federation                                  |MOSKVA              |11918057   |RUS      |
|Indonesia                                           |JAKARTA             |10562088   |IDN      |
|Japan                                               |TOKYO               |9744534    |JPN      |
|Republic of Korea                                   |SEOUL               |9662041    |KOR      |
|Peru                                                |LIMA                |9562280    |PER      |
|Egypt                                               |CAIRO               |9539673    |EGY      |
|Bangladesh                                          |DHAKA               |8906035    |BGD      |
|United States of America                            |New York (NY)       |8804190    |USA      |
|Iran (Islamic Republic of)                          |TEHRAN              |8693706    |IRN      |
|Thailand                                            |BANGKOK             |8305218    |THA      |
|United Kingdom of Great Britain and Northern Ireland|LONDON              |8135667    |GBR      |
|China, Hong Kong SAR                                |HONG KONG SAR       |7481800    |HKG      |
|Colombia                                            |BOGOT├ü, D.C.       |7181469    |COL      |
|Brazil                                              |Rio de Janeiro      |6320446    |BRA      |
|Singapore                                           |SINGAPORE           |5685807    |SGP      |
|Australia                                           |Greater Sydney      |5312163    |AUS      |
|Myanmar                                             |Yangon              |5211431    |MMR      |
|Nigeria                                             |Lagos               |5195247    |NGA      |
|Saudi Arabia                                        |RIYADH              |5188286    |SAU      |
|Kenya                                               |NAIROBI             |4395749    |KEN      |
|...                                      |...             |...    |...      |


## Combine Population Data with Covid Data

Create a temp table with number of reported new cases vs population
monthly per country.
And this time we include the iso_code column.
```
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
```

Find countries with the most months during which more than 10 new cases were reported per thousand people
and make it a CTE.
Then JOIN with the city population data above, joining on the ISO country codes.
And display in descending order of city population
```
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
```

|Location                                            |CountryCode         |Months     |LargestCity|CityPopulation|
|----------------------------------------------------|--------------------|-----------|-----------|--------------|
|Argentina                                           |ARG                 |6          |BUENOS AIRES|15567820.28   |
|Russia                                              |RUS                 |1          |MOSKVA     |11918057      |
|Japan                                               |JPN                 |3          |TOKYO      |9744534       |
|South Korea                                         |KOR                 |4          |SEOUL      |9662041       |
|Peru                                                |PER                 |1          |LIMA       |9562280       |
|United States                                       |USA                 |8          |New York (NY)|8804190       |
|Iran                                                |IRN                 |1          |TEHRAN     |8693706       |
|Thailand                                            |THA                 |1          |BANGKOK    |8305218       |
|United Kingdom                                      |GBR                 |12         |LONDON     |8135667       |
|Hong Kong                                           |HKG                 |2          |HONG KONG SAR|7481800       |
|Colombia                                            |COL                 |4          |BOGOT├ü, D.C.|7181469       |
|Brazil                                              |BRA                 |3          |Rio de Janeiro|6320446       |
|Singapore                                           |SGP                 |7          |SINGAPORE  |5685807       |
|Australia                                           |AUS                 |6          |Greater Sydney|5312163       |
|Jordan                                              |JOR                 |5          |AMMAN      |4007526       |
|Germany                                             |DEU                 |7          |BERLIN     |3644826       |
|Spain                                               |ESP                 |6          |MADRID     |3300428       |
|Canada                                              |CAN                 |2          |Toronto    |2988408       |
|Ukraine                                             |UKR                 |3          |KYIV       |2893215       |
|Italy                                               |ITA                 |8          |ROMA       |2846509.5     |
|Ecuador                                             |ECU                 |1          |Guayaquil  |2291158       |
|Azerbaijan                                          |AZE                 |1          |BAKU       |2285273       |
|France                                              |FRA                 |10         |PARIS      |2206488       |
|Cuba                                                |CUB                 |3          |LA HABANA  |2132288       |
|Belarus                                             |BLR                 |1          |MINSK      |2018281       |
|Kazakhstan                                          |KAZ                 |3          |Almaty     |1947040       |
|Austria                                             |AUT                 |8          |WIEN       |1897491       |
|Malaysia                                            |MYS                 |5          |KUALA LUMPUR|1853918       |
|Romania                                             |ROU                 |4          |BUCURESTI  |1835258       |
|Poland                                              |POL                 |7          |WARSZAWA   |1792692       |
|Hungary                                             |HUN                 |8          |BUDAPEST   |1751251       |
|New Zealand                                         |NZL                 |5          |Auckland   |1717500       |
|Mongolia                                            |MNG                 |8          |ULAANBAATAR|1568550       |
|Serbia                                              |SRB                 |9          |BEOGRAD (BELGRADE)|1386727       |
|Uruguay                                             |URY                 |7          |MONTEVIDEO |1383601.242   |
|Czechia                                             |CZE                 |11         |PRAHA      |1324277       |
|Bulgaria                                            |BGR                 |6          |SOFIA      |1242568       |
|Georgia                                             |GEO                 |11         |TBILISI    |1154314       |
|Bolivia                                             |BOL                 |1          |Santa Cruz |1113582       |
|Armenia                                             |ARM                 |5          |YEREVAN    |1082949       |
|Tunisia                                             |TUN                 |2          |TUNIS      |1056247       |
|Dominican Republic                                  |DOM                 |1          |SANTO DOMINGO|965040        |
|Qatar                                               |QAT                 |3          |DOHA       |956457        |
|Israel                                              |ISR                 |9          |JERUSALEM  |927931        |
|Netherlands                                         |NLD                 |12         |AMSTERDAM  |821752        |
|Croatia                                             |HRV                 |9          |ZAGREB     |790017        |
|Sweden                                              |SWE                 |8          |STOCKHOLM  |789024        |
|Norway                                              |NOR                 |5          |OSLO       |681067        |
|Greece                                              |GRC                 |7          |ATHINAI    |664046        |
|Chile                                               |CHL                 |4          |Puente Alto|655033        |
|Finland                                             |FIN                 |6          |HELSINKI   |650938.5      |
|Denmark                                             |DNK                 |6          |KOBENHAVN  |633035        |
|Latvia                                              |LVA                 |10         |RIGA       |614618        |
|Jamaica                                             |JAM                 |1          |KINGSTON   |592291        |
|Palestine                                           |PSE                 |6          |Gaza       |579481        |
|Lithuania                                           |LTU                 |13         |VILNIUS    |556983        |
|North Macedonia                                     |MKD                 |6          |SKOPJE     |546824        |
|Ireland                                             |IRL                 |9          |DUBLIN     |544107        |
|Bosnia and Herzegovina                              |BIH                 |3          |SARAJEVO   |527049        |
|Paraguay                                            |PRY                 |2          |ASUNCI├ôN  |513399        |
|Portugal                                            |PRT                 |10         |LISBOA     |506654        |
|Belgium                                             |BEL                 |8          |Antwerpen (Anvers)|498473        |
|Panama                                              |PAN                 |5          |CIUDAD DE PANAM├ü|497113        |
|Estonia                                             |EST                 |13         |TALLINN    |437619        |
|Slovakia                                            |SVK                 |12         |BRATISLAVA |435296        |
|Namibia                                             |NAM                 |2          |WINDHOEK   |429974        |
|Switzerland                                         |CHE                 |9          |Z├╝rich    |420217        |
|Albania                                             |ALB                 |2          |TIRANA     |418495        |
|Lebanon                                             |LBN                 |5          |BEIRUT     |363033        |
|Costa Rica                                          |CRI                 |5          |SAN JOS├ë  |349678        |
|Moldova                                             |MDA                 |4          |CHISINAU (KISHINEV)|339079        |
|Slovenia                                            |SVN                 |15         |LJUBLJANA  |285604        |
|Bahamas                                             |BHS                 |1          |NASSAU     |266100        |
|Maldives                                            |MDV                 |6          |MAL├ë      |240984.1142   |
|Suriname                                            |SUR                 |4          |PARAMARIBO |240924        |
|Botswana                                            |BWA                 |5          |GABORONE   |231592        |
|Montenegro                                          |MNE                 |13         |PODGORICA  |185937        |
|Bahrain                                             |BHR                 |9          |MANAMA     |153395        |
|Mauritius                                           |MUS                 |5          |PORT LOUIS |145793        |
|Iceland                                             |ISL                 |6          |REYKJAVIK  |129964.5      |
|Kuwait                                              |KWT                 |3          |Salmiya    |129775        |
|Luxembourg                                          |LUX                 |11         |LUXEMBOURG-VILLE|122823        |
|Bhutan                                              |BTN                 |3          |THIMPHU    |114551        |
|New Caledonia                                       |NCL                 |5          |NOUMEA     |94285         |
|Fiji                                                |FJI                 |3          |SUVA       |74481         |
|Kiribati                                            |KIR                 |1          |TARAWA     |63017         |
|Cape Verde                                          |CPV                 |3          |PRAIA      |61644         |
|Eswatini                                            |SWZ                 |2          |MBABANE    |60691         |
|Vanuatu                                             |VUT                 |2          |PORT VILA  |50944         |
|Grenada                                             |GRD                 |4          |ST. GEORGE'S|38251         |
|Samoa                                               |WSM                 |2          |APIA       |37391         |
|Trinidad and Tobago                                 |TTO                 |3          |PORT-OF-SPAIN|37074         |
|Tonga                                               |TON                 |3          |NUKU'ALOFA |35184         |
|Gibraltar                                           |GIB                 |13         |GIBRALTAR  |34003         |
|Monaco                                              |MCO                 |8          |MONACO     |31109         |
|Aruba                                               |ABW                 |10         |ORANJESTAD |28295         |
|Cayman Islands                                      |CYM                 |8          |GEORGE TOWN|28089         |
|Brunei                                              |BRN                 |6          |BANDAR SERI BEGAWAN|27285         |
|French Polynesia                                    |PYF                 |6          |PAPEETE    |26925         |
|Seychelles                                          |SYC                 |15         |VICTORIA   |26450         |
|Isle of Man                                         |IMN                 |11         |DOUGLAS    |26218         |
|Guyana                                              |GUY                 |1          |GEORGETOWN |24849         |
|Antigua and Barbuda                                 |ATG                 |2          |ST. JOHN   |22342         |
|Andorra                                             |AND                 |15         |ANDORRA LA VELLA|22205         |
|Greenland                                           |GRL                 |4          |NUUK (GODTHAB)|18128         |
|Dominica                                            |DMA                 |9          |ROSEAU     |16243         |
|Saint Vincent and the Grenadines                    |VCT                 |3          |KINGSTOWN  |15466         |
|Saint Kitts and Nevis                               |KNA                 |3          |BASSETERRE |14161         |
|Belize                                              |BLZ                 |5          |BELMOPAN   |13939         |
|Faeroe Islands                                      |FRO                 |5          |T├ôRSHAVN  |13637         |
|Cook Islands                                        |COK                 |3          |RAROTONGA  |13007         |
|Palau                                               |PLW                 |5          |KOROR      |11754         |
|Barbados                                            |BRB                 |9          |BRIDGETOWN |7466          |
|Malta                                               |MLT                 |5          |VALLETTA   |5860          |
|Liechtenstein                                       |LIE                 |9          |VADUZ      |5701          |
|Saint Pierre and Miquelon                           |SPM                 |4          |SAINT-PIERRE|5415          |
|Turks and Caicos Islands                            |TCA                 |4          |GRAND TURK |4831          |
|San Marino                                          |SMR                 |12         |SAN MARINO |4127          |
|Saint Lucia                                         |LCA                 |5          |CASTRIES   |3661          |
|British Virgin Islands                              |VGB                 |4          |ROAD TOWN  |3500          |
|Bermuda                                             |BMU                 |9          |Town of St. George|3398          |
|Anguilla                                            |AIA                 |8          |THE VALLEY |2812          |
|Falkland Islands                                    |FLK                 |3          |STANLEY    |2460          |
|Montserrat                                          |MSR                 |3          |PLYMOUTH   |1478          |
|British Virgin Islands                              |VGB                 |4          |META-UTU   |1126          |
|Vatican                                             |VAT                 |1          |VATICAN CITY|451           |

## Conclusion
This query does not show more "outbreaks" for countries with large cities.
However, the source of the covid data mentions that numbers are for *reported* cases,
which is influenced by the fraction of actual covid cases identified by a countries medical system.

TODO: Look at population of largest city vs percentage of positive tests
          or adjust cases by a countries "testing rate" (tests/population).

