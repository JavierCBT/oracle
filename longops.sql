COLUMN sid FORMAT 9999
COLUMN message FORMAT A30
COLUMN inst FORMAT 9

  SELECT sl.SID,
         DECODE (sl.totalwork, 0, 0, ROUND (100 * sl.sofar / sl.totalwork, 2))
             "Percent",
         sl.MESSAGE
             "Message",
         sl.start_time,
         sl.elapsed_seconds,
         sl.time_remaining,
         sl.inst_id,
         st.sql_fulltext
    FROM GV$Session_longops sl, gv$sql st
   WHERE     sl.OPNAME NOT LIKE '%aggregate%'
         AND sl.TOTALWORK != 0
         AND sl.SOFAR <> sl.TOTALWORK
         AND sl.sql_id = st.sql_id (+)
         AND sl.inst_id = st.inst_id (+)
ORDER BY sl.time_remaining DESC;