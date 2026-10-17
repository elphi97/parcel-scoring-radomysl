-- expected 31769 ( in this case)
SELECT COUNT(*) FROM analysis.parcel_landcover;                 

--If result is 0 or neraest 0 is correct in the other hand class in BDOT10k aren't overlap
SELECT COUNT(*) FROM analysis.parcel_landcover
WHERE share_exclude + share_penalty + share_grass + share_arable > 1.02;  

--How many parcels are excluded, or included ( in general)
SELECT
    CASE
        WHEN share_exclude >= 0.5                THEN 'mostly excluded'
        WHEN share_grass + share_arable >= 0.5   THEN 'mostly grass or arable'
        WHEN share_penalty >= 0.5                THEN 'mostly penalty'
        ELSE 'mixed or other'
    END AS dominant,
    COUNT(*) AS parcels,
    ROUND(SUM(area_m2) / 10000) AS ha
FROM analysis.parcel_landcover
GROUP BY 1
ORDER BY 2 DESC;