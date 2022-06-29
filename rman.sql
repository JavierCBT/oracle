TTITLE LEFT '% Completed. Aggregate is the overall progress:'
SET LINE 132
SELECT opname, round(sofar/totalwork*100) "% Complete"
  FROM gv$session_longops
 WHERE opname LIKE 'RMAN%'
   AND totalwork != 0
   AND sofar <> totalwork
 ORDER BY 1;