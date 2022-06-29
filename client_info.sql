set feedback off verify off

select 'OJOOOOO!! Que esto no verifica que se use más de un cliente, ya que puede usar dll con versiones antiguas (ej. SIDISPRO que tiene solamente 12.2)' from dual;

begin
	execute immediate 'create view xksusecon as select * from sys.x$ksusecon';
exception when others then
    null;
end;
/

with x as (
	select distinct ksusenum sid, ksuseclvsn, trim(to_char(ksuseclvsn,'xxxxxxxxxxxxxx')) to_c, to_char(ksuseclvsn,'xxxxxxxxxxxxxx') v
	from sys.xksusecon
)
select distinct
       username, program, machine,
       decode(to_c,'0','unknown',to_number(substr(v,8,2),'xx') || '.' ||  -- maj_rel
       substr(v,10,1)      || '.' ||  -- mnt_rel
       substr(v,11,2)      || '.' ||  -- ias_rel
       substr(v,13,1)      || '.' ||  -- ptc_set
       substr(v,14,2)) client_version  -- port_mnt
from x, v$session s
where x.sid like s.sid
  and type != 'background'
  and username not like 'SYS%';
  
select 'OJOOOOO!! Que esto no verifica que se use más de un cliente, ya que puede usar dll con versiones antiguas (ej. SIDISPRO que tiene solamente 12.2)' from dual;
