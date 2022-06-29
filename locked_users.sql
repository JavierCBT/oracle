select username, account_status
from dba_users
where account_status != 'OPEN';