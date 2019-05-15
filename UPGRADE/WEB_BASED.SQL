begin
dbms_network_acl_admin.create_acl (
acl             => 'gmail.xml',
description     => 'Normal Access',
principal       => 'CONNECT',
is_grant        => TRUE,
privilege       => 'connect',
start_date      => null,
end_date        => null
);
end;
/
 
-- add priviliege to acl
begin
dbms_network_acl_admin.add_privilege (
acl       => 'gmail.xml',
principal    => 'HCC',
is_grant    => TRUE,
privilege    => 'connect',
start_date    => null,
end_date    => null);
end;
/
 
-- assign host, port to acl
 
begin
dbms_network_acl_admin.assign_acl (
acl => 'gmail.xml',
host => 'localhost',
lower_port => 1925,
upper_port => 1925);
end;
/
 
----------------------
 
create or replace package apex_mail_p
is
g_smtp_host      varchar2 (256)     := 'localhost';
g_smtp_port      pls_integer        := 1925;
g_smtp_domain    varchar2 (256)     := 'gmail.com';
g_mailer_id constant varchar2 (256) := 'Mailer by Oracle UTL_SMTP';
-- send mail using UTL_SMTP
procedure mail (p_sender in varchar2, p_recipient in varchar2, p_subject in varchar2, p_message in varchar2);
end;
/

create or replace package body apex_mail_p
is
-- Write a MIME header
procedure write_mime_header (
p_conn in out nocopy utl_smtp.connection
, p_name in varchar2
, p_value in varchar2
)
is
begin
utl_smtp.write_data ( p_conn, p_name || ': ' || p_value || utl_tcp.crlf);
end;
procedure mail (p_sender in varchar2
, p_recipient in varchar2
, p_subject in varchar2
, p_message in varchar2
)
is
l_conn           utl_smtp.connection;
nls_charset    varchar2(255);
begin
-- get characterset
select value
into   nls_charset
from   nls_database_parameters
where  parameter = 'NLS_CHARACTERSET';
-- establish connection and autheticate
l_conn   := utl_smtp.open_connection (g_smtp_host, g_smtp_port);
utl_smtp.ehlo(l_conn, g_smtp_domain); 
utl_smtp.command(l_conn, 'auth login');
utl_smtp.command(l_conn,utl_encode.text_encode('approval@erpbright.com', nls_charset, 1));
utl_smtp.command(l_conn, utl_encode.text_encode('QAZ123456', nls_charset, 1));
-- set from/recipient
utl_smtp.command(l_conn, 'MAIL FROM: <'||p_sender||'>');
utl_smtp.command(l_conn, 'RCPT TO: <'||p_recipient||'>');
-- write mime headers
utl_smtp.open_data (l_conn);
write_mime_header (l_conn, 'From', p_sender);
write_mime_header (l_conn, 'To', p_recipient);
write_mime_header (l_conn, 'Subject', p_subject);
write_mime_header (l_conn, 'Content-Type', 'text/plain');
write_mime_header (l_conn, 'X-Mailer', g_mailer_id);
utl_smtp.write_data (l_conn, utl_tcp.crlf);
-- write message body
utl_smtp.write_data (l_conn, p_message);
utl_smtp.close_data (l_conn);
-- end connection
utl_smtp.quit (l_conn);
exception
when others
then
begin
utl_smtp.quit(l_conn);
exception
when others then
null;
end;
raise_application_error(-20000,'Failed to send mail due to the following error: ' || sqlerrm);  
end;
end;
/
 
 



ALTER TABLE  FUNCTIONS ADD (MOBILE_ORDER VARCHAR2(25));
ALTER TABLE FUNCTIONS ADD (PRIMARY_NAME_MOBILE VARCHAR2(100));
ALTER TABLE FUNCTIONS ADD (SECONDARY_NAME_MOBILE VARCHAR2(100));
ALTER TABLE FUNCTIONS ADD (FUNCTION_ID_MOBILE NUMBER(15));
ALTER TABLE FUNCTIONS ADD(MOBILE_ICON VARCHAR2(100));

CREATE TABLE BRIGHT_MOBILE_CONFIG 
( REPORT_SERVER_IP  VARCHAR2(50),
  DB_NAME  VARCHAR2(50)
)
/


CREATE OR REPLACE FUNCTION GET_REPORT_SERVER_IP RETURN VARCHAR2 IS
CURSOR C1 IS
	SELECT REPORT_SERVER_IP
	FROM BRIGHT_MOBILE_CONFIG;
V_C1 C1%ROWTYPE;
BEGIN
	OPEN C1;
	FETCH C1 INTO V_C1;
	CLOSE C1;
	RETURN(V_C1.REPORT_SERVER_IP);
  
END;
/

CREATE OR REPLACE FUNCTION GET_DB_NAME RETURN VARCHAR2 IS
CURSOR C1 IS
	SELECT DB_NAME
	FROM BRIGHT_MOBILE_CONFIG;
V_C1 C1%ROWTYPE;
BEGIN
	OPEN C1;
	FETCH C1 INTO V_C1;
	CLOSE C1;
	RETURN(V_C1.DB_NAME);
  
END;
/

CREATE OR REPLACE FUNCTION GET_REPORT_PATH RETURN VARCHAR2 IS 
  V_PATH   VARCHAR2(200);
  BEGIN 
		  SELECT VALUE 
		  INTO V_PATH 
		  FROM SYSTEM_PATH WHERE PARAMETER_NAME='FORMS_PATH' ;
			RETURN V_PATH ;
 	EXCEPTION WHEN OTHERS THEN 
  		RETURN  NULL;
  END ; 
/








CREATE OR REPLACE FUNCTION DECR (INPUT_STR IN VARCHAR2)RETURN VARCHAR2 IS
 CRNT_CHR   VARCHAR2(2) ;                             -- CONCURRENT CHARACTER .
 REVRS_STR  VARCHAR2(2000);
 TEMPSTR    VARCHAR2(2000) := NULL;
 OUTPUT_STR VARCHAR2(2000);
 EN_KEY     NUMBER(1) := 1;
 RSLT       VARCHAR2(2000);
 INPUT      VARCHAR2(2000);
BEGIN
  INPUT := INPUT_STR;

 IF INPUT_STR IS NULL THEN
   RETURN(NULL);
 END IF;

 TEMPSTR := NULL;
 REVRS_STR := NULL;

   FOR I IN  1..LENGTH(INPUT_STR)
  LOOP
    CRNT_CHR := SUBSTR(INPUT_STR,I,1);
   TEMPSTR := TEMPSTR||CHR((ASCII(CRNT_CHR))-I);
  END LOOP;

 FOR I IN REVERSE 1..LENGTH(TEMPSTR)
 LOOP
  CRNT_CHR := SUBSTR(TEMPSTR,I,1);
  IF ASCII(CRNT_CHR) = 32 THEN CRNT_CHR := '}{'; END IF;
  REVRS_STR := REVRS_STR||CRNT_CHR;
  END LOOP;

   FOR I IN  1..LENGTH(REVRS_STR)
  LOOP
    CRNT_CHR := SUBSTR(REVRS_STR,I,1);
    IF CRNT_CHR = '{' THEN
      IF  SUBSTR(REVRS_STR,I+1,1) = '}' THEN CRNT_CHR := NULL;
      END IF;
    END IF;

    IF CRNT_CHR = '}' THEN
      IF  SUBSTR(REVRS_STR,I-1,1) = '{' THEN CRNT_CHR := ' ';
      END IF;
    END IF;

   RSLT := RSLT||CRNT_CHR;
  END LOOP;

    RSLT := SUBSTR(RSLT,1,LENGTH(RSLT));
 RETURN(RSLT);
END;
/

