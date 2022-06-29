select tablespace_name, round(used_percent) used_percent
from dba_tablespace_usage_metrics 
--where used_percent > 80
order by used_percent desc;