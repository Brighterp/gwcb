CREATE OR REPLACE FUNCTION GET_SUP_MAIN_GROUP_CODE(V_SUPPLIERS_GROUPS_MAIN_ID NUMBER) RETURN VARCHAR2 IS
CURSOR C1 IS
	SELECT USER_CODE
	FROM SUPPLIERS_GROUPS_MAIN
	WHERE SUPPLIERS_GROUPS_MAIN_ID = V_SUPPLIERS_GROUPS_MAIN_ID;
V_C1 C1%ROWTYPE;
BEGIN
	OPEN C1;
	FETCH C1 INTO V_C1;
	CLOSE C1;
  RETURN(V_C1.USER_CODE);
END;
/




CREATE OR REPLACE TRIGGER SUP_GROUPS_MAIN_B_TRI
AFTER INSERT OR UPDATE OR DELETE  ON SUPPLIERS_GROUPS_MAIN_B
FOR EACH ROW
DECLARE
CURSOR C1(V_SUPPLIERS_GROUPS_MAIN_ID NUMBER) IS
  SELECT *
  FROM SUPPLIERS_GROUPS_MAIN
  WHERE SUPPLIERS_GROUPS_MAIN_ID = V_SUPPLIERS_GROUPS_MAIN_ID
  AND BRANCH_ID = 0;
V_SUPPLIERS_GROUPS_MAIN_ID NUMBER;
V_C1 C1%ROWTYPE;
BEGIN
    IF INSERTING THEN
	OPEN C1(:NEW.SUPPLIERS_GROUPS_MAIN_ID);
	FETCH C1 INTO V_C1;
	CLOSE C1;
	
     	INSERT INTO SUPPLIERS_GROUPS_MAIN
	(
		SUPPLIERS_GROUPS_MAIN_ID,
		BRANCH_ID                ,      
		USER_CODE                 ,     
		PRIMARY_NAME               ,    
		SECONDARY_NAME              ,   
		CREATED_BY                   ,  
		CREATION_DATE                 , 
		CREATION_MACHINE               ,
		UPDATED_BY                     ,
		UPDATED_DATE                   ,
		UPDATED_MACHINE                	     
	)
     	VALUES
	(
		SUPPLIERS_GROUPS_SEQ.NEXTVAL,
		:NEW.BRANCH_ID                ,      
		V_C1.USER_CODE                 ,     
		V_C1.PRIMARY_NAME               ,    
		V_C1.SECONDARY_NAME              ,   
		V_C1.CREATED_BY                   ,  
		V_C1.CREATION_DATE                 , 
		V_C1.CREATION_MACHINE               ,
		V_C1.UPDATED_BY                     ,
		V_C1.UPDATED_DATE                   ,
		V_C1.UPDATED_MACHINE                	     
	);


    ELSIF UPDATING THEN

	OPEN C1(:OLD.SUPPLIERS_GROUPS_MAIN_ID);
	FETCH C1 INTO V_C1;
	CLOSE C1;

	DELETE FROM SUPPLIERS_GROUPS_MAIN
	WHERE USER_CODE = V_C1.USER_CODE
	AND BRANCH_ID = :OLD.BRANCH_ID;
	
     	INSERT INTO SUPPLIERS_GROUPS_MAIN
	(
		SUPPLIERS_GROUPS_MAIN_ID,
		BRANCH_ID                ,      
		USER_CODE                 ,     
		PRIMARY_NAME               ,    
		SECONDARY_NAME              ,   
		CREATED_BY                   ,  
		CREATION_DATE                 , 
		CREATION_MACHINE               ,
		UPDATED_BY                     ,
		UPDATED_DATE                   ,
		UPDATED_MACHINE                	     
	)
     	VALUES
	(
		SUPPLIERS_GROUPS_SEQ.NEXTVAL,
		:NEW.BRANCH_ID                ,      
		V_C1.USER_CODE                 ,     
		V_C1.PRIMARY_NAME               ,    
		V_C1.SECONDARY_NAME              ,   
		V_C1.CREATED_BY                   ,  
		V_C1.CREATION_DATE                 , 
		V_C1.CREATION_MACHINE               ,
		V_C1.UPDATED_BY                     ,
		V_C1.UPDATED_DATE                   ,
		V_C1.UPDATED_MACHINE                	     
	);

    ELSIF DELETING THEN
	OPEN C1(:OLD.SUPPLIERS_GROUPS_MAIN_ID);
	FETCH C1 INTO V_C1;
	CLOSE C1;

	DELETE FROM SUPPLIERS_GROUPS_MAIN
	WHERE USER_CODE = V_C1.USER_CODE
	AND BRANCH_ID = :OLD.BRANCH_ID;


    END IF;

