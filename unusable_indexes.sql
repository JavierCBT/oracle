set pagesize 9999 heading off feedback off trimspool on
column dbname new_value instance
select 'unusable_' ||host_name||'_'||instance_name||'.sql' dbname from v$instance;
spool &instance
select 'alter index ' ||owner|| '.' ||index_name|| ' rebuild;' from dba_indexes where status = 'UNUSABLE';
spool off
@&instance