alter session set nls_timestamp_format = 'dd/mm/yyyy hh24:mi:ss';

set linesize 250

column start_time format a19
column end_time format a19
column total_time format a29

with
    bck
    as
        (select recid,
                row_type,
                operation,
                status,
                to_timestamp (to_char (start_time, 'dd/mm/yyyy hh24:mi:ss'),
                              'dd/mm/yyyy hh24:mi:ss')    start_time,
                to_timestamp (to_char (end_time, 'dd/mm/yyyy hh24:mi:ss'),
                              'dd/mm/yyyy hh24:mi:ss')    end_time
           from v$rman_status)
  select recid,
         row_type,
         operation,
         status,
         start_time,
         end_time,
		 end_time - start_time total_time
--		 '+' ||
--         extract(day from (end_time - start_time))*86400|| ' ' ||
--		 extract(hour from (end_time - start_time))*3600|| ' ' ||
--		 extract(minute from (end_time - start_time))*60|| ' ' ||
--		 extract(second from (end_time - start_time)) total_time
    from bck
order by recid;