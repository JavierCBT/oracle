set linesize 160
column name format a60
column space_limit format 999,999,999,999,999
column space_available format 999,999,999,999,999
column percent_full format 999
select 
name,
space_limit,
space_limit - space_used + space_reclaimable as space_available,
round((space_used - space_reclaimable)/space_limit * 100, 1) as percent_full
from v$recovery_file_dest;
select * from v$flash_recovery_area_usage;