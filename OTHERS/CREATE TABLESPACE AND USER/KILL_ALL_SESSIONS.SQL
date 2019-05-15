/*=======================================================================*/
/* 	 		   CREATED BY SAMEH NOSHI                        */
/*=======================================================================*/
BEGIN
  FOR r IN (select sid,serial# from v$session where username = 'BRIGHT')
  LOOP
    EXECUTE IMMEDIATE 'alter system kill session ''' || r.sid
      || ',' || r.serial# || '''';
  END LOOP;
END;
/
