COL "%This" FOR A7
--COL p1     FOR 99999999999999
--COL p2     FOR 99999999999999
--COL p3     FOR 99999999999999
COL p1text              FOR A30 word_wrap
COL p2text              FOR A30 word_wrap
COL p3text              FOR A30 word_wrap
COL p1hex               FOR A17
COL p2hex               FOR A17
COL p3hex               FOR A17
COL dop                 FOR 99
COL AAS                 FOR 9999.9
COL seconds             FOR 99999999
COL seen                FOR 999999
COL event               FOR A40 WORD_WRAP
COL event2              FOR A40 WORD_WRAP
COL time_model_name     FOR A50 WORD_WRAP
COL program2            FOR A40 TRUNCATE
COL username            FOR A20 wrap
COL obj                 FOR A30
COL objt                FOR A50
COL sql_opname          FOR A20
COL top_level_call_name FOR A30
COL wait_class          FOR A15
COL module				FOR A35
COL sql_opname2			FOR A40
COL blocked_by			FOR A12
COL sess				FOR A12
COL sql_text			FOR A120

SELECT /*+ gather_plan_statistics */ *
FROM (
        WITH bclass AS (SELECT /*+ INLINE */ class, ROWNUM r from v$waitstat)
        SELECT /*+ LEADING(a) USE_HASH(u) */
--            sum(case when ash = 'gv_ash' then 1 else 10 end) seconds
          ROUND(sum(case when ash = 'gv_ash' then 1 else 10 end) / ((CAST(&4 AS DATE) - CAST(&3 AS DATE)) * 86400), 1) AAS
          , LPAD(ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100)||'%',5,' ')||' |' "%This"
          , TO_CHAR(MIN(sample_time), 'YYYY-MM-DD HH24:MI:SS') first_seen
          , TO_CHAR(MAX(sample_time), 'YYYY-MM-DD HH24:MI:SS') last_seen
