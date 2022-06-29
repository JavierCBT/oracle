create or replace procedure sys.kill_session (v_sid    in  number,
                                              v_serial in  number,
                                              v_inst   in  number)
as
    v_user gv$session.username%type;
begin
    select username
      into v_user
      from gv$session
     where sid = v_sid and serial# = v_serial and inst_id = v_inst;

    dbms_output.put_line('v_user:       ' ||v_user);
    dbms_output.put_line('session_user: ' ||sys_context('userenv', 'session_user'));

    if v_user = sys_context('userenv', 'session_user') 
    then
        execute immediate   'alter system kill session '''
                         || v_sid
                         || ','
                         || v_serial
                         || ',@'
                         || v_inst
                         || ''' immediate';
    else
        raise_application_error (
            -20000,
            'cannot kill a session from another user');
    end if;
end;
/

create public synonym kill for sys.kill_session;