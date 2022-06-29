-- FINDEXT.SQL

-- This script lists all the extents contained in that datafile,
-- the block_id where the extent starts,
-- and how many blocks the extent contains.
-- It also shows the owner, segment name, and segment type.

-- Input: FILE_ID from DBA_DATA_FILES or FILE# from V$DATAFILE

SET ECHO OFF
SET PAGESIZ 25

column file_name format a50
select file_name, file_id from dba_data_files order by 2;

ttitle -
center 'Segment Extent Summary' skip 2

col ownr format a8 heading 'Owner' justify c
col type format a8 heading 'Type' justify c trunc
col name format a30 heading 'Segment Name' justify c
col exid format 990 heading 'Extent#' justify c
col fiid format 9990 heading 'File#' justify c
col blid format 99990 heading 'Block#' justify c
col blks format 999,990 heading 'Blocks' justify c

select owner ownr, segment_name name, segment_type type, extent_id exid, file_id fiid, block_id blid, blocks blks
from dba_extents
where file_id = &file_id
order by block_id
/