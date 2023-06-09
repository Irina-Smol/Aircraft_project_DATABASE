-- 1)
SELECT count(ticket_no) FROM Tickets;

--  Answer:

--  count
--  -------
--  366733
--  (1 строка)

-- 2)
SELECT fare_conditions, count(*) FROM Seats GROUP BY fare_conditions;

--  Answer:

--  fare_conditions | count
--  -------------------------
--  Business        |  152
--  Comfort         |   48
--  Economy         | 1139
--  (3 строки)

-- 3)
SELECT fare_conditions, AVG(amount) FROM ticket_flights GROUP BY fare_conditions;

--  Answer:

--  fare_conditions |        avg
--  ------------------------------------
--  Business        | 51143.416138681927
--  Comfort         | 32740.552888786074
--  Economy         | 15959.813334810321
--  (3 строки)

-- 4)
UPDATE Aircrafts SET range = range * 1.3;
-- UPDATE 9
SELECT range FROM Aircrafts;
--  Answer:
------------
--  14430
--  10270
--  3900
--  7410
--  7280
--  8710
--  5460
--  1560
--  3510
--  (9 строк)
