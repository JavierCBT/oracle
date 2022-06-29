column username format a50
column username heading 'Indica usuario a desbloquear:'
column account_status heading ''
select username, account_status from dba_users where account_status LIKE ('LOCKED%') or account_status like ('EXPIRED%') order by 1;
BEGIN
  FOR r IN (select name, NVL(password,(select spare4 from sys.user$ where name ='&&usuario')) as pwd from user$ where name = '&&usuario')
  LOOP
      EXECUTE IMMEDIATE 'alter user ' || r.name  || ' identified by values ''' || r.pwd || ''' account unlock';
  END LOOP;
END;
/
column username heading 'Estado actual:'
select username, account_status from dba_users where username = '&&usuario';
undefine usuario;