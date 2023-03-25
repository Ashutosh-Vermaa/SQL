drop table if exists students;
CREATE TABLE students(
 studentid int NULL,
 studentname nvarchar(255) NULL,
 subject nvarchar(255) NULL,
 marks int NULL,
 testid int NULL,
 testdate date NULL
);

insert into students values (2,'Max Ruin','Subject1',63,1,'2022-01-02');
insert into students values (3,'Arnold','Subject1',95,1,'2022-01-02');
insert into students values (4,'Krish Star','Subject1',61,1,'2022-01-02');
insert into students values (5,'John Mike','Subject1',91,1,'2022-01-02');
insert into students values (4,'Krish Star','Subject2',71,1,'2022-01-02');
insert into students values (3,'Arnold','Subject2',32,1,'2022-01-02');
insert into students values (5,'John Mike','Subject2',61,2,'2022-11-02');
insert into students values (1,'John Deo','Subject2',60,1,'2022-01-02');
insert into students values (2,'Max Ruin','Subject2',84,1,'2022-01-02');
insert into students values (2,'Max Ruin','Subject3',29,3,'2022-01-03');
insert into students values (5,'John Mike','Subject3',98,2,'2022-11-02');


-- students who scored above avg in each subject
with stu as(
select studentid, subject, sum(marks) as marks
from students
group by studentid, subject),

avg_m as(
select subject, avg(marks) as avg_marks from students
group by subject)

select studentid, stu.subject from stu join
avg_m on stu.subject=avg_m.subject and avg_marks<marks
order by studentid;

-- % of students who scored >90 in any subject amongst others

select distinct 
(select count(distinct studentid) as a from students where marks>90)/
(select count(distinct studentid) as b from students) as percent from students ;

-- 2nd highest and 2nd lowest marks for each subject
with low as
(select subject, marks as lowest,
rank() over(partition by subject order by subject, marks) as asc_rk
from students ),
high as
(select subject, marks as highest,
rank() over(partition by subject order by subject, marks desc) as desc_rk
from students )

select low.subject, lowest, highest from low
join high on low.subject=high.subject
where asc_rk=2 and desc_rk=2; 

-- for each student identify if there marks increased or decrease from the previous test
with temp as(
select studentid, studentname, testdate, marks,
lag(marks) over(partition by studentid order by studentid,testdate) as prev_score
from students order by studentid,testdate)

select *,
case when prev_score<marks then "inc" when prev_score>marks then "dec" 
else null end as stat from temp
order by  studentid,testdate ;
;