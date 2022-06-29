set pagesize 9999
set feedback off
select output from gv$rman_output
where session_recid = (select max(session_recid) from gv$rman_output)
order by recid;