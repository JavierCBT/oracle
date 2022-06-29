select '1.- DATAFILES ' as FITXERS, sum(bytes)/1024/1024/1024 GB from dba_data_files 
union 
select '2.- TEMPFILES ' as FITXERS, sum(bytes)/1024/1024/1024 GB from dba_temp_files 
union 
select '3.- REDOLOGS  ' as FITXERS, sum(bytes*members)/1024/1024/1024 GB from v$LOG;