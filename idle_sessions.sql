select username, osuser, machine, program,  count(*) cnt
from v$session 
where type = 'USER' 
  and last_call_et/3600 > 24
group by username, osuser, machine, program
having count(*) > 2
order by cnt desc;