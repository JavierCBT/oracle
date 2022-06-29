COLUMN name FORMAT A30
COLUMN value FORMAT A15

SELECT name, value
FROM   v$parameter
WHERE  name IN ('pga_aggregate_target', 'sga_target')
UNION
SELECT 'maximum PGA allocated' AS name, TO_CHAR(value) AS value
FROM   v$pgastat
WHERE  name = 'maximum PGA allocated';

COLUMN memory_target_GB format 999999
-- Calculate MEMORY_TARGET
SELECT (sga.value + GREATEST(pga.value, max_pga.value))/1024/1024/1024 AS memory_target_GB
FROM (SELECT TO_NUMBER(value) AS value FROM v$parameter WHERE name = 'sga_target') sga,
     (SELECT TO_NUMBER(value) AS value FROM v$parameter WHERE name = 'pga_aggregate_target') pga,
     (SELECT value FROM v$pgastat WHERE name = 'maximum PGA allocated') max_pga;