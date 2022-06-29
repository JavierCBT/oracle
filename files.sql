set pagesize 0
set feedback off
set trimout on
select * from (
select d.name || ' (datafile - ' || round(d.bytes/power(2,20)) || 'M) - ts: ' ||ts.name from v$datafile d, v$tablespace ts where d.ts# = ts.ts#
union all
select member || ' (online redolog)' from v$logfile
union all
select name || ' (control file)' from v$controlfile
union all
select t.name || ' (temporary file - ' || round(t.bytes/power(2,20)) || 'M) - ts: ' ||ts.name from v$tempfile t, v$tablespace ts where t.ts# = ts.ts#
) order by 1
/
