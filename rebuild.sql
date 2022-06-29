alter session set ddl_lock_timeout = 600;
alter session set workarea_size_policy = manual;
alter session set sort_area_size = 10485760;
Alter index GALOEVOLUTION.IDX_HBASTIDORES_BLOQUE nologging;
Alter index GALOEVOLUTION.IDX_HBASTIDORES_BLOQUE rebuild TABLESPACE GALOEVOLUTION_INDX STORAGE (INITIAL 200M NEXT 200M MAXEXTENTS UNLIMITED PCTINCREASE 0) parallel (degree 2) online;
Alter index GALOEVOLUTION.IDX_HBASTIDORES_BLOQUE logging;
alter session set workarea_size_policy = auto;
alter session set sort_area_size = 1048576;