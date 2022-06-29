COLUMN INST_ID FORMAT 9
COLUMN SID FORMAT 9999
--COLUMN SERIAL# FORMAT 99999
COLUMN SCHEMANAME FORMAT A18
COLUMN OSUSER FORMAT A15
COLUMN MACHINE FORMAT A23
--COLUMN PROGRAM FORMAT A35
COLUMN MODULE FORMAT A16
COLUMN EVENT FORMAT A30
COLUMN WAIT_CLASS FORMAT A11
COLUMN SERVICE_NAME FORMAT A15
COLUMN SECONDS FORMAT 99999

SELECT   s.INST_ID,
         s.SID,
--         s.SERIAL#,
--         s.USERNAME,
--         s.LOCKWAIT,
--         s.STATUS,
         s.SCHEMANAME,
         s.OSUSER,
         s.MACHINE,
--         UPPER (s.PROGRAM) PROGRAM,
--         s.TYPE,
--         s.PREV_SQL_ID,
--         s.PREV_EXEC_START,
         s.MODULE,
         s.LOGON_TIME,
         s.LAST_CALL_ET,
--         s.SEQ#,
--         s.EVENT#,
         s.EVENT,
--         s.P1TEXT,
--         s.P1,
--         s.P2TEXT,
--         s.P2,
--         s.P3TEXT,
--         s.P3,
--         s.WAIT_CLASS#,
         s.WAIT_CLASS,
--         s.WAIT_TIME,
         s.SECONDS_IN_WAIT SECONDS,
--         s.STATE,
--         s.WAIT_TIME_MICRO,
--         s.TIME_REMAINING_MICRO,
--         s.TIME_SINCE_LAST_WAIT_MICRO,
         s.SERVICE_NAME
    FROM GV$SESSION S
   WHERE (    (s.USERNAME IS NOT NULL)
          AND (NVL (s.osuser, 'x') <> 'SYSTEM')
          AND (s.TYPE <> 'BACKGROUND'))
          AND S.EVENT# NOT IN (335, 350, 354, 384, 388)
ORDER BY SECONDS DESC, USERNAME, OWNERID;