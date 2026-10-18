-- Expecred 1866 in this case
SELECT COUNT(*) FROM analysis.parcel_candidates;

--
SELECT COUNT(*) FILTER (WHERE dist_sn_m IS NULL)
FROM analysis.parcel_candidates;

-- Total area of all candidate parcels
SELECT ROUND(SUM(area_ha)) area FROM analysis.parcel_candidates;

--
SELECT 
		CASE
			WHEN dist_sn_m = 0 	 THEN '0: Lines cross parcel'
			WHEN dist_sn_m < 100 THEN '1: <100' 
			WHEN dist_sn_m  <250 THEN '2:>100 <250'
			WHEN dist_sn_m <500 THEN '3: >250 <500'
			WHEN dist_sn_m <1000 THEN '4: >500 <1000'
			ELSE                      '5: >= 1000'
		END AS distance_class,	
		COUNT(*) AS parcels,
		SUM(COUNT(*)) OVER() 	AS total_parcels
FROM analysis.parcel_candidates
GROUP BY 1
ORDER BY 1;

SELECT COUNT(*) FILTER (WHERE line_crosses)     AS crossed,
       COUNT(*) FILTER (WHERE NOT line_crosses) AS not_crossed
FROM analysis.parcel_candidates;