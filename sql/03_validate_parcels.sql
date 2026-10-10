--check the number of parcels : should be 31769
SELECT COUNT(*) FROM raw.dzialki;
--check the number of parcels with null geometry : should be 2180
SELECT Find_SRID('raw', 'dzialki', 'geom');
--check the geometry type of parcels : should be MULTIPOLYGON
SELECT type FROM geometry_columns WHERE f_table_name = 'dzialki';
---check the number of distinct numer_jednostki : should be _4 and _5
SELECT DISTINCT numer_jednostki FROM raw.dzialki;