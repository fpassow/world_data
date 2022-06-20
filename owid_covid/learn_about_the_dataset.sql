-- Queries in this file are for understanding the structure of the dataset, 
-- We are trying to understand what columns and rows are useful for further analysis.


-- Count non-null values in each column.
SELECT 
       count([iso_code])	as	iso_code_count
      ,count([continent])	as	continent_count
      ,count([location])	as	location_count
      ,count([date])	as	date_count
      ,count([total_cases])	as	total_cases_count
      ,count([new_cases])	as	new_cases_count
      ,count([new_cases_smoothed])	as	new_cases_smoothed_count
      ,count([total_deaths])	as	total_deaths_count
      ,count([new_deaths])	as	new_deaths_count
      ,count([new_deaths_smoothed])	as	new_deaths_smoothed_count
      ,count([total_cases_per_million])	as	total_cases_per_million_count
      ,count([new_cases_per_million])	as	new_cases_per_million_count
      ,count([new_cases_smoothed_per_million])	as	new_cases_smoothed_per_million_count
      ,count([total_deaths_per_million])	as	total_deaths_per_million_count
      ,count([new_deaths_per_million])	as	new_deaths_per_million_count
      ,count([new_deaths_smoothed_per_million])	as	new_deaths_smoothed_per_million_count
      ,count([reproduction_rate])	as	reproduction_rate_count
      ,count([icu_patients])	as	icu_patients_count
      ,count([icu_patients_per_million])	as	icu_patients_per_million_count
      ,count([hosp_patients])	as	hosp_patients_count
      ,count([hosp_patients_per_million])	as	hosp_patients_per_million_count
      ,count([weekly_icu_admissions])	as	weekly_icu_admissions_count
      ,count([weekly_icu_admissions_per_million])	as	weekly_icu_admissions_per_million_count
      ,count([weekly_hosp_admissions])	as	weekly_hosp_admissions_count
      ,count([weekly_hosp_admissions_per_million])	as	weekly_hosp_admissions_per_million_count
      ,count([total_tests])	as	total_tests_count
      ,count([new_tests])	as	new_tests_count
      ,count([total_tests_per_thousand])	as	total_tests_per_thousand_count
      ,count([new_tests_per_thousand])	as	new_tests_per_thousand_count
      ,count([new_tests_smoothed])	as	new_tests_smoothed_count
      ,count([new_tests_smoothed_per_thousand])	as	new_tests_smoothed_per_thousand_count
      ,count([positive_rate])	as	positive_rate_count
      ,count([tests_per_case])	as	tests_per_case_count
      ,count([tests_units])	as	tests_units_count
      ,count([total_vaccinations])	as	total_vaccinations_count
      ,count([people_vaccinated])	as	people_vaccinated_count
      ,count([people_fully_vaccinated])	as	people_fully_vaccinated_count
      ,count([total_boosters])	as	total_boosters_count
      ,count([new_vaccinations])	as	new_vaccinations_count
      ,count([new_vaccinations_smoothed])	as	new_vaccinations_smoothed_count
      ,count([total_vaccinations_per_hundred])	as	total_vaccinations_per_hundred_count
      ,count([people_vaccinated_per_hundred])	as	people_vaccinated_per_hundred_count
      ,count([people_fully_vaccinated_per_hundred])	as	people_fully_vaccinated_per_hundred_count
      ,count([total_boosters_per_hundred])	as	total_boosters_per_hundred_count
      ,count([new_vaccinations_smoothed_per_million])	as	new_vaccinations_smoothed_per_million_count
      ,count([new_people_vaccinated_smoothed])	as	new_people_vaccinated_smoothed_count
      ,count([new_people_vaccinated_smoothed_per_hundred])	as	new_people_vaccinated_smoothed_per_hundred_count
      ,count([stringency_index])	as	stringency_index_count
      ,count([population])	as	population_count
      ,count([population_density])	as	population_density_count
      ,count([median_age])	as	median_age_count
      ,count([aged_65_older])	as	aged_65_older_count
      ,count([aged_70_older])	as	aged_70_older_count
      ,count([gdp_per_capita])	as	gdp_per_capita_count
      ,count([extreme_poverty])	as	extreme_poverty_count
      ,count([cardiovasc_death_rate])	as	cardiovasc_death_rate_count
      ,count([diabetes_prevalence])	as	diabetes_prevalence_count
      ,count([female_smokers])	as	female_smokers_count
      ,count([male_smokers])	as	male_smokers_count
      ,count([handwashing_facilities])	as	handwashing_facilities_count
      ,count([hospital_beds_per_thousand])	as	hospital_beds_per_thousand_count
      ,count([life_expectancy])	as	life_expectancy_count
      ,count([human_development_index])	as	human_development_index_count
      ,count([excess_mortality_cumulative_absolute])	as	excess_mortality_cumulative_absolute_count
      ,count([excess_mortality_cumulative])	as	excess_mortality_cumulative_count
      ,count([excess_mortality])	as	excess_mortality_count
      ,count([excess_mortality_cumulative_per_million])	as	excess_mortality_cumulative_per_million_count
FROM [world_data].[dbo].[owid_covid];

-- Check what can be found in the [location] and [continent] columns.
-- We find that real countries all have values in the [continent] column.
-- But non-countries like "Asia" and "High income" have NULLs in the continent column.
SELECT DISTINCT [location], [continent]
FROM [world_data].[dbo].[owid_covid]
ORDER BY [continent];
