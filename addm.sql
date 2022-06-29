set serveroutput on size unlimited 
--set echo on verify on feedback on
declare
	v_dbid v$database.dbid%type;
	v_date varchar2(14);
	v_snap_id_beg dba_hist_snapshot.snap_id%type;
	v_snap_id_end dba_hist_snapshot.snap_id%type;
	v_task_name varchar2(40);
	v_sqlstmt varchar2(4000);
begin
	select dbid into v_dbid from v$database;
	select to_char(sysdate, 'yyyymmddhh24miss') into v_date from dual;
	select max(snap_id) into v_snap_id_beg
	from dba_hist_snapshot
	where begin_interval_time < &1-15/24/60;
	select min(snap_id) into v_snap_id_end
	from dba_hist_snapshot
	where begin_interval_time > &2-15/24/60;
	if v_snap_id_end is null then
		select max(snap_id) into v_snap_id_end
		from dba_hist_snapshot;
	end if;
	v_task_name := v_snap_id_beg||'_'||v_snap_id_end||'_'||v_date;

	-- Create an ADDM task.
	DBMS_ADVISOR.create_task (
	advisor_name => 'ADDM',
	task_name => v_task_name,
	task_desc => 'Advisor for snapshots '||v_snap_id_beg||' to '||v_snap_id_end||'.');

	-- Set the start and end snapshots.
	DBMS_ADVISOR.set_task_parameter (
	task_name => v_task_name,
	parameter => 'START_SNAPSHOT',
	value => v_snap_id_beg);

	DBMS_ADVISOR.set_task_parameter (
	task_name => v_task_name,
	parameter => 'END_SNAPSHOT',
	value => v_snap_id_end);

	-- Execute the task.
	DBMS_ADVISOR.execute_task(task_name => v_task_name);

    for v_output in (
		select DBMS_ADVISOR.get_task_report(v_task_name) text
		from dual )
	loop
		dbms_output.put_line(v_output.text);
	end loop;
end;
/
