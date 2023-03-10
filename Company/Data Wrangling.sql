/********Data Wrangling***********/

#character transformation
select upper(department) from staff;

select lower(department) from staff;

#Concatenation
select last_name, concat(job_title, '-', department) as jobDept from staff;

#TRIM
select length(trim('    comp       ')) as len;

#Employees with assistant roles
select count(*) as assistants from staff where job_title like "%assistant%";

#Assistant roles
select job_title from staff where job_title like "%assistant%";

#which roles are assistants and which are not
SELECT 
	DISTINCT(job_title),
	job_title LIKE '%Assistant%' is_assistant_role
FROM staff
ORDER BY 1;

/*************************PLAYING WITH STRINGS***************/
#SUBSTRING(string, starting postion, length of substring)
select substring('bdfjfh', 2, 4) as sub_string;

#Job category for employees starting with word assistant
select  job_title, substring(job_title from length('Assistant')+1) as category from staff where job_title like 'Assistant%';

#Unique job categories
select distinct(substring(job_title from length('Assistant')+1)) as category, job_title  from staff where job_title like 'Assistant%';

/**********Replacing words**********/

#replace Assistant with Asst.
select replace(job_title, 'Assistant', 'Asst.') as short_category, last_name from staff
where job_title like "%Assistant%";

-- --------------------REGULAR EXPRESSIONS---------------------------
#job title that starts with E, P or S
select job_title from staff where job_title REGEXP '^E|^P|^S';


-- -----------------Reformatting numeric data--------------------
-- TRUNCATE() Truncate values Note: trunc just truncate value, not rounding value.
-- CEIL
-- FLOOR
-- ROUND

select avg(salary),
truncate(avg(salary), 1),
ceil(avg(salary)),
floor(avg(salary)),
round(avg(salary), 1)
from staff
group by department;