CREATE OR REPLACE FUNCTION GET_REPORT_URL(V_DOCUMENT_ID NUMBER, V_DEPARTMENT_ID NUMBER, V_DOCUMENT_TYPES_ID NUMBER, V_BRANCH_ID NUMBER, V_LANGUAGE_ID NUMBER, V_USER_NAME VARCHAR2, V_AND VARCHAR2)  RETURN VARCHAR2 IS
vv_connect  VARCHAR2(100); 
vv_db       VARCHAR2(100); 
vv_password VARCHAR2(100); 
vv_username VARCHAR2(100); 
VC_REP_NAME VARCHAR2(100);
URL         VARCHAR2(15000);
VN_COUNT    NUMBER(8); 
V_REPORT_CODE VARCHAR2(200);
V_REP_NAME	VARCHAR2(100);  
V_REPORT_NAME VARCHAR2(100);
BEGIN
	IF V_DOCUMENT_TYPES_ID = 28  THEN
	  V_REPORT_CODE := 'ACC_R_030_R';
	  V_REPORT_NAME := 'ACC_R_066_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   
	  URL := URL ||V_AND||'P_CHECK_VISIBLE='||1;   
	  URL := URL ||V_AND||'P_COST_CENTER_VISIBLE='||1;   
	  URL := URL ||V_AND||'P_ACTIVITY_VISIBLE='||1;   
	  URL := URL ||V_AND||'P_REFERRAL='||1;   
	
	ELSIF V_DOCUMENT_TYPES_ID = 33  THEN
	  V_REPORT_CODE := 'SAL_R_005_R';
	  V_REPORT_NAME := 'SAL_R_005_R_BRIGHT';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 108  THEN
	  V_REPORT_CODE := 'SAL_R_115_R';
	  V_REPORT_NAME := 'SAL_R_115_R_BRIGHT';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 37  THEN
	  V_REPORT_CODE := 'SAL_R_005_R';
	  V_REPORT_NAME := 'SAL_R_005_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 1  THEN
	  V_REPORT_CODE := 'SAL_R_001_R';
	  V_REPORT_NAME := 'SAL_R_001_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 6  THEN
	  V_REPORT_CODE := 'SAL_R_002_R';
	  V_REPORT_NAME := 'SAL_R_002_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 32  THEN
	  V_REPORT_CODE := 'SAL_R_002_R';
	  V_REPORT_NAME := 'SAL_R_002_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 101  THEN
	  V_REPORT_CODE := 'SAL_R_102_R';
	  V_REPORT_NAME := 'SAL_R_102_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 103  THEN
	  V_REPORT_CODE := 'SAL_R_103_R';
	  V_REPORT_NAME := 'SAL_R_103_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 102  THEN
	  V_REPORT_CODE := 'SAL_R_104_R';
	  V_REPORT_NAME := 'SAL_R_104_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 104  THEN
	  V_REPORT_CODE := 'SAL_R_101_R';
	  V_REPORT_NAME := 'SAL_R_101_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 15  THEN
	  V_REPORT_CODE := 'SAL_R_003_R';
	  V_REPORT_NAME := 'SAL_R_003_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 16  THEN
	  V_REPORT_CODE := 'SAL_R_004_R';
	  V_REPORT_NAME := 'SAL_R_004_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 224  THEN
	  V_REPORT_CODE := 'WFL_R_001_R';
	  V_REPORT_NAME := 'WFL_R_001_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 225  THEN
	  V_REPORT_CODE := 'WFL_R_002_R';
	  V_REPORT_NAME := 'WFL_R_002_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 223  THEN
	  V_REPORT_CODE := 'PUR_R_032_R';
	  V_REPORT_NAME := 'PUR_R_032_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 20  THEN
	  V_REPORT_CODE := 'PUR_R_033_R';
	  V_REPORT_NAME := 'PUR_R_033_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 22  THEN
	  V_REPORT_CODE := 'PUR_R_005_R';
	  V_REPORT_NAME := 'PUR_R_005_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 2  THEN
	  V_REPORT_CODE := 'PUR_R_004_R';
	  V_REPORT_NAME := 'PUR_R_004_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 19  THEN
	  V_REPORT_CODE := 'PUR_R_001_R';
	  V_REPORT_NAME := 'PUR_R_001_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 7  THEN
	  V_REPORT_CODE := 'PUR_R_002_R';
	  V_REPORT_NAME := 'PUR_R_002_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 21  THEN
	  V_REPORT_CODE := 'PUR_R_003_R';
	  V_REPORT_NAME := 'PUR_R_003_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 110  THEN
	  V_REPORT_CODE := 'PUR_R_107_R';
	  V_REPORT_NAME := 'PUR_R_107_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 105  THEN
	  V_REPORT_CODE := 'PUR_R_103_R';
	  V_REPORT_NAME := 'PUR_R_103_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 106  THEN
	  V_REPORT_CODE := 'PUR_R_104_R';
	  V_REPORT_NAME := 'PUR_R_104_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 107  THEN
	  V_REPORT_CODE := 'PUR_R_105_R';
	  V_REPORT_NAME := 'PUR_R_105_R_BRIGHT';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 40  THEN
	  V_REPORT_CODE := 'PUR_R_026_R';
	  V_REPORT_NAME := 'PUR_R_026_R_BRIGHT';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 41  THEN
	  V_REPORT_CODE := 'PUR_R_027_R';
	  V_REPORT_NAME := 'PUR_R_027_R_BRIGHT';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 23  THEN
	  V_REPORT_CODE := 'STK_R_023_R_SAMEH';
	  V_REPORT_NAME := 'STK_R_023_R_SAMEH';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 24  THEN
	  V_REPORT_CODE := 'STK_R_024_R_SAMEH';
	  V_REPORT_NAME := 'STK_R_024_R_SAMEH';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 3  THEN
	  V_REPORT_CODE := 'STK_R_025_R_SAMEH';
	  V_REPORT_NAME := 'STK_R_025_R_SAMEH';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 5  THEN
	  V_REPORT_CODE := 'STK_R_021_R_SAMEH';
	  V_REPORT_NAME := 'STK_R_021_R_SAMEH';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 18  THEN
	  V_REPORT_CODE := 'STK_R_026_R_SAMEH';
	  V_REPORT_NAME := 'STK_R_026_R_SAMEH';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 13  THEN
	  V_REPORT_CODE := 'STK_R_027_R_SAMEH';
	  V_REPORT_NAME := 'STK_R_027_R_SAMEH';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 111  THEN
	  V_REPORT_CODE := 'FST_R_031_R';
	  V_REPORT_NAME := 'FST_R_031_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 30  THEN
	  V_REPORT_CODE := 'CSH_R_035_R';
	  V_REPORT_NAME := 'CSH_R_035_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 211  THEN
	  V_REPORT_CODE := 'CSH_R_036_R';
	  V_REPORT_NAME := 'CSH_R_036_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 212  THEN
	  V_REPORT_CODE := 'CSH_R_037_R';
	  V_REPORT_NAME := 'CSH_R_037_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 204  THEN
	  V_REPORT_CODE := 'CSH_R_038_R';
	  V_REPORT_NAME := 'CSH_R_038_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 205  THEN
	  V_REPORT_CODE := 'CSH_R_039_R';
	  V_REPORT_NAME := 'CSH_R_039_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 31  THEN
	  V_REPORT_CODE := 'CSH_R_040_R';
	  V_REPORT_NAME := 'CSH_R_040_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 213  THEN
	  V_REPORT_CODE := 'CSH_R_041_R';
	  V_REPORT_NAME := 'CSH_R_041_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 214  THEN
	  V_REPORT_CODE := 'CSH_R_042_R';
	  V_REPORT_NAME := 'CSH_R_042_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 206  THEN
	  V_REPORT_CODE := 'CSH_R_043_R';
	  V_REPORT_NAME := 'CSH_R_043_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 207  THEN
	  V_REPORT_CODE := 'CSH_R_044_R';
	  V_REPORT_NAME := 'CSH_R_044_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 208  THEN
	  V_REPORT_CODE := 'CSH_R_045_R';
	  V_REPORT_NAME := 'CSH_R_045_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 209  THEN
	  V_REPORT_CODE := 'CSH_R_046_R';
	  V_REPORT_NAME := 'CSH_R_046_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 47  THEN
	  V_REPORT_CODE := 'CON_R_001_R';
	  V_REPORT_NAME := 'CON_R_001_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 49  THEN
	  V_REPORT_CODE := 'CON_R_001_R';
	  V_REPORT_NAME := 'CON_R_001_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 218  THEN
	  V_REPORT_CODE := 'LGR_R_013_R';
	  V_REPORT_NAME := 'LGR_R_013_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 219  THEN
	  V_REPORT_CODE := 'LGR_R_016_R';
	  V_REPORT_NAME := 'LGR_R_016_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 221  THEN
	  V_REPORT_CODE := 'LGR_R_014_R';
	  V_REPORT_NAME := 'LGR_R_014_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	ELSIF V_DOCUMENT_TYPES_ID = 222  THEN
	  V_REPORT_CODE := 'LGR_R_015_R';
	  V_REPORT_NAME := 'LGR_R_015_R';
	  V_REP_NAME := GET_REPORT_TEMPLET (V_DOCUMENT_TYPES_ID, V_BRANCH_ID, V_REPORT_NAME);
	  IF V_LANGUAGE_ID = 1 THEN
	    VC_REP_NAME := V_REP_NAME;                    
	  ELSE
	    VC_REP_NAME := V_REP_NAME||'_RT';                  
	  END IF;
	
	  URL:= GET_REPORT_SERVER_IP||':7778/reports/rwservlet?'||GET_DB_NAME||V_AND||'report='||GET_REPORT_PATH||'\'||VC_REP_NAME||	V_AND||'desformat='||'PDF'||V_AND||'paramform=NO'||V_AND||'maximize=yes';  
	
	  URL := URL ||V_AND||'P_DEPARTMENT_ID='||V_DEPARTMENT_ID;   
	  URL := URL ||V_AND||'P_DOCUMENT_ID='||V_DOCUMENT_ID;   

	END IF;

	URL := URL ||V_AND||'DESTYPE='||'CACHE';
	URL := URL ||V_AND||'REPORT_CODE='||V_REPORT_CODE;  	
	URL := URL ||V_AND||'P_BRANCH_ID=' ||V_BRANCH_ID; 
	URL := URL ||V_AND||'LANGUAGE_ID='||V_LANGUAGE_ID;    	
	URL := URL ||V_AND||'PARAMFORM='||'NO'; 
	URL := URL ||V_AND||'P_USER_NAME='||V_USER_NAME; 
	
	
	RETURN(URL);
END;
/


CREATE OR REPLACE FUNCTION GET_APPROVED_REJECT_NEXT_LEVEL(V_WORKFLOW_ID NUMBER, V_APPROVED_DISAPRROVED_FLAG NUMBER, V_USER_LEVEL NUMBER, V_USER_NAME VARCHAR2, V_ARRANGMENT_NO NUMBER) RETURN NUMBER IS
CURSOR C1 IS
	SELECT YES_ACTION, NO_ACTION
	FROM WORKFLOWS_DTL
	WHERE WORKFLOW_ID = V_WORKFLOW_ID
	AND USER_LEVEL = V_USER_LEVEL
	AND ARRANGMENT_NO = V_ARRANGMENT_NO;
V_C1 C1%ROWTYPE;
BEGIN
	OPEN C1;
	FETCH C1 INTO V_C1;
	CLOSE C1;
	IF V_APPROVED_DISAPRROVED_FLAG = 1 THEN
			IF V_C1.YES_ACTION IS NOT NULL THEN
					RETURN(V_C1.YES_ACTION);
			ELSE
					RETURN(V_USER_LEVEL + 1);
			END IF;
	ELSE
			IF V_C1.NO_ACTION IS NOT NULL THEN
					RETURN(V_C1.NO_ACTION);
			ELSE
					RETURN(0);
			END IF;
	END IF;				
   
END;
/



CREATE OR REPLACE PROCEDURE WFLOW_SUBMIT_DOC_DB(V_DOCUMENT_ID NUMBER, V_DEPARTMENT_ID NUMBER, V_DOCUMENT_TYPES_ID NUMBER, V_DOCUMENT_NO VARCHAR2, V_DOCUMENT_DATE DATE, V_BRANCH_ID NUMBER, V_WORKFLOW_ID NUMBER, V_NOTES VARCHAR2, V_USER_NAME VARCHAR2, V_LANGUAGE_ID NUMBER ) IS
V_WORKFLOWS_DOCUMENTS_ID NUMBER;
V_GLOBAL_USER_NAME 				VARCHAR2(100);
V_GLOBAL_USER_COMPUTER		VARCHAR2(100);
CURSOR C2 IS
	SELECT NVL(MAX(USER_LEVEL),0) USER_LEVEL
	FROM WORKFLOWS_DTL
	WHERE WORKFLOW_ID = V_WORKFLOW_ID
	AND (USER_NAME = V_USER_NAME OR SEND_COPY_USER_NAME = V_USER_NAME);
V_C2 C2%ROWTYPE;
CURSOR C3 IS
	SELECT NVL(MAX(USER_LEVEL),0) USER_LEVEL
	FROM WORKFLOWS_DTL
	WHERE WORKFLOW_ID = V_WORKFLOW_ID;
V_C3 C3%ROWTYPE;
V_LEVEL NUMBER;	
CURSOR C4(V_USER_LEVEL NUMBER) IS
	SELECT 
			USER_NAME ,             
			USER_LEVEL ,            
			PROCESS_DAYS,           
			SEND_COPY_USER_NAME     ,
			SEND_COPY_DAYS,
			ALL_LEVEL_APPROVED     ,
			SEND_NOTIFICATION_MAIL,
			USER_TYPE,
			YES_ACTION,
			NO_ACTION,
			ARRANGMENT_NO,
			SEND_SMS
	FROM WORKFLOWS_DTL
	WHERE WORKFLOW_ID = V_WORKFLOW_ID
	AND USER_LEVEL = V_USER_LEVEL;
V_C4 C4%ROWTYPE;
V_SYSDATE DATE;			
P_MESSAGE          VARCHAR2(2000) ;
CRLF VARCHAR2(2) :=CHR(10)||CHR(13) ;
V_FUNCTION_RETURN NUMBER;
V_REJECTED_MESSAGE VARCHAR2(500);
BEGIN
	V_GLOBAL_USER_NAME := V_USER_NAME;
	SELECT SYSDATE
	INTO V_SYSDATE
	FROM DUAL;
	OPEN C2;
	FETCH C2 INTO V_C2;
	CLOSE C2;
	OPEN C3;
	FETCH C3 INTO V_C3;
	CLOSE C3;
