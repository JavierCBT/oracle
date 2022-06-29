SET PAGES 999
SET LINES 300
COL username FOR A20
COL program FOR A50
COL machine FOR A40
COL LAST_ACCESS FOR A30
select c.username, a.program, a.machine, MAX(a.SAMPLE_TIME) as LAST_ACCESS
from DBA_HIST_ACTIVE_SESS_HISTORY a, dba_users c
where a.user_id=c.user_id and
a.program not like '%ORACLE%' and 
a.program not like '%oracle%' and 
a.program not like '%rman%' and 
a.program not like '%Toad%' and 
a.sample_time > systimestamp - 3000 and
c.username != 'SYS'
group by c.username, a.machine , a.program
order by 1;