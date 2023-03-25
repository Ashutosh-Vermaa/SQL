drop table if exists products;
create table products
(
product_id varchar(20) ,
cost int
);
insert into products values ('P1',200),('P2',300),('P3',500),('P4',800);

drop table if exists customer_budget;
create table customer_budget
(
customer_id int,
budget int
);

insert into customer_budget values (100,400),(200,800),(300,1500);

-- how many products fall into customer budget along 
-- with list of products
with temp as(
select *,
sum(cost) over(order by cost) as cumulative
 from products)


select cb.customer_id, budget, group_concat(product_id), count(*) as total_prod from customer_budget as cb
left join temp on budget>=cumulative
group by customer_id, budget;