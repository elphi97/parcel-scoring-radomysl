-- Land cover and constraints around parcels: share of each parcel covered by each role.
-- Run in database dzialki_radomysl. Safe to run multiple times.
-- Requires: analysis.parcels_base (04) and raw.bdot_* tables (script 02_import_bdot10k).
-- Roles: exclude (hard constraint), penalty (soft), grass / arable (candidate land).

DROP TABLE IF EXISTS analysis.landcover;

-- 1. All relevant polygons in one table, with a role assigned by rules.
CREATE TABLE analysis.landcover AS
SELECT
    layer,
    rodzaj,
    CASE
        WHEN layer = 'ptlz_a' AND rodzaj IN ('las', 'zagajnik')   THEN 'exclude'
        WHEN layer = 'ptlz_a'                                      THEN 'penalty'
        WHEN layer IN ('ptwp_a', 'ptzb_a', 'ptkm_a', 'tcon_a', 'tcrz_a') THEN 'exclude'
        WHEN layer = 'ptut_a'                                      THEN 'penalty'
        WHEN layer = 'pttr_a' AND rodzaj = 'roślinność trawiasta'  THEN 'grass'
        WHEN layer = 'pttr_a'                                      THEN 'arable'
    END AS role,
    ST_CollectionExtract(ST_MakeValid(geom), 3) AS geom
FROM (
    SELECT 'ptlz_a' AS layer, rodzaj, geom FROM raw.bdot_ptlz_a
    UNION ALL SELECT 'pttr_a', rodzaj, geom FROM raw.bdot_pttr_a
    UNION ALL SELECT 'ptut_a', rodzaj, geom FROM raw.bdot_ptut_a
    UNION ALL SELECT 'ptwp_a', rodzaj, geom FROM raw.bdot_ptwp_a
    UNION ALL SELECT 'ptzb_a', rodzaj, geom FROM raw.bdot_ptzb_a
    UNION ALL SELECT 'ptkm_a', NULL::varchar, geom FROM raw.bdot_ptkm_a
    UNION ALL SELECT 'tcon_a', nazwa, geom FROM raw.bdot_tcon_a
    UNION ALL SELECT 'tcrz_a', nazwa, geom FROM raw.bdot_tcrz_a
) src;

CREATE INDEX landcover_geom_idx ON analysis.landcover USING GIST (geom);
ANALYZE analysis.landcover;

-- 2. Intersect parcels with these polygons, sum the overlap area per parcel and role.
DROP TABLE IF EXISTS analysis.parcel_landcover;

CREATE TABLE analysis.parcel_landcover AS
WITH inter AS (
    SELECT
        p.id_dzialki,
        l.role,
        SUM(ST_Area(ST_Intersection(p.geom, l.geom))) AS inter_m2
    FROM analysis.parcels_base p
    JOIN analysis.landcover l ON ST_Intersects(p.geom, l.geom)
    GROUP BY p.id_dzialki, l.role
)
SELECT
    p.id_dzialki,
    p.area_m2,
    ROUND((COALESCE(SUM(i.inter_m2) FILTER (WHERE i.role = 'exclude'), 0) / p.area_m2)::numeric, 3) AS share_exclude,
    ROUND((COALESCE(SUM(i.inter_m2) FILTER (WHERE i.role = 'penalty'), 0) / p.area_m2)::numeric, 3) AS share_penalty,
    ROUND((COALESCE(SUM(i.inter_m2) FILTER (WHERE i.role = 'grass'),   0) / p.area_m2)::numeric, 3) AS share_grass,
    ROUND((COALESCE(SUM(i.inter_m2) FILTER (WHERE i.role = 'arable'),  0) / p.area_m2)::numeric, 3) AS share_arable
FROM analysis.parcels_base p
LEFT JOIN inter i ON i.id_dzialki = p.id_dzialki
GROUP BY p.id_dzialki, p.area_m2;

-- 3. Part of the parcel not covered by any of the imported classes.
ALTER TABLE analysis.parcel_landcover ADD COLUMN share_other numeric;
UPDATE analysis.parcel_landcover
SET share_other = ROUND(GREATEST(1 - (share_exclude + share_penalty + share_grass + share_arable), 0), 3);

ALTER TABLE analysis.parcel_landcover ADD PRIMARY KEY (id_dzialki);