select e.owner,l.table_name,l.segment_name
from dba_extents e, dba_lobs l
where e.owner = l.owner
and e.segment_name = l.segment_name
and e.segment_type = 'LOBSEGMENT'
and e.owner like '&SCHEMA';