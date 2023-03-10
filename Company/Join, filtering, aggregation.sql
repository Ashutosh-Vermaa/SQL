/***** Filtering, Join and Aggregation **************/

# an employees salary compared to their department's avg salary
select last_name, s1.department, salary, avg_salary
from staff as s1, (select department, avg(salary) as avg_salary from staff as s2 group by department) as 
temp(department, avg_salary)
where temp.department=  s1.department
order by department;
####################  ORR
SELECT
	s.last_name,s.salary,s.department,
	(SELECT ROUND(AVG(salary),2)
	 FROM staff s2
	 WHERE s2.department = s.department) AS department_average_salary
FROM staff s
order by department;

# How many people earn more/less than avg salary in their department

create view dept_sal as
select department, salary, (select avg(salary) from staff as s1
where s1.department=s2.department) as avg_sal from staff as s2;

select * from dept_sal;
select distinct(department), (select count(*) from dept_sal s1 where s1.department= s2.department
and s1.salary>s1.avg_sal) as count from dept_sal as s2 order by 1;

##### ORR
CREATE VIEW vw_salary_comparision_by_department
AS
	SELECT 
	s.department,
	(
		s.salary > (SELECT ROUND(AVG(s2.salary),2)
					 FROM staff s2
					 WHERE s2.department = s.department)
	)AS is_higher_than_dept_avg_salary
	FROM staff s;
	
	
SELECT * FROM vw_salary_comparision_by_department;

SELECT department, sum(is_higher_than_dept_avg_salary), COUNT(*) AS total_employees
FROM vw_salary_comparision_by_department
GROUP BY 1;

/* Assume that people who earn at least 100,000 salary is Executive.
We want to know the average salary for executives for each department. */

select department, round(avg(salary),2) as excutive_avg_sal 
from staff where salary>=100000 group by department order by excutive_avg_sal;
-- sports executives have highest avg salary and moviea executives have lowest

#who earns the most in the company
select last_name, department, salary from staff where salary= (select max(salary) from staff);
-- stanley earns the most in the company. He is from grocery department

#who earns the most in respective department
select last_name,  department, salary from staff as s1 where
salary= (select max(salary) from staff as s2 where s1.department=s2.department);

-- --------------------------------------------------------------
#Combining staff and division for more information about the employees
 select count(*) from staff inner join divisions on staff.department= divisions.department;
-- there are only 953 records in the merged table whereas staff table has 1000 records

#Checking if division column has missing department
select count(*) from staff left join divisions on staff.department=divisions.department;
-- it confirms that divisions table has missing department values

#where is department values missing
select * from staff left join divisions on staff.department=divisions.department
where divisions.department is null;
-- the BOOK department information is missing from division table

#How many missing values in the joined table
select count(*) from staff left join divisions on staff.department=divisions.department
where divisions.department is null;

-- --------------------------------------------------------------------------------
#Merging all the tables
create or replace view merged as
select s.*, divisions.company_division, regions.company_regions, regions.country
from staff as s left join divisions on s.department=divisions.department
left join regions on s.region_id= regions.region_id;

#how many staff in each company regions
select region_id, count(*) as totEmp from merged
group by region_id;

#department-wise distribution of employees in regions
select department, region_id, count(*) as totEmp from merged
group by department, region_id
order by 1, 2;

# employees per region per country
select company_regions, country, count(*) as totEmp from merged
group by region_id, country
order by 3, 1;


/* *************** Rollup***********/
-- the ROLLUP generates multiple grouping sets based on the columns or expressions specified in the GROUP BY clause
/* number of employees per regions & country, Then sub totals per Country, Then total for whole table*/
create view emp as
SELECT country,company_regions, COUNT(*) AS total_employees
FROM merged
GROUP BY
	country, company_regions with rollup
;

select e1.*, (select sum(total_employees) from emp e2 where
 e1.country= e2.country)
 as empNo from emp as e1; 
 
# top 10 salary earners
select * from merged
order by salary desc 
limit 10;

/* Top 5 division with highest number of employees*/
select company_division, count(*) as total_emp from merged
group by company_division
order by 2 desc
limit 5;