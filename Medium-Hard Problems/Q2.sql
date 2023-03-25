create table customer_orders (
order_id integer,
customer_id integer,
order_date date,
order_amount integer
);

insert into customer_orders values(1,100,cast('2022-01-01' as date),2000),(2,200,cast('2022-01-01' as date),2500),(3,300,cast('2022-01-01' as date),2100)
,(4,100,cast('2022-01-02' as date),2000),(5,400,cast('2022-01-02' as date),2200),(6,500,cast('2022-01-02' as date),2700)
,(7,100,cast('2022-01-03' as date),3000),(8,400,cast('2022-01-03' as date),1000),(9,600,cast('2022-01-03' as date),3000)
;

select * from customer_orders;


with temp as
(select customer_id, min(order_date) as first_visit
from customer_orders
group by customer_id),

visit_flag  as

(select co.*, first_visit,
case when first_visit=order_date then 1 else 0 end as new_customer, 
case when first_visit<>order_date then 1 else 0 end as repeat_customer

from customer_orders as co 
join
temp on temp.customer_id=co.customer_id),

final as

(select vf.*, 
case when new_customer=1 then order_amount else 0 end as new_customer_amount,
case when repeat_customer=1 then order_amount else 0 end as repeat_customer_amount
from visit_flag as vf)

select order_date, sum(new_customer) as new_c,
sum(repeat_customer) as repeat_c, sum(new_customer_amount) as new_amt,
sum(repeat_customer_amount) as repeat_amt
from final 
group by order_date
;
