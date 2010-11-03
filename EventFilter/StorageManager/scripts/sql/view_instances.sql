-- ---------------- subsidiary half views (basically copy of MAIN VIEW, but restricted ranges for display):
--
create or replace view view_sm_instances_part2
AS SELECT "RUN_NUMBER",
          "INSTANCE_NUMBER",
          "HOST_NAME",
          "UN_FILES",
          "NUM_FILES",
          "NUM_OPEN",
          "NUM_CLOSED",
          "NUM_INJECTED",
          "NUM_TRANSFERRED",
          "NUM_CHECKED",
          "NUM_REPACKED",
          "NUM_DELETED",
          "UN_STATUS",
          "OPEN_STATUS",
          "INJECTED_STATUS",
          "TRANSFERRED_STATUS",
          "CHECKED_STATUS",
          "REPACKED_STATUS",
          "DELETED_STATUS",
          "RANK" 
FROM (SELECT TO_CHAR( RUNNUMBER ) AS RUN_NUMBER, 
             -- no TO_CHAR, otherwise numerical sort in Page-1 doesn't work!
                       INSTANCE   AS INSTANCE_NUMBER, 
             TO_CHAR( HOSTNAME )  AS HOST_NAME,
             TO_CHAR( NVL(N_UNACCOUNT, 0)) AS UN_FILES,
             TO_CHAR( NVL(N_CREATED,   0)) AS NUM_FILES,
             TO_CHAR( NVL(N_CREATED,   0) - NVL(N_INJECTED,0)) AS NUM_OPEN,
             TO_CHAR( NVL(N_INJECTED,  0)) AS NUM_CLOSED,
             TO_CHAR( NVL(N_NEW,       0)) AS NUM_INJECTED,
             TO_CHAR( NVL(N_COPIED,    0)) AS NUM_TRANSFERRED,
             TO_CHAR( NVL(N_CHECKED,   0)) AS NUM_CHECKED,
             TO_CHAR( NVL(N_REPACKED,  0)) AS NUM_REPACKED,
             TO_CHAR( NVL(N_DELETED,   0)) AS NUM_DELETED,
            --These fields will return 1 if the field has a value differing from the preceding field (still active)
             TO_CHAR( NOTFILES_CHECK2(RUNNUMBER, LAST_WRITE_TIME, NVL(N_UNACCOUNT,0), 1.0 ) ) AS UN_STATUS,
	    (CASE 
             WHEN NVL(N_CREATED,0) - NVL(N_INJECTED,0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)< 301  THEN TO_CHAR(1)
             WHEN NVL(N_CREATED,0) - NVL(N_INJECTED,0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)> 300  THEN TO_CHAR(2)
             ELSE TO_CHAR(0)
             END) AS OPEN_STATUS,
            (CASE 
             WHEN NVL(N_INJECTED, 0) - NVL(N_NEW, 0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)< 301  THEN TO_CHAR(1)
             WHEN NVL(N_INJECTED, 0) - NVL(N_NEW, 0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)> 300  THEN TO_CHAR(2)
             WHEN NVL(N_INJECTED, 0) - NVL(N_NEW, 0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)>1200  THEN TO_CHAR(3)
             ELSE TO_CHAR(0)
             END) AS INJECTED_STATUS,
            (CASE 
             WHEN NVL(N_NEW, 0) - NVL(N_COPIED, 0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)< 301  THEN TO_CHAR(1)
             WHEN NVL(N_NEW, 0) - NVL(N_COPIED, 0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)> 300  THEN TO_CHAR(2)
             WHEN NVL(N_NEW, 0) - NVL(N_COPIED, 0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)>1200  THEN TO_CHAR(3)
             ELSE TO_CHAR(0)
             END) AS TRANSFERRED_STATUS,
            (CASE 
             WHEN NVL(N_COPIED, 0) - NVL(N_CHECKED, 0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)< 301  THEN TO_CHAR(1)
             WHEN NVL(N_COPIED, 0) - NVL(N_CHECKED, 0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)> 300  THEN TO_CHAR(2)
             WHEN NVL(N_COPIED, 0) - NVL(N_CHECKED, 0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)>1200  THEN TO_CHAR(3)
             ELSE TO_CHAR(0)
             END) AS CHECKED_STATUS,
            (CASE 
           --WHEN (NVL(N_CHECKED, 0)-NVL(N_REPACKED, 0))*(NVL(N_CHECKED, 0) - NVL(N_DELETED, 0))=0       THEN TO_CHAR(0)
             WHEN (NVL(N_CHECKED, 0)-NVL(N_REPACKED, 0))=0                                               THEN TO_CHAR(0)
             WHEN  NVL(N_CHECKED, 0)-NVL(N_REPACKED, 0)!=0  AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)>300   THEN TO_CHAR(2)
             WHEN  NVL(N_CHECKED, 0)-NVL(N_REPACKED, 0)!=0  AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)>18000 THEN TO_CHAR(3)
             ELSE TO_CHAR(1)
             END) AS REPACKED_STATUS,
            (CASE 
             WHEN (NVL(N_REPACKED, 0) - NVL(N_DELETED, 0))*(NVL(N_CHECKED, 0) - NVL(N_DELETED, 0))=0 THEN TO_CHAR(0)
             WHEN (NVL(N_REPACKED, 0) - NVL(N_DELETED, 0))*(NVL(N_CHECKED, 0) - NVL(N_DELETED, 0))!=0  AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)<29555 THEN TO_CHAR(1)
             WHEN (NVL(N_REPACKED, 0) - NVL(N_DELETED, 0))*(NVL(N_CHECKED, 0) - NVL(N_DELETED, 0))!=0  AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)>60550 THEN TO_CHAR(3)
             WHEN (NVL(N_REPACKED, 0) - NVL(N_DELETED, 0))*(NVL(N_CHECKED, 0) - NVL(N_DELETED, 0))!=0  AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)>29550 THEN TO_CHAR(2)
             ELSE TO_CHAR(1)
             END) AS DELETED_STATUS,
             TO_CHAR( run ) as RANK