--	IF V_C2.USER_LEVEL = V_C3.USER_LEVEL THEN
--			raise_application_error(-20101,'USER IS TOP WORKFLOW AND WORKFLOW NOT CREATED');
--	ELSE
--			V_LEVEL := NVL(V_C2.USER_LEVEL,0) + 1;
                        V_LEVEL :=  1;
			SELECT WORKFLOWS_DOCUMENTS_SEQ.NEXTVAL
			INTO V_WORKFLOWS_DOCUMENTS_ID
			FROM DUAL;
			INSERT INTO WORKFLOWS_DOCUMENTS
					(
						WORKFLOWS_DOCUMENTS_ID,
						DOCUMENT_ID            ,
						DEPARTMENT_ID          ,
						DOCUMENT_TYPES_ID      ,
						DOCUMENT_NO            ,
						DOCUMENT_DATE          ,
						SUBMITTED_DATE          ,
						SUBMITTED_BY          ,
						WORKFLOW_ID            ,
						BRANCH_ID              ,
						DOCUMENT_STATUS        ,
						NOTES                  ,
						CREATED_BY             ,
						CREATION_DATE          ,
						CREATION_MACHINE       ,
						UPDATED_BY             ,
						UPDATED_DATE           ,
						UPDATED_MACHINE        
					)
			VALUES
					(
						V_WORKFLOWS_DOCUMENTS_ID,
						V_DOCUMENT_ID            ,
						V_DEPARTMENT_ID          ,
						V_DOCUMENT_TYPES_ID      ,
						V_DOCUMENT_NO            ,
						V_DOCUMENT_DATE          ,
						V_SYSDATE          ,
						V_GLOBAL_USER_NAME,
						V_WORKFLOW_ID  ,          
						V_BRANCH_ID        ,      
						3        ,
						V_NOTES   ,               
						V_GLOBAL_USER_NAME					,
						SYSDATE										,
						V_GLOBAL_USER_COMPUTER			,
						NULL												,
						NULL												,
						NULL
					);
			OPEN C4(V_LEVEL);
			LOOP
					FETCH C4 INTO V_C4;
					EXIT WHEN C4%NOTFOUND;
					IF V_C4.USER_TYPE = 1 THEN
							V_C4.USER_NAME := GET_USER_DELEGATION(V_C4.USER_NAME  , V_SYSDATE);
					
					ELSIF V_C4.USER_TYPE = 2 THEN
							V_C4.USER_NAME := GET_USER_DELEGATION(GET_WFLOW_DYNAMIC_USER(V_DOCUMENT_ID, V_DEPARTMENT_ID,V_DOCUMENT_TYPES_ID,V_BRANCH_ID, V_GLOBAL_USER_NAME, V_SYSDATE, V_WORKFLOW_ID, V_C4.ARRANGMENT_NO) , V_SYSDATE);
					END IF;
					
					IF V_C4.USER_NAME IS NOT NULL THEN

							INSERT INTO WORKFLOWS_DOCUMENTS_DTL
									(
										WORKFLOWS_DOCUMENTS_ID         ,
										USER_NAME                      ,
										SEND_COPY_USER_NAME						 ,
										SEND_COPY_DAYS								 ,
										USER_LEVEL                     ,
										APPROVED_DISAPRROVED_FLAG      ,
										NOTIFIED_DATE									 ,
										PROCESS_DAYS									 ,
										PROCESSED_DATE                 ,
										PROCESSED_BY                   ,
										NOTES                          ,
										USER_TYPE,
										ARRANGMENT_NO,
										USER_LEVEL_ORDER,
										CREATED_BY                     ,
										CREATION_DATE                  ,
										CREATION_MACHINE               ,
										UPDATED_BY                     ,
										UPDATED_DATE                   ,
										UPDATED_MACHINE                							
									)
							VALUES
									(
										V_WORKFLOWS_DOCUMENTS_ID         ,
										V_C4.USER_NAME                      ,
										V_C4.SEND_COPY_USER_NAME						 ,
										V_C4.SEND_COPY_DAYS								 ,
										V_C4.USER_LEVEL                     ,
										3      ,
										V_SYSDATE									 ,
										V_C4.PROCESS_DAYS									 ,
										NULL                 ,
										NULL                   ,
										NULL                          ,
										V_C4.USER_TYPE,
										V_C4.ARRANGMENT_NO,
										V_C4.USER_LEVEL,
										V_GLOBAL_USER_NAME					,
										SYSDATE										,
										V_GLOBAL_USER_COMPUTER			,
										NULL												,
										NULL												,
										NULL
									);
		
							IF V_C4.SEND_NOTIFICATION_MAIL = 1 THEN
									SEND_WFLOW_SUBMIT_EMAIL_DB(GET_DOCUMENT_TYPES_NAME(V_DOCUMENT_TYPES_ID, V_LANGUAGE_ID), V_DOCUMENT_NO , V_DOCUMENT_DATE, V_SYSDATE,  V_GLOBAL_USER_NAME, V_C4.USER_NAME, GET_USER_EMAIL(V_C4.USER_NAME));
							END IF;
		
							IF V_C4.SEND_SMS = 1 AND GET_USER_MOBILE(V_C4.USER_NAME) IS NOT NULL THEN
							   	P_MESSAGE:='Dear '||INITCAP(V_C4.USER_NAME)||' ,';
							   	P_MESSAGE:=P_MESSAGE ||CRLF;
							   	P_MESSAGE:=P_MESSAGE ||' There is ' ||LOWER(GET_DOCUMENT_TYPES_NAME(V_DOCUMENT_TYPES_ID, V_LANGUAGE_ID)) ||' document submitted by '||LOWER(V_GLOBAL_USER_NAME) ||' required your approval' ;
							 	  P_MESSAGE:=P_MESSAGE ||CHR(10);
							 	  P_MESSAGE:=P_MESSAGE || ' Document no: ' || LOWER(V_DOCUMENT_NO) || CHR(10);
							 	  P_MESSAGE:=P_MESSAGE || ' Document date: ' || LOWER(V_DOCUMENT_DATE) || CHR(10);
							 	  P_MESSAGE:=P_MESSAGE || ' Submitted date: ' || LOWER(V_SYSDATE) || CHR(10);
							 	  P_MESSAGE:=P_MESSAGE || ' Submitted by: ' || LOWER(V_GLOBAL_USER_NAME) || CHR(10);
									INSERT INTO MessageOut
										(
											MESSAGETO,
											MESSAGETEXT
										)
									VALUES
										(
											GET_USER_MOBILE(V_C4.USER_NAME),
											P_MESSAGE
										);
							END IF;

							IF V_C4.USER_TYPE = 3 THEN
									WFLOW_EXECUTE_FUNCTION(V_DOCUMENT_ID, V_DEPARTMENT_ID,V_DOCUMENT_TYPES_ID,V_BRANCH_ID, V_GLOBAL_USER_NAME, V_SYSDATE, V_WORKFLOW_ID, V_C4.ARRANGMENT_NO, V_FUNCTION_RETURN, V_REJECTED_MESSAGE);
									IF V_FUNCTION_RETURN = 1 THEN
											APPROVED_REJECT_DOC_DB(V_WORKFLOWS_DOCUMENTS_ID, 1,V_WORKFLOW_ID, V_C4.USER_LEVEL, V_C4.USER_NAME, V_REJECTED_MESSAGE,  V_DOCUMENT_ID, V_DEPARTMENT_ID, V_DOCUMENT_TYPES_ID, V_DOCUMENT_NO, V_DOCUMENT_DATE, V_SUBMITTED_BY, V_SYSDATE, V_BRANCH_ID, V_LANGUAGE_ID, V_C4.ARRANGMENT_NO) ;
									ELSE
											APPROVED_REJECT_DOC_DB(V_WORKFLOWS_DOCUMENTS_ID, 2,V_WORKFLOW_ID, V_C4.USER_LEVEL, V_C4.USER_NAME, V_REJECTED_MESSAGE,  V_DOCUMENT_ID, V_DEPARTMENT_ID, V_DOCUMENT_TYPES_ID, V_DOCUMENT_NO, V_DOCUMENT_DATE, V_SUBMITTED_BY, V_SYSDATE, V_BRANCH_ID, V_LANGUAGE_ID, V_C4.ARRANGMENT_NO) ;
									END IF;
							
							END IF;					

					END IF;
			END LOOP;
			CLOSE C4;
			COMMIT;		
--	END IF;		
END;
/







CREATE OR REPLACE PROCEDURE MAKE_EMP_VACATION_DB(V_DOCUMENT_ID NUMBER, V_DEPARTMENT_ID NUMBER) IS
V_COUNT NUMBER;
V_EMPLOYEE_VACATION_ID NUMBER;
V_SYSDATE DATE;
CURSOR C1 IS
 SELECT *
 FROM VACATION_REQUEST
 WHERE DOCUMENT_ID =V_DOCUMENT_ID
 AND DEPARTMENT_ID = V_DEPARTMENT_ID;
V_C1 C1%ROWTYPE;
BEGIN
 V_COUNT := 0;
 SELECT EMPLOYEE_VACATION_SEQ.NEXTVAL
 INTO V_EMPLOYEE_VACATION_ID
 FROM DUAL;
 SELECT SYSDATE
 INTO V_SYSDATE
 FROM DUAL;

 OPEN C1;
 FETCH C1 INTO V_C1;
 CLOSE C1;
	

 INSERT INTO EMPLOYEE_VACATION
   (
    EMPLOYEE_VACATION_ID                   ,
    VACATION_DATE                          ,
    VACATION_TYPES_ID                      ,
    EMPLOYEE_ID                            ,
    FROM_DATE                              ,
    TO_DATE                                ,
    BRANCH_ID                              ,
    APPROVED_BY                            ,
    CONFIRMED                              ,
    CANCELED                               ,
    NOTES                                  ,
    CREATED_BY                             ,
    CREATION_DATE                          ,
    CREATION_MACHINE                       ,
    UPDATED_BY                             ,
    UPDATED_DATE                           ,
    UPDATED_MACHINE                        ,
    NO_OF_VAC_DAYS                         ,
    BASE_DOCUMENT_ID                       ,
    BASE_DEPARTMENT_ID                     ,
    BASE_DOCUMENT_TYPES_ID
   )
 VALUES
   (
    V_EMPLOYEE_VACATION_ID                   ,
    V_C1.DOCUMENT_DATE                          ,
    V_C1.VACATION_TYPES_ID                      ,
    V_C1.EMPLOYEE_ID                            ,
    V_C1.FROM_DATE                              ,
    V_C1.TO_DATE                                ,
    V_C1.BRANCH_ID                              ,
    NULL                           ,
    2                              ,
    2                               ,
    V_C1.NOTES                                  ,
    V_C1.CREATED_BY,
    V_SYSDATE,
    V_C1.CREATION_MACHINE,
    NULL,
    NULL,
    NULL,
    (V_C1.TO_DATE - V_C1.FROM_DATE) + 1                         ,
    V_C1.DOCUMENT_ID                       ,
    V_C1.DEPARTMENT_ID                     ,
    V_C1.DOCUMENT_TYPES_ID
   );
END;
/

