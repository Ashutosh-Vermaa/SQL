-- find companies having at least two users who speak English and German both the languages
with temp as(
select company_id, user_id, count(distinct language) as no_of_lang
from company_users 
where language in ('English', 'German')
group by company_id, user_id
having count(distinct language)=2)

select company_id, count(no_of_lang) as total_users from temp
group by company_id
having count(no_of_lang)>=2
;