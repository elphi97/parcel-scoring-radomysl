@echo off
REM Imports parcels of gmina Radomysl Wielki (TERYT 181108) from the county GPKG into PostGIS.
REM Run from OSGeo4W Shell (GDAL required). PGPASSWORD must be set.
set GPKG=%~dp0..\data\raw\1811.gpkg

ogr2ogr -f PostgreSQL PG:"host=localhost port=5433 dbname=dzialki_radomysl user=postgres" "%GPKG%" dzialki -where "numer_jednostki LIKE '181108%%'" -nln raw.dzialki -nlt MULTIPOLYGON -lco GEOMETRY_NAME=geom -lco SPATIAL_INDEX=GIST -overwrite