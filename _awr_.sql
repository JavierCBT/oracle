set serveroutput on size unlimited 
--set echo on verify on feedback on
declare
	v_dbid v$database.dbid%type;
	v_instnum v$instance.instance_number%type;
	v_snap_id_beg dba_hist_snapshot.snap_id%type;
	v_snap_id_end dba_hist_snapshot.snap_id%type;
	v_sqlstmt varchar2(4000);
begin
	select dbid into v_dbid from v$database;
	select instance_number into v_instnum from v$instance;
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
	if v_snap_id_beg = v_snap_id_end then
		v_snap_id_beg := v_snap_id_end-1;
	end if;
	--dbms_output.put_line(chr(10));
	dbms_output.put_line('------------------------');
	for v_output in (
		with
		awr as (
			select output
			from table(sys.dbms_workload_repository.awr_report_text(v_dbid,v_instnum,v_snap_id_beg,v_snap_id_end))
			where output like 'log file sync%' or
				  output like 'log file parallel write%' or
				  output like 'user calls %'
		)
		select 'log file sync:           ' ||regexp_substr(output, '[0-9\.\,]+[^ ]*', 1, 3)|| '	(must be under 20ms)' text from awr where output like 'log file sync%' and rownum = 1 union all
		select 'log file parallel write: ' ||regexp_substr(output, '[0-9\.\,]+[^ ]*', 1, 4)|| '	(must be under 20ms)'  text from awr where output like 'log file parallel write%' and rownum = 1 union all
		select 'user calls per commit:   ' ||regexp_substr(output, '[0-9\.]+$')|| '	(must be over 30)' text from awr where output like 'user calls%' and rownum = 1) 
	loop
		dbms_output.put_line(v_output.text);
	end loop;
	dbms_output.put_line('------------------------');
	dbms_output.put_line(chr(10));
end;
/