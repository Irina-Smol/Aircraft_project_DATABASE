 SELECT airport_name, city, longitude FROM airports ORDER BY longitude DESC LIMIT 3 OFFSET 3;
 
 SELECT airport_name, city, longitude FROM airports ORDER BY longitude DESC LIMIT 3;
 
 SELECT DISTINCT timezone FROM airports ORDER BY 1;
 
 SELECT timezone FROM airports ORDER BY 1;
 
 SELECT * FROM aircrafts ORDER BY range DESC;
 
 SELECT * FROM aircrafts WHERE range IS NOT NULL;
 
 SELECT * FROM aircrafts WHERE range > 3000 AND range < 6000;
 
 SELECT model, range, round(range / 1.609, 5) AS miles FROM aircrafts;
 
 SELECT model, range, range / 1.609 AS miles FROM aircrafts;
 
 SELECT * FROM aircrafts WHERE model NOT LIKE 'Airbus%' AND model NOT LIKE 'Boeing%';
 
 
