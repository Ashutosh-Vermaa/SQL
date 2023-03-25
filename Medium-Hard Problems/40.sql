-- return student_id, student_name of those students
-- who attended atleast one exam and didn't come last or first in any of the exams

with temp as(
select exam_id, min(score) minimum, max(score) maximum
from exams group by exam_id)

,inter as(
select exams.exam_id, student_id, score, minimum, maximum
from exams left join temp
on temp.exam_id= exams.exam_id and 
(temp.minimum=exams.score or temp.maximum=exams.score))



select distinct exams.student_id, student_name from exams join students
on students.student_id=exams.student_id
 where exams.student_id not in(
select student_id from inter where minimum is not null) ;
