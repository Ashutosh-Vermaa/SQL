drop table if exists orders;
create table orders
(
order_id int,
customer_id int,
product_id int
);


insert into orders VALUES 
(1, 1, 1),
(1, 1, 2),
(1, 1, 3),
(2, 2, 1),
(2, 2, 2),
(2, 2, 4),
(3, 1, 5);

drop table if exists products;
create table products (
id int,
name varchar(10)
);
insert into products VALUES 
(1, 'A'),
(2, 'B'),
(3, 'C'),
(4, 'D'),
(5, 'E');

with temp as(
select o1.*, o2.product_id as product_id1 from orders o1
join orders o2 on o1.order_id=o2.order_id and
o1.customer_id=o2.customer_id
where o1.product_id<>o2.product_id and o1.product_id<o2.product_id),

inter as(

select temp.*, p1.name as product_name,
p2.name as product1_name, concat(p1.name, p2.name) pair
 from temp join products p1 on temp.product_id= p1.id
join products p2 on temp.product_id1=p2.id)

select pair, count(pair) as 
total
from inter 
group by pair
;