CREATE OR REPLACE PROCEDURE SEND_WFLOW_APPROVED_EMAIL_DB(V_DOCUMENT_TYPES_NAME VARCHAR2, V_DOCUMENT_NO VARCHAR2, V_DOCUMENT_DATE DATE, V_SUBMITTED_DATE DATE, V_SUBMITTED_BY VARCHAR2,V_EMAIL VARCHAR2) IS
CRLF VARCHAR2(2) :=CHR(10)||CHR(13) ;
P_MESSAGE          VARCHAR2(2000) ;
BEGIN
	IF V_EMAIL IS NOT NULL THEN

	----------Format The Message ----------------------------------------------------
	   	P_MESSAGE:='Dear '||INITCAP(V_SUBMITTED_BY)||' ,';
	   	P_MESSAGE:=P_MESSAGE ||CRLF;
	   	P_MESSAGE:=P_MESSAGE ||' Your ' ||LOWER(V_DOCUMENT_TYPES_NAME) ||' document submitted on '||LOWER(V_DOCUMENT_DATE) ||' has been approved ';
	   	P_MESSAGE:=P_MESSAGE ||CHR(10);
	 	  P_MESSAGE:=P_MESSAGE ||'----------------------------------------------';
	 	  P_MESSAGE:=P_MESSAGE ||CHR(10);
	 	  P_MESSAGE:=P_MESSAGE || ' Document type: ' || LOWER(V_DOCUMENT_TYPES_NAME) || CHR(10);
	 	  P_MESSAGE:=P_MESSAGE || ' Document no: ' || LOWER(V_DOCUMENT_NO) || CHR(10);
	 	  P_MESSAGE:=P_MESSAGE || ' Document date: ' || LOWER(V_DOCUMENT_DATE) || CHR(10);
	 	  P_MESSAGE:=P_MESSAGE || ' Submitted date: ' || LOWER(V_SUBMITTED_DATE) || CHR(10);
	
	---------Send The Mail ---------------------------------------------------------------

		 apex_mail_p.mail(	'approval@erpbright.com', 
					V_EMAIL, 
					' Your ' ||LOWER(V_DOCUMENT_TYPES_NAME) ||' document submitted on '||LOWER(V_DOCUMENT_DATE) ||' has been approved ',
			               	P_MESSAGE       
				);

	END IF;
END;
/


CREATE OR REPLACE PROCEDURE SEND_WFLOW_REJECTED_EMAIL_DB(V_DOCUMENT_TYPES_NAME VARCHAR2, V_DOCUMENT_NO VARCHAR2, V_DOCUMENT_DATE DATE, V_SUBMITTED_DATE DATE, V_SUBMITTED_BY VARCHAR2, V_REJECTED_BY VARCHAR, V_EMAIL VARCHAR2, V_REASON VARCHAR2) IS
CRLF VARCHAR2(2) :=CHR(10)||CHR(13) ;
P_MESSAGE          VARCHAR2(2000) ;
BEGIN
	IF V_EMAIL IS NOT NULL THEN

	----------Format The Message ----------------------------------------------------
	   	P_MESSAGE:='Dear '||INITCAP(V_SUBMITTED_BY)||' ,';
	   	P_MESSAGE:=P_MESSAGE ||CRLF;
	   	P_MESSAGE:=P_MESSAGE ||' Your ' ||LOWER(V_DOCUMENT_TYPES_NAME) ||' document submitted on '||LOWER(V_DOCUMENT_DATE) ||' has been rejected by ' ||INITCAP(V_REJECTED_BY);
	   	P_MESSAGE:=P_MESSAGE ||CHR(10);
	 	  P_MESSAGE:=P_MESSAGE ||'----------------------------------------------';
	 	  P_MESSAGE:=P_MESSAGE ||CHR(10);
	 	  P_MESSAGE:=P_MESSAGE || ' Document type: ' || LOWER(V_DOCUMENT_TYPES_NAME) || CHR(10);
	 	  P_MESSAGE:=P_MESSAGE || ' Document no: ' || LOWER(V_DOCUMENT_NO) || CHR(10);
	 	  P_MESSAGE:=P_MESSAGE || ' Document date: ' || LOWER(V_DOCUMENT_DATE) || CHR(10);
	 	  P_MESSAGE:=P_MESSAGE || ' Submitted date: ' || LOWER(V_SUBMITTED_DATE) || CHR(10);
	 	  P_MESSAGE:=P_MESSAGE || ' Rejected by: ' || INITCAP(V_REJECTED_BY) || CHR(10);
	 	  P_MESSAGE:=P_MESSAGE || ' Reason: ' || LOWER(V_REASON) || CHR(10);
	
	---------Send The Mail ---------------------------------------------------------------


		 apex_mail_p.mail(	'approval@erpbright.com', 
					V_EMAIL, 
					' Your ' ||LOWER(V_DOCUMENT_TYPES_NAME) ||' document submitted on '||LOWER(V_DOCUMENT_DATE) ||' has been rejected by ' ||INITCAP(V_REJECTED_BY),
			               	P_MESSAGE       
				);

	END IF;
END;
/



CREATE OR REPLACE PROCEDURE SEND_WFLOW_SUBMIT_EMAIL_DB(V_DOCUMENT_TYPES_NAME VARCHAR2, V_DOCUMENT_NO VARCHAR2, V_DOCUMENT_DATE DATE, V_SUBMITTED_DATE DATE, V_SUBMITTED_BY VARCHAR2, V_SUBMITTED_TO VARCHAR, V_EMAIL VARCHAR2) IS
CRLF VARCHAR2(2) :=CHR(10)||CHR(13) ;
P_MESSAGE          VARCHAR2(2000) ;
BEGIN
	IF V_EMAIL IS NOT NULL THEN

	----------Format The Message ----------------------------------------------------
	   	P_MESSAGE:='Dear '||INITCAP(V_SUBMITTED_TO)||' ,';
	   	P_MESSAGE:=P_MESSAGE ||CRLF;
	   	P_MESSAGE:=P_MESSAGE ||' There is ' ||LOWER(V_DOCUMENT_TYPES_NAME) ||' document submitted by '||LOWER(V_SUBMITTED_BY) ||' required your approval' ;
	   	P_MESSAGE:=P_MESSAGE ||CHR(10);
	 	  P_MESSAGE:=P_MESSAGE ||'----------------------------------------------';
	 	  P_MESSAGE:=P_MESSAGE ||CHR(10);
	 	  P_MESSAGE:=P_MESSAGE || ' Document type: ' || LOWER(V_DOCUMENT_TYPES_NAME) || CHR(10);
	 	  P_MESSAGE:=P_MESSAGE || ' Document no: ' || LOWER(V_DOCUMENT_NO) || CHR(10);
	 	  P_MESSAGE:=P_MESSAGE || ' Document date: ' || LOWER(V_DOCUMENT_DATE) || CHR(10);
	 	  P_MESSAGE:=P_MESSAGE || ' Submitted date: ' || LOWER(V_SUBMITTED_DATE) || CHR(10);
	 	  P_MESSAGE:=P_MESSAGE || ' Submitted by: ' || LOWER(V_SUBMITTED_BY) || CHR(10);
	 	
	 	  P_MESSAGE:=P_MESSAGE ||'Please logon to Bright system and approve this document';
	
	---------Send The Mail ---------------------------------------------------------------

		 apex_mail_p.mail(	'approval@erpbright.com', 
					V_EMAIL, 
					' There is ' ||LOWER(V_DOCUMENT_TYPES_NAME) ||' document submitted by '||LOWER(V_SUBMITTED_BY) ||' required your approval',
			               	P_MESSAGE       
				);

	END IF;
END;
/




CREATE OR REPLACE PROCEDURE APPROVED_REJECT_DOC_DB(V_WORKFLOWS_DOCUMENTS_ID NUMBER, V_APPROVED_DISAPRROVED_FLAG NUMBER,V_WORKFLOW_ID NUMBER, V_USER_LEVEL NUMBER, V_USER_NAME VARCHAR2, V_REASON VARCHAR2,  V_DOCUMENT_ID NUMBER, V_DEPARTMENT_ID NUMBER, V_DOCUMENT_TYPES_ID NUMBER,V_DOCUMENT_NO VARCHAR2,V_DOCUMENT_DATE DATE, V_SUBMITTED_BY VARCHAR2, V_SUBMITTED_DATE DATE,  V_BRANCH_ID NUMBER, V_LANGUAGE_ID NUMBER, V_ARRANGMENT_NO NUMBER)   IS
CURSOR C1 IS
	SELECT 
		WORKFLOWS_DOCUMENTS_ID ,
		DOCUMENT_ID            ,
		DEPARTMENT_ID          ,
		DOCUMENT_TYPES_ID      ,
		DOCUMENT_NO            ,
		DOCUMENT_DATE          ,
		SUBMITTED_DATE         ,
		SUBMITTED_BY           ,
		WORKFLOW_ID            ,
		BRANCH_ID              ,
		DOCUMENT_STATUS        ,
		NOTES                  	
	FROM WORKFLOWS_DOCUMENTS
	WHERE WORKFLOWS_DOCUMENTS_ID = V_WORKFLOWS_DOCUMENTS_ID;
V_C1 C1%ROWTYPE;

CURSOR C2 IS
	SELECT COUNT(1)
	FROM WORKFLOWS_DTL
	WHERE WORKFLOW_ID = V_WORKFLOW_ID
	AND USER_LEVEL = V_USER_LEVEL
	AND ALL_LEVEL_APPROVED = 2;

CURSOR C3 IS
	SELECT COUNT(1)
	FROM WORKFLOWS_DOCUMENTS_VIEW
	WHERE WORKFLOWS_DOCUMENTS_ID = V_WORKFLOWS_DOCUMENTS_ID
	AND USER_LEVEL = V_USER_LEVEL
	AND APPROVED_DISAPRROVED_FLAG = 3;

CURSOR C4(V_NEXT_LEVEL NUMBER) IS
	SELECT COUNT(1)
	FROM WORKFLOWS_DTL
	WHERE WORKFLOW_ID = V_WORKFLOW_ID
	AND USER_LEVEL = V_NEXT_LEVEL;
	
V_COUNT NUMBER;

CURSOR C5(V_WORKFLOW_ID NUMBER, V_USER_LEVEL NUMBER) IS
	SELECT 
			USER_NAME ,             
			USER_LEVEL ,            
			PROCESS_DAYS,           
			SEND_COPY_USER_NAME     ,
			SEND_COPY_DAYS,
			ALL_LEVEL_APPROVED,
			SEND_NOTIFICATION_MAIL,
			SEND_SMS,
			USER_TYPE,
			ARRANGMENT_NO     
	FROM WORKFLOWS_DTL
	WHERE WORKFLOW_ID = V_WORKFLOW_ID
	AND USER_LEVEL = V_USER_LEVEL;
V_C5 C5%ROWTYPE;

CURSOR C6 IS
	SELECT NVL(MAX(USER_LEVEL_ORDER) +1,1)  USER_LEVEL_ORDER
	FROM WORKFLOWS_DOCUMENTS_DTL
	WHERE WORKFLOWS_DOCUMENTS_ID = V_WORKFLOWS_DOCUMENTS_ID;
V_C6 C6%ROWTYPE;


V_GLOBAL_USER_NAME 				VARCHAR2(100);
V_GLOBAL_USER_COMPUTER		VARCHAR2(100);

V_SYSDATE DATE;		
P_MESSAGE          VARCHAR2(2000) ;
CRLF VARCHAR2(2) :=CHR(10)||CHR(13) ;
V_MESSAGETO VARCHAR2(100);
V_CONFIRMED NUMBER;



CURSOR C90(V_DOCUMENT_ID NUMBER, V_DEPARTMENT_ID NUMBER) IS
SELECT 
		DOCUMENT_ID            ,
		DEPARTMENT_ID          ,
		DOCUMENT_TYPES_ID      ,
		DOCUMENT_NO            ,
		DOCUMENT_DATE          ,
		BRANCH_ID              ,
		EMPLOYEE_ID            ,
		VACATION_TYPES_ID      ,
		FROM_DATE              ,
		TO_DATE                ,
		WORKFLOW_SUBMITTED     ,
		CONFIRMED              ,
		CANCELED               ,
		FINANCIAL_YEARS_ID     ,
		NOTES                  ,
		CREATED_BY             ,
		CREATION_DATE          ,
		CREATION_MACHINE       ,
		UPDATED_BY             ,
		UPDATED_DATE           ,
		UPDATED_MACHINE        ,
		VACATION_ID            ,
		VAC_FROM_OT_DAYS       ,
		HAJJ_VAC_FLAG          
