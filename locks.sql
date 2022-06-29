with data as (
SELECT s1.INST_ID inst_id, s1.username || '@' || s1.machine schema, 
    s1.sid sid, s1.serial# serial#,
    s2.username || '@' || s2.machine || ' (SID=' || s2.sid || ', SQL_ID=' ||s2.sql_id|| ')' c2
     FROM gv$lock l1, gv$session s1, gv$lock l2, gv$session s2
    WHERE s1.sid=l1.sid AND
     s1.inst_id=l1.inst_id AND
     s2.sid=l2.sid AND
     s2.inst_id=l2.inst_id AND
     l1.BLOCK=1 AND
    l2.request > 0 AND
    l1.id1 = l2.id1 AND
    l2.id2 = l2.id2
)
select 'ALTER SYSTEM KILL SESSION ''' ||sid|| ',' ||serial#|| ',@' ||inst_id|| ''' immediate;' --[inst #' ||inst_id|| '] ' ||schema|| ' (SID=' ||sid|| ', SERIAL#=' ||serial#|| ') is blocking ' ||count(*)|| ' sessions'''
from data
group by inst_id, schema, sid, serial#;