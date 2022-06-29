-- chk_longops
-- martin Widlake 21/3/08
--
set linesize 200
set pagesize 255
--
col sid_ser form a9
col doing form a25
col elapsed_seconds form 9999,999 head elapsed
col time_remaining  form 9999,999 head to_go_hours
col time_remaining2  form 9999,999 head to_go_mins
col message form a85
spool chk_longops.lst
select sid||'-'||serial# sid_ser
,opname ||' on '|| target doing
,start_time
,last_update_time
,elapsed_seconds
,time_remaining/60/60 time_remaining
,time_remaining/60 time_remaining2
,message
from V$SESSION_LONGOPS
where sofar<totalwork
order by start_time desc
/
spool off
