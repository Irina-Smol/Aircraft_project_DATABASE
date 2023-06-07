\h explain

Команда:     EXPLAIN
Описание:    показать план выполнения оператора
Синтаксис:
EXPLAIN [ ( параметр [, ...] ) ] оператор
EXPLAIN [ ANALYZE ] [ VERBOSE ] оператор

где допустимый параметр:

    ANALYZE [ логическое_значение ]
    VERBOSE [ логическое_значение ]
    COSTS [ логическое_значение ]
    SETTINGS [ логическое_значение ]
    BUFFERS [ логическое_значение ]
    WAL [ логическое_значение ]
    TIMING [ логическое_значение ]
    SUMMARY [ логическое_значение ]
    FORMAT { TEXT | XML | JSON | YAML }

URL: https://www.postgresql.org/docs/15/sql-explain.html


EXPLAIN select * from aircrafts;

                        QUERY PLAN
----------------------------------------------------------
 Seq Scan on aircrafts  (cost=0.00..1.09 rows=9 width=52)
(1 строка)


EXPLAIN select * from aircrafts;

                        QUERY PLAN
----------------------------------------------------------
 Seq Scan on aircrafts  (cost=0.00..1.09 rows=9 width=52)
(1 строка)


 explain (costs off) select * from aircrafts;
      QUERY PLAN
-----------------------
 Seq Scan on aircrafts
(1 строка)

explain select * from aircrafts where model ~ 'Air';
                        QUERY PLAN
----------------------------------------------------------
 Seq Scan on aircrafts  (cost=0.00..1.11 rows=1 width=52)
   Filter: (model ~ 'Air'::text)
(2 строки)


explain select * from bookings order by book_ref;
                                      QUERY PLAN
---------------------------------------------------------------------------------------
 Index Scan using bookings_pkey on bookings  (cost=0.42..8511.24 rows=262788 width=21)
(1 строка)


explain select * from seats where aircraft_code = 'SU9';
                                QUERY PLAN
--------------------------------------------------------------------------
 Bitmap Heap Scan on seats  (cost=5.03..14.24 rows=97 width=15)
   Recheck Cond: (aircraft_code = 'SU9'::bpchar)
   ->  Bitmap Index Scan on seats_pkey  (cost=0.00..5.00 rows=97 width=0)
         Index Cond: (aircraft_code = 'SU9'::bpchar)
(4 строки)


explain select * from bookings where book_ref > '0000FF' and book_ref < '000FFF' order by book_ref;
                                   QUERY PLAN
---------------------------------------------------------------------------------
 Index Scan using bookings_pkey on bookings  (cost=0.42..8.44 rows=1 width=21)
   Index Cond: ((book_ref > '0000FF'::bpchar) AND (book_ref < '000FFF'::bpchar))
(2 строки)


 explain select count(*) from seats where aircraft_code = 'SU9';
                                     QUERY PLAN
------------------------------------------------------------------------------------
 Aggregate  (cost=6.22..6.23 rows=1 width=8)
   ->  Index Only Scan using seats_pkey on seats  (cost=0.28..5.97 rows=97 width=0)
         Index Cond: (aircraft_code = 'SU9'::bpchar)
(3 строки)



explain select a.aircraft_code, a.model, s.seat_no, s.fare_conditions from seats s join aircrafts a on s.aircraft_code = a.aircraft_code where a.model ~ '^Air' order by s.seat_no;
                                      QUERY PLAN
---------------------------------------------------------------------------------------
 Sort  (cost=23.28..23.65 rows=149 width=59)
   Sort Key: s.seat_no
   ->  Nested Loop  (cost=5.43..17.90 rows=149 width=59)
         ->  Seq Scan on aircrafts a  (cost=0.00..1.11 rows=1 width=48)
               Filter: (model ~ '^Air'::text)
         ->  Bitmap Heap Scan on seats s  (cost=5.43..15.29 rows=149 width=15)
               Recheck Cond: (aircraft_code = a.aircraft_code)
               ->  Bitmap Index Scan on seats_pkey  (cost=0.00..5.39 rows=149 width=0)
                     Index Cond: (aircraft_code = a.aircraft_code)
(9 строк)



explain select r.flight_no, r.departure_airport_name, r.arrival_airport_name, a.model from routes r join aircrafts a on r.aircraft_code = a.aircraft_code order by flight_no;
                                  QUERY PLAN
------------------------------------------------------------------------------
 Sort  (cost=61.67..63.44 rows=710 width=75)
   Sort Key: r.flight_no
   ->  Hash Join  (cost=1.20..28.05 rows=710 width=75)
         Hash Cond: (r.aircraft_code = a.aircraft_code)
         ->  Seq Scan on routes r  (cost=0.00..24.10 rows=710 width=47)
         ->  Hash  (cost=1.09..1.09 rows=9 width=48)
               ->  Seq Scan on aircrafts a  (cost=0.00..1.09 rows=9 width=48)
