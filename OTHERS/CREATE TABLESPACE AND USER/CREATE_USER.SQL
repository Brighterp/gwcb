/*=======================================================================*/
/* 	 		   CREATED BY SAMEH NOSHI                        */
/*=======================================================================*/
CREATE USER "DEMO"  PROFILE "DEFAULT" 
    IDENTIFIED BY "DEMO" DEFAULT TABLESPACE "BRIGHT" 
    ACCOUNT UNLOCK;
GRANT "DBA" TO "DEMO";

ALTER SYSTEM SET open_cursors = 1000;

