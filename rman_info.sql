SET ECHO OFF
SET FEEDBACK 6
SET HEADING ON
SET LINESIZE 1000
SET PAGESIZE 9999
SET TERMOUT ON
SET TIMING OFF
SET TRIMOUT ON
SET TRIMSPOOL ON
SET VERIFY OFF
COL Backup_Size FORMAT A30
COL Backup_Time FORMAT A30
col start_time for a20
col input_type for a20
col status for a25
col end_time for a20
select session_key,
case when input_type = 'DB INCR' then 
	case when (output_bytes / (input_bytes+1) * 100) < 2 
		then 'INC1' else 'FULL' 
	end 
else
	input_type
end as TIPO_BACKUP,
status,
to_char(start_time,'yyyy-mm-dd hh24:mi') start_time,
to_char(end_time,'yyyy-mm-dd hh24:mi') end_time,
output_bytes_display Backup_Size,
time_taken_display Backup_Time
from v$rman_backup_job_details
order by session_key asc;