(7 строк)



 explain select t.ticket_no, t.passenger_name, tf.flight_id, tf.amount from tickets t join ticket_flights tf on t.ticket_no = tf.ticket_no order by t.ticket_no;
                                                  QUERY PLAN
--------------------------------------------------------------------------------------------------------------
 Merge Join  (cost=0.95..102550.35 rows=1045726 width=40)
   Merge Cond: (t.ticket_no = tf.ticket_no)
   ->  Index Scan using tickets_pkey on tickets t  (cost=0.42..17308.42 rows=366733 width=30)
   ->  Index Scan using ticket_flights_pkey on ticket_flights tf  (cost=0.42..71253.52 rows=1045726 width=24)
(4 строки)


set enable_mergejoin = off;
SET
explain select t.ticket_no, t.passenger_name, tf.flight_id, tf.amount from tickets t join ticket_flights tf on t.ticket_no = tf.ticket_no order by t.ticket_no;
                                              QUERY PLAN
------------------------------------------------------------------------------------------------------
 Gather Merge  (cost=84725.31..186400.17 rows=871438 width=40)
   Workers Planned: 2
   ->  Sort  (cost=83725.29..84814.58 rows=435719 width=40)
         Sort Key: t.ticket_no
         ->  Parallel Hash Join  (cost=10627.12..30996.08 rows=435719 width=40)
               Hash Cond: (tf.ticket_no = t.ticket_no)
               ->  Parallel Seq Scan on ticket_flights tf  (cost=0.00..13072.19 rows=435719 width=24)
               ->  Parallel Hash  (cost=7672.05..7672.05 rows=152805 width=30)
                     ->  Parallel Seq Scan on tickets t  (cost=0.00..7672.05 rows=152805 width=30)
(9 строк)



set enable_mergejoin = on;
SET
explain analyze select t.ticket_no, t.passenger_name, tf.flight_id, tf.amount from tickets t join ticket_flights tf on t.ticket_no = tf.ticket_no order by t.ticket_no;
                                                                           QUERY PLAN
----------------------------------------------------------------------------------------------------------------------------------------------------------------
 Merge Join  (cost=0.95..102550.35 rows=1045726 width=40) (actual time=9.034..915.985 rows=1045726 loops=1)
   Merge Cond: (t.ticket_no = tf.ticket_no)
   ->  Index Scan using tickets_pkey on tickets t  (cost=0.42..17308.42 rows=366733 width=30) (actual time=9.005..107.015 rows=366733 loops=1)
   ->  Index Scan using ticket_flights_pkey on ticket_flights tf  (cost=0.42..71253.52 rows=1045726 width=24) (actual time=0.022..327.126 rows=1045726 loops=1)
 Planning Time: 0.315 ms
 Execution Time: 935.429 ms
(6 строк)


explain analyze select t.ticket_no, t.passenger_name, tf.flight_id, tf.amount from tickets t join ticket_flights tf on t.ticket_no = tf.ticket_no where amount > 50000 order by t.ticket_no;
                                                                        QUERY PLAN
----------------------------------------------------------------------------------------------------------------------------------------------------------
 Gather Merge  (cost=26099.69..33010.33 rows=59230 width=40) (actual time=230.389..316.204 rows=72647 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Sort  (cost=25099.66..25173.70 rows=29615 width=40) (actual time=184.772..185.536 rows=24216 loops=3)
         Sort Key: t.ticket_no
         Sort Method: quicksort  Memory: 2881kB
         Worker 0:  Sort Method: quicksort  Memory: 2768kB
         Worker 1:  Sort Method: quicksort  Memory: 2774kB
         ->  Parallel Hash Join  (cost=14531.68..22900.15 rows=29615 width=40) (actual time=50.999..88.939 rows=24216 loops=3)
               Hash Cond: (t.ticket_no = tf.ticket_no)
               ->  Parallel Seq Scan on tickets t  (cost=0.00..7672.05 rows=152805 width=30) (actual time=0.092..13.213 rows=122244 loops=3)
               ->  Parallel Hash  (cost=14161.49..14161.49 rows=29615 width=24) (actual time=50.150..50.150 rows=24216 loops=3)
                     Buckets: 131072  Batches: 1  Memory Usage: 5632kB
                     ->  Parallel Seq Scan on ticket_flights tf  (cost=0.00..14161.49 rows=29615 width=24) (actual time=0.049..44.730 rows=24216 loops=3)
                           Filter: (amount > '50000'::numeric)
                           Rows Removed by Filter: 324360
 Planning Time: 0.434 ms
 Execution Time: 318.154 ms
(18 строк)



explain analyze select a.aircraft_code, a.model, s.seat_no, s.fare_conditions from seats s join aircrafts a on s.aircraft_code = a.aircraft_code where a.model ~ '^Air' order by s.seat_no;
                                                            QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=23.28..23.65 rows=149 width=59) (actual time=1.159..1.178 rows=426 loops=1)
   Sort Key: s.seat_no
   Sort Method: quicksort  Memory: 54kB
   ->  Nested Loop  (cost=5.43..17.90 rows=149 width=59) (actual time=0.188..0.324 rows=426 loops=1)
         ->  Seq Scan on aircrafts a  (cost=0.00..1.11 rows=1 width=48) (actual time=0.085..0.090 rows=3 loops=1)
               Filter: (model ~ '^Air'::text)
               Rows Removed by Filter: 6
         ->  Bitmap Heap Scan on seats s  (cost=5.43..15.29 rows=149 width=15) (actual time=0.044..0.057 rows=142 loops=3)
               Recheck Cond: (aircraft_code = a.aircraft_code)
               Heap Blocks: exact=6
               ->  Bitmap Index Scan on seats_pkey  (cost=0.00..5.39 rows=149 width=0) (actual time=0.030..0.030 rows=142 loops=3)
                     Index Cond: (aircraft_code = a.aircraft_code)
 Planning Time: 0.314 ms
 Execution Time: 1.243 ms
