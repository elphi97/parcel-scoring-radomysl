-- Validation of the parcel score table. Read-only, safe to run multiple times.
-- Requires: analysis.parcel_score (13).

-- 1. Row count. Expected: 1866 (same as parcel_candidates).
SELECT COUNT(*) FROM analysis.parcel_score;

-- 2. Basic statistics of the score. All values must lie between 0 and 100.
SELECT
    MIN(score)           AS min_score,
    ROUND(AVG(score), 1) AS avg_score,
    MAX(score)           AS max_score
FROM analysis.parcel_score;

-- 3. Score distribution in 10-point buckets (0 = 0-9.9, 10 = 10-19.9, ...).
SELECT
    FLOOR(score / 10) * 10 AS bucket_from,
    COUNT(*)               AS parcels
FROM analysis.parcel_score
GROUP BY 1
ORDER BY 1;

-- 4. Ten best parcels. Do they look right (large, near a line, grass, no forest)?
SELECT score_rank, id_dzialki, nazwa_obrebu, area_ha, dist_sn_m, line_crosses, score
FROM analysis.parcel_score
ORDER BY score DESC
LIMIT 10;

-- 5. Ten worst candidates. Should be weaker than the top ten.
SELECT score_rank, id_dzialki, nazwa_obrebu, area_ha, dist_sn_m, line_crosses, score
FROM analysis.parcel_score
ORDER BY score ASC
LIMIT 10;

-- 6. Average score by line_crosses. Crossed parcels should score lower (penalty factor).
SELECT
    line_crosses,
    COUNT(*)             AS parcels,
    ROUND(AVG(score), 1) AS avg_score
FROM analysis.parcel_score
GROUP BY line_crosses;