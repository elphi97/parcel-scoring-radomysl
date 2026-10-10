--Creates the schemas used in the dzialki_radomysl database 
--Script is running in dzialki_radomysl database
--This script is fully reusable (safe to run multiple times)

--source data form GUGiK, unmodified, original data
CREATE SCHEMA IF NOT EXISTS raw;
--result of analysis and scoring of parcels 
CREATE SCHEMA IF NOT EXISTS analysis;