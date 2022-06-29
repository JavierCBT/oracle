set feedback off
set pagesize 0
spool _unlimited_quota_.sql
select 'alter user ' ||username|| ' quota unlimited on ' ||tablespace_name|| ';' from dba_ts_quotas where max_bytes != -1;
spool off
@_unlimited_quota_.sql