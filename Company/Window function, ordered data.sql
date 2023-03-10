-- --------------------------Window Function and Ordered Data---------------

/*** over(partition by)**/
#employees salary vs their dept avg salary
select last_name, department, salary,
avg(salary) over(partition by department) as avg_sal
from staff;

#emp salary vs their department's max salary
select last_name, department, salary,
max(salary) over(partition by department) as max_sal
from staff;

#emp salary vs their department's min salary
select last_name, department, salary,
min(salary) over(partition by department) as min_sal
from staff;

-- ----------FIRST VALUE---------
-- returns the first value

#return highest earning individuals in each departments
select last_name, department,
first_value(salary) over (partition by department order by salary desc)
as salary
from staff;

#individuals earning lowest in their departments
select last_name, department, 
first_value(salary) over (partition by department order by salary asc)
as salary
from staff;

-- ------RANK()----------
-- the ranking 1, 2, 3 will restart when it reaches to another unique group.

#adding rank column to data
select last_name, department, salary,
rank() over(partition by department order by salary desc) as rrank
from staff;
-- employees earning same amount will have same rank

############ROW_NUMBER()
-- adds row number to the data

select last_name, department, salary,
row_number() over() as rowNumber
from staff;
-- every record is assigned a number. We can change it as every a new department starts

select last_name, department, salary,
row_number() over(partition by department) as rowNumber
from staff;

-- -------------DENSE_RANK()--------------------
-- It gives the same rank to records having same value (say in salary
-- column but does n't skip a number e.g. 1, 2, 2, 3 
-- here 2nd and 3rd records have same salary value

select last_name, department, salary,
dense_rank() over(partition by department order by salary desc)
as denseRank from staff;

-- -----------LAG()-----------
-- gives the value (e.g. salary) of the employees previous to the 
-- current one
select id, last_name, department, salary,
lag(salary, 2) over(partition by department order by id) as prevEmpSal
from staff;
/* gives the salary who falls two records above the current employees.
It can be used to compare current employees income with the previous ones*/

/* we want to know person's salary and prev lower salary in that department */
select last_name, department, salary,
lag(salary) over(partition by department order by salary asc) as prevLowSal
from staff;

-- ---------------LEAD()---------
-- gives next value of the choosen column

#display the salary of next high paying employee in the department
select last_name, department, salary,
lead(salary) over(partition by department order by salary asc) as nextEmpSal
from staff;

-- -------------NTILE(bin number) -----------------
-- allows to create bins/ bucket

/* there are bins (1-10) assigned each employees based on the decending salary of specific department
and bin number restart for another department agian */

select last_name, department, salary,
ntile(10) over(partition by department order by salary desc) as salBin
from staff;  
