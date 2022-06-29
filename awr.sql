set pagesize 0 linesize 1000 trimspool on feedback off termout off timing off
define begin_date = "&1"
define end_date = "&2"
define pth = "e:/oracle/scripts"
column choose_sql new_value awr
select case substr(version, 1, 2)
    when '10' then '&pth/_awr_v10.sql'
	when '11' then '&pth/_awr_.sql'
	when '12' then '&pth/_awr_.sql'
	when '19' then '&pth/_awr_.sql'
    else '&pth/notsupported.sql'
    end choose_sql
from v$instance;
set pagesize 999 termout on
@&awr "&begin_date" "&end_date"