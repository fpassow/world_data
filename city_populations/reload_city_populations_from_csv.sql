-- Import the csv into a table of strings
-- so it can be examined, converted, and cleaned using the power of SQL.
DROP TABLE IF EXISTS [world_data].[dbo].[city_population_raw];
CREATE TABLE [world_data].[dbo].[city_population_raw] (
	[CountryOrArea] [nvarchar](100) NULL,
	[Year] [nvarchar](100) NULL,	
	[Area]  [nvarchar](100) NULL,
	[Sex] [nvarchar](100) NULL,
	[City] [nvarchar](100) NULL,
	[CityType] [nvarchar](100) NULL,
	[RecordType] [nvarchar](100) NULL,
	[Reliability] [nvarchar](100) NULL,
	[SourceYear] [nvarchar](100) NULL,
	[Value] [nvarchar](100) NULL,
	[ValueFootnotes] [nvarchar](100) NULL
);
BULK INSERT [world_data].[dbo].[city_population_raw]
FROM 'C:\github\world_data\city_populations\import_me.txt'  -- <<<<< YOU WILL HAVE TO CHANGE THIS PATH <<<<<
WITH
(
		ROWTERMINATOR = '0x0a',  
		FIELDTERMINATOR = '\t', -- Exported from excel as tab delimited because the Reliability column has commas.
        FIRSTROW=2
);

-- Check the data
SELECT * FROM [world_data].[dbo].[city_population_raw]

-- Create a table with the types we ultimately want
DROP TABLE IF EXISTS [world_data].[dbo].[city_population_nocode];
CREATE TABLE [world_data].[dbo].[city_population_nocode] (
	[CountryOrArea] [nvarchar](100) NULL,
	[Year] int NULL,	
	[Area]  [nvarchar](100) NULL,
	[Sex] [nvarchar](100) NULL,
	[City] [nvarchar](100) NULL,
	[CityType] [nvarchar](100) NULL,
	[RecordType] [nvarchar](100) NULL,
	[Reliability] [nvarchar](100) NULL,
	[Source Year] int NULL,
	[Value] float NULL,
	[ValueFootnotes] [nvarchar](100)  NULL,
);

-- Convert strings into the expected types and insert into final table
-- Strip quotes where needed.
INSERT INTO [world_data].[dbo].[city_population_nocode]
SELECT
	trim('"' FROM [CountryOrArea]),
	convert(int, [Year]),
	[Area],
	[Sex],
	[City],
	[CityType] ,
	[RecordType],
	trim('"' FROM [Reliability]),
	convert(int, [SourceYear] ),
	convert(float, [Value]),
	[ValueFootnotes]
FROM  [world_data].[dbo].[city_population_raw];

-- Check
SELECT * FROM [world_data].[dbo].[city_population_nocode];



