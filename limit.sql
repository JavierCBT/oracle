set feedback off
column RESOURCE_NAME format a30
column INITIAL_ALLOCATION format a20
column LIMIT_VALUE format a20
column USERNAME format a20
column MACHINE format a25
select * from gv$resource_limit where limit_value != 'UNLIMITED' and max_utilization > 0.8*to_number(limit_value);

select distinct s.inst_id, s.username, s.machine, count(*)
from gv$session s, gv$process p
where s.paddr=p.addr
and s.inst_id=p.inst_id
GROUP BY s.inst_id, s.username, s.machine
having count(*) > 20
ORDER BY 4 desc;
select count (*) from v$process;
