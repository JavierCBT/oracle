column name format a14
column value format a9
column description format a38
select name, value, isdefault, description from v$parameter where name in ('commit_wait', 'commit_logging', 'commit_write') and isdeprecated = 'FALSE';