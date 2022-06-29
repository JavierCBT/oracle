select file_name,autoextensible from dba_temp_files
where file_name like ('%temp%')
group by file_name,autoextensible;

