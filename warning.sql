column time format a19
column error format a80
select to_char(originating_timestamp, 'yyyy/mm/dd hh24:mi:ss') time, message_text "error" 
from x$dbgalertext 
where originating_timestamp > (sysdate - 1) 
  and (message_text like '%ORA-%' or 
       lower(message_text) like '%not %' or
       lower(message_text) like '%instance%')
order by originating_timestamp;