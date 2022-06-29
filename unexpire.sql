set pagesize 0 linesize 1000 trimspool on feedback off termout off
define pth = "e:/oracle/scripts"
column choose_sql new_value unexp
select case substr(version, 1, 4)
	when '19.0' then '&pth/_unexpire_v12_2.sql'
	when '12.2' then '&pth/_unexpire_v12_2.sql'
	when '12.1' then '&pth/_unexpire_v12_1.sql'
    else '&pth/_unexpire_.sql'
    end choose_sql
from v$instance;
set pagesize 999 termout on
@&unexp