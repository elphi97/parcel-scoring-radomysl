-- Builds the base parcel table for analysis from raw data.
-- Run in database dzialki_radomysl (not postgres). Safe to run multiple times.
-- Requires: raw.dzialki (script 01 import) and schema analysis (script 02).

DROP TABLE IF EXISTS analysis.parcels_base;

-- 1. Base table: key attributes + area calculated from geometry (EPSG:2180 = metres)
CREATE TABLE analysis.parcels_base AS
SELECT
    id_dzialki,
    numer_dzialki,
    nazwa_obrebu,
    numer_obrebu,
    numer_jednostki,
    ROUND(ST_Area(geom)::numeric, 2)           AS area_m2,
    ROUND((ST_Area(geom) / 10000)::numeric, 4) AS area_ha,
    geom
FROM raw.dzialki;

-- 2. Primary key (fails if id_dzialki is not unique - see check below)
ALTER TABLE analysis.parcels_base
    ADD CONSTRAINT parcels_base_pkey PRIMARY KEY (id_dzialki);

-- 3. Spatial index - speeds up every spatial query on this table
CREATE INDEX parcels_base_geom_idx
    ON analysis.parcels_base USING GIST (geom);

-- 4. Refresh planner statistics after creating the table
ANALYZE analysis.parcels_base;