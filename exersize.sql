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
 
 
 SELECT a.aircraft_code, a.model, s.seat_no, s.fare_conditions FROM seats as s JOIN aircrafts as a ON s.aircraft_code = a.aircraft_code WHERE a.model ~ '^Cessna' ORDER BY s.seat_no;
 
 SELECT a.aircraft_code, a.model, s.seat_no, s.fare_conditions FROM seats s, aircrafts a WHERE s.aircraft_code = a.aircraft_code AND a.model ~ '^Cessna' ORDER BY s.seat_no;
 
CREATE OR REPLACE VIEW flights_v AS
SELECT f.flight_id, f.flight_no, f.scheduled_departure, timezone( dep.timezone, f.scheduled_departure ) AS scheduled_departure_local, f.scheduled_arrival, timezone( arr.timezone, f.scheduled_arrival) as scheduled_arrival_local, f.scheduled_arrival - f.scheduled_departure as scheduled_duration, f.departure_airport, dep.airport_name as departure_airport_name, dep.city as departure_city, f.arrival_airport, arr.airport_name as arrival_airport_name, arr.city as arrival_city, f.status, f.aircraft_code, f.actual_departure, timezone(dep.timezone, f.actual_departure) as actual_departure_local, f.actual_arrival, timezone(arr.timezone, f.actual_arrival) as actual_arrival_local, f.actual_arrival - f.actual_departure AS actual_duration
FROM flights f,
airports dep,
airports arr
WHERE f.departure_airport = dep.airport_code
AND f.arrival_airport = arr.airport_code;
 
SELECT count( * ) FROM airports dep, airports arr WHERE dep.city <> arr.city;

SELECT r.aircraft_code, a.model, count( * ) AS num_routes
FROM routes r
JOIN aircrafts a ON r.aircraft_code = a.aircraft_code
GROUP BY 1, 2
ORDER BY 3 DESC;

SELECT a.aircraft_code AS a_code,
a.model,
r.aircraft_code AS r_code,
count( r.aircraft_code ) AS num_routes
FROM aircrafts a
LEFT OUTER JOIN routes r ON r.aircraft_code = a.aircraft_code
GROUP BY 1, 2, 3
ORDER BY 4 DESC;

SELECT count( * ) FROM ( ticket_flights t JOIN flights f ON t.flight_id = f.flight_id ) LEFT OUTER JOIN boarding_passes b ON t.ticket_no = b.ticket_no AND t.flight_id = b.flight_id WHERE f.actual_departure IS NOT NULL AND b.flight_id IS NULL;
