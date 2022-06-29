set linesize 200
set pagesize 999
column username format a21
column osuser format a30
column machine format a30
--column terminal format a15
column program format a50
column sid format 9999
--column serial# format 999999
column spid format a8
--alter session set nls_date_format="dd/mm/yyyy hh24:mi:ss";
--select s.username, s.osuser, s.machine, s.program, p.spid, s.logon_time, sysdate-s.last_call_et/86400 last_exec, s.sid, s.serial#
select p.spid, s.username, s.osuser, s.machine, s.program, s.logon_time, sysdate-s.last_call_et/86400 last_exec
from v$session s, v$process p
where s.username is not null
  and s.paddr = p.addr
order by last_exec desc;
select count (*) from v$session;