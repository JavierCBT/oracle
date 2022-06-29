SET LINE 200
SET FEEDBACK OFF
alter session set nls_date_format='dd/mm/yyyy hh24:mi';
TTITLE LEFT '% Completed. Aggregate is the overall progress:'
column start_time format a19
column end_date format a19
SELECT inst_id inst, opname, start_time, round(sofar/totalwork*100) "% Complete", time_remaining/60/60/24+sysdate end_date
 FROM gv$session_longops
WHERE opname LIKE 'RMAN%'
  AND totalwork != 0
  AND sofar <> totalwork
ORDER BY start_time;

TTITLE LEFT 'Channels waiting:'
COL client_info FORMAT A25 TRUNC
COL event FORMAT A30 TRUNC
COL state FORMAT A20
COL wait FORMAT 9999 HEAD "Min waiting"
COL tracefile FORMAT A80
--SELECT s.client_info, status, event, state, seconds_in_wait/60 wait, tracefile
SELECT s.client_info, status, event, state, seconds_in_wait/60 wait
 FROM gv$process p, gv$session s
WHERE p.addr = s.paddr
  AND client_info LIKE 'rman%'
  AND p.inst_id = s.inst_id;

TTITLE LEFT 'Files currently being accessed to:'
COL filename FORMAT a130
SELECT inst_id inst, filename, buffer_size, buffer_count, ceil(bytes/power(2,20)) mb, long_waits
 FROM gv$backup_async_io
WHERE status='IN PROGRESS'
ORDER BY inst;

TTITLE OFF
SET HEAD OFF
SELECT 'Throughput: '||
      ROUND(SUM(v.value/1024/1024),1) || ' Meg so far @ ' ||
      ROUND(SUM(v.value     /1024/1024)/NVL((SELECT MIN(elapsed_seconds)
           FROM v$session_longops
           WHERE opname          LIKE 'RMAN: aggregate%'
             AND sofar           != TOTALWORK
             AND elapsed_seconds IS NOT NULL
      ),SUM(v.value     /1024/1024)),2) || ' Meg/sec'
FROM gv$sesstat v, v$statname n, gv$session s
WHERE v.statistic# = n.statistic#
 AND n.name       = 'physical write total bytes'
 AND v.sid        = s.sid
 AND v.inst_id    = s.inst_id
 AND s.program LIKE 'rman@%'
GROUP BY n.name;

SELECT 'Throughput: '||
      ROUND(SUM(v.value/1024/1024),1) || ' Meg so far @ ' ||
      ROUND(SUM(v.value     /1024/1024)/NVL((SELECT MIN(elapsed_seconds)
           FROM v$session_longops
           WHERE opname          LIKE 'RMAN: aggregate%'
             AND sofar           != TOTALWORK
             AND elapsed_seconds IS NOT NULL
      ),SUM(v.value     /1024/1024)),2) || ' Meg/sec'
FROM gv$sesstat v, v$statname n, gv$session s
WHERE v.statistic# = n.statistic#
 AND n.name       = 'physical read total bytes'
 AND v.sid        = s.sid
 AND v.inst_id    = s.inst_id
 AND s.program LIKE 'rman@%'
GROUP BY n.name;

SET HEAD ON
SET FEEDBACK ON