set pagesize 500
set linesize 300
col job_name format a30
col operation format a30
col job_mode format a30
col OWNER_NAME format a10
col module format a18
col event format a45
col state format a18
col sql_text format a75
col secs format 99999
col sid format 9999

select owner_name, job_name, operation, job_mode
from dba_datapump_jobs
where state='EXECUTING' ;
select owner_name, job_name, session_type
from dba_datapump_sessions;
select v.status, v.sid,v.serial#,io.block_changes,event
from v$sess_io io, v$session v
where io.sid = v.sid
and v.saddr in (
select saddr
from dba_datapump_sessions
) order by sid;
select s.sid, s.module, s.state,
substr(s.event, 1, 40) as event,
s.seconds_in_wait as secs,
substr(sql.sql_text, 1, 75) as sql_text
from v$session s
join v$sql sql on sql.sql_id = s.sql_id
where s.module like 'Data Pump%'
order by s.module, s.sid;