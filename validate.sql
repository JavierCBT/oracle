set pagesize 0 feedback off trimspool on
column dbname new_value instance
select 'validate_' ||host_name||'_'||instance_name||'.sql' dbname from v$instance;
spool &instance
select 'alter ' || decode(object_type, 'PACKAGE BODY', 'package', 'TYPE BODY', 'type', nls_lower(object_type)) || ' "' || owner || '"."' || object_name || '" compile' || decode(object_type, 'PACKAGE BODY', ' body', '') || ';' from dba_objects where status='INVALID';
spool off
@&instance
