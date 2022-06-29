column username format a13
column osuser format a15
column tablespace format a10
set linesize 160
SELECT a.inst_id, b.tablespace, b.segfile#, b.blocks * e.block_size/1024/1024 mb_temp_used, a.sid, a.serial#, a.username, a.osuser, a.status--, d.sql_text
FROM gv$session a,gv$sort_usage b, dba_tablespaces e--, v$sqlarea d
WHERE a.saddr = b.session_addr
and b.tablespace = e.tablespace_name
--and a.sql_address=d.address(+)
ORDER BY b.blocks desc;
--ORDER BY b.tablespace, b.segfile#, b.segblk#, b.blocks;