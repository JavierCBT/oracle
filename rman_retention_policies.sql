-- conectando con la instancia de catálogo
select db.name, cnf.value 
from rcat.rc_database db, rcat.rc_rman_configuration cnf
where cnf.name = 'RETENTION POLICY'
  and db.DB_KEY = cnf.DB_KEY
order by 1;