FROM VACATION_REQUEST
WHERE DOCUMENT_ID = V_DOCUMENT_ID
AND DEPARTMENT_ID = V_DEPARTMENT_ID;
V_C90 C90%ROWTYPE;
V_FUNCTION_RETURN NUMBER;
V_REJECTED_MESSAGE VARCHAR2(500);
V_NEXT_LEVEL NUMBER;
BEGIN
	SELECT SYSDATE
	INTO V_SYSDATE
	FROM DUAL;
	
	V_GLOBAL_USER_NAME := V_USER_NAME;
	V_GLOBAL_USER_COMPUTER := 'MOBILE';

	OPEN C1;
	FETCH C1 INTO V_C1;
	CLOSE C1;

	IF V_APPROVED_DISAPRROVED_FLAG = 1 THEN

			UPDATE WORKFLOWS_DOCUMENTS_DTL
			SET APPROVED_DISAPRROVED_FLAG = 1,
					PROCESSED_DATE = SYSDATE,
					PROCESSED_BY = V_GLOBAL_USER_NAME,
					NOTES = V_REASON
			WHERE WORKFLOWS_DOCUMENTS_ID = V_WORKFLOWS_DOCUMENTS_ID
			AND USER_NAME = V_USER_NAME
			AND USER_LEVEL = V_USER_LEVEL;
			
			V_COUNT := 0;
			OPEN C2;
			FETCH C2 INTO V_COUNT;
			CLOSE C2; 
			
			IF V_COUNT > 0 THEN

					UPDATE WORKFLOWS_DOCUMENTS_DTL
					SET APPROVED_DISAPRROVED_FLAG = 1,
							PROCESSED_DATE = SYSDATE,
							PROCESSED_BY = V_GLOBAL_USER_NAME
					WHERE WORKFLOWS_DOCUMENTS_ID = V_WORKFLOWS_DOCUMENTS_ID
					AND USER_LEVEL = V_USER_LEVEL;
			END IF;		

			V_COUNT := 0;
			OPEN C3;
			FETCH C3 INTO V_COUNT;
			CLOSE C3; 
		
			
			
			IF V_COUNT = 0 THEN

					V_NEXT_LEVEL := GET_APPROVED_REJECT_NEXT_LEVEL(V_WORKFLOW_ID, V_APPROVED_DISAPRROVED_FLAG, V_USER_LEVEL, V_USER_NAME, V_ARRANGMENT_NO);		
					IF V_NEXT_LEVEL <> 0 THEN
							V_COUNT := 0;

							OPEN C4(V_NEXT_LEVEL);
							FETCH C4 INTO V_COUNT;
							CLOSE C4; 
											
							IF V_COUNT > 0 THEN
									OPEN C6;
									FETCH C6 INTO V_C6;
									CLOSE C6;
							
									OPEN C5(V_C1.WORKFLOW_ID, V_NEXT_LEVEL);
									LOOP
											FETCH C5 INTO V_C5;
											EXIT WHEN C5%NOTFOUND;
							
							
											IF V_C5.USER_TYPE = 1 THEN
													V_C5.USER_NAME := GET_USER_DELEGATION(V_C5.USER_NAME  , V_SYSDATE);
											
											ELSIF V_C5.USER_TYPE = 2 THEN
													V_C5.USER_NAME := GET_USER_DELEGATION(GET_WFLOW_DYNAMIC_USER(V_DOCUMENT_ID, V_DEPARTMENT_ID,V_DOCUMENT_TYPES_ID,V_BRANCH_ID, V_GLOBAL_USER_NAME, V_SYSDATE, V_WORKFLOW_ID, V_C5.ARRANGMENT_NO)  , V_SYSDATE);
											END IF;
		
											
											IF V_C5.USER_NAME IS NOT NULL THEN
										
													INSERT INTO WORKFLOWS_DOCUMENTS_DTL
															(
																WORKFLOWS_DOCUMENTS_ID         ,
																USER_NAME                      ,
																SEND_COPY_USER_NAME						 ,
																SEND_COPY_DAYS								 ,
																USER_LEVEL                     ,
																APPROVED_DISAPRROVED_FLAG      ,
																NOTIFIED_DATE,
																PROCESS_DAYS,
																PROCESSED_DATE                 ,
																PROCESSED_BY                   ,
																NOTES                          ,
																USER_TYPE,
																ARRANGMENT_NO,
																USER_LEVEL_ORDER,
																CREATED_BY                     ,
																CREATION_DATE                  ,
																CREATION_MACHINE               ,
																UPDATED_BY                     ,
																UPDATED_DATE                   ,
																UPDATED_MACHINE                							
															)
													VALUES
															(
																V_WORKFLOWS_DOCUMENTS_ID         ,
																V_C5.USER_NAME                      ,
																V_C5.SEND_COPY_USER_NAME						 ,
																V_C5.SEND_COPY_DAYS								 ,
																V_C5.USER_LEVEL                     ,
																3      ,
																V_SYSDATE,
																V_C5.PROCESS_DAYS,
																NULL                 ,
																NULL                   ,
																NULL                          ,
																V_C5.USER_TYPE,
																V_C5.ARRANGMENT_NO,
																V_C6.USER_LEVEL_ORDER,
																V_GLOBAL_USER_NAME					,
																SYSDATE										,
																V_GLOBAL_USER_COMPUTER			,
																NULL												,
																NULL												,
																NULL
															);
				
			
													IF V_C5.SEND_NOTIFICATION_MAIL = 1 THEN
															SEND_WFLOW_SUBMIT_EMAIL_DB(GET_DOCUMENT_TYPES_NAME(V_DOCUMENT_TYPES_ID, V_LANGUAGE_ID), V_DOCUMENT_NO , V_DOCUMENT_DATE, V_SYSDATE,  V_SUBMITTED_BY, V_C5.USER_NAME, GET_USER_EMAIL(V_C5.USER_NAME));
															NULL;
													END IF;
			
				
													IF V_C5.SEND_SMS = 1 AND GET_USER_MOBILE(V_C5.USER_NAME) IS NOT NULL THEN
												   	
													   	P_MESSAGE:='Dear '||INITCAP(V_C5.USER_NAME)||' ,';
													   	P_MESSAGE:=P_MESSAGE ||CRLF;
													   	P_MESSAGE:=P_MESSAGE ||' There is ' ||LOWER(GET_DOCUMENT_TYPES_NAME(V_DOCUMENT_TYPES_ID, V_LANGUAGE_ID)) ||' document submitted by '||LOWER(V_SUBMITTED_BY) ||' required your approval' ;
													 	  P_MESSAGE:=P_MESSAGE ||CHR(10);
													 	  P_MESSAGE:=P_MESSAGE || ' Document no: ' || LOWER(V_DOCUMENT_NO) || CHR(10);
													 	  P_MESSAGE:=P_MESSAGE || ' Document date: ' || LOWER(V_DOCUMENT_DATE) || CHR(10);
													 	  P_MESSAGE:=P_MESSAGE || ' Submitted date: ' || LOWER(V_SYSDATE) || CHR(10);
										 	
															INSERT INTO MessageOut
																(
																	MESSAGETO,
																	MESSAGETEXT
																)
															VALUES
																(
																	GET_USER_MOBILE(V_C5.USER_NAME),
																	P_MESSAGE
																);
													END IF;
		
													IF V_C5.USER_TYPE = 3 THEN
															WFLOW_EXECUTE_FUNCTION(V_DOCUMENT_ID, V_DEPARTMENT_ID,V_DOCUMENT_TYPES_ID,V_BRANCH_ID, V_GLOBAL_USER_NAME, V_SYSDATE, V_WORKFLOW_ID, V_C5.ARRANGMENT_NO, V_FUNCTION_RETURN, V_REJECTED_MESSAGE);
															IF V_FUNCTION_RETURN = 1 THEN
																	APPROVED_REJECT_DOC_DB(V_WORKFLOWS_DOCUMENTS_ID, 1,V_WORKFLOW_ID, V_C5.USER_LEVEL, V_C5.USER_NAME, V_REJECTED_MESSAGE,  V_DOCUMENT_ID, V_DEPARTMENT_ID, V_DOCUMENT_TYPES_ID, V_DOCUMENT_NO, V_DOCUMENT_DATE, V_SUBMITTED_BY, V_SYSDATE, V_BRANCH_ID, V_LANGUAGE_ID, V_C5.ARRANGMENT_NO) ;
															ELSE
																	APPROVED_REJECT_DOC_DB(V_WORKFLOWS_DOCUMENTS_ID, 2,V_WORKFLOW_ID, V_C5.USER_LEVEL, V_C5.USER_NAME, V_REJECTED_MESSAGE,  V_DOCUMENT_ID, V_DEPARTMENT_ID, V_DOCUMENT_TYPES_ID, V_DOCUMENT_NO, V_DOCUMENT_DATE, V_SUBMITTED_BY, V_SYSDATE, V_BRANCH_ID, V_LANGUAGE_ID, V_C5.ARRANGMENT_NO) ;
															END IF;
													END IF;					
		
											END IF;
									END LOOP;
									CLOSE C5;							
						
							ELSE
									UPDATE WORKFLOWS_DOCUMENTS
									SET DOCUMENT_STATUS = 1
									WHERE WORKFLOWS_DOCUMENTS_ID = V_WORKFLOWS_DOCUMENTS_ID;
									
		
									IF V_DOCUMENT_TYPES_ID = 224 THEN
											OPEN C90(V_C1.DOCUMENT_ID, V_C1.DEPARTMENT_ID);
											FETCH C90 INTO V_C90;
											CLOSE C90;
		
		
		
											CONFIRM_VAC_REQ_DOCUMENT (V_BRANCH_ID , 
														  V_C90.DOCUMENT_ID   ,
														  V_C90.DEPARTMENT_ID   ,
														  V_C90.DOCUMENT_TYPES_ID   ,
														  V_CONFIRMED    ,
														  V_LANGUAGE_ID   ,
														  V_USER_NAME,
														  'MOBILE')  ;
											UPDATE VACATION_REQUEST 
											SET CONFIRMED = 1
											WHERE  DOCUMENT_ID = V_C1.DOCUMENT_ID
											AND DEPARTMENT_ID = V_C1.DEPARTMENT_ID;
		
									END IF;
		
									SEND_WFLOW_APPROVED_EMAIL_DB(GET_DOCUMENT_TYPES_NAME(V_DOCUMENT_TYPES_ID, V_LANGUAGE_ID), V_DOCUMENT_NO , V_DOCUMENT_DATE, V_SYSDATE, V_SUBMITTED_BY, GET_USER_EMAIL(V_SUBMITTED_BY));
									NULL;
		
									IF GET_USER_SEND_SMS(V_SUBMITTED_BY) = 1 AND 	GET_USER_MOBILE(V_SUBMITTED_BY) IS NOT NULL THEN
									   	P_MESSAGE:='Dear '||INITCAP(V_SUBMITTED_BY)||' ,';
									   	P_MESSAGE:=P_MESSAGE ||CRLF;
									   	P_MESSAGE:=P_MESSAGE ||' Your ' ||LOWER(GET_DOCUMENT_TYPES_NAME(V_DOCUMENT_TYPES_ID, V_LANGUAGE_ID)) ||' document submitted on '||LOWER(V_DOCUMENT_DATE) ||' has been approved ';
									   	P_MESSAGE:=P_MESSAGE ||CHR(10);
									 	  P_MESSAGE:=P_MESSAGE || ' Document no: ' || LOWER(V_DOCUMENT_NO) || CHR(10);
									 	  P_MESSAGE:=P_MESSAGE || ' Document date: ' || LOWER(V_DOCUMENT_DATE) || CHR(10);
									 	  P_MESSAGE:=P_MESSAGE || ' Submitted date: ' || LOWER(V_SUBMITTED_DATE) || CHR(10);
									 		V_MESSAGETO := GET_USER_MOBILE(V_SUBMITTED_BY);
		
											INSERT INTO MessageOut
												(
													MESSAGETO,
													MESSAGETEXT
												)
											VALUES
												(
													V_MESSAGETO,
													P_MESSAGE
												);
									END IF;
							
							END IF;					
						
					ELSE
							UPDATE WORKFLOWS_DOCUMENTS
							SET DOCUMENT_STATUS = 1
							WHERE WORKFLOWS_DOCUMENTS_ID = V_WORKFLOWS_DOCUMENTS_ID;
							

							IF V_DOCUMENT_TYPES_ID = 224 THEN
									OPEN C90(V_C1.DOCUMENT_ID, V_C1.DEPARTMENT_ID);
									FETCH C90 INTO V_C90;
									CLOSE C90;



									CONFIRM_VAC_REQ_DOCUMENT (V_BRANCH_ID , 
												  V_C90.DOCUMENT_ID   ,
												  V_C90.DEPARTMENT_ID   ,
												  V_C90.DOCUMENT_TYPES_ID   ,
												  V_CONFIRMED    ,
												  V_LANGUAGE_ID   ,
												  V_USER_NAME,
												  'MOBILE')  ;
									UPDATE VACATION_REQUEST 
									SET CONFIRMED = 1
									WHERE  DOCUMENT_ID = V_C1.DOCUMENT_ID
									AND DEPARTMENT_ID = V_C1.DEPARTMENT_ID;

							END IF;

							SEND_WFLOW_APPROVED_EMAIL_DB(GET_DOCUMENT_TYPES_NAME(V_DOCUMENT_TYPES_ID, V_LANGUAGE_ID), V_DOCUMENT_NO , V_DOCUMENT_DATE, V_SYSDATE, V_SUBMITTED_BY, GET_USER_EMAIL(V_SUBMITTED_BY));
							NULL;

							IF GET_USER_SEND_SMS(V_SUBMITTED_BY) = 1 AND 	GET_USER_MOBILE(V_SUBMITTED_BY) IS NOT NULL THEN
							   	P_MESSAGE:='Dear '||INITCAP(V_SUBMITTED_BY)||' ,';
							   	P_MESSAGE:=P_MESSAGE ||CRLF;
							   	P_MESSAGE:=P_MESSAGE ||' Your ' ||LOWER(GET_DOCUMENT_TYPES_NAME(V_DOCUMENT_TYPES_ID, V_LANGUAGE_ID)) ||' document submitted on '||LOWER(V_DOCUMENT_DATE) ||' has been approved ';
							   	P_MESSAGE:=P_MESSAGE ||CHR(10);
							 	  P_MESSAGE:=P_MESSAGE || ' Document no: ' || LOWER(V_DOCUMENT_NO) || CHR(10);
							 	  P_MESSAGE:=P_MESSAGE || ' Document date: ' || LOWER(V_DOCUMENT_DATE) || CHR(10);
							 	  P_MESSAGE:=P_MESSAGE || ' Submitted date: ' || LOWER(V_SUBMITTED_DATE) || CHR(10);
							 		V_MESSAGETO := GET_USER_MOBILE(V_SUBMITTED_BY);

									INSERT INTO MessageOut
										(
											MESSAGETO,
											MESSAGETEXT
										)
									VALUES
										(
											V_MESSAGETO,
											P_MESSAGE
										);
							END IF;
							
					END IF;					
			END IF;
	ELSE
			UPDATE WORKFLOWS_DOCUMENTS_DTL
			SET APPROVED_DISAPRROVED_FLAG = 2,
					PROCESSED_DATE = SYSDATE,
					PROCESSED_BY = V_GLOBAL_USER_NAME,
					NOTES = V_REASON
			WHERE WORKFLOWS_DOCUMENTS_ID = V_WORKFLOWS_DOCUMENTS_ID
			AND USER_NAME = V_USER_NAME;

			DELETE FROM WORKFLOWS_DOCUMENTS_DTL
			WHERE APPROVED_DISAPRROVED_FLAG = 3
			AND WORKFLOWS_DOCUMENTS_ID = V_WORKFLOWS_DOCUMENTS_ID;
			
			V_NEXT_LEVEL := GET_APPROVED_REJECT_NEXT_LEVEL(V_WORKFLOW_ID, V_APPROVED_DISAPRROVED_FLAG, V_USER_LEVEL, V_USER_NAME, V_ARRANGMENT_NO);		

	
			IF V_NEXT_LEVEL <> 0 THEN
				V_COUNT := 0;

				OPEN C4(V_NEXT_LEVEL);
				FETCH C4 INTO V_COUNT;
				CLOSE C4; 
								
				IF V_COUNT > 0 THEN
						OPEN C6;
						FETCH C6 INTO V_C6;
						CLOSE C6;
				
						OPEN C5(V_C1.WORKFLOW_ID, V_NEXT_LEVEL);
						LOOP
								FETCH C5 INTO V_C5;
								EXIT WHEN C5%NOTFOUND;
				
				
								IF V_C5.USER_TYPE = 1 THEN
										V_C5.USER_NAME := GET_USER_DELEGATION(V_C5.USER_NAME  , V_SYSDATE);
								
								ELSIF V_C5.USER_TYPE = 2 THEN
										V_C5.USER_NAME := GET_USER_DELEGATION(GET_WFLOW_DYNAMIC_USER(V_DOCUMENT_ID, V_DEPARTMENT_ID,V_DOCUMENT_TYPES_ID,V_BRANCH_ID, V_GLOBAL_USER_NAME, V_SYSDATE, V_WORKFLOW_ID, V_C5.ARRANGMENT_NO)  , V_SYSDATE);
								END IF;

								
								IF V_C5.USER_NAME IS NOT NULL THEN
							
										INSERT INTO WORKFLOWS_DOCUMENTS_DTL
												(
													WORKFLOWS_DOCUMENTS_ID         ,
													USER_NAME                      ,
													SEND_COPY_USER_NAME						 ,
													SEND_COPY_DAYS								 ,
													USER_LEVEL                     ,
													APPROVED_DISAPRROVED_FLAG      ,
													NOTIFIED_DATE,
													PROCESS_DAYS,
													PROCESSED_DATE                 ,
													PROCESSED_BY                   ,
													NOTES                          ,
													USER_TYPE,
													ARRANGMENT_NO,
													USER_LEVEL_ORDER,
													CREATED_BY                     ,
													CREATION_DATE                  ,
													CREATION_MACHINE               ,
													UPDATED_BY                     ,
													UPDATED_DATE                   ,
													UPDATED_MACHINE                							
												)
										VALUES
												(
													V_WORKFLOWS_DOCUMENTS_ID         ,
													V_C5.USER_NAME                      ,
													V_C5.SEND_COPY_USER_NAME						 ,
													V_C5.SEND_COPY_DAYS								 ,
													V_C5.USER_LEVEL                     ,
													3      ,
													V_SYSDATE,
													V_C5.PROCESS_DAYS,
													NULL                 ,
													NULL                   ,
													NULL                          ,
													V_C5.USER_TYPE,
													V_C5.ARRANGMENT_NO,
													V_C6.USER_LEVEL_ORDER,
													V_GLOBAL_USER_NAME					,
													SYSDATE										,
													V_GLOBAL_USER_COMPUTER			,
													NULL												,
													NULL												,
													NULL
												);
	

										IF V_C5.SEND_NOTIFICATION_MAIL = 1 THEN
												SEND_WFLOW_SUBMIT_EMAIL_DB(GET_DOCUMENT_TYPES_NAME(V_DOCUMENT_TYPES_ID, V_LANGUAGE_ID), V_DOCUMENT_NO , V_DOCUMENT_DATE, V_SYSDATE,  V_SUBMITTED_BY, V_C5.USER_NAME, GET_USER_EMAIL(V_C5.USER_NAME));
												NULL;
										END IF;

	
										IF V_C5.SEND_SMS = 1 AND GET_USER_MOBILE(V_C5.USER_NAME) IS NOT NULL THEN
									   	
										   	P_MESSAGE:='Dear '||INITCAP(V_C5.USER_NAME)||' ,';
										   	P_MESSAGE:=P_MESSAGE ||CRLF;
										   	P_MESSAGE:=P_MESSAGE ||' There is ' ||LOWER(GET_DOCUMENT_TYPES_NAME(V_DOCUMENT_TYPES_ID, V_LANGUAGE_ID)) ||' document submitted by '||LOWER(V_SUBMITTED_BY) ||' required your approval' ;
										 	  P_MESSAGE:=P_MESSAGE ||CHR(10);
										 	  P_MESSAGE:=P_MESSAGE || ' Document no: ' || LOWER(V_DOCUMENT_NO) || CHR(10);
										 	  P_MESSAGE:=P_MESSAGE || ' Document date: ' || LOWER(V_DOCUMENT_DATE) || CHR(10);
										 	  P_MESSAGE:=P_MESSAGE || ' Submitted date: ' || LOWER(V_SYSDATE) || CHR(10);
							 	
												INSERT INTO MessageOut
													(
														MESSAGETO,
														MESSAGETEXT
													)
												VALUES
													(
														GET_USER_MOBILE(V_C5.USER_NAME),
														P_MESSAGE
													);
										END IF;

										IF V_C5.USER_TYPE = 3 THEN
												WFLOW_EXECUTE_FUNCTION(V_DOCUMENT_ID, V_DEPARTMENT_ID,V_DOCUMENT_TYPES_ID,V_BRANCH_ID, V_GLOBAL_USER_NAME, V_SYSDATE, V_WORKFLOW_ID, V_C5.ARRANGMENT_NO, V_FUNCTION_RETURN, V_REJECTED_MESSAGE);
												IF V_FUNCTION_RETURN = 1 THEN
														APPROVED_REJECT_DOC_DB(V_WORKFLOWS_DOCUMENTS_ID, 1,V_WORKFLOW_ID, V_C5.USER_LEVEL, V_C5.USER_NAME, V_REJECTED_MESSAGE,  V_DOCUMENT_ID, V_DEPARTMENT_ID, V_DOCUMENT_TYPES_ID, V_DOCUMENT_NO, V_DOCUMENT_DATE, V_SUBMITTED_BY, V_SYSDATE, V_BRANCH_ID, V_LANGUAGE_ID, V_C5.ARRANGMENT_NO) ;
												ELSE
														APPROVED_REJECT_DOC_DB(V_WORKFLOWS_DOCUMENTS_ID, 2,V_WORKFLOW_ID, V_C5.USER_LEVEL, V_C5.USER_NAME, V_REJECTED_MESSAGE,  V_DOCUMENT_ID, V_DEPARTMENT_ID, V_DOCUMENT_TYPES_ID, V_DOCUMENT_NO, V_DOCUMENT_DATE, V_SUBMITTED_BY, V_SYSDATE, V_BRANCH_ID, V_LANGUAGE_ID, V_C5.ARRANGMENT_NO) ;
												END IF;
										END IF;					

								END IF;
						END LOOP;
						CLOSE C5;							
			
				ELSE
						UPDATE WORKFLOWS_DOCUMENTS
						SET DOCUMENT_STATUS = 1
						WHERE WORKFLOWS_DOCUMENTS_ID = V_WORKFLOWS_DOCUMENTS_ID;
						

						IF V_DOCUMENT_TYPES_ID = 224 THEN
								OPEN C90(V_C1.DOCUMENT_ID, V_C1.DEPARTMENT_ID);
								FETCH C90 INTO V_C90;
								CLOSE C90;



								CONFIRM_VAC_REQ_DOCUMENT (V_BRANCH_ID , 
											  V_C90.DOCUMENT_ID   ,
											  V_C90.DEPARTMENT_ID   ,
											  V_C90.DOCUMENT_TYPES_ID   ,
											  V_CONFIRMED    ,
											  V_LANGUAGE_ID   ,
											  V_USER_NAME,
											  'MOBILE')  ;
								UPDATE VACATION_REQUEST 
								SET CONFIRMED = 1
								WHERE  DOCUMENT_ID = V_C1.DOCUMENT_ID
								AND DEPARTMENT_ID = V_C1.DEPARTMENT_ID;

						END IF;

						SEND_WFLOW_APPROVED_EMAIL_DB(GET_DOCUMENT_TYPES_NAME(V_DOCUMENT_TYPES_ID, V_LANGUAGE_ID), V_DOCUMENT_NO , V_DOCUMENT_DATE, V_SYSDATE, V_SUBMITTED_BY, GET_USER_EMAIL(V_SUBMITTED_BY));
						NULL;

						IF GET_USER_SEND_SMS(V_SUBMITTED_BY) = 1 AND 	GET_USER_MOBILE(V_SUBMITTED_BY) IS NOT NULL THEN
						   	P_MESSAGE:='Dear '||INITCAP(V_SUBMITTED_BY)||' ,';
						   	P_MESSAGE:=P_MESSAGE ||CRLF;
						   	P_MESSAGE:=P_MESSAGE ||' Your ' ||LOWER(GET_DOCUMENT_TYPES_NAME(V_DOCUMENT_TYPES_ID, V_LANGUAGE_ID)) ||' document submitted on '||LOWER(V_DOCUMENT_DATE) ||' has been approved ';
						   	P_MESSAGE:=P_MESSAGE ||CHR(10);
						 	  P_MESSAGE:=P_MESSAGE || ' Document no: ' || LOWER(V_DOCUMENT_NO) || CHR(10);
						 	  P_MESSAGE:=P_MESSAGE || ' Document date: ' || LOWER(V_DOCUMENT_DATE) || CHR(10);
						 	  P_MESSAGE:=P_MESSAGE || ' Submitted date: ' || LOWER(V_SUBMITTED_DATE) || CHR(10);
						 		V_MESSAGETO := GET_USER_MOBILE(V_SUBMITTED_BY);

								INSERT INTO MessageOut
									(
										MESSAGETO,
										MESSAGETEXT
									)
								VALUES
									(
										V_MESSAGETO,
										P_MESSAGE
									);
						END IF;
				
				END IF;					
			ELSE
			
			
					UPDATE WORKFLOWS_DOCUMENTS
					SET DOCUMENT_STATUS = 2
					WHERE WORKFLOWS_DOCUMENTS_ID = V_WORKFLOWS_DOCUMENTS_ID;
		
					SEND_WFLOW_REJECTED_EMAIL_DB(GET_DOCUMENT_TYPES_NAME(V_DOCUMENT_TYPES_ID, V_LANGUAGE_ID), V_DOCUMENT_NO , V_DOCUMENT_DATE, V_SYSDATE, V_SUBMITTED_BY , V_GLOBAL_USER_NAME, GET_USER_EMAIL(V_SUBMITTED_BY),V_REASON );
					NULL;
		
					IF GET_USER_SEND_SMS(V_SUBMITTED_BY) = 1 AND 	GET_USER_MOBILE(V_SUBMITTED_BY) IS NOT NULL THEN
					   	P_MESSAGE:='Dear '||INITCAP(V_SUBMITTED_BY)||' ,';
					   	P_MESSAGE:=P_MESSAGE ||CRLF;
					   	P_MESSAGE:=P_MESSAGE ||' Your ' ||LOWER(GET_DOCUMENT_TYPES_NAME(V_DOCUMENT_TYPES_ID, V_LANGUAGE_ID)) ||' document submitted on '||LOWER(V_DOCUMENT_DATE) ||' has been rejected by ' ||INITCAP(V_GLOBAL_USER_NAME);
					   	P_MESSAGE:=P_MESSAGE ||CHR(10);
					 	  P_MESSAGE:=P_MESSAGE || ' Document no: ' || LOWER(V_DOCUMENT_NO) || CHR(10);
					 	  P_MESSAGE:=P_MESSAGE || ' Document date: ' || LOWER(V_DOCUMENT_DATE) || CHR(10);
					 	  P_MESSAGE:=P_MESSAGE || ' Submitted date: ' || LOWER(V_SUBMITTED_DATE) || CHR(10);
					 	  P_MESSAGE:=P_MESSAGE || ' Rejected by: ' || INITCAP(V_GLOBAL_USER_NAME) || CHR(10);
					 	  P_MESSAGE:=P_MESSAGE || ' Reason: ' || LOWER(V_REASON) || CHR(10);
		
							INSERT INTO MessageOut
								(
									MESSAGETO,
									MESSAGETEXT
								)
							VALUES
								(
									GET_USER_MOBILE(V_SUBMITTED_BY),
									P_MESSAGE
								);
		
					END IF;
			END IF;
	END IF;			

	COMMIT;		

