set serveroutput on size unlimited 
--set echo on verify on feedback on
declare
    v_dbid v$database.dbid%type;
    v_snap_id_beg dba_hist_snapshot.snap_id%type;
    v_snap_id_end dba_hist_snapshot.snap_id%type;
    v_sqlstmt varchar2(4000);
begin
    select dbid into v_dbid from v$database;
    select max(snap_id) into v_snap_id_beg
    from dba_hist_snapshot
    where begin_interval_time < &1-15/24/60;
    select max(snap_id) into v_snap_id_end
    from dba_hist_snapshot
    where begin_interval_time <= &2;
--    if v_snap_id_end is null then
--        select max(snap_id) into v_snap_id_end
--        from dba_hist_snapshot;
--    end if;
	dbms_output.put_line(chr(10));
	dbms_output.put_line('---------------------');
    for v_output in (
		with
		awr as (
			select output
			from table(sys.dbms_workload_repository.awr_report_text(v_dbid,1,v_snap_id_beg,v_snap_id_end))
			where output like 'log file sync%' or
				  output like 'log file parallel write%' or
				  output like 'user calls %'
		)
		select 'log file sync:           ' ||case
											 when regexp_substr(output, '[0-9\.\,]+[^ ]*', 1, 3) like '%us'
											 then regexp_substr(output, '[0-9\.\,]+[^ ]*', 1, 3)
											 when to_number(regexp_substr(output, '[0-9\.\,]+', 1, 3)) > 10 or
											      (regexp_substr(output, '[0-9\.\,]+cs', 1, 3) like '%cs' and to_number(regexp_substr(output, '[0-9\.\,]+', 1, 4)) > 1) or
												  (regexp_substr(output, '[0-9\.\,]+s', 1, 3) like '%s' and to_number(regexp_substr(output, '[0-9\.\,]+', 1, 4)) > 0.01)
											 then regexp_substr(output, '[0-9\.\,]+[^ ]*', 1, 3)|| '    *access to disk must be under 10ms' 
											 else regexp_substr(output, '[0-9\.\,]+[^ ]*', 1, 3)
											 end text 
		from awr 
		where output like 'log file sync%' and rownum = 1 
		union all
		--select 'log file parallel write: ' ||regexp_substr(output, '[0-9\.]+.?s') text from awr where output like 'log file parallel write%' and rownum = 1 union all
		select 'user calls per commit:   ' ||case 
											 when to_number(regexp_substr(output, '[0-9\.]+$')) < 30 
											 then regexp_substr(output, '[0-9\.]+$')|| '    *small transactions (must be over 30 user modifications per commit)' 
											 else regexp_substr(output, '[0-9\.]+$') 
											 end text 
		from awr
		where output like 'user calls%' and rownum = 1)
	loop
		dbms_output.put_line(v_output.text);
	end loop;
	dbms_output.put_line('---------------------');
end;
/