END;
/



CREATE OR REPLACE TRIGGER SUP_GROUPS_B_TRI
AFTER INSERT OR UPDATE OR DELETE  ON SUPPLIERS_GROUPS_B
FOR EACH ROW
DECLARE
CURSOR C1(V_SUPPLIERS_GROUPS_ID NUMBER) IS
  SELECT *
  FROM SUPPLIERS_GROUPS
  WHERE SUPPLIERS_GROUPS_ID = V_SUPPLIERS_GROUPS_ID
  AND BRANCH_ID = 0;
CURSOR C2(V_SUPPLIERS_GROUPS_MAIN_CODE  VARCHAR2, V_BRANCH_ID NUMBER) IS
  SELECT SUPPLIERS_GROUPS_MAIN_ID
  FROM SUPPLIERS_GROUPS_MAIN
  WHERE USER_CODE = V_SUPPLIERS_GROUPS_MAIN_CODE 
  AND BRANCH_ID = V_BRANCH_ID;
V_SUPPLIERS_GROUPS_MAIN_ID NUMBER;

CURSOR C3(V_SUPPLIERS_GROUPS_MAIN_ID NUMBER) IS
  SELECT USER_CODE
  FROM SUPPLIERS_GROUPS_MAIN
  WHERE SUPPLIERS_GROUPS_MAIN_ID = V_SUPPLIERS_GROUPS_MAIN_ID;
V_SUPPLIERS_GROUPS_MAIN_CODE VARCHAR2(100);

V_SUPPLIERS_GROUPS_ID NUMBER;
V_C1 C1%ROWTYPE;
BEGIN
    IF INSERTING THEN
	OPEN C1(:NEW.SUPPLIERS_GROUPS_ID);
	FETCH C1 INTO V_C1;
	CLOSE C1;

	OPEN C3(V_C1.SUPPLIERS_GROUPS_MAIN_ID);
	FETCH C3 INTO V_SUPPLIERS_GROUPS_MAIN_CODE;
	CLOSE C3;

	OPEN C2(V_SUPPLIERS_GROUPS_MAIN_CODE, :NEW.BRANCH_ID);
	FETCH C2 INTO V_SUPPLIERS_GROUPS_MAIN_ID;
	CLOSE C2;
	
     	INSERT INTO SUPPLIERS_GROUPS
	(
		SUPPLIERS_GROUPS_ID,
		SUPPLIERS_GROUPS_MAIN_ID,
		BRANCH_ID                ,      
		USER_CODE                 ,     
		PRIMARY_NAME               ,    
		SECONDARY_NAME              ,   
		CREATED_BY                   ,  
		CREATION_DATE                 , 
		CREATION_MACHINE               ,
		UPDATED_BY                     ,
		UPDATED_DATE                   ,
		UPDATED_MACHINE                	     
	)
     	VALUES
	(
		SUPPLIERS_GROUPS_SEQ.NEXTVAL,
		V_SUPPLIERS_GROUPS_MAIN_ID,
		:NEW.BRANCH_ID                ,      
		V_C1.USER_CODE                 ,     
		V_C1.PRIMARY_NAME               ,    
		V_C1.SECONDARY_NAME              ,   
		V_C1.CREATED_BY                   ,  
		V_C1.CREATION_DATE                 , 
		V_C1.CREATION_MACHINE               ,
		V_C1.UPDATED_BY                     ,
		V_C1.UPDATED_DATE                   ,
		V_C1.UPDATED_MACHINE                	     
	);
    ELSIF UPDATING THEN
	OPEN C1(:OLD.SUPPLIERS_GROUPS_ID);
	FETCH C1 INTO V_C1;
	CLOSE C1;

	DELETE FROM SUPPLIERS_GROUPS
	WHERE USER_CODE = V_C1.USER_CODE
	AND BRANCH_ID = :OLD.BRANCH_ID;
	
	OPEN C1(:NEW.SUPPLIERS_GROUPS_ID);
	FETCH C1 INTO V_C1;
	CLOSE C1;

	OPEN C3(V_C1.SUPPLIERS_GROUPS_MAIN_ID);
	FETCH C3 INTO V_SUPPLIERS_GROUPS_MAIN_CODE;
	CLOSE C3;

	OPEN C2(V_SUPPLIERS_GROUPS_MAIN_CODE, :NEW.BRANCH_ID);
	FETCH C2 INTO V_SUPPLIERS_GROUPS_MAIN_ID;
	CLOSE C2;
	
     	INSERT INTO SUPPLIERS_GROUPS
	(
		SUPPLIERS_GROUPS_ID,
		SUPPLIERS_GROUPS_MAIN_ID,
		BRANCH_ID                ,      
		USER_CODE                 ,     
		PRIMARY_NAME               ,    
		SECONDARY_NAME              ,   
		CREATED_BY                   ,  
		CREATION_DATE                 , 
		CREATION_MACHINE               ,
		UPDATED_BY                     ,
		UPDATED_DATE                   ,
		UPDATED_MACHINE                	     
	)
     	VALUES
	(
		SUPPLIERS_GROUPS_SEQ.NEXTVAL,
		V_SUPPLIERS_GROUPS_MAIN_ID,
		:NEW.BRANCH_ID                ,      
		V_C1.USER_CODE                 ,     
		V_C1.PRIMARY_NAME               ,    
		V_C1.SECONDARY_NAME              ,   
		V_C1.CREATED_BY                   ,  
		V_C1.CREATION_DATE                 , 
		V_C1.CREATION_MACHINE               ,
		V_C1.UPDATED_BY                     ,
		V_C1.UPDATED_DATE                   ,
		V_C1.UPDATED_MACHINE                	     
	);
    ELSIF DELETING THEN
	OPEN C1(:OLD.SUPPLIERS_GROUPS_ID);
	FETCH C1 INTO V_C1;
	CLOSE C1;

	DELETE FROM SUPPLIERS_GROUPS
	WHERE USER_CODE = V_C1.USER_CODE
	AND BRANCH_ID = :OLD.BRANCH_ID;
    END IF;
