-- SHRINK_DATAFILE.SQL

-- This script lists the object names and types that must be moved in order to resize a datafile to a specified smaller size

-- Input: FILE_ID from DBA_DATA_FILES or FILE# from V$DATAFILE
-- Size in bytes that the datafile will be resized to

SET SERVEROUTPUT ON

DECLARE
     V_FILE_ID NUMBER;
     V_BLOCK_SIZE NUMBER;
     V_RESIZE_SIZE NUMBER;
BEGIN
     V_FILE_ID := &FILE_ID;
     V_RESIZE_SIZE := &RESIZE_FILE_TO;

     SELECT BLOCK_SIZE INTO V_BLOCK_SIZE FROM V$DATAFILE WHERE FILE# = V_FILE_ID;

     DBMS_OUTPUT.PUT_LINE('.');
     DBMS_OUTPUT.PUT_LINE('.');
     DBMS_OUTPUT.PUT_LINE('.');
     DBMS_OUTPUT.PUT_LINE('OBJECTS IN FILE '||V_FILE_ID||' THAT MUST MOVE IN ORDER TO RESIZE THE FILE TO '||V_RESIZE_SIZE||' BYTES');
     DBMS_OUTPUT.PUT_LINE('===================================================================');
     DBMS_OUTPUT.PUT_LINE('NON-PARTITIONED OBJECTS');
     DBMS_OUTPUT.PUT_LINE('===================================================================');

     for my_record in (
          SELECT DISTINCT(OWNER||'.'||SEGMENT_NAME||' - OBJECT TYPE = '||SEGMENT_TYPE) ONAME
          FROM DBA_EXTENTS
          WHERE (block_id + blocks-1)*V_BLOCK_SIZE > V_RESIZE_SIZE 
          AND FILE_ID = V_FILE_ID
          AND SEGMENT_TYPE NOT LIKE '%PARTITION%'
          ORDER BY 1) LOOP
               DBMS_OUTPUT.PUT_LINE(my_record.ONAME); 
     END LOOP;

     DBMS_OUTPUT.PUT_LINE('===================================================================');
     DBMS_OUTPUT.PUT_LINE('PARTITIONED OBJECTS');
     DBMS_OUTPUT.PUT_LINE('===================================================================');

     for my_record in (
          SELECT DISTINCT(OWNER||'.'||SEGMENT_NAME||' - PARTITION = '||PARTITION_NAME||' - OBJECT TYPE = '||SEGMENT_TYPE) ONAME
          FROM DBA_EXTENTS
          WHERE (block_id + blocks-1)*V_BLOCK_SIZE > V_RESIZE_SIZE
          AND FILE_ID = V_FILE_ID 
          AND SEGMENT_TYPE LIKE '%PARTITION%'
          ORDER BY 1) LOOP 
               DBMS_OUTPUT.PUT_LINE(my_record.ONAME);
     END LOOP;

END;
/