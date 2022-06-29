select file_name,autoextensible from dba_data_files
union
select file_name,autoextensible from dba_temp_files
group by file_name,autoextensible;

