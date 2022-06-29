SELECT distinct
   h.sample_time,
   u.username,
   h.module,
   dbms_lob.substr(s.sql_text, 4000, 1)
FROM
   DBA_HIST_ACTIVE_SESS_HISTORY h,
   DBA_USERS u,
   DBA_HIST_SQLTEXT s
WHERE  sample_time BETWEEN &1 AND &2
   AND h.user_id=u.user_id
   AND h.sql_id = s.sql_iD
--   AND u.username = 'CLIMAPROODS'
ORDER BY h.sample_time;