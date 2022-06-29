column hostname format a24
column ip format a15
column rac format a5
column dg format a5
column role format a7
column cpus format 999
column cores format 999
column sockets format 999
column os format a20

select
   (select host_name from v$instance)                                                           hostname,
    utl_inaddr.get_host_address                                                                 ip,
   (select instance_name info from v$instance)                                                                                                          instance,
   (select value from v$parameter where name = 'cluster_database')                                                                                      rac,
   (select * from (select currently_used from dba_feature_usage_statistics where name = 'Data Guard' order by last_sample_date desc) where rownum <= 1) dg,
   (SELECT decode(database_role, 'PHYSICAL STANDBY', 'STANDBY', database_role) FROM v$database)                                                         role,
   (select max(value) from dba_hist_osstat where stat_name = 'NUM_CPUS')                                                                                CPUs,
   (select max(value) from dba_hist_osstat where stat_name = 'NUM_CPU_CORES')                                                                           cores,
   (select max(value) from dba_hist_osstat where stat_name = 'NUM_CPU_SOCKETS')                                                                         sockets,
   (select platform_name from v$database)                                                                                                               os,
   dbms_utility.port_string                                                                                                                            os,
   (SELECT BANNER from v$version where BANNER like '%Oracle%')                                                                                          version
from dual;