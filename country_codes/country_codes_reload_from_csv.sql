-- Import the csv into a table of strings
-- so it can be examined, converted, and cleaned using the power of SQL.
DROP TABLE IF EXISTS [world_data].[dbo].[country_codes_raw];
CREATE TABLE [world_data].[dbo].[country_codes_raw] (
    CountryOrArea nvarchar(100) NULL,
	M49code nvarchar(100) NULL,
	ISOalpha3 nvarchar(100) NULL
);
BULK INSERT [world_data].[dbo].[country_codes_raw]
FROM 'C:\github\world_data\country_codes\country_codes_from_unstats.txt'  -- <<<<< YOU WILL HAVE TO CHANGE THIS PATH <<<<<
WITH
(
		ROWTERMINATOR = '0x0a',  
		FIELDTERMINATOR = '\t', -- Exported from excel as tab delimited because the Reliability column has commas.
        FIRSTROW=2
);

-- Check the data
SELECT * FROM [world_data].[dbo].[country_codes_raw]


-- Create a table with the types we ultimately want
DROP TABLE IF EXISTS [world_data].[dbo].[country_codes];
CREATE TABLE [world_data].[dbo].[country_codes] (
    CountryOrArea nvarchar(100) NULL,
	M49code int NULL,
	ISOalpha3 char(3) NULL,
	isStandardName bit NULL  -- 1 if this is the name to use when converting country codes back to names.
);


-- Convert strings into the expected types and insert into the final table.
-- Some rows have a double quoted string containing a comma in the CountryOrArea column, like:
--    "Bonaire, Sint Eustatius and Saba"	535	BES
-- So we trim double quotes from that column, and spaces while we're at it.
-- The ISOalpha3 column had some space or newline character at the end.
--   The easy solution is to just take the first 3 characters.
INSERT INTO [world_data].[dbo].[country_codes]
SELECT
	trim('" ' FROM CountryOrArea),
	convert(int, M49code),
	left(ISOalpha3, 3) ,
	1
FROM  [world_data].[dbo].[country_codes_raw];


-- Now add alternate forms of a country's English language name.
-- Since these are "alternate" names, we set isStandardName to zero.

-- China, Hong Kong SAR   should be  344 HKG
INSERT [world_data].[dbo].[country_codes] (CountryOrArea, M49code, ISOalpha3, isStandardName) 
VALUES ('China, Hong Kong SAR', 344, 'HKG', 0);

-- China, Macao SAR       should be  446 MAC
INSERT [world_data].[dbo].[country_codes] (CountryOrArea, M49code, ISOalpha3, isStandardName) 
VALUES ('China, Macao SAR', 446, 'MAC', 0);


-- Check our final data
SELECT * FROM [world_data].[dbo].[country_codes];
