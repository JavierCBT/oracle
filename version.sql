
set linesize 300
col username format A22
col machine format A30
col program format A40
col host_name format A22
col open_mode format A12
col status format A12
col database_status format A16
col database_role format A16
col archiver format A10
col instance_name format a20
col GB format 99999.99

SELECT banner FROM v$version WHERE ROWNUM = 1;
select I.host_name, I.instance_name, I.version, I.startup_time , I.status, D.database_role, I.database_status, D.open_mode, I.archiver from gv$instance I, gv$database D where I.inst_id=D.inst_id;
select machine, username, program, inst_id, count(*) sesiones from gv$session where username is not null group by machine, username, program, inst_id order by 4,2,1;

select '1.- DATAFILES ' as FITXERS, sum(bytes)/1024/1024/1024 GB from dba_data_files
union
select '2.- TEMPFILES ' as FITXERS, sum(bytes)/1024/1024/1024 GB from dba_temp_files
union
select '3.- REDOLOGS  ' as FITXERS, sum(bytes*members)/1024/1024/1024 GB from v$LOG;
