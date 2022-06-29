set pagesize 0 feedback off trimspool on termout off
column choose_sql new_value sql_to_execute
select case substr(version, 1, 1)
    when '1' then '_purgebin_.sql'
    else 'quit.sql'
    end choose_sql
from v$instance;
@&sql_to_execute