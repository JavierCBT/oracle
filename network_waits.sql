column TOTAL_WAITS format 999,999,999
column PCT_WAITS   format 99.99
column TIME_WAITED format 999,999,999
column PCT_TIME    format 99.99
column WAIT_CLASS  format A20

/* Formatted on 01/06/2020 13:28:09 (QP5 v5.336) */
  SELECT wait_class,
         total_waits,
         ROUND (100 * (total_waits / sum_waits), 2)     pct_waits,
         time_waited,
         ROUND (100 * (time_waited / sum_time), 2)      pct_time
    FROM (SELECT wait_class, total_waits, time_waited
            FROM v$system_wait_class
           WHERE wait_class = 'Network' AND wait_class != 'Idle'),
         (SELECT SUM (total_waits) sum_waits, SUM (time_waited) sum_time
            FROM v$system_wait_class
           WHERE wait_class != 'Idle')
ORDER BY 5 DESC;