END;
/



CREATE OR REPLACE TRIGGER SUPPLIERS_B_TRI
AFTER INSERT OR UPDATE OR DELETE  ON SUPPLIERS_B
FOR EACH ROW
DECLARE
CURSOR C1(V_SUPPLIER_ID NUMBER) IS
  SELECT *
  FROM SUPPLIERS
  WHERE SUPPLIER_ID = V_SUPPLIER_ID
  AND BRANCH_ID = 0;
CURSOR C2(V_SUPPLIERS_GROUPS_CODE  VARCHAR2, V_BRANCH_ID NUMBER) IS
  SELECT SUPPLIERS_GROUPS_ID
  FROM SUPPLIERS_GROUPS
  WHERE USER_CODE = V_SUPPLIERS_GROUPS_CODE 
  AND BRANCH_ID = V_BRANCH_ID;
V_SUPPLIERS_GROUPS_ID NUMBER;

CURSOR C3(V_SUPPLIERS_GROUPS_ID NUMBER) IS
  SELECT USER_CODE
  FROM SUPPLIERS_GROUPS
  WHERE SUPPLIERS_GROUPS_ID = V_SUPPLIERS_GROUPS_ID;
V_SUPPLIERS_GROUPS_CODE VARCHAR2(100);

CURSOR C4(V_ACCOUNT_CODE  VARCHAR2, V_BRANCH_ID NUMBER) IS
  SELECT ACCOUNT_ID
  FROM ACCOUNTS
  WHERE USER_CODE = V_ACCOUNT_CODE 
  AND BRANCH_ID = V_BRANCH_ID;
V_ACCOUNT_ID NUMBER;

CURSOR C5(V_ACCOUNT_ID NUMBER) IS
  SELECT USER_CODE
  FROM ACCOUNTS
  WHERE ACCOUNT_ID = V_ACCOUNT_ID;
V_ACCOUNT_CODE VARCHAR2(100);
V_SUPPLIER_ID NUMBER;
V_C1 C1%ROWTYPE;

CURSOR C6(V_SUPPLIER_ID NUMBER) IS
  SELECT *
  FROM SUPPLIERS_CONTACT_PERSONS
  WHERE SUPPLIER_ID = V_SUPPLIER_ID;
V_C6 C6%ROWTYPE;

CURSOR C7(V_SUPPLIER_ID NUMBER) IS
  SELECT *
  FROM SUPPLIERS_ACC
  WHERE SUPPLIER_ID = V_SUPPLIER_ID;
V_C7 C7%ROWTYPE;


