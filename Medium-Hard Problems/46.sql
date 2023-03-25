drop table if exists tbl_orders;
create table tbl_orders (
order_id integer,
order_date date
);
insert into tbl_orders
values (1,'2022-10-21'),(2,'2022-10-22'),
(3,'2022-10-25'),(4,'2022-10-25');

drop table if exists tbl_orders_copy;
create table tbl_orders_copy (
order_id integer,
order_date date
);
insert into tbl_orders_copy select * from  tbl_orders;

select * from tbl_orders;
insert into tbl_orders
values (5,'2022-10-26'),(6,'2022-10-26');
delete from tbl_orders where order_id=1;

with temp as(
select tbl_orders.order_id as pre,t1.order_id lat from tbl_orders 
left join tbl_orders_copy as t1
on tbl_orders.order_id= t1.order_id
union
select tbl_orders.order_id,t1.order_id from tbl_orders
right join tbl_orders_copy as t1
on tbl_orders.order_id= t1.order_id
where tbl_orders.order_id is null or t1.order_id is null)


select coalesce(pre,lat),
case when pre is null then 'D' else 'I' end as flag
 from temp where pre is null or lat is null;