drop table if exists  billings;
create table billings 
(
emp_name varchar(10),
bill_date date,
bill_rate int
);
delete from billings;
insert into billings values
('Sachin',STR_TO_DATE('01-01-1990', '%d-%m-%Y'),25)
,('Sehwag' ,STR_TO_DATE('01-01-1989', '%d-%m-%Y'), 15)
,('Dhoni' ,STR_TO_DATE('01-01-1989', '%d-%m-%Y'), 20)
,('Sachin' ,STR_TO_DATE('05-02-1991','%d-%m-%Y'), 30)
;

drop table if exists  HoursWorked;
create table HoursWorked 
(
emp_name varchar(20),
work_date date,
bill_hrs int
);
insert into HoursWorked values
('Sachin', STR_TO_DATE('01-07-1990', '%d-%m-%Y') ,3)
,('Sachin', STR_TO_DATE('01-08-1990', '%d-%m-%Y'), 5)
,('Sehwag',STR_TO_DATE('01-07-1990', '%d-%m-%Y'), 2)
,('Sachin',STR_TO_DATE('01-07-1991', '%d-%m-%Y'), 4);

with temp as(
select b.*, 
lead(date_sub(bill_date, interval 1 day), 1, "9999-01-28") 
over(partition by b.emp_name order by bill_date) as gap from billings b)
,
inter as(
select temp.*,
h.bill_hrs from temp 
join hoursworked h
on h.emp_name=temp.emp_name and h.work_date between bill_date and gap)

select emp_name, sum(bill_rate*bill_hrs) as total_charges from inter
group by emp_name
;
