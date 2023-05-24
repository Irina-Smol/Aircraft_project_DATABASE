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


demo=# CREATE INDEX passenger_name ON tickets (passenger_name);
CREATE INDEX
Время: 1536,985 мс (00:01,537)
demo=# \d tickets
                                   Таблица "bookings.tickets"
    Столбец     |          Тип          | Правило сортировки | Допустимость NULL | По умолчанию
----------------+-----------------------+--------------------+-------------------+--------------
 ticket_no      | character(13)         |                    | not null          |
 book_ref       | character(6)          |                    | not null          |
 passenger_id   | character varying(20) |                    | not null          |
 passenger_name | text                  |                    | not null          |
 contact_data   | jsonb                 |                    |                   |
Индексы:
    "tickets_pkey" PRIMARY KEY, btree (ticket_no)
    "passenger_name" btree (passenger_name)
Ограничения внешнего ключа:
    "tickets_book_ref_fkey" FOREIGN KEY (book_ref) REFERENCES bookings(book_ref)
Ссылки извне:
    TABLE "ticket_flights" CONSTRAINT "ticket_flights_ticket_no_fkey" FOREIGN KEY (ticket_no) REFERENCES tickets(ticket_no)


demo=# SELECT count(*) FROM tickets WHERE passenger_name = 'IVAN IVANOV';
 count
-------
   200
(1 строка)


Время: 0,674 мс

demo=# DROP INDEX passenger_name;
DROP INDEX
Время: 7,483 мс

CREATE INDEX ticket_book_ref_test_key ON tickets (book_ref);
CREATE INDEX
Время: 1840,692 мс (00:01,841)
demo=# SELECT * FROM tickets ORDER BY book_ref LIMIT 5;
   ticket_no   | book_ref | passenger_id |  passenger_name  |                                contact_data
---------------+----------+--------------+------------------+----------------------------------------------------------------------------
 0005435838975 | 00000F   | 1708 262537  | ANNA ANTONOVA    | {"email": "annaantonova-19021973@postgrespro.ru", "phone": "+70938049942"}
 0005432527326 | 000012   | 9091 269355  | TAMARA ZAYCEVA   | {"email": "tamarazayceva-1971@postgrespro.ru", "phone": "+70749401734"}
 0005432293273 | 000068   | 5895 674437  | TATYANA PETROVA  | {"email": "t_petrova1970@postgrespro.ru", "phone": "+70886117503"}
 0005435545944 | 000181   | 6799 285573  | ALEKSANDR ZHUKOV | {"email": "aleksandrzhukov111972@postgrespro.ru", "phone": "+70411811316"}
 0005435545945 | 000181   | 0929 739492  | EVGENIYA KARPOVA | {"email": "karpovaevgeniya.1985@postgrespro.ru", "phone": "+70669289906"}
(5 строк)


Время: 1,024 мс


demo=# SELECT * FROM bookings WHERE total_amount > 1000000 ORDER BY book_date DESC;
 book_ref |       book_date        | total_amount
----------+------------------------+--------------
 D7E9AA   | 2016-10-06 04:29:00+03 |   1062800.00
 EF479E   | 2016-09-30 14:58:00+03 |   1035100.00
 3AC131   | 2016-09-28 00:06:00+03 |   1087100.00
 3B54BB   | 2016-09-02 16:08:00+03 |   1204500.00
 65A6EA   | 2016-08-31 05:28:00+03 |   1065600.00
(5 строк)


Время: 56,828 мс

demo=# CREATE INDEX bookings_book_date_part_key ON bookings (book_date) WHERE total_amount > 1000000;
CREATE INDEX
Время: 73,696 мс

demo=# CREATE INDEX bookings_book_date_part_key ON bookings (book_date) WHERE total_amount > 1000000;
CREATE INDEX
Время: 73,696 мс
demo=# SELECT * FROM bookings WHERE total_amount > 1100000;
 book_ref |       book_date        | total_amount
----------+------------------------+--------------
 3B54BB   | 2016-09-02 16:08:00+03 |   1204500.00
(1 строка)


Время: 1,048 мс

