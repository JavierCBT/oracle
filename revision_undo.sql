select file_name,autoextensible from dba_data_files
where file_name like ('%undo%')
group by file_name,autoextensible;

