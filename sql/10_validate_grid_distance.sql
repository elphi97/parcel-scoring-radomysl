--expected 31769 ( in this case)
SELECT COUNT(*) FROM analysis.parcel_grid;

--If result is 0 or near 0 is correct
SELECT COUNT(*) FILTER (WHERE dist_sn_m IS NULL)
FROM analysis.parcel_grid;

-- MIN and MAX and AVG for dist_sn_m
SELECT MIN(dist_sn_m) as minium ,
 ROUND(MAX(dist_sn_m), 1)    as maksium,
 ROUND(AVG(dist_sn_m),0)    as average
FROM analysis.parcel_grid;


-- DATA range depends on distance
SELECT 
		CASE 
			WHEN dist_sn_m < 100 THEN '1: <100' 
			WHEN dist_sn_m  <250 THEN '2:>100 <250'
			WHEN dist_sn_m <500 THEN '3: >250 <500'
			WHEN dist_sn_m <1000 THEN '4: >500 <1000'
			ELSE                      '5: >= 1000'
		END AS distance_class,	
		COUNT(*) AS parcels,
		SUM(COUNT(*)) OVER() 	AS total_parcels
FROM analysis.parcel_grid
GROUP BY 1
ORDER BY 1;


--How many parcels have line_crosses=true
SELECT COUNT(*) FROM analysis.parcel_grid
WHERE parcel_grid.line_crosses = true;


ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct