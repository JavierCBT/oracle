select username, account_status, expiry_date, profile, to_char(last_login, 'dd/mm/yyyy hh24:mi') last_login
from dba_users 
where account_status in ('EXPIRED(GRACE)', 'EXPIRED');