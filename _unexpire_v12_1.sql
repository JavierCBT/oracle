set pagesize 0 feedback off timing off
def days = 30
select 'Users with expiry_date between sysdate-&days and sysdate+&days:' from dual;
select '--------------------------------------------------------' from dual;
select '' from dual;
select '-- username: ' ||username||chr(10)||
       '-- account_status: ' ||account_status||chr(10)||
       '-- expiry_date: '||expiry_date||chr(10)||
       '-- profile: ' ||profile||chr(10)||
       '-- last_login: ' ||last_login||chr(10)|| 
       'alter user '||du.username|| ' identified by values ''' ||u.password|| ''';'  
from dba_users du, user$ u 
where du.expiry_date between sysdate-&days and sysdate+&days
  and u.name = du.username
order by username;