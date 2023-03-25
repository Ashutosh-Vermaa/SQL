CREATE TABLE int_orders(
 order_number int NOT NULL,
 order_date date NOT NULL,
 cust_id int NOT NULL,
 salesperson_id int NOT NULL,
 amount float NOT NULL
);

INSERT INTO int_orders VALUES (30, CAST('1995-07-14' AS Date), 9, 1, 460);

INSERT into int_orders VALUES (10, CAST('1996-08-02' AS Date), 4, 2, 540);

INSERT INTO int_orders VALUES (40, CAST('1998-01-29' AS Date), 7, 2, 2400);

INSERT INTO  int_orders VALUES (50, CAST('1998-02-03' AS Date), 6, 7, 600);

INSERT into int_orders VALUES (60, CAST('1998-03-02' AS Date), 6, 7, 720);

INSERT into int_orders VALUES (70, CAST('1998-05-06' AS Date), 9, 7, 150);

INSERT into int_orders VALUES (20, CAST('1999-01-30' AS Date), 4, 8, 1800);

-- find the largest order by value for each salesperson with details
with temp as (
select *,
max(amount) over(partition by salesperson_id) as max_amt 
 from int_orders)
 
 select distinct * from temp where amount=max_amt
 ;
 
 -- without using cte, window, subquery etc.
-- select t.* from int_orders t
-- join
-- int_orders on t.salesperson_id=int_orders.salesperson_id 
-- group by  


--  
--  