set pagesize 0 feedback off trimspool on termout off
column choose_sql new_value sql_to_execute
select case substr(version, 1, 2)
	when '19' then '_alert11g_.sql'
    when '12' then '_alert11g_.sql'
	when '11' then '_alert11g_.sql'
    else '_alert10g_.sql'
    end choose_sql
from v$instance;
set termout on
@&sql_to_execute &1 &2