SELECT 'pttr_a' AS layer, rodzaj, COUNT(*) AS n FROM raw.bdot_pttr_a GROUP BY rodzaj
UNION ALL SELECT 'ptut_a', rodzaj, COUNT(*) FROM raw.bdot_ptut_a GROUP BY rodzaj
UNION ALL SELECT 'ptwp_a', rodzaj, COUNT(*) FROM raw.bdot_ptwp_a GROUP BY rodzaj
UNION ALL SELECT 'ptzb_a', rodzaj, COUNT(*) FROM raw.bdot_ptzb_a GROUP BY rodzaj
UNION ALL SELECT 'tcon_a', rodzaj, COUNT(*) FROM raw.bdot_tcon_a GROUP BY rodzaj
UNION ALL SELECT 'tcrz_a', rodzaj, COUNT(*) FROM raw.bdot_tcrz_a GROUP BY rodzaj
ORDER BY layer, n DESC;


SELECT 'pttr_a' AS layer, rodzaj, COUNT(*) AS n FROM raw.bdot_pttr_a GROUP BY rodzaj
UNION ALL SELECT 'ptut_a', rodzaj, COUNT(*) FROM raw.bdot_ptut_a GROUP BY rodzaj
UNION ALL SELECT 'ptwp_a', rodzaj, COUNT(*) FROM raw.bdot_ptwp_a GROUP BY rodzaj
UNION ALL SELECT 'ptzb_a', rodzaj, COUNT(*) FROM raw.bdot_ptzb_a GROUP BY rodzaj
ORDER BY layer, n DESC;

--Layer ....ptkm_a doesn't have a "rodzaj" column, so we will just count the number of records in each table

SELECT table_name, column_name
FROM information_schema.columns
WHERE table_schema = 'raw'
  AND table_name IN ('bdot_ptkm_a', 'bdot_tcon_a', 'bdot_tcrz_a')
  AND column_name NOT IN (
      'ogc_fid', 'teryt', 'lokalnyid', 'przestrzennazw', 'wersja',
      'poczatekwersjiobiektu', 'oznaczeniezmiany', 'zrodlodanychgeometrycznych',
      'kategoriaistnienia', 'uwagi', 'informacjadodatkowa', 'kodkarto10k',
      'skrotkartograficzny', 'geom'
  )
ORDER BY table_name, ordinal_position;