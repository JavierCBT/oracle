set pagesize 255
select 'authentication_data: ' || sys_context('userenv', 'authentication_data') from dual
union all
select 'authentication_type: ' || sys_context('userenv', 'authentication_type') from dual
union all
select 'bg_job_id:           ' || sys_context('userenv', 'bg_job_id') from dual
union all
select 'client_info:         ' || sys_context('userenv', 'client_info') from dual
union all
select 'current_schema:      ' || sys_context('userenv', 'current_schema') from dual
union all
select 'current_schemaid:    ' || sys_context('userenv', 'current_schemaid') from dual
union all
select 'current_user:        ' || sys_context('userenv', 'current_user') from dual
union all
select 'current_userid:      ' || sys_context('userenv', 'current_userid') from dual
union all
select 'db_domain:           ' || sys_context('userenv', 'db_domain') from dual
union all
select 'db_name:             ' || sys_context('userenv', 'db_name') from dual
union all
select 'entryid:             ' || sys_context('userenv', 'entryid') from dual
union all
select 'external_name:       ' || sys_context('userenv', 'external_name') from dual
union all
select 'fg_job_id:           ' || sys_context('userenv', 'fg_job_id') from dual
union all
select 'host:                ' || sys_context('userenv', 'host') from dual
union all
select 'instance:            ' || sys_context('userenv', 'instance') from dual
union all
select 'ip_address:          ' || sys_context('userenv', 'ip_address') from dual
union all
select 'isdba:               ' || sys_context('userenv', 'isdba') from dual
union all
select 'lang:                ' || sys_context('userenv', 'lang') from dual
union all
select 'language:            ' || sys_context('userenv', 'language') from dual
union all
select 'network_protocol:    ' || sys_context('userenv', 'network_protocol') from dual
union all
select 'nls_calendar:        ' || sys_context('userenv', 'nls_calendar') from dual
union all
select 'nls_currency:        ' || sys_context('userenv', 'nls_currency') from dual
union all
select 'nls_date_format:     ' || sys_context('userenv', 'nls_date_format') from dual
union all
select 'nls_date_language:   ' || sys_context('userenv', 'nls_date_language') from dual
union all
select 'nls_sort:            ' || sys_context('userenv', 'nls_sort') from dual
union all
select 'nls_territory:       ' || sys_context('userenv', 'nls_territory') from dual
union all
select 'os_user:             ' || sys_context('userenv', 'os_user') from dual
union all
select 'proxy_user:          ' || sys_context('userenv', 'proxy_user') from dual
union all
select 'proxy_userid:        ' || sys_context('userenv', 'proxy_userid') from dual
union all
select 'session_user:        ' || sys_context('userenv', 'session_user') from dual
union all
select 'session_userid:      ' || sys_context('userenv', 'session_userid') from dual
union all
select 'sessionid:           ' || sys_context('userenv', 'sessionid') from dual
union all
select 'terminal:            ' || sys_context('userenv', 'terminal') from dual
;