V_SUPPLIER_ID_2 NUMBER;
BEGIN
    IF INSERTING THEN
	OPEN C1(:NEW.SUPPLIER_ID);
	FETCH C1 INTO V_C1;
	CLOSE C1;
	
	V_SUPPLIERS_GROUPS_ID := NULL;

	OPEN C3(V_C1.SUPPLIERS_GROUPS_ID);
	FETCH C3 INTO V_SUPPLIERS_GROUPS_CODE;
	CLOSE C3;

	OPEN C2(V_SUPPLIERS_GROUPS_CODE, :NEW.BRANCH_ID);
	FETCH C2 INTO V_SUPPLIERS_GROUPS_ID;
	CLOSE C2;
	
	IF V_SUPPLIERS_GROUPS_ID IS NULL THEN
		RAISE_APPLICATION_ERROR(-20900,'Supplier group not defined in this branch') ;
	END IF;

	V_ACCOUNT_ID := NULL;

	OPEN C5(V_C1.ACCOUNT_ID);
	FETCH C5 INTO V_ACCOUNT_CODE;
	CLOSE C5;

	OPEN C4(V_ACCOUNT_CODE, :NEW.BRANCH_ID);
	FETCH C4 INTO V_ACCOUNT_ID;
	CLOSE C4;
	
	IF V_ACCOUNT_ID IS NULL THEN
		RAISE_APPLICATION_ERROR(-20901,'account not defined in this branch') ;
	END IF;
	
	SELECT SUPPLIERS_SEQ.NEXTVAL
	INTO V_SUPPLIER_ID_2
	FROM DUAL;

     	INSERT INTO SUPPLIERS
	(
		SUPPLIER_ID            ,     
		USER_CODE              ,    
		PRIMARY_NAME           ,   
		SECONDARY_NAME         ,  
		BRANCH_ID              , 
		SUPPLIERS_GROUPS_ID    ,
		CREDIT_LIMIT_DAYS      ,
		PAYMENT_TYPE           ,
		CURRENCIES_ID          ,
		ACCOUNT_ID             ,
		TEL_NO1                ,
		TEL_NO2                ,
		FAX_NO1                ,
		MOBILE                 ,
		ADDRESS_P              ,
		ADDRESS_S              ,
		COUNTRY                ,
		CITY                   ,
		DESTINATION            ,
		POSTAL_CODE            ,
		EMAIL                  ,
		WEB_SITE               ,
		PRIMARY_DESCRIPTION    ,
		SECONDARY_DESCRIPTION  ,
		MORNING_OPEN           ,
		MORNING_CLOSE          ,
		NOON_OPEN              ,
		NOON_CLOSE             ,
		OFF_DAYS               ,
		ACTIVE                 ,
		CREATED_BY             ,
		CREATION_DATE          ,
		CREATION_MACHINE       ,
		UPDATED_BY             ,
		UPDATED_DATE           ,
		UPDATED_MACHINE        ,
		SECOND_OFF_DAYS        ,
		EMP_USER_NUM1          ,
		EMP_USER_NUM2          ,
		EMP_USER_NUM3          ,
		EMP_USER_NUM4          ,
		EMP_USER_CHAR1         ,
		EMP_USER_CHAR2         ,
		EMP_USER_CHAR3         ,
		EMP_USER_CHAR4         ,
		EMP_USER_DATE1         ,
		EMP_USER_DATE2         ,
		EMP_USER_DATE3         ,
		EMP_USER_DATE4         ,
		USER_CODES_SYS_ID1     ,
		USER_CODES_SYS_ID2     ,
		USER_CODES_SYS_ID3     ,
		USER_CODES_SYS_ID4     ,
		DEFAULT_BATCH_SUPPLIER ,
		SUPPLIER_TYPE          ,
		TAX_ID                 ,
		TAX_FILE_NO            ,
		TAX_DEPARTMENT_ID      
	)
     	VALUES
	(
		V_SUPPLIER_ID_2            ,     
		V_C1.USER_CODE              ,    
		V_C1.PRIMARY_NAME           ,   
		V_C1.SECONDARY_NAME         ,  
		:NEW.BRANCH_ID              , 
		V_SUPPLIERS_GROUPS_ID    ,
		V_C1.CREDIT_LIMIT_DAYS      ,
		V_C1.PAYMENT_TYPE           ,
		V_C1.CURRENCIES_ID          ,
		V_ACCOUNT_ID             ,
		V_C1.TEL_NO1                ,
		V_C1.TEL_NO2                ,
		V_C1.FAX_NO1                ,
		V_C1.MOBILE                 ,
		V_C1.ADDRESS_P              ,
		V_C1.ADDRESS_S              ,
		V_C1.COUNTRY                ,
		V_C1.CITY                   ,
		V_C1.DESTINATION            ,
		V_C1.POSTAL_CODE            ,
		V_C1.EMAIL                  ,
		V_C1.WEB_SITE               ,
		V_C1.PRIMARY_DESCRIPTION    ,
		V_C1.SECONDARY_DESCRIPTION  ,
		V_C1.MORNING_OPEN           ,
		V_C1.MORNING_CLOSE          ,
		V_C1.NOON_OPEN              ,
		V_C1.NOON_CLOSE             ,
		V_C1.OFF_DAYS               ,
		V_C1.ACTIVE                 ,
		V_C1.CREATED_BY             ,
		V_C1.CREATION_DATE          ,
		V_C1.CREATION_MACHINE       ,
		V_C1.UPDATED_BY             ,
		V_C1.UPDATED_DATE           ,
		V_C1.UPDATED_MACHINE        ,
		V_C1.SECOND_OFF_DAYS        ,
		V_C1.EMP_USER_NUM1          ,
		V_C1.EMP_USER_NUM2          ,
		V_C1.EMP_USER_NUM3          ,
		V_C1.EMP_USER_NUM4          ,
		V_C1.EMP_USER_CHAR1         ,
		V_C1.EMP_USER_CHAR2         ,
		V_C1.EMP_USER_CHAR3         ,
		V_C1.EMP_USER_CHAR4         ,
		V_C1.EMP_USER_DATE1         ,
		V_C1.EMP_USER_DATE2         ,
		V_C1.EMP_USER_DATE3         ,
		V_C1.EMP_USER_DATE4         ,
		V_C1.USER_CODES_SYS_ID1     ,
		V_C1.USER_CODES_SYS_ID2     ,
		V_C1.USER_CODES_SYS_ID3     ,
		V_C1.USER_CODES_SYS_ID4     ,
		V_C1.DEFAULT_BATCH_SUPPLIER ,
		V_C1.SUPPLIER_TYPE          ,
		V_C1.TAX_ID                 ,
		V_C1.TAX_FILE_NO            ,
		V_C1.TAX_DEPARTMENT_ID      
	);
	

	OPEN C6(:NEW.SUPPLIER_ID);
	LOOP
		FETCH C6 INTO V_C6;
		EXIT WHEN C6%NOTFOUND;

		INSERT INTO SUPPLIERS_CONTACT_PERSONS
		(
			SUPPLIERS_CONTACT_PERSONS_ID   ,
			SUPPLIER_ID                    ,  
			JOB_TITLE                      ,  
			PRIMARY_NAME                   , 
			SECONDARY_NAME                 ,
			TEL_NO1                        ,
			TEL_NO2                        ,
			FAX_NO1                        ,
			PERSONAL_MOBILE                ,
			BUSINESS_MOBILE                ,
			EMAIL                          ,
			NOTES                          ,
			CREATED_BY                     ,
			CREATION_DATE                  ,
			CREATION_MACHINE               ,
			UPDATED_BY                     ,
			UPDATED_DATE                   ,
			UPDATED_MACHINE                		
		)
		VALUES
		(
			SUPPLIERS_CONTACT_PERSONS_SEQ.NEXTVAL   ,
			V_SUPPLIER_ID_2                    ,  
			V_C6.JOB_TITLE                      ,  
			V_C6.PRIMARY_NAME                   , 
			V_C6.SECONDARY_NAME                 ,
			V_C6.TEL_NO1                        ,
			V_C6.TEL_NO2                        ,
			V_C6.FAX_NO1                        ,
			V_C6.PERSONAL_MOBILE                ,
			V_C6.BUSINESS_MOBILE                ,
			V_C6.EMAIL                          ,
			V_C6.NOTES                          ,
			V_C6.CREATED_BY                     ,
			V_C6.CREATION_DATE                  ,
			V_C6.CREATION_MACHINE               ,
			V_C6.UPDATED_BY                     ,
			V_C6.UPDATED_DATE                   ,
			V_C6.UPDATED_MACHINE                		
		);


	END LOOP;
	CLOSE C6;

	OPEN C7(:NEW.SUPPLIER_ID);
	LOOP
		FETCH C7 INTO V_C7;
		EXIT WHEN C7%NOTFOUND;

		V_ACCOUNT_ID := NULL;

		OPEN C5(V_C7.ACCOUNT_ID);
		FETCH C5 INTO V_ACCOUNT_CODE;
		CLOSE C5;

		OPEN C4(V_ACCOUNT_CODE, :NEW.BRANCH_ID);
		FETCH C4 INTO V_ACCOUNT_ID;
		CLOSE C4;
	
		IF V_ACCOUNT_ID IS NULL THEN
			RAISE_APPLICATION_ERROR(-20901,'account not defined in this branch') ;
		END IF;

		INSERT INTO SUPPLIERS_ACC
		(
			SUPPLIER_ID    		       ,
			ACCOUNT_ID     		       ,
			ACCOUNT_TYPE		       ,	
			CREATED_BY                     ,
			CREATION_DATE                  ,
			CREATION_MACHINE               ,
			UPDATED_BY                     ,
			UPDATED_DATE                   ,
			UPDATED_MACHINE                		
		)
		VALUES
		(
			V_SUPPLIER_ID_2                    ,  
			V_ACCOUNT_ID		       ,
			V_C7.ACCOUNT_TYPE		       ,	
			V_C7.CREATED_BY                     ,
			V_C7.CREATION_DATE                  ,
			V_C7.CREATION_MACHINE               ,
			V_C7.UPDATED_BY                     ,
			V_C7.UPDATED_DATE                   ,
			V_C7.UPDATED_MACHINE                		
		);

	END LOOP;
	CLOSE C7;
	
    ELSIF UPDATING THEN
	OPEN C1(:OLD.SUPPLIER_ID);
	FETCH C1 INTO V_C1;
	CLOSE C1;

	DELETE FROM SUPPLIERS_ACC
	WHERE SUPPLIER_ID IN
		( SELECT SUPPLIER_ID
		  FROM SUPPLIERS
		  WHERE USER_CODE = V_C1.USER_CODE
	          AND BRANCH_ID = :OLD.BRANCH_ID);

	DELETE FROM SUPPLIERS_CONTACT_PERSONS
	WHERE SUPPLIER_ID IN
		( SELECT SUPPLIER_ID
		  FROM SUPPLIERS
		  WHERE USER_CODE = V_C1.USER_CODE
	          AND BRANCH_ID = :OLD.BRANCH_ID);


	DELETE FROM SUPPLIERS
	WHERE USER_CODE = V_C1.USER_CODE
	AND BRANCH_ID = :OLD.BRANCH_ID;


	OPEN C1(:NEW.SUPPLIER_ID);
	FETCH C1 INTO V_C1;
	CLOSE C1;
	
	V_SUPPLIERS_GROUPS_ID := NULL;

	OPEN C3(V_C1.SUPPLIERS_GROUPS_ID);
	FETCH C3 INTO V_SUPPLIERS_GROUPS_CODE;
	CLOSE C3;

	OPEN C2(V_SUPPLIERS_GROUPS_CODE, :NEW.BRANCH_ID);
	FETCH C2 INTO V_SUPPLIERS_GROUPS_ID;
	CLOSE C2;
	
	IF V_SUPPLIERS_GROUPS_ID IS NULL THEN
		RAISE_APPLICATION_ERROR(-20900,'Supplier group not defined in this branch') ;
	END IF;

	V_ACCOUNT_ID := NULL;

	OPEN C5(V_C1.ACCOUNT_ID);
	FETCH C5 INTO V_ACCOUNT_CODE;
	CLOSE C5;

	OPEN C4(V_ACCOUNT_CODE, :NEW.BRANCH_ID);
	FETCH C4 INTO V_ACCOUNT_ID;
	CLOSE C4;
	
	IF V_ACCOUNT_ID IS NULL THEN
		RAISE_APPLICATION_ERROR(-20901,'account not defined in this branch') ;
	END IF;
	
	SELECT SUPPLIERS_SEQ.NEXTVAL
	INTO V_SUPPLIER_ID_2
	FROM DUAL;

     	INSERT INTO SUPPLIERS
	(
		SUPPLIER_ID            ,     
		USER_CODE              ,    
		PRIMARY_NAME           ,   
		SECONDARY_NAME         ,  
		BRANCH_ID              , 
		SUPPLIERS_GROUPS_ID    ,
		CREDIT_LIMIT_DAYS      ,
		PAYMENT_TYPE           ,
		CURRENCIES_ID          ,
		ACCOUNT_ID             ,
		TEL_NO1                ,
		TEL_NO2                ,
		FAX_NO1                ,
		MOBILE                 ,
		ADDRESS_P              ,
		ADDRESS_S              ,
		COUNTRY                ,
		CITY                   ,
		DESTINATION            ,
		POSTAL_CODE            ,
		EMAIL                  ,
		WEB_SITE               ,
		PRIMARY_DESCRIPTION    ,
		SECONDARY_DESCRIPTION  ,
		MORNING_OPEN           ,
		MORNING_CLOSE          ,
		NOON_OPEN              ,
		NOON_CLOSE             ,
		OFF_DAYS               ,
		ACTIVE                 ,
		CREATED_BY             ,
		CREATION_DATE          ,
		CREATION_MACHINE       ,
		UPDATED_BY             ,
		UPDATED_DATE           ,
		UPDATED_MACHINE        ,
		SECOND_OFF_DAYS        ,
		EMP_USER_NUM1          ,
		EMP_USER_NUM2          ,
		EMP_USER_NUM3          ,
		EMP_USER_NUM4          ,
		EMP_USER_CHAR1         ,
		EMP_USER_CHAR2         ,
		EMP_USER_CHAR3         ,
		EMP_USER_CHAR4         ,
		EMP_USER_DATE1         ,
		EMP_USER_DATE2         ,
		EMP_USER_DATE3         ,
		EMP_USER_DATE4         ,
		USER_CODES_SYS_ID1     ,
		USER_CODES_SYS_ID2     ,
		USER_CODES_SYS_ID3     ,
		USER_CODES_SYS_ID4     ,
		DEFAULT_BATCH_SUPPLIER ,
		SUPPLIER_TYPE          ,
		TAX_ID                 ,
		TAX_FILE_NO            ,
		TAX_DEPARTMENT_ID      
	)
     	VALUES
	(
		V_SUPPLIER_ID_2            ,     
		V_C1.USER_CODE              ,    
		V_C1.PRIMARY_NAME           ,   
		V_C1.SECONDARY_NAME         ,  
		:NEW.BRANCH_ID              , 
		V_SUPPLIERS_GROUPS_ID    ,
		V_C1.CREDIT_LIMIT_DAYS      ,
		V_C1.PAYMENT_TYPE           ,
		V_C1.CURRENCIES_ID          ,
		V_ACCOUNT_ID             ,
		V_C1.TEL_NO1                ,
		V_C1.TEL_NO2                ,
		V_C1.FAX_NO1                ,
		V_C1.MOBILE                 ,
		V_C1.ADDRESS_P              ,
		V_C1.ADDRESS_S              ,
		V_C1.COUNTRY                ,
		V_C1.CITY                   ,
		V_C1.DESTINATION            ,
		V_C1.POSTAL_CODE            ,
		V_C1.EMAIL                  ,
		V_C1.WEB_SITE               ,
		V_C1.PRIMARY_DESCRIPTION    ,
		V_C1.SECONDARY_DESCRIPTION  ,
		V_C1.MORNING_OPEN           ,
		V_C1.MORNING_CLOSE          ,
		V_C1.NOON_OPEN              ,
		V_C1.NOON_CLOSE             ,
		V_C1.OFF_DAYS               ,
		V_C1.ACTIVE                 ,
		V_C1.CREATED_BY             ,
		V_C1.CREATION_DATE          ,
		V_C1.CREATION_MACHINE       ,
		V_C1.UPDATED_BY             ,
		V_C1.UPDATED_DATE           ,
		V_C1.UPDATED_MACHINE        ,
		V_C1.SECOND_OFF_DAYS        ,
		V_C1.EMP_USER_NUM1          ,
		V_C1.EMP_USER_NUM2          ,
		V_C1.EMP_USER_NUM3          ,
		V_C1.EMP_USER_NUM4          ,
		V_C1.EMP_USER_CHAR1         ,
		V_C1.EMP_USER_CHAR2         ,
		V_C1.EMP_USER_CHAR3         ,
		V_C1.EMP_USER_CHAR4         ,
		V_C1.EMP_USER_DATE1         ,
		V_C1.EMP_USER_DATE2         ,
		V_C1.EMP_USER_DATE3         ,
		V_C1.EMP_USER_DATE4         ,
		V_C1.USER_CODES_SYS_ID1     ,
		V_C1.USER_CODES_SYS_ID2     ,
		V_C1.USER_CODES_SYS_ID3     ,
		V_C1.USER_CODES_SYS_ID4     ,
		V_C1.DEFAULT_BATCH_SUPPLIER ,
		V_C1.SUPPLIER_TYPE          ,
		V_C1.TAX_ID                 ,
		V_C1.TAX_FILE_NO            ,
		V_C1.TAX_DEPARTMENT_ID      
	);
	

	OPEN C6(:NEW.SUPPLIER_ID);
	LOOP
		FETCH C6 INTO V_C6;
		EXIT WHEN C6%NOTFOUND;

		INSERT INTO SUPPLIERS_CONTACT_PERSONS
		(
			SUPPLIERS_CONTACT_PERSONS_ID   ,
			SUPPLIER_ID                    ,  
			JOB_TITLE                      ,  
			PRIMARY_NAME                   , 
			SECONDARY_NAME                 ,
			TEL_NO1                        ,
			TEL_NO2                        ,
			FAX_NO1                        ,
			PERSONAL_MOBILE                ,
			BUSINESS_MOBILE                ,
			EMAIL                          ,
			NOTES                          ,
			CREATED_BY                     ,
			CREATION_DATE                  ,
			CREATION_MACHINE               ,
			UPDATED_BY                     ,
			UPDATED_DATE                   ,
			UPDATED_MACHINE                		
		)
		VALUES
		(
			SUPPLIERS_CONTACT_PERSONS_SEQ.NEXTVAL   ,
			V_SUPPLIER_ID_2                    ,  
			V_C6.JOB_TITLE                      ,  
			V_C6.PRIMARY_NAME                   , 
			V_C6.SECONDARY_NAME                 ,
			V_C6.TEL_NO1                        ,
			V_C6.TEL_NO2                        ,
			V_C6.FAX_NO1                        ,
			V_C6.PERSONAL_MOBILE                ,
			V_C6.BUSINESS_MOBILE                ,
			V_C6.EMAIL                          ,
			V_C6.NOTES                          ,
			V_C6.CREATED_BY                     ,
			V_C6.CREATION_DATE                  ,
			V_C6.CREATION_MACHINE               ,
			V_C6.UPDATED_BY                     ,
			V_C6.UPDATED_DATE                   ,
			V_C6.UPDATED_MACHINE                		
		);


	END LOOP;
	CLOSE C6;

	OPEN C7(:NEW.SUPPLIER_ID);
	LOOP
		FETCH C7 INTO V_C7;
		EXIT WHEN C7%NOTFOUND;

		V_ACCOUNT_ID := NULL;

		OPEN C5(V_C7.ACCOUNT_ID);
		FETCH C5 INTO V_ACCOUNT_CODE;
		CLOSE C5;

		OPEN C4(V_ACCOUNT_CODE, :NEW.BRANCH_ID);
		FETCH C4 INTO V_ACCOUNT_ID;
		CLOSE C4;
	
		IF V_ACCOUNT_ID IS NULL THEN
			RAISE_APPLICATION_ERROR(-20901,'account not defined in this branch') ;
		END IF;

		INSERT INTO SUPPLIERS_ACC
		(
			SUPPLIER_ID    		       ,
			ACCOUNT_ID     		       ,
			ACCOUNT_TYPE		       ,	
			CREATED_BY                     ,
			CREATION_DATE                  ,
			CREATION_MACHINE               ,
			UPDATED_BY                     ,
			UPDATED_DATE                   ,
			UPDATED_MACHINE                		
		)
		VALUES
		(
			V_SUPPLIER_ID_2                    ,  
			V_ACCOUNT_ID		       ,
			V_C7.ACCOUNT_TYPE		       ,	
			V_C7.CREATED_BY                     ,
			V_C7.CREATION_DATE                  ,
			V_C7.CREATION_MACHINE               ,
			V_C7.UPDATED_BY                     ,
			V_C7.UPDATED_DATE                   ,
			V_C7.UPDATED_MACHINE                		
		);

	END LOOP;
	CLOSE C7;

    ELSIF DELETING THEN
	OPEN C1(:OLD.SUPPLIER_ID);
	FETCH C1 INTO V_C1;
	CLOSE C1;

	DELETE FROM SUPPLIERS_ACC
	WHERE SUPPLIER_ID IN
		( SELECT SUPPLIER_ID
		  FROM SUPPLIERS
		  WHERE USER_CODE = V_C1.USER_CODE
	          AND BRANCH_ID = :OLD.BRANCH_ID);

	DELETE FROM SUPPLIERS_CONTACT_PERSONS
	WHERE SUPPLIER_ID IN
		( SELECT SUPPLIER_ID
		  FROM SUPPLIERS
		  WHERE USER_CODE = V_C1.USER_CODE
	          AND BRANCH_ID = :OLD.BRANCH_ID);


	DELETE FROM SUPPLIERS
	WHERE USER_CODE = V_C1.USER_CODE
	AND BRANCH_ID = :OLD.BRANCH_ID;
    END IF;
END;
/








