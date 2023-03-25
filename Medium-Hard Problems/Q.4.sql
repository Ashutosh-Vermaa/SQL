-- 20% of the products/service that lead to 80% of sales
with temp as
(select product_name, sum(sales) totalSales from orders
group by Product_Name
order by totalSales desc),

final as

(select t.*,
sum(totalSales) over(order by totalSales desc) as cumulative
from temp  t)
select * from final
where cumulative<=(select 0.8*sum(sales) from orders)
;

;