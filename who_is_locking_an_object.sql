BREAK ON sid ON lock_id1 ON kill_sid

COL sid            FOR 999999
COL lock_type      FOR A25
--COL mode_held      FOR A12
--COL mode_requested FOR A12
COL lock_id1       FOR A30
COL lock_id2       FOR A20
COL kill_sid       FOR A50

SELECT s.sid,
       l.lock_type,
--       l.mode_held,
--       l.mode_requested,
       l.lock_id1,
       'alter system kill session '''|| s.sid|| ','|| s.serial#|| ''' immediate;' kill_sid
FROM   dba_lock_internal l,
       v$session s
WHERE  s.sid = l.session_id
AND    UPPER(l.lock_id1) LIKE '%&package_name%'
AND    l.lock_type = 'Body Definition Lock'
/