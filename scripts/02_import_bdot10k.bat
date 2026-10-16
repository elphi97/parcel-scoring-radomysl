@echo off
REM Imports selected BDOT10k layers (county 1811) into schema raw.
REM Only objects inside the gmina bounding box (+ 2 km margin) are loaded.
REM Run from OSGeo4W Shell (GDAL required). PGPASSWORD must be set.

set SRC=%~dp0..\data\raw\1811_GPKG
set PREFIX=PL.PZGiK.332.BDOT10k.1811__OT_
set PG=PG:"host=localhost port=5433 dbname=dzialki_radomysl user=postgres"

REM Bounding box in EPSG:2180: xmin ymin xmax ymax (from ST_Extent query)
set BBOX=650708 252068 672795 270096

for %%L in (ptlz_a pttr_a ptut_a ptwp_a ptzb_a ptkm_a suln_l skdr_l bubd_a swrs_l swkn_l tcon_a tcrz_a) do (
    echo Importing %%L ...
    ogr2ogr -f PostgreSQL %PG% "%SRC%\%PREFIX%%%L.gpkg" -nln raw.bdot_%%L -nlt PROMOTE_TO_MULTI -nlt CONVERT_TO_LINEAR -spat %BBOX% -lco GEOMETRY_NAME=geom -lco SPATIAL_INDEX=GIST -overwrite
)
echo Done.