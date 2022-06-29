set feedback off serveroutput on size unlimited verify off termout on
set pagesize 9999
set linesize 2000
set long 2000
set trimspool on
set tab off
def _editor = "C:\Program Files (x86)\Notepad++\notepad++.exe"

set termout off
set serveroutput on size unlimited
set time on
column myp new_value myprompt noprint
column cuser new_value c_user noprint
set termout on
set heading off

whenever sqlerror continue

alter session set nls_date_format = 'dd/mm/yyyy hh24:mi:ss';
select sys_context('userenv', 'current_user') as cuser from dual;

declare
	v_os string(200);
	v_version integer;
	v_alertlog string(200);
	cursor c_info is
		select 'os:           ' ||dbms_utility.port_string info from dual
		union all
		select 'version:      ' ||banner from v$version where banner like 'Oracle%'
		union all
		select 'status:       ' ||status info from sys.v$instance
		union all
		select 'startup time: ' ||to_char (startup_time, 'dd/mm/yyyy hh24:mi') || case when sysdate - startup_time < 10 then ' <<<' end info from sys.v$instance
		union all
		select 'host name:    ' ||host_name info from v$instance
		union all
		select 'ip address:   ' ||utl_inaddr.get_host_address from dual
		union all
		select 'instance:     ' ||instance_name info from v$instance
		;
begin

	for v_info in c_info loop
		dbms_output.put_line(v_info.info);
	end loop;

	select dbms_utility.port_string into v_os from dual;
	select to_number(substr(version, 1, instr(version, '.', 1, 1)-1)) into v_version from product_component_version where product like 'Oracle%';
	if v_version >= 11 then 
		select p.value|| '/diag/rdbms/' ||lower(d.db_unique_name)|| '/' ||i.instance_name|| '/trace/alert_' ||i.instance_name|| '.log' into v_alertlog from v$database d, v$instance i, v$parameter p where p.name = 'diagnostic_dest';
	else
		select p.value|| '/alert_' ||i.instance_name|| '.log' into v_alertlog from v$parameter p, v$instance i where p.name = 'background_dump_dest';
	end if;
	if v_os like '%WIN_NT%' then
		v_alertlog := replace(v_alertlog, '/', '\');
	end if;
	dbms_output.put_line('alert log:    ' ||v_alertlog);

end;
/

set termout off

select '[&c_user@' ||sys_context('userenv', 'db_name')|| '][' ||sys_context('userenv', 'instance')|| '] SQL> ' as myp from dual;
--SELECT '[' ||user|| '@' ||upper(instance_name)|| '] SQL> ' AS myp FROM sys.v$instance;
set sqlprompt '&myprompt'

column NAME_COL_PLUS_SHOW_PARAM heading NAME format a40
column TYPE format a11
column VALUE_COL_PLUS_SHOW_PARAM heading VALUE format a100
column directory_path format a70
column directory_name format a30
column owner format a15
column host format a25
column username format a22
column db_link format a20
column name format a40
column value format a100
column tstamp format a30
column ip_address format a15
column module format a15
column os_user format a15
column proxy_user format a15
column first_change# format 999,999,999,999,999
column next_change# format 999,999,999,999,999
column member format a90
set termout on
set heading on
set feedback on
prompt

def SQLPATH=e:\oracle\scripts\tpt
@&SQLPATH/init.sql
@&SQLPATH/i.sql
set timing on