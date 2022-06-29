set pagesize 0 linesize 1000 trimspool on feedback off termout off timing off
define begin_date = "&1"
define end_date = "&2"
define pth = "e:/oracle/scripts"
column choose_sql new_value ash
select case substr(version, 1, 4)
    when '10.2' then '&pth/ash_v10.sql'
	when '11.1' then '&pth/ash.sql'
	when '11.2' then '&pth/ash.sql'
	when '12.1' then '&pth/ash.sql'
	when '12.2' then '&pth/ash.sql'
	when '19.0' then '&pth/ash.sql'
    else '&pth/notsupported.sql'
    end choose_sql
from v$instance;
set pagesize 999 termout on
@&ash wait_class "session_type = 'FOREGROUND' and (event2 != 'ges generic event' or event2 is null)" "&begin_date" "&end_date"
@&ash wait_class,event2,program2 "session_type = 'FOREGROUND' and event2 != 'ges generic event' and wait_class != 'ON CPU'" "&begin_date" "&end_date"
@&ash sess,wait_class,event2,program2,sql_opname2,owner,object_name,sql_id,sql_text "session_type = 'FOREGROUND' and event2 != 'ges generic event' and wait_class != 'ON CPU'" "&begin_date" "&end_date"
@&pth/awr.sql "&begin_date" "&end_date"
@&pth/addm.sql "&begin_date" "&end_date"