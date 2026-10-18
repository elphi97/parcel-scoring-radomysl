-- Candidate parcels after hard filters (area, excluded land cover, candidate land cover).
-- Run in database dzialki_radomysl. Safe to run multiple times.
-- Requires: analysis.parcels_base (04), analysis.parcel_landcover (07), analysis.parcel_grid (09).

DROP TABLE IF EXISTS analysis.parcel_candidates;

CREATE TABLE analysis.parcel_candidates AS
WITH params AS (
    SELECT
        10000 AS min_area_m2,        -- minimum parcel area (1 ha)
        0.2   AS max_exclude,        -- max share of excluded land cover
        0.7   AS min_candidate_land  -- min share of grass + arable land
)
SELECT
    p.id_dzialki,
    p.numer_dzialki,
    p.nazwa_obrebu,
    p.area_m2,
    p.area_ha,
    lc.share_exclude,
    lc.share_penalty,
    lc.share_grass,
    lc.share_arable,
    lc.share_other,
    g.dist_sn_m,
    g.dist_wn_m,
    g.dist_nn_m,
    g.line_crosses,
    p.geom
FROM analysis.parcels_base p
JOIN analysis.parcel_landcover lc USING (id_dzialki)
JOIN analysis.parcel_grid g USING (id_dzialki)
CROSS JOIN params
WHERE p.area_m2 >= params.min_area_m2
  AND lc.share_exclude <= params.max_exclude
  AND lc.share_grass + lc.share_arable >= params.min_candidate_land;

ALTER TABLE analysis.parcel_candidates ADD PRIMARY KEY (id_dzialki);

CREATE INDEX parcel_candidates_geom_idx
    ON analysis.parcel_candidates USING GIST (geom);

ANALYZE analysis.parcel_candidates;