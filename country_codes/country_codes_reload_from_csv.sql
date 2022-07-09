-- Import the csv into a table of strings
-- so it can be examined, converted, and cleaned using the power of SQL.
DROP TABLE IF EXISTS [world_data].[dbo].[country_codes_raw];
CREATE TABLE [world_data].[dbo].[country_codes_raw] (
    ISOalpha3 nvarchar(100) NULL,
	CountryOrArea nvarchar(100) NULL
);
BULK INSERT [world_data].[dbo].[country_codes_raw]
FROM 'C:\github\world_data\country_codes\raw.txt'  -- <<<<< YOU WILL HAVE TO CHANGE THIS PATH <<<<<
WITH
(
		ROWTERMINATOR = '0x0a',  
		FIELDTERMINATOR = '\t', -- Exported from excel as tab delimited because the Reliability column has commas.
        FIRSTROW=1
);

-- Create a table with the types we ultimately want
DROP TABLE IF EXISTS [world_data].[dbo].[country_codes];
CREATE TABLE [world_data].[dbo].[country_codes] (
    ISOalpha3 char(3) NULL,
	CountryOrArea nvarchar(100) NULL,
	isPrimaryName bit NULL  -- 1 if this is the name to use when converting country codes back to names. 
	                      -- Zero for all alternate forms of the name.
);

-- Convert strings into the expected types and insert into the final table.
-- Some rows have a double quoted string containing a comma in the CountryOrArea column, like:
--    "Bonaire, Sint Eustatius and Saba"	535	BES
-- So we trim double quotes from that column, and spaces while we're at it.
-- The ISOalpha3 column had some space or newline character at the end.
--   The easy solution is to just take the first 3 characters.
INSERT INTO [world_data].[dbo].[country_codes]
SELECT
	ISOalpha3,
	CountryOrArea,
	1
FROM  [world_data].[dbo].[country_codes_raw];

-- Now add alternate forms of a country's English language name.
-- Since these are "alternate" names, we set isPrimaryName to zero.

-- British Virgin Islands
INSERT [world_data].[dbo].[country_codes] (ISOalpha3, CountryOrArea, isPrimaryName) 
VALUES ('VGB', 'British Virgin Islands', 0);

-- China, Hong Kong SAR
INSERT [world_data].[dbo].[country_codes] (ISOalpha3, CountryOrArea, isPrimaryName) 
VALUES ('HKG', 'China, Hong Kong SAR', 0);

-- China, Macao SAR
INSERT [world_data].[dbo].[country_codes] (ISOalpha3, CountryOrArea, isPrimaryName) 
VALUES ('MAC', 'China, Macao SAR', 0);

-- Democratic People's Republic of Korea
INSERT [world_data].[dbo].[country_codes] (ISOalpha3, CountryOrArea, isPrimaryName) 
VALUES ('PRK', 'Democratic People''s Republic of Korea', 0);

-- Republic of Korea
INSERT [world_data].[dbo].[country_codes] (ISOalpha3, CountryOrArea, isPrimaryName) 
VALUES ('KOR', 'Republic of Korea', 0);

-- Republic of Moldova
INSERT [world_data].[dbo].[country_codes] (ISOalpha3, CountryOrArea, isPrimaryName) 
VALUES ('MDA', 'Republic of Moldova', 0);

-- Republic of South Sudan
INSERT [world_data].[dbo].[country_codes] (ISOalpha3, CountryOrArea, isPrimaryName) 
VALUES ('SSD', 'Republic of South Sudan', 0);

-- Reunion
INSERT [world_data].[dbo].[country_codes] (ISOalpha3, CountryOrArea, isPrimaryName) 
VALUES ('REU', 'Reunion', 0);

-- Saint Helena ex. dep.
INSERT [world_data].[dbo].[country_codes] (ISOalpha3, CountryOrArea, isPrimaryName) 
VALUES ('SHN', 'Saint Helena ex. dep.', 0);

-- State of Palestine
INSERT [world_data].[dbo].[country_codes] (ISOalpha3, CountryOrArea, isPrimaryName) 
VALUES ('PSE', 'State of Palestine', 0);

-- United Republic of Tanzania
INSERT [world_data].[dbo].[country_codes] (ISOalpha3, CountryOrArea, isPrimaryName) 
VALUES ('TZA', 'United Republic of Tanzania', 0);

-- United States Virgin Islands
INSERT [world_data].[dbo].[country_codes] (ISOalpha3, CountryOrArea, isPrimaryName) 
VALUES ('VIR', 'United States Virgin Islands', 0);

-- Wallis and Futuna Islands
INSERT [world_data].[dbo].[country_codes] (ISOalpha3, CountryOrArea, isPrimaryName) 
VALUES ('VGB', 'Wallis and Futuna Islands', 0);


-- Check the final table
SELECT * FROM [world_data].[dbo].[country_codes]

