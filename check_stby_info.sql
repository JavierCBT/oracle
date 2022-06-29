set linesize 300
set pages 70
col name for a40
col value for a70
col message for a90
col destination for a35
col dest_name for a40
select name,value from gv$parameter where name in ('db_name','db_unique_name','db_domain','db_file_name_convert','log_file_name_convert','fal_server','fal_client','remote_login_passwordfile','standby_file_management','dg_broker_start','dg_broker_config_file1','dg_broker_config_file2');
select status,instance_name,database_role,open_mode,protection_mode,switchover_status from gv$instance,gv$database;
select name,(space_limit/1024/1024/1024) "Limit in GB",(space_used/1024/1024/1024) "Used in GB" from v$recovery_file_dest;
select thread#,max(sequence#) from gv$archived_log group by thread#;
select thread#,max(sequence#) from gv$archived_log where applied='YES' group by thread#;
select dest_id, dest_name, status, target, archiver , destination from GV$ARCHIVE_DEST where destination IS NOT NULL;
select inst_id,process,status,sequence#,thread#,client_process from gv$managed_standby;
select group#,thread#,status,members,(bytes/1024/1024)"Each ORL File Size in MB" from gv$log;
select group#,thread#,status,(bytes/1024/1024)"Each SRL File Size in MB" from gv$standby_log;
select * from  V$STANDBY_EVENT_HISTOGRAM where to_date(LAST_TIME_UPDATED,'MM/DD/YYYY HH24:MI:SS') >= sysdate - 15/60/24 order by LAST_TIME_UPDATED;
select to_char(START_TIME,'DD-MON-YYYY HH24:MI:SS') "Recovery Start Time",to_char(item)||' = '||to_char(sofar)||' '||to_char(units) "Progress"
from v$recovery_progress where start_time=(select max(start_time) from v$recovery_progress);