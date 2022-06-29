with 
al as (
	select thread#, sequence#, first_time, applied
	  from v$archived_log
	 where standby_dest = 'YES'
	   and resetlogs_change# = (select resetlogs_change# from v$database)
),
ad as (
	select db_unique_name db_name, dest_id
	from v$archive_dest
	where target = 'STANDBY'
	  and status != 'INACTIVE'
),
arch as (
	select thread#, sequence#
	  from (
		select thread#, sequence#, first_time, max(first_time) over (partition by thread#) max_first_time
		from al
	  )
	 where first_time = max_first_time
),
appl as (
	select thread#, sequence#
	  from (
		select thread#, sequence#, first_time, applied, max(first_time) over (partition by thread#) max_first_time
		from al
	  )
	where applied = 'YES'
	  and first_time = max_first_time
),
prim as (
	select thread#, sequence#-1 sequence#
	  from v$log
	 where status like '%CURRENT'
)
select ad.db_name,
       ad.dest_id,
       arch.thread#,
       prim.sequence#-appl.sequence#					gap_to_primary,
       arch.sequence#-appl.sequence#					gap_applied,
       prim.sequence#-arch.sequence#					gap_received,
       arch.sequence#-appl.sequence#+prim.sequence#-arch.sequence#	gap
  from arch, appl, prim, ad
 where arch.thread# = appl.thread#
   and prim.thread# = appl.thread#;