(14 строк)


 begin;
BEGIN
explain analyze update aircrafts set range = range + 100 where model ~ '^Air';
                                                QUERY PLAN
----------------------------------------------------------------------------------------------------------
 Update on aircrafts  (cost=0.00..1.11 rows=0 width=0) (actual time=0.211..0.211 rows=0 loops=1)
   ->  Seq Scan on aircrafts  (cost=0.00..1.11 rows=1 width=10) (actual time=0.023..0.027 rows=3 loops=1)
         Filter: (model ~ '^Air'::text)
         Rows Removed by Filter: 6
 Planning Time: 0.088 ms
 Execution Time: 0.877 ms
(6 строк)


analyze aircrafts;
ANALYZE
explain select num_tickets, count(*) as num_bookings from (select b.book_ref, (select count(*) from tickets t where t.book_ref = b.book_ref) from bookings b where date_trunc('mon', book_date)='2016-09-01')as count_tickets(book_ref, num_tickets) group by num_tickets order by num_tickets DESC;
                                                      QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------
 GroupAggregate  (cost=14102017.42..28198865.65 rows=1314 width=16)
   Group Key: ((SubPlan 1))
   ->  Sort  (cost=14102017.42..14102020.70 rows=1314 width=8)
         Sort Key: ((SubPlan 1)) DESC
         ->  Gather  (cost=1000.00..14101949.35 rows=1314 width=8)
               Workers Planned: 1
               ->  Parallel Seq Scan on bookings b  (cost=0.00..3992.72 rows=773 width=7)
                     Filter: (date_trunc('mon'::text, book_date) = '2016-09-01 00:00:00+03'::timestamp with time zone)
               SubPlan 1
                 ->  Aggregate  (cost=10728.17..10728.18 rows=1 width=8)
                       ->  Seq Scan on tickets t  (cost=0.00..10728.16 rows=2 width=0)
                             Filter: (book_ref = b.book_ref)
(12 строк)



create index tickets_book_ref_key on tickets (book_ref);
CREATE INDEX
explain analyze select num_tickets, count(*) as num_bookings from (select b.book_ref, (select count(*) from tickets t where t.book_ref = b.book_ref) from bookings b where date_trunc('mon', book_date)='2016-09-01')as count_tickets(book_ref, num_tickets) group by num_tickets order by num_tickets DESC;
                                                                             QUERY PLAN
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
 GroupAggregate  (cost=11069.05..16968.91 rows=1314 width=16) (actual time=1071.815..1087.439 rows=5 loops=1)
   Group Key: ((SubPlan 1))
   ->  Sort  (cost=11069.05..11072.33 rows=1314 width=8) (actual time=1071.811..1076.231 rows=165647 loops=1)
         Sort Key: ((SubPlan 1)) DESC
         Sort Method: quicksort  Memory: 4096kB
         ->  Gather  (cost=1000.00..11000.98 rows=1314 width=8) (actual time=0.451..1063.869 rows=165647 loops=1)
               Workers Planned: 1
               Workers Launched: 1
               ->  Parallel Seq Scan on bookings b  (cost=0.00..3992.72 rows=773 width=7) (actual time=0.040..36.722 rows=82824 loops=2)
                     Filter: (date_trunc('mon'::text, book_date) = '2016-09-01 00:00:00+03'::timestamp with time zone)
                     Rows Removed by Filter: 48571
               SubPlan 1
                 ->  Aggregate  (cost=4.46..4.47 rows=1 width=8) (actual time=0.006..0.006 rows=1 loops=165647)
                       ->  Index Only Scan using tickets_book_ref_key on tickets t  (cost=0.42..4.46 rows=2 width=0) (actual time=0.006..0.006 rows=1 loops=165647)
                             Index Cond: (book_ref = b.book_ref)
                             Heap Fetches: 0
 Planning Time: 0.460 ms
 Execution Time: 1087.733 ms
(18 строк)


