#1. nth (5th) highest salary in employee table
(select id, salary from emp 
order by salary desc limit 4,1);
-- putting the command in paranthesis removes null record in ouptput

#2. top n records (top 5 records from emp table)
select * from emp
order by salary desc limit 0,5;

#3. Write a SQL query to find the count of employees working in department 'Admin'
select department, count(*) from emp
group by department
having department='Admin';

#4. fetch department wise count employees sorted by department count in desc order
select department, count(*) as totalEmp from emp
group by department
order by totalEmp desc;

#5.  fetch only the first name(string before space) from the FullName column of user_name table
select substring_index(full_names, ' ', 1) as firstName
from user_name;

#6. SQL query to find all the employees from employee table who are also managers
select e1.first_name, e1.id
from emp e1, emp e2
where e1.id= e2.manager_id;

#7. find all employees who have bonus record in bonus table
select emp.*, bonus.* from bonus left join emp
on bonus.empId= emp.id;

#8. find only odd rows from employee table
select * from
(select e.*, row_number() over() as rowNumber from emp e) as temp
where mod(temp.rowNumber,2)<>0;
-- first create a table containing rankNumber then extract rankNumber for use

#9. fetch first_name from employee table in upper case
select upper(first_name) from emp;

#.10 get combine name (first name and last name) of employees from employee table
select concat(first_name, " ", last_name) as full_name from emp;

#11. print details of employee 'Jennifer' and 'James'
select * from emp
where first_name in ('Jennifer', "James");

#12. fetch records of employee whose salary lies between 
select * from emp where salary between 100000 and 500000;

#13. get records of employe who have joined in Jan 2017
select * from emp 
where month(joining_date)=1 and year(joining_date)= 2017;

#14. get the list of employees with the same salary
select first_name, salary from emp
where salary=(select salary from emp as e2 where emp.id<>e2.id
and emp.salary=e2.salary);

-- ORR
select e1.first_name, e1.salary from emp e1, emp e2
where e1.salary= e2.salary and e1.id<>e2.id;

#15.  show all departments along with the number of people working there
select department, count(*) as TotalEmp from emp
group by department;

#16. show the last record from a table
select emp.*, row_number() over() as rowNumber from emp
order by rowNumber desc limit 0,1;

#17. how the first record from a table
select * from emp limit 1;

#18. get last five records from a employee table
-- assuming emp id are in order, otherwise we could have used row_number
select * from emp
order by id desc limit 5;

#19. find employees having the highest salary in each department
select emp.*, max(salary) over(partition by department order by salary desc)
as maxSal from emp;

#20. fetch three max salaries from employee table
select * from
(select emp.*,
rank() over(order by salary desc) as rnk from emp) as temp
where rnk<4;
-- to get three different max salaries use dense_rank() instead of rank()

-- OR
select distinct Salary from emp e1 WHERE 3 >= (SELECT count(distinct Salary) from emp e2 WHERE e1.Salary <= e2.Salary) order by e1.Salary desc;

#21. fetch departments along with the total salaries paid for each of them
select department, sum(salary) as totalSal from emp
group by department;

#22. find employee with highest salary in an organization from employee table
select first_name, salary from emp
where salary= (select max(salary) from emp);

#23. find employee (first name, last name, department and bonus) with highest bonus
select first_name, last_name, department, bonus_amount as maxBonus
from emp, bonus
where emp.id= bonus.empId and bonus_amount= (select max(bonus_amount) from bonus);
-- we can also use rank()