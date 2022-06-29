set pagesize 0 feedback off trimspool on
--column dbname new_value instance
--select 'recover_datafiles_' ||host_name||'_'||instance_name||'.sql' dbname from v$instance;
--spool &instance
select 'recover datafile ' ||listagg(file#, ', ') within group (order by file#)|| ';'
from v$datafile
where status = 'RECOVER'
union all
select 'SQL ''alter database datafile ' ||file#|| ' online'';'
from v$datafile
where status = 'RECOVER'
union all
select 'SQL ''alter database datafile ' ||file#|| ' online'';'
from v$datafile
where status = 'OFFLINE';
--spool off
--@&instance