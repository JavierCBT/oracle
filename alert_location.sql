--select value from v$diag_info where name = 'Diag Trace';
select p.value|| '/diag/rdbms/' ||lower(d.name)|| '/' ||i.instance_name|| '/trace/alert_' ||i.instance_name|| '.log'
from v$database d, v$instance i, v$parameter p 
where p.name = 'diagnostic_dest';