column time format a19
column error format a100
SELECT to_char(alert_date, 'yyyy/mm/dd hh24:mi:ss') time, alert_text error
FROM alert_log
WHERE alert_date between &1 and &2	
  and (alert_text like '%ORA-%' or 
       alert_text like '%died%' or 
	   alert_text like '%failed%' or 
	   alert_text like '%unable to%' or 
	   lower(alert_text) like '%increase%' or
	   lower(alert_text) like '%deadlock%' or
	   lower(alert_text) like '%shutdown%' or
	   lower(alert_text) like '%startup%' or
	   lower(alert_text) like '%alter%')
order by row_num;