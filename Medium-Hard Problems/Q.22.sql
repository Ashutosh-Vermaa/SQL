create table exams (student_id int, subject varchar(20), marks int);
delete from exams;
insert into exams values (1,'Chemistry',91),(1,'Physics',91)
,(2,'Chemistry',80),(2,'Physics',90)
,(3,'Chemistry',80)
,(4,'Chemistry',71),(4,'Physics',54);

-- find students having same marks in physics and chemistry
select marks, student_id, count(distinct subject) from exams 
where subject in ('Chemistry', 'Physics')
group by marks, student_id
having count(distinct subject)=2; 