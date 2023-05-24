CREATE INDEX ON airports (airport_name);

\d airports

                             Таблица "bookings.airports"
   Столбец    |       Тип        | Правило сортировки | Допустимость NULL | По умолчанию
--------------+------------------+--------------------+-------------------+--------------
 airport_code | character(3)     |                    | not null          |
 airport_name | text             |                    | not null          |
 city         | text             |                    | not null          |
 longitude    | double precision |                    | not null          |
 latitude     | double precision |                    | not null          |
 timezone     | text             |                    | not null          |
Индексы:
    "airports_pkey" PRIMARY KEY, btree (airport_code)
    "airports_airport_name_idx" btree (airport_name)
Ссылки извне:
    TABLE "flights" CONSTRAINT "flights_arrival_airport_fkey" FOREIGN KEY (arrival_airport) REFERENCES airports(airport_code)
    TABLE "flights" CONSTRAINT "flights_departure_airport_fkey" FOREIGN KEY (departure_airport) REFERENCES airports(airport_code)
    

 \d boarding_passes
                             Таблица "bookings.boarding_passes"
   Столбец   |         Тип          | Правило сортировки | Допустимость NULL | По умолчанию
-------------+----------------------+--------------------+-------------------+--------------
 ticket_no   | character(13)        |                    | not null          |
 flight_id   | integer              |                    | not null          |
 boarding_no | integer              |                    | not null          |
 seat_no     | character varying(4) |                    | not null          |
Индексы:
    "boarding_passes_pkey" PRIMARY KEY, btree (ticket_no, flight_id)
    "boarding_passes_flight_id_boarding_no_key" UNIQUE CONSTRAINT, btree (flight_id, boarding_no)
    "boarding_passes_flight_id_seat_no_key" UNIQUE CONSTRAINT, btree (flight_id, seat_no)
Ограничения внешнего ключа:
    "boarding_passes_ticket_no_fkey" FOREIGN KEY (ticket_no, flight_id) REFERENCES ticket_flights(ticket_no, flight_id)


demo=# \di
                                      Список отношений
  Схема   |                    Имя                    |  Тип   | Владелец |     Таблица
----------+-------------------------------------------+--------+----------+-----------------
 bookings | aircrafts_pkey                            | индекс | postgres | aircrafts
 bookings | airports_airport_name_idx                 | индекс | postgres | airports
 bookings | airports_pkey                             | индекс | postgres | airports
 bookings | boarding_passes_flight_id_boarding_no_key | индекс | postgres | boarding_passes
 bookings | boarding_passes_flight_id_seat_no_key     | индекс | postgres | boarding_passes
 bookings | boarding_passes_pkey                      | индекс | postgres | boarding_passes
 bookings | bookings_pkey                             | индекс | postgres | bookings
 bookings | flights_flight_no_scheduled_departure_key | индекс | postgres | flights
 bookings | flights_pkey                              | индекс | postgres | flights
 bookings | seats_pkey                                | индекс | postgres | seats
 bookings | ticket_flights_pkey                       | индекс | postgres | ticket_flights
 bookings | tickets_pkey                              | индекс | postgres | tickets
(12 строк)


--! Включить таймер (timing on), выключить таймер (timing off) 
\timing on
Секундомер включён.
demo=# SELECT count(*) FROM tickets WHERE passenger_name = 'Ivan Ivanov';
 count
-------
     0
(1 строка)


Время: 75,963 мс