END;
/





CREATE OR REPLACE FUNCTION GET_DOCUMENT_NO_NEW_DB( V_BRANCH_ID NUMBER, V_DOCUMENT_TYPES_ID NUMBER, V_FINANCIAL_YEARS_ID NUMBER,V_PREFIX VARCHAR2 DEFAULT NULL, V_SUFFIX VARCHAR2 DEFAULT NULL, V_SEQUENCE_LENGTH NUMBER DEFAULT NULL, V_DETAIL_ID NUMBER DEFAULT NULL, V_DATE DATE DEFAULT NULL, V_DOCUMENT_ID NUMBER) RETURN VARCHAR2 IS
CURSOR C1(V_BRANCH_ID NUMBER) IS
	SELECT MAX(DOCUMENT_NO)
	FROM JOURNALS_NO_VIEW
	WHERE BRANCH_ID = V_BRANCH_ID
	AND JOURNAL_TYPES_ID = NVL(V_DETAIL_ID, JOURNAL_TYPES_ID)
	AND TO_CHAR(DOCUMENT_DATE,'MM-YYYY') = NVL(TO_CHAR(V_DATE,'MM-YYYY'), TO_CHAR(DOCUMENT_DATE,'MM-YYYY'))
	AND FINANCIAL_YEARS_ID = V_FINANCIAL_YEARS_ID
	AND NVL(DOCUMENT_ID,1) <> NVL(V_DOCUMENT_ID,-1);

