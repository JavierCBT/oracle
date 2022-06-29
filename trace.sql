declare
	v_tracedir      varchar2(200);
	v_tracefile     varchar2(100);
	v_table_exists  integer;
	v_filename      varchar2(255) := '&1';
begin
	select count(*)
	into v_table_exists
	from dba_tables
	where owner = 'SYS'
	  and table_name = 'TRACEFILE_EXTERNAL';
	if v_table_exists = 1
	then
		execute immediate 'drop table tracefile_external purge';
	end if;
	-- get the trace dir
	select substr(v_filename, 1, instr(v_filename, '/', -1))
	into v_tracedir
	from dual;
	-- get the trace filename
	select substr(v_filename, instr(v_filename, '/', -1)+1)
	into v_tracefile
	from dual;
	-- create the directory for the bdump dir
	execute immediate 'create or replace directory trace_dir as ''' ||v_tracedir|| '''';
	-- create the external table
	execute immediate 'create table tracefile_external (text varchar2(4000)) organization external
(type oracle_loader default directory trace_dir access parameters
    (records delimited by newline nobadfile nologfile fields terminated by ''~'' missing field values are null)
    location (''' ||v_tracefile|| ''')
)
reject limit unlimited
';
end;
/
select * from tracefile_external;