SELECT a.serial# as serial,a.sid,a.username,b.type,b.ctime,lmode,a.osuser,c.sql_text  
FROM v$session a,v$lock b, v$sqlarea c 
  WHERE b.type in ('TM','TX','UL') and 
  a.sid=b.sid and 
       lmode > 0 and 
       ((a.PREV_HASH_VALUE = c.hash_value and 
       a.prev_sql_addr = c.address and 
       a.sql_hash_value = 0) or 
       (c.hash_value=a.sql_hash_value and c.address = a.sql_address));