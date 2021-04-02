CREATE VIEW forestation AS
SELECT f.country_code, f.country_name, f.year, f.forest_area_sqkm, 
l.total_area_sq_mi*2.59 as total_area_sqkm, r.region, r.income_group,
f.forest_area_sqkm/(l.total_area_sq_mi*2.59) as forest_percent
FROM forest_area f 
JOIN land_area l
ON f.country_code = l.country_code AND f.year = l.year 
JOIN regions r 
ON f.country_code = r.country_code; 



SELECT forest_area_sqkm FROM
forestation
WHERE year = 1990 AND country_name = 'World';

SELECT forest_area_sqkm FROM
forestation
WHERE year = 2016 AND country_name = 'World';



SELECT 
	(SELECT forest_area_sqkm FROM forestation WHERE year = 1990 AND country_name = 'World' ) -
    (SELECT forest_area_sqkm FROM forestation WHERE year = 2016 AND country_name = 'World' ) AS diff,
	((SELECT forest_area_sqkm FROM forestation WHERE year = 1990 AND country_name = 'World' ) -
    (SELECT forest_area_sqkm FROM forestation WHERE year = 2016 AND country_name = 'World' ))*100/(SELECT forest_area_sqkm FROM forestation WHERE year = 1990 AND country_name = 'World' ) AS percent_change
FROM forestation;


SELECT * FROM
forestation
WHERE total_area_sqkm < 1324449 AND year = 2016
ORDER BY total_area_sqkm DESC;


SELECT * FROM
forestation 
WHERE country_name = 'World' AND year = 2016;


SELECT ROUND(SUM(forest_area_sqkm)*100/SUM(total_area_sqkm),2) as relative_forestation, region
FROM forestation 
WHERE year = 2016
GROUP BY 2
ORDER BY relative_forestation DESC;


SELECT * FROM
forestation 
WHERE country_name = 'World' AND year = 1990;

SELECT ROUND(SUM(forest_area_sqkm)*100/SUM(total_area_sqkm),2) as relative_forestation, region
FROM forestation 
WHERE year = 1990
GROUP BY 2
ORDER BY relative_forestation DESC;


/************************************/
/*QUERIES FOR COUNTRY-LEVEL DETAIL */
/************************************/

WITH t1 AS (SELECT country_name, forest_area_sqkm as forest_area_1990 FROM forest_area WHERE year = 1990),
t2 AS (SELECT country_name, forest_area_sqkm as forest_area_2016 FROM forest_area WHERE year = 2016)
SELECT (t2.forest_area_2016 - t1.forest_area_1990) AS forest_difference, t2.country_name
FROM t2 
JOIN t1
ON  t2.country_name = t1.country_name
ORDER BY forest_difference DESC; 

WITH t1 AS (SELECT country_name, forest_area_sqkm as forest_sqkm_1990 FROM forestation WHERE year = 1990),
t2 AS (SELECT country_name, forest_area_sqkm as forest_sqkm_2016 FROM forestation WHERE year = 2016)
SELECT (t2.forest_sqkm_2016 - t1.forest_sqkm_1990)/t1.forest_sqkm_1990 AS forest_percent_difference, t2.country_name
FROM t2 
JOIN t1
ON  t2.country_name = t1.country_name
ORDER BY forest_percent_difference DESC; 


WITH t1 AS (SELECT country_name, forest_area_sqkm as forest_area_1990 FROM forest_area WHERE year = 1990),
t2 AS (SELECT country_name, forest_area_sqkm as forest_area_2016 FROM forest_area WHERE year = 2016)
SELECT (t2.forest_area_2016 - t1.forest_area_1990) AS forest_difference, t2.country_name, r.region
FROM t2 
JOIN t1
ON  t2.country_name = t1.country_name
JOIN regions r 
ON r.country_name = t2.country_name
ORDER BY forest_difference ;


WITH t1 AS (SELECT country_name, forest_area_sqkm as forest_area_1990 FROM forest_area WHERE year = 1990),
t2 AS (SELECT country_name, forest_area_sqkm as forest_area_2016 FROM forest_area WHERE year = 2016)
SELECT (t2.forest_area_2016 - t1.forest_area_1990)*100/t1.forest_area_1990 AS forest_difference_percent, t2.country_name, r.region
FROM t2 
JOIN t1
ON  t2.country_name = t1.country_name
JOIN regions r 
ON r.country_name = t2.country_name
ORDER BY forest_difference_percent ;



SELECT * FROM forestation; 


SELECT SUM( CASE WHEN f.forest_percent <=  0.25 THEN 1 ELSE 0 END) as quatile_1_count,
SUM( CASE WHEN f.forest_percent <=  0.5 AND f.forest_percent > 0.25  THEN 1 ELSE 0 END) as quatile_2_count,
SUM( CASE WHEN f.forest_percent <=  0.75 AND f.forest_percent > 0.5  THEN 1 ELSE 0 END) as quatile_3_count,
SUM( CASE WHEN f.forest_percent >  0.75   THEN 1 ELSE 0 END) as quatile_4_count
FROM forestation f
WHERE f.year = 2016 AND country_name != 'World';




SELECT f.country_name, ROUND(CAST(f.forest_percent*100 AS Decimal),2) as forest_percentage, r.region,
NTILE(4) OVER (PARTITION BY year ORDER BY forest_percent DESC) AS forest_percent_quatile
FROM forestation f
JOIN regions r 
ON r.country_name = f.country_name
WHERE YEAR = 2016;


SELECT * FROM forest_area; 
SELECT * FROM land_area;
SELECT * FROM regions;