V_MAX VARCHAR2(50);
V_NUMBER NUMBER;
V_LAST_SEQUENCE VARCHAR2(25);
BEGIN
	V_MAX :='';

	OPEN C1(V_BRANCH_ID);
	FETCH C1 INTO V_MAX;
	CLOSE C1;
	
  V_NUMBER := NVL(SUBSTR(V_MAX, NVL(LENGTH(V_PREFIX), 0) + 1 , V_SEQUENCE_LENGTH) + 1,1);
  IF V_DATE IS NULL THEN
  		V_LAST_SEQUENCE := V_PREFIX || LPAD(V_NUMBER,V_SEQUENCE_LENGTH, '0') || V_SUFFIX;
  ELSE
  		V_LAST_SEQUENCE := V_PREFIX || LPAD(V_NUMBER,V_SEQUENCE_LENGTH, '0') || V_SUFFIX||'/'||TO_CHAR(V_DATE,'MM');
  END IF;
	RETURN(V_LAST_SEQUENCE);
END;
/


CREATE OR REPLACE FUNCTION GET_DOCUMENT_NO_DB(V_BRANCH_ID NUMBER, V_DOCUMENT_TYPES_ID NUMBER, V_FINANCIAL_YEARS_ID NUMBER, V_DETAIL_ID NUMBER DEFAULT NULL, V_DATE DATE DEFAULT NULL, V_DOCUMENT_ID NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
CURSOR C1(V_BRANCH_ID NUMBER) IS
	SELECT COUNT(1)
	FROM DOCUMENT_NO_SETUP
	WHERE BRANCH_ID = V_BRANCH_ID
	AND DOCUMENT_TYPES_ID = V_DOCUMENT_TYPES_ID
	AND FINANCIAL_YEARS_ID = V_FINANCIAL_YEARS_ID;
CURSOR C2(V_BRANCH_ID NUMBER) IS
	SELECT MASTER_DETIAL_TYPE, AUTO_USER_CHOICE, LAST_SEQUENCE, PREFIX, SEQUENCE_LENGTH, SUFFIX
	FROM DOCUMENT_NO_SETUP
	WHERE BRANCH_ID = V_BRANCH_ID
	AND DOCUMENT_TYPES_ID = V_DOCUMENT_TYPES_ID
	AND FINANCIAL_YEARS_ID = V_FINANCIAL_YEARS_ID
	FOR UPDATE;
V_C2 C2%ROWTYPE;
CURSOR C3(V_BRANCH_ID NUMBER) IS
	SELECT COUNT(1)
	FROM DOCUMENT_NO_SETUP_DETAIL
	WHERE BRANCH_ID = V_BRANCH_ID
	AND DOCUMENT_TYPES_ID = V_DOCUMENT_TYPES_ID
	AND FINANCIAL_YEARS_ID = V_FINANCIAL_YEARS_ID
	AND DETAIL_ID = V_DETAIL_ID;
V_C3 C3%ROWTYPE;
CURSOR C4(V_BRANCH_ID NUMBER) IS
	SELECT  AUTO_USER_CHOICE, LAST_SEQUENCE, PREFIX, SEQUENCE_LENGTH, SUFFIX
	FROM DOCUMENT_NO_SETUP_DETAIL
	WHERE BRANCH_ID = V_BRANCH_ID
	AND DOCUMENT_TYPES_ID = V_DOCUMENT_TYPES_ID
	AND FINANCIAL_YEARS_ID = V_FINANCIAL_YEARS_ID
	AND DETAIL_ID = V_DETAIL_ID
	FOR UPDATE;
V_C4 C4%ROWTYPE;
CURSOR C5 IS
	SELECT YEARLY_MONTHLY_FLAG
	FROM GL_DOC_NO_SETUP;
V_C5 C5%ROWTYPE;


V_COUNT NUMBER;
V_NUMBER NUMBER;
V_LAST_SEQUENCE VARCHAR2(25);
BEGIN
	V_COUNT :=0;
  OPEN C5;
  FETCH C5 INTO V_C5;
  CLOSE C5;

  OPEN C1(V_BRANCH_ID);
  FETCH C1 INTO V_COUNT;
  CLOSE C1;
  IF V_COUNT = 0 THEN
  		RETURN('ERROR');
  END IF;
  OPEN C2(V_BRANCH_ID);
  FETCH C2 INTO V_C2;
  CLOSE C2;
  IF V_C2.MASTER_DETIAL_TYPE = 2 THEN
		  OPEN C3(V_BRANCH_ID);
		  FETCH C3 INTO V_COUNT;
		  CLOSE C3;
		  IF V_COUNT = 0 THEN
		  		RETURN('ERROR');
		  END IF;

		  OPEN C4(V_BRANCH_ID);
		  FETCH C4 INTO V_C4;
		  CLOSE C4;
		  IF V_C4.AUTO_USER_CHOICE = 2 THEN
		  		RETURN('USER');
		  END IF;
		  IF V_DOCUMENT_TYPES_ID = 28 AND GET_USER_PARAMETER(58, V_BRANCH_ID) = 2 THEN
		  		IF V_C5.YEARLY_MONTHLY_FLAG = 1 THEN
		  				RETURN(GET_DOCUMENT_NO_NEW_DB(V_BRANCH_ID, V_DOCUMENT_TYPES_ID,V_FINANCIAL_YEARS_ID,V_C4.PREFIX,V_C4.SUFFIX,V_C4.SEQUENCE_LENGTH,V_DETAIL_ID, NULL,V_DOCUMENT_ID));
		  		ELSE
		  				RETURN(GET_DOCUMENT_NO_NEW_DB(V_BRANCH_ID, V_DOCUMENT_TYPES_ID,V_FINANCIAL_YEARS_ID,V_C4.PREFIX,V_C4.SUFFIX,V_C4.SEQUENCE_LENGTH,V_DETAIL_ID, V_DATE,V_DOCUMENT_ID));
		  		END IF;
		  END IF;
		  		
		  V_NUMBER := SUBSTR(V_C4.LAST_SEQUENCE, NVL(LENGTH(V_C4.PREFIX), 0) + 1 , V_C4.SEQUENCE_LENGTH) + 1;
		  V_LAST_SEQUENCE := V_C4.PREFIX || LPAD(V_NUMBER,V_C4.SEQUENCE_LENGTH, '0') || V_C4.SUFFIX;
		  UPDATE DOCUMENT_NO_SETUP_DETAIL
		  SET LAST_SEQUENCE = V_LAST_SEQUENCE
			WHERE BRANCH_ID = V_BRANCH_ID
			AND DOCUMENT_TYPES_ID = V_DOCUMENT_TYPES_ID
			AND FINANCIAL_YEARS_ID = V_FINANCIAL_YEARS_ID
			AND DETAIL_ID = V_DETAIL_ID;
			RETURN(V_LAST_SEQUENCE);
  ELSE
		  IF V_C2.AUTO_USER_CHOICE = 2 THEN
		  		RETURN('USER');
		  END IF;

		  IF V_DOCUMENT_TYPES_ID = 28 AND GET_USER_PARAMETER(58, V_BRANCH_ID) = 2 THEN
		  		IF V_C5.YEARLY_MONTHLY_FLAG = 1 THEN
		  				RETURN(GET_DOCUMENT_NO_NEW_DB(V_BRANCH_ID,V_DOCUMENT_TYPES_ID,V_FINANCIAL_YEARS_ID,V_C2.PREFIX,V_C2.SUFFIX,V_C2.SEQUENCE_LENGTH,NULL, NULL,V_DOCUMENT_ID));
		  		ELSE
		  				RETURN(GET_DOCUMENT_NO_NEW_DB(V_BRANCH_ID,V_DOCUMENT_TYPES_ID,V_FINANCIAL_YEARS_ID,V_C2.PREFIX,V_C2.SUFFIX,V_C2.SEQUENCE_LENGTH,NULL, V_DATE,V_DOCUMENT_ID));
		  		END IF;
		  END IF;
		  
		  V_NUMBER := SUBSTR(V_C2.LAST_SEQUENCE, NVL(LENGTH(V_C2.PREFIX), 0) + 1 , V_C2.SEQUENCE_LENGTH) + 1;
		  V_LAST_SEQUENCE := V_C2.PREFIX || LPAD(V_NUMBER,V_C2.SEQUENCE_LENGTH, '0') || V_C2.SUFFIX;
		  UPDATE DOCUMENT_NO_SETUP
		  SET LAST_SEQUENCE = V_LAST_SEQUENCE
			WHERE BRANCH_ID = V_BRANCH_ID
			AND DOCUMENT_TYPES_ID = V_DOCUMENT_TYPES_ID
			AND FINANCIAL_YEARS_ID = V_FINANCIAL_YEARS_ID;
			RETURN(V_LAST_SEQUENCE);
	END IF;
END;
/


CREATE OR REPLACE FUNCTION GET_DOCUMENT_NO_DEPT_DB(V_BRANCH_ID NUMBER, V_DEPARTMENT_ID NUMBER, V_FINANCIAL_YEARS_ID NUMBER, V_DOCUMENT_TYPES_ID NUMBER, V_DETAIL_ID NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
CURSOR C1(V_BRANCH_ID NUMBER) IS
	SELECT COUNT(1)
	FROM DOC_NO_SETUP_DEPT
	WHERE DEPARTMENT_ID = V_DEPARTMENT_ID
	AND DOCUMENT_TYPES_ID = V_DOCUMENT_TYPES_ID
	AND FINANCIAL_YEARS_ID = V_FINANCIAL_YEARS_ID;
CURSOR C2(V_BRANCH_ID NUMBER) IS
	SELECT MASTER_DETIAL_TYPE, AUTO_USER_CHOICE, LAST_SEQUENCE, PREFIX, SEQUENCE_LENGTH, SUFFIX
	FROM DOC_NO_SETUP_DEPT
	WHERE DEPARTMENT_ID = V_DEPARTMENT_ID
	AND DOCUMENT_TYPES_ID = V_DOCUMENT_TYPES_ID
	AND FINANCIAL_YEARS_ID = V_FINANCIAL_YEARS_ID
	FOR UPDATE;
V_C2 C2%ROWTYPE;
CURSOR C3(V_BRANCH_ID NUMBER) IS
	SELECT COUNT(1)
	FROM DOC_NO_SETUP_DEPT_DETAIL
	WHERE DEPARTMENT_ID = V_DEPARTMENT_ID
	AND DOCUMENT_TYPES_ID = V_DOCUMENT_TYPES_ID
	AND FINANCIAL_YEARS_ID = V_FINANCIAL_YEARS_ID
	AND DETAIL_ID = V_DETAIL_ID;
V_C3 C3%ROWTYPE;
CURSOR C4(V_BRANCH_ID NUMBER) IS
	SELECT  AUTO_USER_CHOICE, LAST_SEQUENCE, PREFIX, SEQUENCE_LENGTH, SUFFIX
	FROM DOC_NO_SETUP_DEPT_DETAIL
	WHERE DEPARTMENT_ID = V_DEPARTMENT_ID
	AND DOCUMENT_TYPES_ID = V_DOCUMENT_TYPES_ID
	AND FINANCIAL_YEARS_ID = V_FINANCIAL_YEARS_ID
	AND DETAIL_ID = V_DETAIL_ID
	FOR UPDATE;
V_C4 C4%ROWTYPE;
V_COUNT NUMBER;
V_NUMBER NUMBER;
V_LAST_SEQUENCE VARCHAR2(25);
BEGIN
	V_COUNT :=0;
  OPEN C1(V_BRANCH_ID);
  FETCH C1 INTO V_COUNT;
  CLOSE C1;
  IF V_COUNT = 0 THEN
  		RETURN('ERROR');
  END IF;
  OPEN C2(V_BRANCH_ID);
  FETCH C2 INTO V_C2;
  CLOSE C2;
  IF V_C2.MASTER_DETIAL_TYPE = 2 THEN
		  OPEN C3(V_BRANCH_ID);
		  FETCH C3 INTO V_COUNT;
		  CLOSE C3;
		  IF V_COUNT = 0 THEN
		  		RETURN('ERROR');
		  END IF;

		  OPEN C4(V_BRANCH_ID);
		  FETCH C4 INTO V_C4;
		  CLOSE C4;
		  IF V_C4.AUTO_USER_CHOICE = 2 THEN
		  		RETURN('USER');
		  END IF;
		  
		  V_NUMBER := SUBSTR(V_C4.LAST_SEQUENCE, NVL(LENGTH(V_C4.PREFIX), 0) + 1 , V_C4.SEQUENCE_LENGTH) + 1;
		  V_LAST_SEQUENCE := V_C4.PREFIX || LPAD(V_NUMBER,V_C4.SEQUENCE_LENGTH, '0') || V_C4.SUFFIX;
		  UPDATE DOC_NO_SETUP_DEPT_DETAIL
		  SET LAST_SEQUENCE = V_LAST_SEQUENCE
			WHERE DEPARTMENT_ID = V_DEPARTMENT_ID
			AND DOCUMENT_TYPES_ID = V_DOCUMENT_TYPES_ID
			AND FINANCIAL_YEARS_ID = V_FINANCIAL_YEARS_ID
			AND DETAIL_ID = V_DETAIL_ID;
			RETURN(V_LAST_SEQUENCE);
  ELSE
		  IF V_C2.AUTO_USER_CHOICE = 2 THEN
		  		RETURN('USER');
		  END IF;
		  V_NUMBER := SUBSTR(V_C2.LAST_SEQUENCE, NVL(LENGTH(V_C2.PREFIX), 0) + 1 , V_C2.SEQUENCE_LENGTH) + 1;
		  V_LAST_SEQUENCE := V_C2.PREFIX || LPAD(V_NUMBER,V_C2.SEQUENCE_LENGTH, '0') || V_C2.SUFFIX;
		  UPDATE DOC_NO_SETUP_DEPT
		  SET LAST_SEQUENCE = V_LAST_SEQUENCE
			WHERE DEPARTMENT_ID = V_DEPARTMENT_ID
			AND DOCUMENT_TYPES_ID = V_DOCUMENT_TYPES_ID
			AND FINANCIAL_YEARS_ID = V_FINANCIAL_YEARS_ID;
			RETURN(V_LAST_SEQUENCE);
	END IF;
END;
/



CREATE OR REPLACE FUNCTION DISPLAY_ALERT_DB(V_MESSAGE_NO VARCHAR2, V_LANGUAGE_ID NUMBER) RETURN VARCHAR2 IS
CURSOR C1 IS
	SELECT 	DECODE(V_LANGUAGE_ID, 1, PRIMARY_NAME, 2, SECONDARY_NAME, PRIMARY_NAME) MESSAGE
	FROM MESSAGES
	WHERE MESSAGE_NO = V_MESSAGE_NO;
V_C1 C1%ROWTYPE;
BEGIN
	OPEN C1;
	FETCH C1 INTO V_C1;
	CLOSE C1;
	
	RETURN(V_C1.MESSAGE);
END;
/

CREATE OR REPLACE FUNCTION GET_USER_WFL_DOC_NO(V_USER_NAME VARCHAR2, V_BRANCH_ID NUMBER) RETURN NUMBER IS
CURSOR C1 IS
	SELECT COUNT(1)
	FROM WORKFLOWS_DOCUMENTS_VIEW WFD
	WHERE BRANCH_ID = V_BRANCH_ID
	AND ( USER_NAME = V_USER_NAME
				OR
				(SEND_COPY_USER_NAME =V_USER_NAME AND SYSDATE >= SUBMITTED_DATE + SEND_COPY_DAYS))	
	AND APPROVED_DISAPRROVED_FLAG = 3
	AND WORKFLOWS_DOCUMENTS_ID NOT IN
			(	SELECT WORKFLOWS_DOCUMENTS_ID
				FROM WORKFLOWS_DOCUMENTS_DTL
				WHERE APPROVED_DISAPRROVED_FLAG = 2);
V_COUNT NUMBER;
BEGIN
	V_COUNT :=0;
	OPEN C1;
	FETCH C1 INTO V_COUNT;
	CLOSE C1;
  
  RETURN(V_COUNT);
  
END;
/







