set pagesize 9999
set linesize 200
set long 200
SET FEEDBACK OFF;
column "UNDO RETENTION [Sec]" format a25

SELECT i.instance_name, d.undo_size/(1024*1024) "ACTUAL UNDO SIZE [MByte]",
       SUBSTR(e.value,1,25) "UNDO RETENTION [Sec]",
       (TO_NUMBER(e.value) * TO_NUMBER(f.value) *
       g.undo_block_per_sec) / (1024*1024) 
      "NEEDED UNDO SIZE [MByte]"	  
  FROM (
       SELECT SUM(a.bytes) undo_size
         FROM v$datafile a,
              v$tablespace b,
              dba_tablespaces c
        WHERE c.contents = 'UNDO'
          AND c.status = 'ONLINE'
          AND b.name = c.tablespace_name
          AND a.ts# = b.ts#
       ) d,
      v$parameter e,
       v$parameter f,
	   v$instance i,
       (
       SELECT MAX(undoblks/((end_time-begin_time)*3600*24))
         undo_block_per_sec
         FROM v$undostat
       ) g
 WHERE e.name = 'undo_retention'
  AND f.name = 'db_block_size'
/
 
break on today 
column today noprint new_value xdate 
select substr(to_char(sysdate,'fmMonth DD, YYYY HH:MI:SS P.M.'),1,35) today 
from dual; 
column name noprint new_value dbname 
column owner format a35
column object format a35
column object_name format a35
column "ID#" format a12
column "ID" format a12
column "File Name" format a60
column "Phy Reads" format a10
column "Phy Writes" format a10
column "Blk Reads" format a10
column "Blk Writes" format a10
column "Read Time" format a10
column "Write Time" format a10
column "File Total" format a10
column "Table Name (Segment)" format a35
column "DataFile Name" format a60
column "Tablespace Name" format a35
column "TableSpace Name" format a35
column "Rollback Name" format a35
column "Rollback_Name" format a35
column "Rollback_name" format a35
column "INI_extent" format a10
column "Next Exts" format a10
column "MinEx" format a10
column "MaxEx" format a10
column "Size (Bytes)" format a10
column "Extent#" format a10
column "Status" format a10
column "%Incr" format a10
column machine format a25
column terminal format a25
column extent format a12
column extend format a12
column waits format a12
column xacts format a12
column wraps format a12
column "Seg Type" format a35
column "DB Username" format a35 
select name from v$database; 

set heading on 
set feedback off 
set linesize 350 trimspool on

spool undo_info.lst 

prompt ********************************************************** 
prompt *****            Database Information                ***** 
prompt ********************************************************** 
ttitle left "DATABASE:  "dbname"    (AS OF:  "xdate")" 
select name, created, log_mode from v$database; 
prompt 
prompt ********************************************************** 
ttitle off 

rem ------------------------------------------------------------- 
rem             Rollback Information 
rem ------------------------------------------------------------- 

set pagesize 66 
set line 350 trimspool on

TTitle left "*** Database:  "dbname", Rollback Information ( As of:  " xdate "  ) ***" skip 2 

select  substr(sys.dba_rollback_segs.SEGMENT_ID,1,5) "ID#", 
	 substr(sys.dba_segments.OWNER,1,8) "Owner", 
	 substr(sys.dba_segments.TABLESPACE_NAME,1,17) "Tablespace Name", 
	 substr(sys.dba_segments.SEGMENT_NAME,1,17) "Rollback Name", 
	 substr(sys.dba_rollback_segs.INITIAL_EXTENT,1,10) "INI_Extent", 
	 substr(sys.dba_rollback_segs.NEXT_EXTENT,1,10) "Next Exts", 
	 substr(sys.dba_segments.MIN_EXTENTS,1,5) "MinEx", 
   substr(sys.dba_segments.MAX_EXTENTS,1,5) "MaxEx", 
	 substr(sys.dba_segments.PCT_INCREASE,1,5) "%Incr", 
	 substr(sys.dba_segments.BYTES,1,15) "Size (Bytes)", 
	 substr(sys.dba_segments.EXTENTS,1,6) "Extent#", 
	 substr(sys.dba_rollback_segs.STATUS,1,10) "Status" 
from sys.dba_segments, sys.dba_rollback_segs 
where sys.dba_segments.segment_name = sys.dba_rollback_segs.segment_name and 
   sys.dba_segments.segment_type = 'ROLLBACK' 
order by sys.dba_rollback_segs.segment_id; 

ttitle off 

TTitle left " " skip 2 - 
	left "*** Database:  "dbname", Rollback Status ( As of:  " xdate " )  ***" skip 2 

select substr(V$rollname.NAME,1,20) "Rollback_Name", 
	 substr(V$rollstat.EXTENTS,1,6) "EXTENT", 
	 v$rollstat.RSSIZE, v$rollstat.WRITES, 
	 substr(v$rollstat.XACTS,1,6) "XACTS", 
	 v$rollstat.GETS, 
	 substr(v$rollstat.WAITS,1,6) "WAITS", 
	 v$rollstat.HWMSIZE, v$rollstat.SHRINKS, 
	 substr(v$rollstat.WRAPS,1,6) "WRAPS", 
	 substr(v$rollstat.EXTENDS,1,6) "EXTEND", 
	 v$rollstat.AVESHRINK, 
	 v$rollstat.AVEACTIVE 
from v$rollname, v$rollstat 
where v$rollname.USN = v$rollstat.USN 
order by v$rollname.USN; 

ttitle off 

TTitle left " " skip 2 - 
	left "*** Database:  "dbname", Rollback Segment Mapping ( As of:  "   xdate " ) ***" skip 2 

select  r.name Rollback_Name, 
   p.pid Oracle_PID, 
	 p.spid OS_PID, 
	 nvl(p.username,'NO TRANSACTION') TXN_OWNER, 
	 p.terminal Terminal 
from v$lock l, v$process p, v$rollname r 
where   l.addr = p.addr(+) 
	 and trunc(l.id1(+)/65536)=r.usn 
   and l.type(+) = 'TX' 
	 and l.lmode(+) = 6 
order by r.name; 

ttitle off 


rem ------------------------------------------------------------- 
rem ------------------------------------------------------------- 

spool off 
set feedback on 