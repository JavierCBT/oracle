column time format a19
column error format a100
select to_char(originating_timestamp, 'yyyy/mm/dd hh24:mi:ss') time, message_text error 
from x$dbgalertext 
where originating_timestamp between &1 and &2
  and (message_text like '%ORA-%' or 
       message_text like '%died%' or 
	   message_text like '%failed%' or 
	   message_text like '%unable to%' or 
	   lower(message_text) like '%increase%' or
	   lower(message_text) like '%deadlock%' or
	   lower(message_text) like '%shutdown%' or
	   lower(message_text) like '%startup%' or
	   lower(message_text) like '%alter%')
order by originating_timestamp;