declare
	v_tab_exists integer;
	v_proc_exists integer;
	v_prog_exists integer;
	v_sched_exists integer;
	v_job_exists integer;

begin
	select count(*) into v_tab_exists
	from dba_tables
	where owner = 'SYS'
	  and table_name = 'ERR_LOG';
	  
	if v_tab_exists =  1
	then
		execute immediate 'drop table sys.err_log purge';
	end if;
	  
	select count(*) into v_proc_exists
	from dba_procedures
	where owner = 'SYS'
	  and procedure_name = 'PURGE_RECYCLEBIN';
	  
	if v_proc_exists = 1
	then
		execute immediate 'drop procedure sys.purge_recyclebin';
	end if;
	
	select count(*) into v_proc_exists
	from dba_procedures
	where owner = 'SYS'
	  and procedure_name = 'REC_ERROR';
	  
	if v_proc_exists = 1
	then
		execute immediate 'drop procedure sys.rec_error';
	end if;
	
	select count(*) into v_prog_exists
	from dba_scheduler_programs 
	where owner = 'SYS'
	  and program_name = 'PURGEBIN_PROG';

	if v_prog_exists = 1
	then
		dbms_scheduler.drop_program(program_name=>'PURGEBIN_PROG', force=>true);
	end if;

	select count(*) into v_sched_exists
	from dba_scheduler_schedules
	where owner = 'SYS'
	  and schedule_name = 'PURGEBIN_SCHED';

	if v_sched_exists = 1
	then
		dbms_scheduler.drop_schedule(schedule_name=>'PURGEBIN_SCHED', force=>true);
	end if;	  
	  
	select count(*) into v_job_exists
	from dba_scheduler_jobs 
	where owner = 'SYS' 
	  and job_name = 'PURGEBIN_JOB';

	if v_job_exists = 1
	then
		dbms_scheduler.drop_job(job_name=>'PURGEBIN_JOB', force=>true);
	end if;

	execute immediate (q'[
create table err_log
(
error_code      integer
,  error_message   varchar2 (4000)
,  backtrace       clob
,  callstack       clob
,  created_on      date
,  created_by      varchar2 (30)
)
]');

	execute immediate (q'[
create or replace procedure rec_error
is
pragma autonomous_transaction;
l_code   pls_integer := sqlcode;
l_mesg varchar2(32767) := sqlerrm; 
begin
insert into err_log (error_code
					,  error_message
					,  backtrace
					,  callstack
					,  created_on
					,  created_by)
	values (l_code
		  ,  l_mesg 
		  ,  sys.dbms_utility.format_error_backtrace
		  ,  sys.dbms_utility.format_call_stack
		  ,  sysdate
		  ,  user);
commit;
end;
]');		
	
	execute immediate (q'[
create or replace procedure purge_recyclebin (ndays in int)
is
cursor rb is
	select 'purge table ' ||owner|| '."' ||object_name|| '"' as sqlStmt
	  from dba_recyclebin
	 where can_purge = 'YES'
	   and type = 'TABLE'
	   and to_date(droptime, 'yyyy-mm-dd:hh24:mi:ss') < sysdate-ndays
	order by droptime;

r   rb%rowtype;
begin
for r in rb
loop
	execute immediate (r.sqlStmt);
end loop;
exception
when others
then
	rec_error();
	raise;	
end;
]');

    dbms_scheduler.create_program
	(
	  program_name         => 'SYS.PURGEBIN_PROG'
	 ,program_type         => 'STORED_PROCEDURE'
	 ,program_action       => 'SYS.PURGE_RECYCLEBIN'
	 ,number_of_arguments  => 1
	 ,enabled              => false
	 ,comments             => null
	);

	dbms_scheduler.define_program_argument
	(
	  program_name         => 'SYS.PURGEBIN_PROG'
	 ,argument_name        => 'ndays'
	 ,argument_position    => 1
	 ,argument_type        => 'INTEGER'
	 ,default_value        => '10'
	);

	dbms_scheduler.enable
	(name                  => 'SYS.PURGEBIN_PROG');

	dbms_scheduler.create_schedule
	(
	  schedule_name    => 'SYS.PURGEBIN_SCHED'
	 ,start_date       => null
	 ,repeat_interval  => 'freq=daily;byhour=22;byminute=0;bysecond=0'
	 ,end_date         => null
	 ,comments         => null
	);

	dbms_scheduler.create_job
	(
	   job_name        => 'SYS.PURGEBIN_JOB'
	  ,schedule_name   => 'SYS.PURGEBIN_SCHED'
	  ,program_name    => 'SYS.PURGEBIN_PROG'
	  ,comments        => null
	);
	dbms_scheduler.set_attribute
	( name      => 'SYS.PURGEBIN_JOB'
	 ,attribute => 'RESTARTABLE'
	 ,value     => false);
	dbms_scheduler.set_attribute_null
	( name      => 'SYS.PURGEBIN_JOB'
	 ,attribute => 'MAX_FAILURES');
	dbms_scheduler.set_attribute_null
	( name      => 'SYS.PURGEBIN_JOB'
	 ,attribute => 'MAX_RUNS');
	dbms_scheduler.set_attribute
	( name      => 'SYS.PURGEBIN_JOB'
	 ,attribute => 'STOP_ON_WINDOW_CLOSE'
	 ,value     => false);
	dbms_scheduler.set_attribute
	( name      => 'SYS.PURGEBIN_JOB'
	 ,attribute => 'JOB_PRIORITY'
	 ,value     => 3);
	dbms_scheduler.set_attribute_null
	( name      => 'SYS.PURGEBIN_JOB'
	 ,attribute => 'SCHEDULE_LIMIT');
	dbms_scheduler.set_attribute
	( name      => 'SYS.PURGEBIN_JOB'
	 ,attribute => 'AUTO_DROP'
	 ,value     => false);

	sys.dbms_scheduler.enable
	(name                  => 'SYS.PURGEBIN_JOB');
end;
/