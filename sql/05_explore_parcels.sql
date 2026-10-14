--Exploratory queries on parcels of gmina Radomysl Wielki.
--Run in database dzialki_radomysl. Read-only:creates nothing.
--Requires : analysis.parcels_base (script 04) and raw.dzailki (script 01).

--1. Columns available in the raw data
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'raw' AND table_name = 'dzialki'
ORDER BY ordinal_position;


--2. Basick area statistics (ha)
SELECT
    COUNT(*)                                    AS parcels,
    ROUND(SUM(area_ha), 1)                       AS total_ha,
    ROUND(MIN(area_ha), 4)                       AS min_ha,
    ROUND((percentile_cont(0.5) WITHIN GROUP (ORDER BY area_ha))::numeric, 4) AS mediana_ha,
    ROUND(AVG(area_ha),4)                        AS mean_ha,
    ROUND(MAX(area_ha), 2)                       AS max_ha,
    ROUND(MAX(area_ha), 2)                       AS max_ha
FROM analysis.parcels_base;

--3. Area distribution : how many parcels fall into each size class

SELECT
    CASE
        WHEN area_ha <0.1 THEN '1: < 0.1ha'
        WHEN area_ha < 0.5 then '2: 0.1 - 0.5 ha'
        WHEN area_ha <1 THEN '3: 0.5 - 1 ha'
        WHEN area_ha < 2 THEN '4: 1 - 2 ha'
        WHEN area_ha < 5 THEN '5: 2 - 5 ha'
        ELSE '6: > 5 ha'      '6: >= 5 ha'
    END                        AS size_class,
    COUNT(*)                  AS parcels,
    ROUND(SUM(area_ha), 1)     AS total_ha,
FROM analysis.parcels_base
GROUP BY 1
ORDER BY 1;


-- 4. Parcels per cadastral district (obreb)
SELECT
    nazwa_obrebu,
    number_obrebu,
    COUNT(*)                    AS parcels,
    ROUND(SUM(area_ha), 1)      AS total_ha,
    ROUND(AVG(area_ha), 3)     AS mean_ha
FROM analysis.parcels_base
GROUP BY nazwa_obrebu, number_obrebu
ORDER BY total_ha DESC;

--5. Parcels per unit (urban 181108_4 vs rural 181108_5)
SELECT numer_jednostki, COUNT(*) AS parcels, ROUND(SUM(area_ha), 1) AS total_ha
FROM analysis.parcels_base
GROUP BY numer_jednostki
ORDER BY numer-jednostki;

--6. Data completeness: how many parcels have NULL in key attribute colums
SELECT
    COUNT(*)                         AS parcels,
    COUNT(*) FILTER (WHERE pole_ewidencyjne IS NULL) AS null_pole_ewidencyjne,
    COUNT(*) FILTER (WHERE klasyouzytki_egib IS NULL) AS null_klasouzytki_egib
FROM raw.dzialki;

-- 7. Ten larges parcels (sanity check - are they plausible?)
SELECT id_dzialki, nazwa_obrebu, area_ha
FROM analysis.parcels_base
ORDER BY area_ha DESC
LIMIT 10;


  