--    , MAX(sql_exec_id) - MIN(sql_exec_id)
          , COUNT(DISTINCT sql_exec_start||':'||sql_exec_id) seen
          , &1
        FROM
			(SELECT
			    'gv_ash' ash
			   , nvl(wait_class, 'ON CPU') wait_class
			   , sql_exec_id
			   , sql_id
			   , sample_time
			   , current_obj#
			   , user_id
			   , sql_exec_start
			   , session_type
			   , session_id sid
			   , session_serial# serial
			   , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p1 ELSE null END, '0XXXXXXXXXXXXXXX') p1hex
			   , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p2 ELSE null END, '0XXXXXXXXXXXXXXX') p2hex
			   , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p3 ELSE null END, '0XXXXXXXXXXXXXXX') p3hex
			   , TRUNC(px_flags / 2097152) dop
			   , NVL(a.event, a.session_state)||
							CASE
									WHEN a.event like 'enq%' AND session_state = 'WAITING'
									THEN ' [mode='||BITAND(p1, POWER(2,14)-1)||']'
									WHEN a.event IN (SELECT name FROM v$event_name WHERE parameter3 = 'class#')
									THEN ' ['||CASE WHEN a.p3 <= (SELECT MAX(r) FROM bclass)
													   THEN (SELECT class FROM bclass WHERE r = a.p3)
													   ELSE (SELECT DECODE(MOD(BITAND(a.p3,TO_NUMBER('FFFF','XXXX')) - 17,2),0,'undo header',1,'undo data', 'error') FROM dual)
													   END  ||']'
									ELSE null
							END event2 -- event is NULL in ASH if the session is not waiting (session_state = ON CPU)
			   , CASE WHEN a.session_type = 'BACKGROUND' OR REGEXP_LIKE(a.program, '.*\([PJ]\d+\)') THEN
							REGEXP_REPLACE(SUBSTR(a.program,INSTR(a.program,'(')), '\d', 'n')
					 ELSE
							'('||REGEXP_REPLACE(REGEXP_REPLACE(a.program, '(.*)@(.*)(\(.*\))', '\1'), '\d', 'n')||')'
					 END || ' ' program2
			   , CASE WHEN sql_opname != sql_plan_operation THEN
							sql_opname||' ('||sql_plan_operation||' '||sql_plan_options||')'
					 ELSE
							sql_opname
					 END sql_opname2
			   , CASE WHEN blocking_session IS NOT NULL THEN blocking_session||','||blocking_session_serial#||'@'||blocking_inst_id ELSE NULL END blocked_by
			   , session_id||','||session_serial#||'@'||inst_id sess
			   -- , CASE WHEN BITAND(time_model, POWER(2, 01)) = POWER(2, 01) THEN 'DBTIME '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 02)) = POWER(2, 02) THEN 'BACKGROUND '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 03)) = POWER(2, 03) THEN 'CONNECTION_MGMT '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 04)) = POWER(2, 04) THEN 'PARSE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 05)) = POWER(2, 05) THEN 'FAILED_PARSE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 06)) = POWER(2, 06) THEN 'NOMEM_PARSE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 07)) = POWER(2, 07) THEN 'HARD_PARSE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 08)) = POWER(2, 08) THEN 'NO_SHARERS_PARSE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 09)) = POWER(2, 09) THEN 'BIND_MISMATCH_PARSE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 10)) = POWER(2, 10) THEN 'SQL_EXECUTION '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 11)) = POWER(2, 11) THEN 'PLSQL_EXECUTION '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 12)) = POWER(2, 12) THEN 'PLSQL_RPC '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 13)) = POWER(2, 13) THEN 'PLSQL_COMPILATION '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 14)) = POWER(2, 14) THEN 'JAVA_EXECUTION '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 15)) = POWER(2, 15) THEN 'BIND '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 16)) = POWER(2, 16) THEN 'CURSOR_CLOSE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 17)) = POWER(2, 17) THEN 'SEQUENCE_LOAD '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 18)) = POWER(2, 18) THEN 'INMEMORY_QUERY '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 19)) = POWER(2, 19) THEN 'INMEMORY_POPULATE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 20)) = POWER(2, 20) THEN 'INMEMORY_PREPOPULATE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 21)) = POWER(2, 21) THEN 'INMEMORY_REPOPULATE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 22)) = POWER(2, 22) THEN 'INMEMORY_TREPOPULATE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 23)) = POWER(2, 23) THEN 'TABLESPACE_ENCRYPTION ' END time_model_name
			FROM gv$active_session_history a
			UNION ALL
			SELECT --/*+ parallel(b,16) */
				--/*+ noparallel(user_editioning$) */
				'dh_ash' ash
			   , nvl(wait_class, 'ON CPU') wait_class
			   , sql_exec_id
			   , sql_id
			   , sample_time
			   , current_obj#
			   , user_id
			   , sql_exec_start
			   , session_type
			   , session_id sid
			   , session_serial# serial
			   , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p1 ELSE null END, '0XXXXXXXXXXXXXXX') p1hex
			   , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p2 ELSE null END, '0XXXXXXXXXXXXXXX') p2hex
			   , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p3 ELSE null END, '0XXXXXXXXXXXXXXX') p3hex
			   , TRUNC(px_flags / 2097152) dop
			   , NVL(b.event, b.session_state)||
							CASE
									WHEN b.event like 'enq%' AND session_state = 'WAITING'
									THEN ' [mode='||BITAND(p1, POWER(2,14)-1)||']'
									WHEN b.event IN (SELECT name FROM v$event_name WHERE parameter3 = 'class#')
									THEN ' ['||CASE WHEN b.p3 <= (SELECT MAX(r) FROM bclass)
													   THEN (SELECT class FROM bclass WHERE r = b.p3)
													   ELSE (SELECT DECODE(MOD(BITAND(b.p3,TO_NUMBER('FFFF','XXXX')) - 17,2),0,'undo header',1,'undo data', 'error') FROM dual)
													   END  ||']'
									ELSE null
							END event2 -- event is NULL in ASH if the session is not waiting (session_state = ON CPU)
			   , CASE WHEN b.session_type = 'BACKGROUND' OR REGEXP_LIKE(b.program, '.*\([PJ]\d+\)') THEN
							REGEXP_REPLACE(SUBSTR(b.program,INSTR(b.program,'(')), '\d', 'n')
					 ELSE
							'('||REGEXP_REPLACE(REGEXP_REPLACE(b.program, '(.*)@(.*)(\(.*\))', '\1'), '\d', 'n')||')'
					 END || ' ' program2
			   , CASE WHEN sql_opname != sql_plan_operation THEN
							sql_opname||' ('||sql_plan_operation||' '||sql_plan_options||')'
					 ELSE
							sql_opname
					 END sql_opname2
			   , CASE WHEN blocking_session IS NOT NULL THEN blocking_session||','||blocking_session_serial#||'@'||blocking_inst_id ELSE NULL END blocked_by
			   , session_id||','||session_serial#||'@'||instance_number sess
			   -- , CASE WHEN BITAND(time_model, POWER(2, 01)) = POWER(2, 01) THEN 'DBTIME '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 02)) = POWER(2, 02) THEN 'BACKGROUND '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 03)) = POWER(2, 03) THEN 'CONNECTION_MGMT '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 04)) = POWER(2, 04) THEN 'PARSE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 05)) = POWER(2, 05) THEN 'FAILED_PARSE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 06)) = POWER(2, 06) THEN 'NOMEM_PARSE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 07)) = POWER(2, 07) THEN 'HARD_PARSE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 08)) = POWER(2, 08) THEN 'NO_SHARERS_PARSE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 09)) = POWER(2, 09) THEN 'BIND_MISMATCH_PARSE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 10)) = POWER(2, 10) THEN 'SQL_EXECUTION '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 11)) = POWER(2, 11) THEN 'PLSQL_EXECUTION '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 12)) = POWER(2, 12) THEN 'PLSQL_RPC '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 13)) = POWER(2, 13) THEN 'PLSQL_COMPILATION '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 14)) = POWER(2, 14) THEN 'JAVA_EXECUTION '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 15)) = POWER(2, 15) THEN 'BIND '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 16)) = POWER(2, 16) THEN 'CURSOR_CLOSE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 17)) = POWER(2, 17) THEN 'SEQUENCE_LOAD '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 18)) = POWER(2, 18) THEN 'INMEMORY_QUERY '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 19)) = POWER(2, 19) THEN 'INMEMORY_POPULATE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 20)) = POWER(2, 20) THEN 'INMEMORY_PREPOPULATE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 21)) = POWER(2, 21) THEN 'INMEMORY_REPOPULATE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 22)) = POWER(2, 22) THEN 'INMEMORY_TREPOPULATE '  END
			   -- ||CASE WHEN BITAND(time_model, POWER(2, 23)) = POWER(2, 23) THEN 'TABLESPACE_ENCRYPTION ' END time_model_name
			FROM dba_hist_active_sess_history b
			) c
          , dba_users u
          , (SELECT
                         object_id,data_object_id,owner,object_name,subobject_name,object_type
                   , owner||'.'||object_name obj
                   , owner||'.'||object_name||' ['||object_type||']' objt
                 FROM dba_objects) o
          , (SELECT sql_id sqlid, dbms_lob.substr(sql_text, 2000, 1) sql_text FROM dba_hist_sqltext) s
          --, (SELECT sql_id sqlid, dbms_lob.substr(sql_text, 2000, 1) sql_text FROM v$sqltext) s
        WHERE
                c.user_id = u.user_id (+)
        AND c.current_obj# = o.object_id(+)
        AND c.sql_id = s.sqlid(+)
		AND &2
		AND c.sample_time BETWEEN &3 AND &4
--		AND a.sql_exec_id is not null
		GROUP BY
			&1
		ORDER BY
			"%This" DESC
		  , &1
)
WHERE
        ROWNUM <= 5;