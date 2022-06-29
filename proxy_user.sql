set echo on

drop user neutral;
drop user one_gets_in;
drop user one_wants_in;

create user neutral identified by neutral;
grant create session to neutral;

create user one_gets_in identified by gets;
grant create session to one_gets_in;


create user one_wants_in identified by wants;
alter user one_wants_in grant connect through one_gets_in;
grant create session to one_wants_in;



set heading off


connect neutral/neutral@esml
select 
     --'AUTHENTICATED_IDENTITY: '|| sys_context('USERENV','AUTHENTICATED_IDENTITY'),
       'CURRENT_SCHEMA........: '|| sys_context('USERENV','CURRENT_SCHEMA'),
       'CURRENT_SCHEMAID......: '|| sys_context('USERENV','CURRENT_SCHEMAID'),     
     --'ENTERPRISE_IDENTITY...: '|| sys_context('USERENV','ENTERPRISE_IDENTITY'),      
     --'IDENTIFICATION_TYPE...: '|| sys_context('USERENV','IDENTIFICATION_TYPE'),      
       'OS_USER...............: '|| sys_context('USERENV','OS_USER'),           
       'PROXY_USER............: '|| sys_context('USERENV','PROXY_USER'),           
       'PROXY_USERID..........: '|| sys_context('USERENV','PROXY_USERID'),           
       'SESSION_USER..........: '|| sys_context('USERENV','SESSION_USER'),           
       'SESSION_USERID........: '|| sys_context('USERENV','SESSION_USERID'),           
       'SESSIONID.............: '|| sys_context('USERENV','SESSIONID'),           
       'SID...................: '|| sys_context('USERENV','SID')
   from dual;

rem Standard connect for 'Gets'
connect one_gets_in/gets@esml
/

connect neutral/neutral@esml

rem standard connect for 'Wants'
connect one_wants_in/wants@esml
/

rem connect proxy[user]/proxy_password
rem these should not work:
rem 
rem User wants using wants password
connect one_wants_in[one_gets_in]/wants@esml
/

rem User wants using gets passworf
connect one_wants_in[one_gets_in]/gets@esml
/

rem User gets using gets password
connect one_gets_in[one_wants_in]/wants@esml
/

rem this should work
connect one_gets_in[one_wants_in]/gets@esml
/


rem and now switch the schema we a reusing
alter session set current_schema=neutral;

select 
     --'AUTHENTICATED_IDENTITY: '|| sys_context('USERENV','AUTHENTICATED_IDENTITY'),
       'CURRENT_SCHEMA........: '|| sys_context('USERENV','CURRENT_SCHEMA'),
       'CURRENT_SCHEMAID......: '|| sys_context('USERENV','CURRENT_SCHEMAID'),     
     --'ENTERPRISE_IDENTITY...: '|| sys_context('USERENV','ENTERPRISE_IDENTITY'),      
     --'IDENTIFICATION_TYPE...: '|| sys_context('USERENV','IDENTIFICATION_TYPE'),      
       'OS_USER...............: '|| sys_context('USERENV','OS_USER'),           
       'PROXY_USER............: '|| sys_context('USERENV','PROXY_USER'),           
       'PROXY_USERID..........: '|| sys_context('USERENV','PROXY_USERID'),           
       'SESSION_USER..........: '|| sys_context('USERENV','SESSION_USER'),           
       'SESSION_USERID........: '|| sys_context('USERENV','SESSION_USERID'),           
       'SESSIONID.............: '|| sys_context('USERENV','SESSIONID'),           
       'SID...................: '|| sys_context('USERENV','SID')
   from dual;