FROM (SELECT RUNNUMBER, INSTANCE, HOSTNAME, N_UNACCOUNT, N_CREATED, N_INJECTED, N_NEW, N_COPIED, N_CHECKED, 
             N_INSERTED, N_REPACKED, N_DELETED, LAST_WRITE_TIME, 
             DENSE_RANK() OVER (ORDER BY RUNNUMBER DESC  NULLS LAST) run,
             DENSE_RANK() OVER (PARTITION BY RUNNUMBER ORDER BY  RUNNUMBER DESC  NULLS LAST,  INSTANCE ASC  NULLS LAST) inst_rank
FROM SM_INSTANCES WHERE RUNNUMBER>100000 )
WHERE 8*(run-1)+inst_rank> 8 and run < 50 and HOSTNAME like 'srv-C2C%'
ORDER BY 1 DESC, 2 ASC); 

grant select on view_sm_instances_part2 to public;





-- ---------------- MAIN VIEW
--Basically dumps all per-instance information for the last 10 runs (view has a row for each instance for each run)
create or replace view view_sm_instances
AS SELECT "RUN_NUMBER",
          "INSTANCE_NUMBER",
          "HOST_NAME",
          "UN_FILES",
          "NUM_FILES",
          "NUM_OPEN",
          "NUM_CLOSED",
          "NUM_INJECTED",
          "NUM_TRANSFERRED",
          "NUM_CHECKED",
          "NUM_REPACKED",
          "NUM_DELETED",
          "UN_STATUS",
          "OPEN_STATUS",
          "INJECTED_STATUS",
          "TRANSFERRED_STATUS",
          "CHECKED_STATUS",
          "REPACKED_STATUS",
          "DELETED_STATUS",
          "RANK" 
