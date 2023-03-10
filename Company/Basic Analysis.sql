#Basic SQL
select * from divisions limit 5;

select * from regions limit 5;

select * from staff limit 5;

#Total number of employees in the company
select count(*) from staff;

#Gender distribution
select gender, count(*) as `employee number` from staff group by gender;

#Number of Employees in each department
select department, count(*) as totalEmp from staff group by department
order by totalEmp desc;

#Total number of distince departments
select count(distinct(department)) from staff;

#highest and lowest salaries of employees
select last_name, id, salary from staff where
salary=(select min(salary) from staff) or salary=(select max(salary) from staff);

#salary distribution by gender
select avg(salary), min(salary) as minSal, max(salary) as maxSal, gender 
from staff group by gender;

#How much salary company is giving to how many employees every year
select year(start_date) as year, sum(salary) as totalSal, count(*) as TotalEmp from staff 
group by year(start_date)  order by year;
-- where start_date>='2014-01-01'and start_date<='2014-12-31';

#Distribution of min, max and avg sal across departments
select department, min(salary) as minSal, max(salary) as maxSal, avg(salary) as avgSal
from staff
group by department;

#what is the variation in the salary around the mean in each department
select department, min(salary), max(salary), avg(salary), var_pop(salary), stddev_pop(salary)
from staff group by department;
/* Data Interpretation: Although average salary for Outdoors is highest among deparment, it seems like data points
are pretty close to average salary compared to other departments. */

#which department has highest variation in salary
select department, stddev_pop(salary) from staff
group by department order by 2 desc;
-- health department has highest variation in salary

#Salary in health department
select  department, min(salary), max(salary) from staff
where department= 'Health';

#divide the Health department employees in buckets on the basis of their salary
create view healthDept as
select case
when salary>100000 then 'high earner'
when salary between 50000 and 100000 then 'middle earner'
else 'low earner'
end as earning_status
from staff where department like 'health';

#Distribution of income in Health department
select earning_status, count(*) from healthDept
group by earning_status;
-- there are 24 high earners, 14 middle earners and 8 low earners

#Understanding salary in outdoor department which has lowest variation in salary
select department, min(salary), max(salary) from staff
where department= 'Outdoors';

#creating buckets for outdoors department
create view outdoorDept as
select case
when salary>100000 then 'high_earners'
when salary between 50000 and 100000 then 'middle earners'
else 'low_earners'
end as earning_status
from staff where department='Outdoors';

#distribution of income in outdoors department
select earning_status, count(*) from outdoorDept
group by earning_status;
-- most of the employees earn more than 100000 (34) and only 2 earn <50000. 

#dropping views
drop view healthDept;
drop view outdoorDept;

#departments starting with B

select distinct(department) from staff where department like 'B%';