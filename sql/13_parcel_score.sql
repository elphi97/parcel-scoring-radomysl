-- Soft scoring of candidate parcels (0-100) and ranking.
-- Run in database dzialki_radomysl. Safe to run multiple times.
-- Requires: analysis.parcel_candidates (11).
-- All weights and thresholds are starting assumptions - tune after inspecting results.

DROP TABLE IF EXISTS analysis.parcel_score;

CREATE TABLE analysis.parcel_score AS
WITH params AS (
    SELECT
        0.35 AS w_dist,       -- weight: closeness to medium-voltage line
        0.25 AS w_area,       -- weight: parcel area
        0.20 AS w_land,       -- weight: land type (grass preferred over arable)
        0.20 AS w_clean,      -- weight: low share of excluded / penalised cover
        0.7  AS line_factor   -- score multiplier when a line crosses the parcel
),
comp AS (
    SELECT
        c.id_dzialki,
        c.numer_dzialki,
        c.nazwa_obrebu,
        c.area_ha,
        c.dist_sn_m,
        c.line_crosses,
        ROUND(1 - LEAST(c.dist_sn_m / 1000.0, 1), 3)                 AS score_dist,
        ROUND(LEAST(c.area_ha / 5.0, 1), 3)                           AS score_area,
        ROUND(c.share_grass + 0.5 * c.share_arable, 3)                AS score_land,
        ROUND(GREATEST(1 - c.share_exclude - c.share_penalty, 0), 3)  AS score_clean,
        c.geom
    FROM analysis.parcel_candidates c
),
scored AS (
    SELECT
        comp.*,
        ROUND(100 * (p.w_dist  * comp.score_dist
                   + p.w_area  * comp.score_area
                   + p.w_land  * comp.score_land
                   + p.w_clean * comp.score_clean)
              * CASE WHEN comp.line_crosses THEN p.line_factor ELSE 1 END, 1) AS score
    FROM comp
    CROSS JOIN params p
)
SELECT
    scored.*,
    RANK() OVER (ORDER BY score DESC) AS score_rank
FROM scored;

ALTER TABLE analysis.parcel_score ADD PRIMARY KEY (id_dzialki);

CREATE INDEX parcel_score_geom_idx
    ON analysis.parcel_score USING GIST (geom);

ANALYZE analysis.parcel_score;