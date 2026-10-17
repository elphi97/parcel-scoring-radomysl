-- Distance from each parcel to the nearest power line, by voltage class.
-- Run in database dzialki_radomysl. Safe to run multiple times.
-- Requires: analysis.parcels_base (04) and raw.bdot_suln_l (BDOT10k import).
-- Distance 0 means a line crosses the parcel (see line_crosses).

DROP TABLE IF EXISTS analysis.parcel_grid;

CREATE TABLE analysis.parcel_grid AS
SELECT
    p.id_dzialki,
    ROUND(sn.dist::numeric, 1) AS dist_sn_m,   -- medium voltage
    ROUND(wn.dist::numeric, 1) AS dist_wn_m,   -- high voltage
    ROUND(nn.dist::numeric, 1) AS dist_nn_m,   -- extra-high voltage
    EXISTS (
        SELECT 1
        FROM raw.bdot_suln_l l
        WHERE l.kategoriaistnienia = 'eksploatowany'
          AND ST_Intersects(l.geom, p.geom)
    ) AS line_crosses
FROM analysis.parcels_base p
LEFT JOIN LATERAL (
    SELECT ST_Distance(l.geom, p.geom) AS dist
    FROM raw.bdot_suln_l l
    WHERE l.kategoriaistnienia = 'eksploatowany'
      AND l.rodzaj = 'linia elektroenergetyczna średniego napięcia'
    ORDER BY l.geom <-> p.geom
    LIMIT 1
) sn ON true
LEFT JOIN LATERAL (
    SELECT ST_Distance(l.geom, p.geom) AS dist
    FROM raw.bdot_suln_l l
    WHERE l.kategoriaistnienia = 'eksploatowany'
      AND l.rodzaj = 'linia elektroenergetyczna wysokiego napięcia'
    ORDER BY l.geom <-> p.geom
    LIMIT 1
) wn ON true
LEFT JOIN LATERAL (
    SELECT ST_Distance(l.geom, p.geom) AS dist
    FROM raw.bdot_suln_l l
    WHERE l.kategoriaistnienia = 'eksploatowany'
      AND l.rodzaj = 'linia elektroenergetyczna najwyższego napięcia'
    ORDER BY l.geom <-> p.geom
    LIMIT 1
) nn ON true;

ALTER TABLE analysis.parcel_grid ADD PRIMARY KEY (id_dzialki);