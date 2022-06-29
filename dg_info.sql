column name format a10
column version format a10

select name, version, replace(feature_info, ', ', chr(10)) feature_info
from dba_feature_usage_statistics
where name = 'Data Guard';