FROM (SELECT TO_CHAR( RUNNUMBER ) AS RUN_NUMBER, 
             -- no TO_CHAR, otherwise numerical sort in Page-1 doesn't work!
                       INSTANCE   AS INSTANCE_NUMBER, 
             TO_CHAR( HOSTNAME )  AS HOST_NAME,
             TO_CHAR( NVL(N_UNACCOUNT, 0)) AS UN_FILES,
             TO_CHAR( NVL(N_CREATED,   0)) AS NUM_FILES,
             TO_CHAR( NVL(N_CREATED,   0) - NVL(N_INJECTED,0)) AS NUM_OPEN,
             TO_CHAR( NVL(N_INJECTED,  0)) AS NUM_CLOSED,
             TO_CHAR( NVL(N_NEW,       0)) AS NUM_INJECTED,
             TO_CHAR( NVL(N_COPIED,    0)) AS NUM_TRANSFERRED,
             TO_CHAR( NVL(N_CHECKED,   0)) AS NUM_CHECKED,
             TO_CHAR( NVL(N_REPACKED,  0)) AS NUM_REPACKED,
             TO_CHAR( NVL(N_DELETED,   0)) AS NUM_DELETED,
            --These fields will return 1 if the field has a value differing from the preceding field (still active)
             TO_CHAR( NOTFILES_CHECK2(RUNNUMBER, LAST_WRITE_TIME, NVL(N_UNACCOUNT,0), 1.0 ) ) AS UN_STATUS,
	    (CASE 
             WHEN NVL(N_CREATED,0) - NVL(N_INJECTED,0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)< 301  THEN TO_CHAR(1)
             WHEN NVL(N_CREATED,0) - NVL(N_INJECTED,0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)> 300  THEN TO_CHAR(2)
             ELSE TO_CHAR(0)
             END) AS OPEN_STATUS,
            (CASE 
             WHEN NVL(N_INJECTED, 0) - NVL(N_NEW, 0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)< 301  THEN TO_CHAR(1)
             WHEN NVL(N_INJECTED, 0) - NVL(N_NEW, 0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)> 300  THEN TO_CHAR(2)
             WHEN NVL(N_INJECTED, 0) - NVL(N_NEW, 0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)>1200  THEN TO_CHAR(3)
             ELSE TO_CHAR(0)
             END) AS INJECTED_STATUS,
            (CASE 
             WHEN NVL(N_NEW, 0) - NVL(N_COPIED, 0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)< 301  THEN TO_CHAR(1)
             WHEN NVL(N_NEW, 0) - NVL(N_COPIED, 0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)> 300  THEN TO_CHAR(2)
             WHEN NVL(N_NEW, 0) - NVL(N_COPIED, 0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)>1200  THEN TO_CHAR(3)
             ELSE TO_CHAR(0)
             END) AS TRANSFERRED_STATUS,
            (CASE 
             WHEN NVL(N_COPIED, 0) - NVL(N_CHECKED, 0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)< 301  THEN TO_CHAR(1)
             WHEN NVL(N_COPIED, 0) - NVL(N_CHECKED, 0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)> 300  THEN TO_CHAR(2)
             WHEN NVL(N_COPIED, 0) - NVL(N_CHECKED, 0)!=0 AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)>1200  THEN TO_CHAR(3)
             ELSE TO_CHAR(0)
             END) AS CHECKED_STATUS,
            (CASE 
           --WHEN (NVL(N_CHECKED, 0)-NVL(N_REPACKED, 0))*(NVL(N_CHECKED, 0) - NVL(N_DELETED, 0))=0       THEN TO_CHAR(0)
             WHEN (NVL(N_CHECKED, 0)-NVL(N_REPACKED, 0))=0                                               THEN TO_CHAR(0)
             WHEN  NVL(N_CHECKED, 0)-NVL(N_REPACKED, 0)!=0  AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)>300   THEN TO_CHAR(2)
             WHEN  NVL(N_CHECKED, 0)-NVL(N_REPACKED, 0)!=0  AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)>18000 THEN TO_CHAR(3)
             ELSE TO_CHAR(1)
             END) AS REPACKED_STATUS,
            (CASE 
             WHEN (NVL(N_REPACKED, 0) - NVL(N_DELETED, 0))*(NVL(N_CHECKED, 0) - NVL(N_DELETED, 0))=0 THEN TO_CHAR(0)
             WHEN (NVL(N_REPACKED, 0) - NVL(N_DELETED, 0))*(NVL(N_CHECKED, 0) - NVL(N_DELETED, 0))!=0  AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)<29555 THEN TO_CHAR(1)
             WHEN (NVL(N_REPACKED, 0) - NVL(N_DELETED, 0))*(NVL(N_CHECKED, 0) - NVL(N_DELETED, 0))!=0  AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)>60550 THEN TO_CHAR(3)
             WHEN (NVL(N_REPACKED, 0) - NVL(N_DELETED, 0))*(NVL(N_CHECKED, 0) - NVL(N_DELETED, 0))!=0  AND TIME_DIFF(SYSDATE,LAST_WRITE_TIME)>29550 THEN TO_CHAR(2)
             ELSE TO_CHAR(1)
             END) AS DELETED_STATUS,
             TO_CHAR( run ) as RANK
FROM (SELECT RUNNUMBER, INSTANCE, HOSTNAME, N_UNACCOUNT, N_CREATED, N_INJECTED, N_NEW, N_COPIED, N_CHECKED, N_INSERTED, N_REPACKED, N_DELETED, LAST_WRITE_TIME, DENSE_RANK() OVER (ORDER BY RUNNUMBER DESC NULLS LAST) run
FROM SM_INSTANCES)
WHERE run <= 25 AND  HOSTNAME like 'srv-C2C%'
ORDER BY 1 DESC, 2 ASC); 

grant select on view_sm_instances to public;
