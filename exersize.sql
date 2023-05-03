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
 
 
 SELECT a.aircraft_code, a.model, s.seat_no, s.fare_conditions FROM seats as s JOIN aircrafts as a ON s.aircraft_code = a.aircraft_code 
 WHERE a.model ~ '^Cessna' ORDER BY s.seat_no;
 
 SELECT a.aircraft_code, a.model, s.seat_no, s.fare_conditions FROM seats s, aircrafts a WHERE s.aircraft_code = a.aircraft_code 
 AND a.model ~ '^Cessna' ORDER BY s.seat_no;
 
CREATE OR REPLACE VIEW flights_v AS
SELECT f.flight_id, f.flight_no, f.scheduled_departure, timezone( dep.timezone, f.scheduled_departure ) AS scheduled_departure_local, f.scheduled_arrival, 
timezone( arr.timezone, f.scheduled_arrival) as scheduled_arrival_local, f.scheduled_arrival - f.scheduled_departure as scheduled_duration, f.departure_airport, 
dep.airport_name as departure_airport_name, dep.city as departure_city, f.arrival_airport, arr.airport_name as arrival_airport_name, arr.city as arrival_city, 
f.status, f.aircraft_code, f.actual_departure, timezone(dep.timezone, f.actual_departure) as actual_departure_local, f.actual_arrival, timezone(arr.timezone, 
f.actual_arrival) as actual_arrival_local, f.actual_arrival - f.actual_departure AS actual_duration
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

SELECT count( * ) FROM ( ticket_flights t JOIN flights f ON t.flight_id = f.flight_id ) LEFT OUTER JOIN boarding_passes b ON t.ticket_no = b.ticket_no 
AND t.flight_id = b.flight_id
WHERE f.actual_departure IS NOT NULL AND b.flight_id IS NULL;

--! Пересадить человека:
--! изначально 0 строк, так как не пересажены люди, вторым действием пересажываем людей
SELECT f.flight_no, f.scheduled_departure, f.flight_id, f.departure_airport, f.arrival_airport, f.aircraft_code, t.passenger_name, tf.fare_conditions 
AS fc_to_be, s.fare_conditions AS fc_fact, b.seat_no FROM boarding_passes b JOIN ticket_flights tf ON b.ticket_no = tf.ticket_no AND b.flight_id = tf.flight_id 
JOIN tickets t ON tf.ticket_no = t.ticket_no JOIN flights f ON tf.flight_id = f.flight_id JOIN seats s ON b.seat_no = s.seat_no AND f.aircraft_code = s.aircraft_code 
WHERE tf.fare_conditions <> s.fare_conditions ORDER BY f.flight_no, f.scheduled_departure;

--!  count | 0

UPDATE boarding_passes
SET seat_no = '1A'
WHERE flight_id = 1 AND seat_no = '17A';

--! UPDATE 1




SELECT r.min_sum, r.max_sum, count( b.* )
FROM bookings b
RIGHT OUTER JOIN
( VALUES ( 0, 100000 ), ( 100000, 200000 ),
( 200000, 300000 ), ( 300000, 400000 ),
( 400000, 500000 ), ( 500000, 600000 ),
( 600000, 700000 ), ( 700000, 800000 ),
( 800000, 900000 ), ( 900000, 1000000 ),
( 1000000, 1100000 ), ( 1100000, 1200000 ),
( 1200000, 1300000 )
) AS r ( min_sum, max_sum )
ON b.total_amount >= r.min_sum AND b.total_amount < r.max_sum
GROUP BY r.min_sum, r.max_sum
ORDER BY r.min_sum;


--!В какие города можно улететь либо из Москвы, либо из Санкт-Петербурга

SELECT arrival_city FROM routes WHERE departure_city = 'Москва' UNION SELECT arrival_city FROM routes WHERE departure_city = 'Санкт-Петербург' ORDER BY arrival_city;

В--!В какие города можно улететь как из Москвы, так и из Санкт-Петербурга

SELECT arrival_city FROM routes WHERE departure_city = 'Москва' INTERSECT SELECT arrival_city FROM routes WHERE departure_city = 'Санкт-Петербург' ORDER BY arrival_city;

--! В какие города можно улететь из Санкт-Петербурга, но нельзя из Москвы?
SELECT arrival_city FROM routes WHERE departure_city = 'Санкт-Петербург' EXCEPT SELECT arrival_city FROM routes WHERE departure_city = 'Москва' ORDER BY arrival_city;

--!среднее значение:
SELECT avg( total_amount ) FROM bookings;
--!максимальное значение:
SELECT max( total_amount ) FROM bookings;
--!минимальное значение:
SELECT min( total_amount ) FROM bookings;

--!Рассчитаем количество маршрутов из Москвы:
SELECT arrival_city, count( * ) FROM routes WHERE departure_city = 'Москва' GROUP BY arrival_city ORDER BY count DESC;

--!Частота вылетов:
SELECT array_length( days_of_week, 1 ) AS days_per_week, count( * ) AS num_routes FROM routes GROUP BY days_per_week ORDER BY 1 desc;

--!Выведем названия городов, из которых в другие города существует не менее 15 маршрутов
SELECT departure_city, count( * ) FROM routes GROUP BY departure_city HAVING count( * ) >= 15 ORDER BY count DESC;

--!Выведем города, в которых более одного аэропорта:
SELECT city, count( * ) FROM airports GROUP BY city HAVING count( * ) > 1;

SELECT b.book_ref, b.book_date, extract( 'month' from b.book_date ) AS month, extract( 'day' from b.book_date ) AS day, 
count( * ) OVER ( PARTITION BY date_trunc( 'month', b.book_date ) ORDER BY b.book_date ) AS count FROM ticket_flights tf JOIN tickets t 
ON tf.ticket_no = t.ticket_no JOIN bookings b ON t.book_ref = b.book_ref WHERE tf.flight_id = 1 ORDER BY b.book_date;

count( * ) OVER ( PARTITION BY date_trunc( 'month', b.book_date ) ORDER BY b.book_date ) AS coun

SELECT airport_name, city, timezone, latitude,
first_value( latitude ) OVER tz AS first_in_timezone,
latitude - first_value( latitude ) OVER tz AS delta,
rank() OVER tz
FROM airports
WHERE timezone IN ( 'Asia/Irkutsk', 'Asia/Krasnoyarsk' )
WINDOW tz AS ( PARTITION BY timezone ORDER BY latitude DESC )
ORDER BY timezone, rank;

SELECT airport_name, city, timezone, latitude,
first_value( latitude ) OVER tz AS first_in_timezone,
latitude - first_value( latitude ) OVER tz AS delta,
rank() OVER tz
FROM airports
WHERE timezone IN ( 'Asia/Irkutsk', 'Asia/Krasnoyarsk' )
WINDOW tz AS ( PARTITION BY timezone ORDER BY latitude DESC )
ORDER BY timezone, rank;

