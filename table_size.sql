COLUMN object_name format a50
COLUMN table_name format a30
COLUMN object_type format a15
COLUMN tablespace_name format a15
SELECT * FROM (
  SELECT
    owner, object_name, object_type, table_name, ROUND(bytes)/1024/1024 AS meg,
    tablespace_name, extents, initial_extent,
    ROUND(Sum(bytes/1024/1024) OVER (PARTITION BY table_name)) AS total_table_meg
  FROM (
    -- Tables
    SELECT owner, segment_name AS object_name, 'TABLE' AS object_type,
          segment_name AS table_name, bytes,
          tablespace_name, extents, initial_extent
    FROM   dba_segments
    WHERE  segment_type IN ('TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION')
    UNION ALL
    -- Indexes
    SELECT i.owner, i.index_name AS object_name, 'INDEX' AS object_type,
          i.table_name, s.bytes,
          s.tablespace_name, s.extents, s.initial_extent
    FROM   dba_indexes i, dba_segments s
    WHERE  s.segment_name = i.index_name
    AND    s.owner = i.owner
    AND    s.segment_type IN ('INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION')
    -- LOB Segments
    UNION ALL
    SELECT l.owner, l.column_name AS object_name, 'LOB_COLUMN' AS object_type,
          l.table_name, s.bytes,
          s.tablespace_name, s.extents, s.initial_extent
    FROM   dba_lobs l, dba_segments s
    WHERE  s.segment_name = l.segment_name
    AND    s.owner = l.owner
    AND    s.segment_type = 'LOBSEGMENT'
    -- LOB Indexes
    UNION ALL
    SELECT l.owner, l.column_name AS object_name, 'LOB_INDEX' AS object_type,
          l.table_name, s.bytes,
          s.tablespace_name, s.extents, s.initial_extent
    FROM   dba_lobs l, dba_segments s
    WHERE  s.segment_name = l.index_name
    AND    s.owner = l.owner
    AND    s.segment_type = 'LOBINDEX'
  )
  WHERE owner in UPPER('&schema_name')
)
WHERE total_table_meg > 10
ORDER BY total_table_meg DESC, meg DESC
/