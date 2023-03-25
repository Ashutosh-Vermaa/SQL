Create Table Trade_tbl(
TRADE_ID varchar(20),
Trade_Timestamp time,
Trade_Stock varchar(20),
Quantity int,
Price Float
);

Insert into Trade_tbl Values('TRADE1','10:01:05','ITJunction4All',100,20);
Insert into Trade_tbl Values('TRADE2','10:01:06','ITJunction4All',20,15);
Insert into Trade_tbl Values('TRADE3','10:01:08','ITJunction4All',150,30);
Insert into Trade_tbl Values('TRADE4','10:01:09','ITJunction4All',300,32);
Insert into Trade_tbl Values('TRADE5','10:10:00','ITJunction4All',-100,19);
Insert into Trade_tbl Values('TRADE6','10:10:01','ITJunction4All',-300,19);

/* all couples of trade for same stock that happened
in the range of 10 secs and having price diff of more than
10% */
select t1.trade_id, 
t1.trade_timestamp, t1.trade_stock, t1.price,
t2.trade_id, 
t2.trade_timestamp, t2.trade_stock, t2.price
from trade_tbl t1
join trade_tbl t2
where t1.Trade_Timestamp<t2.Trade_Timestamp
and t1.trade_stock=t2.trade_stock and
timestampdiff(second, t1.trade_timestamp, t2.trade_timestamp)<10
and abs(t1.price-t2.price)/t1.price>0.10
order by t1.trade_id;
