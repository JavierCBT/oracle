set feedback off
column value format a7
column name format a21
select inst_id, name, value from gv$parameter where name in ('db_block_checksum', 'db_block_checking', 'db_lost_write_protect');

/*

##### https://docs.oracle.com/database/121/REFRN/GUID-A0F72B65-BC1C-441B-824E-03ADCE66063A.htm#REFRN10030 #####

DB_BLOCK_CHECKSUM = { OFF | FALSE | TYPICAL | TRUE | FULL }
Default value: TYPICAL
Modifiable: ALTER SESSION, ALTER SYSTEM
Modifiable in a PDB: No

DB_BLOCK_CHECKSUM determines whether DBWn and the direct loader will calculate a checksum (a number calculated from all the bytes stored in the block) and store it in the cache header of every data block when writing it to disk. Checksums are verified when a block is read - only if this parameter is TYPICAL or FULL and the last write of the block stored a checksum. In FULL mode, Oracle also verifies the checksum before a change application from update/delete statements and recomputes it after the change is applied. In addition, Oracle gives every log block a checksum before writing it to the current log.

Most of the log block checksum is done by the generating foreground processes, while the LGWR or the LGWR slave processes (LGnn processes) perform the rest of the work, for better CPU and cache efficiency.

If this parameter is set to OFF, DBWn calculates checksums only for the SYSTEM tablespace, but not for user tablespaces. In addition, no log checksum is performed when this parameter is set to OFF.

Checksums allow Oracle to detect corruption caused by underlying disks, storage systems, or I/O systems. If set to FULL, DB_BLOCK_CHECKSUM also catches in-memory corruptions and stops them from making it to the disk. Turning on this feature in TYPICAL mode causes only an additional 1% to 2% overhead. In the FULL mode it causes 4% to 5% overhead. Oracle recommends that you set DB_BLOCK_CHECKSUM to TYPICAL.

For backward compatibility the use of TRUE (implying TYPICAL) and FALSE (implying OFF) values is preserved.


##### https://docs.oracle.com/database/121/REFRN/GUID-23700E5C-6BFC-48C2-9728-EB1F93F95DD6.htm#REFRN10029 #####

DB_BLOCK_CHECKING = { FALSE | OFF | LOW | MEDIUM | TRUE | FULL }
Default value: FALSE
Modifiable: ALTER SYSTEM
Modifiable in a PDB: Yes

DB_BLOCK_CHECKING specifies whether Oracle Database performs block checking for database blocks.

OFF or FALSE: No block checking is performed for blocks in user tablespaces. However, semantic block checking for SYSTEM tablespace blocks is always turned on.
LOW: Basic block header checks are performed after block contents change in memory (for example, after UPDATE, INSERT or DELETE statements, or after inter-instance block transfers in Oracle RAC).
MEDIUM: All LOW checks and full semantic checks are performed for all objects except indexes (whose contents can be reconstructed by a drop+rebuild on encountering a corruption).
FULL or TRUE: All LOW and MEDIUM checks and full semantic checks are performed for all objects.

Oracle checks a block by going through the data in the block, making sure it is logically self-consistent. Block checking can often prevent memory and data corruption. Block checking typically causes 1% to 10% overhead in most applications, depending on workload and the parameter value. Specific DML overhead may be higher. The more updates or inserts in a workload, the more expensive it is to turn on block checking. You should set DB_BLOCK_CHECKING to FULL if the performance overhead is acceptable.

For backward compatibility, the use of FALSE (implying OFF) and TRUE (implying FULL) is preserved.


##### https://docs.oracle.com/database/121/REFRN/GUID-52B4045A-5500-4C02-AFEB-80121659C0EE.htm#REFRN10268 #####

DB_LOST_WRITE_PROTECT = { NONE | TYPICAL | FULL }
Default value: NONE
Modifiable: ALTER SYSTEM
Modifiable in a PDB: No

In Oracle RAC instances, the parameter value is systemwide.
DB_LOST_WRITE_PROTECT enables or disables lost write detection. A data block lost write occurs when an I/O subsystem acknowledges the completion of the block write, while in fact the write did not occur in the persistent storage.

When the parameter is set to TYPICAL on the primary database, the instance logs buffer cache reads for read/write tablespaces in the redo log, which is necessary for detection of lost writes.
When the parameter is set to FULL on the primary database, the instance logs reads for read-only tablespaces and read/write tablespaces.
When the parameter is set to TYPICAL or FULL on the standby database or on the primary database during media recovery, the instance performs lost write detection.
When the parameter is set to NONE on either the primary database or the standby database, no lost write detection functionality is enabled.

*/