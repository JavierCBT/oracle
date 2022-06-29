set heading off
set feedback off
set linesize 160
set pagesize 0
set verify off
undefine tablespace
select 'alter database datafile ''' ||
       ddf.file_name ||
           ''' resize ' ||
--           decode(floor((ddf.bytes+resize)/1024/1024/maxsize), 0, 10*ceil((ddf.bytes+resize)/1024/1024/10), maxsize)  ||
           floor((ddf.bytes+resize)/1024/1024)  ||
           'M;       -- actually has ' ||
           round(ddf.bytes/1024/1024) ||
           ' Mb' ||
           ' and needs ' || 10*ceil((resize)/1024/1024/10) || 'M more'
from dba_data_files ddf,
     v$datafile vdf,
         (
           select ts1,
                  decode(floor(decode(free, NULL, 0, free)/alloc/0.20), 0, (20*alloc-100*decode(free, NULL, 0, free))/80, 0) resize
           from
       (select tablespace_name ts1, sum(bytes) alloc from sys.dba_data_files group by tablespace_name),
       (select tablespace_name ts2, sum(bytes) free from sys.dba_free_space group by tablespace_name)
       where ts1 = ts2(+)
     )
--	 ,(select min(dfsiz) maxsize from (select 64000 dfsiz from dual union all select 32000 dfsiz from v$version where banner like '%Windows%'))
where ddf.tablespace_name = upper('&tablespace') and
      ddf.file_id = vdf.file# and
      ddf.tablespace_name = ts1
order by ddf.file_name asc;