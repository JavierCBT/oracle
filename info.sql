
--o Conocer el espacio ocupado por la base de datos:
select sum(bytes)/1024/1024 FROM dba_extents;

--------------------------------------------------------------
--o Number of users and CPU/Processors:
select * from v$license;

--------------------------------------------------------------
--o Database edition installed:

select banner from v$version where BANNER like '%Edition%';

--o Features used/not used (from 10g):

Set feedback off
Set linesize 122
Col name format a45 heading "Feature"
Col version format a10 heading "Version"
Col detected_usages format 999,990 heading "Detected|usages"
Col currently_used format a06 heading "Curr.|used?"
Col first_usage_date format a10 heading "First use"
Col last_usage_date format a10 heading "Last use"
Col nop noprint
Break on nop skip 1 on name
Select decode(detected_usages,0,2,1) nop,
 name, version, detected_usages, currently_used,
 to_char(first_usage_date,'DD/MM/YYYY') first_usage_date,
 to_char(last_usage_date,'DD/MM/YYYY') last_usage_date
from dba_feature_usage_statistics
order by nop, 1, 2
/