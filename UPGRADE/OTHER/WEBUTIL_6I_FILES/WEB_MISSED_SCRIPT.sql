
ALTER TABLE SUPPLIERS ADD MAX_CREDIT_LIMIT  NUMBER(17,5)
/ 


CREATE TABLE PUR_INVOICES_ITEMS_S
(
  DOCUMENT_ID       NUMBER(15)                  NOT NULL,
  DEPARTMENT_ID     NUMBER(15)                  NOT NULL,
  ARRANGMENT_NO     NUMBER(15)                  NOT NULL,
  SERIAL_NUMBER     VARCHAR2(25 BYTE)           NOT NULL,
  NOTES             VARCHAR2(100 BYTE),
  CREATED_BY        VARCHAR2(25 BYTE),
  CREATION_DATE     DATE,
  CREATION_MACHINE  VARCHAR2(25 BYTE),
  UPDATED_BY        VARCHAR2(25 BYTE),
  UPDATED_DATE      DATE,
  UPDATED_MACHINE   VARCHAR2(25 BYTE)
)
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING
/

COMMENT ON TABLE PUR_INVOICES_ITEMS_S IS 'Created By Sameh Noshi'
/


CREATE UNIQUE INDEX PK_SERIAL_F_0009 ON PUR_INVOICES_ITEMS_S
(DOCUMENT_ID, DEPARTMENT_ID, ARRANGMENT_NO, SERIAL_NUMBER)
LOGGING
NOPARALLEL
/


CREATE UNIQUE INDEX UK_SERIAL_F_0009 ON PUR_INVOICES_ITEMS_S
(DOCUMENT_ID, SERIAL_NUMBER)
LOGGING
NOPARALLEL
/


ALTER TABLE PUR_INVOICES_ITEMS_S ADD (
  CONSTRAINT PK_SERIAL_F_0009
 PRIMARY KEY
 (DOCUMENT_ID, DEPARTMENT_ID, ARRANGMENT_NO, SERIAL_NUMBER))
/

ALTER TABLE PUR_INVOICES_ITEMS_S ADD (
  CONSTRAINT UK_SERIAL_F_0009
 UNIQUE (DOCUMENT_ID, SERIAL_NUMBER))
/


ALTER TABLE PUR_INVOICES_ITEMS_S ADD (
  CONSTRAINT FK_SERIAL_F_0009 
 FOREIGN KEY (DOCUMENT_ID, DEPARTMENT_ID, ARRANGMENT_NO) 
 REFERENCES PUR_INVOICES_ITEMS (DOCUMENT_ID,DEPARTMENT_ID,ARRANGMENT_NO)
    ON DELETE CASCADE)
/


CREATE TABLE STORES_ITEMS_S
(
  STORES_ID         NUMBER(15)                  NOT NULL,
  ITEMS_ID          NUMBER(15)                  NOT NULL,
  SERIAL_NUMBER     VARCHAR2(25 BYTE)           NOT NULL,
  CURRENT_BALANCE   NUMBER(15)                  NOT NULL,
  NOTES             VARCHAR2(100 BYTE),
  CREATED_BY        VARCHAR2(25 BYTE),
  CREATION_DATE     DATE,
  CREATION_MACHINE  VARCHAR2(25 BYTE),
  UPDATED_BY        VARCHAR2(25 BYTE),
  UPDATED_DATE      DATE,
  UPDATED_MACHINE   VARCHAR2(25 BYTE)
)
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING
/

COMMENT ON TABLE STORES_ITEMS_S IS 'Created By Sameh Noshi'
/


CREATE UNIQUE INDEX PK_SERIAL_F_0012 ON STORES_ITEMS_S
(STORES_ID, ITEMS_ID, SERIAL_NUMBER)
LOGGING
NOPARALLEL
/


ALTER TABLE STORES_ITEMS_S ADD (
  CONSTRAINT UK_SERIAL_F_0012
 CHECK (CURRENT_BALANCE between 0 and 1))
/

ALTER TABLE STORES_ITEMS_S ADD (
  CONSTRAINT PK_SERIAL_F_0012
 PRIMARY KEY
 (STORES_ID, ITEMS_ID, SERIAL_NUMBER))
/


ALTER TABLE STORES_ITEMS_S ADD (
  CONSTRAINT FK_SERIAL_F_0012 
 FOREIGN KEY (ITEMS_ID, STORES_ID) 
 REFERENCES STORES_ITEMS (ITEMS_ID,STORES_ID)
    ON DELETE CASCADE)
/


CREATE OR REPLACE FUNCTION GET_ITEM_NAT(V_ITEMS_ID NUMBER) RETURN NUMBER IS
CURSOR C1 IS
	SELECT ITEM_NATURE
	FROM ITEMS
	WHERE ITEMS_ID = V_ITEMS_ID;
V_ITEM_NATURE NUMBER;
BEGIN
	OPEN C1;
	FETCH C1 INTO V_ITEM_NATURE;
	CLOSE C1;

	RETURN(NVL(V_ITEM_NATURE,1));

END;
/


CREATE TABLE PUR_RETURNES_ITEMS_S
(
  DOCUMENT_ID       NUMBER(15)                  NOT NULL,
  DEPARTMENT_ID     NUMBER(15)                  NOT NULL,
  ARRANGMENT_NO     NUMBER(15)                  NOT NULL,
  SERIAL_NUMBER     VARCHAR2(25 BYTE)           NOT NULL,
  NOTES             VARCHAR2(100 BYTE),
  CREATED_BY        VARCHAR2(25 BYTE),
  CREATION_DATE     DATE,
  CREATION_MACHINE  VARCHAR2(25 BYTE),
  UPDATED_BY        VARCHAR2(25 BYTE),
  UPDATED_DATE      DATE,
  UPDATED_MACHINE   VARCHAR2(25 BYTE)
)
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING
/

COMMENT ON TABLE PUR_RETURNES_ITEMS_S IS 'Created By Sameh Noshi'
/


CREATE UNIQUE INDEX PK_SERIAL_F_0010 ON PUR_RETURNES_ITEMS_S
(DOCUMENT_ID, DEPARTMENT_ID, ARRANGMENT_NO, SERIAL_NUMBER)
LOGGING
NOPARALLEL
/


CREATE UNIQUE INDEX UK_SERIAL_F_0010 ON PUR_RETURNES_ITEMS_S
(DOCUMENT_ID, SERIAL_NUMBER)
LOGGING
NOPARALLEL
/


ALTER TABLE PUR_RETURNES_ITEMS_S ADD (
  CONSTRAINT PK_SERIAL_F_0010
 PRIMARY KEY
 (DOCUMENT_ID, DEPARTMENT_ID, ARRANGMENT_NO, SERIAL_NUMBER))
/

ALTER TABLE PUR_RETURNES_ITEMS_S ADD (
  CONSTRAINT UK_SERIAL_F_0010
 UNIQUE (DOCUMENT_ID, SERIAL_NUMBER))
/


ALTER TABLE PUR_RETURNES_ITEMS_S ADD (
  CONSTRAINT FK_SERIAL_F_0010 
 FOREIGN KEY (DOCUMENT_ID, DEPARTMENT_ID, ARRANGMENT_NO) 
 REFERENCES PUR_RETURNES_ITEMS (DOCUMENT_ID,DEPARTMENT_ID,ARRANGMENT_NO)
    ON DELETE CASCADE)
/




ALTER TABLE PUR_SERVICES_INVOICES ADD ADVANCED_PAYMENT  NUMBER(17,5)
/ 



ALTER TABLE SAL_INVOICES ADD TOTAL_COST   NUMBER(17,5)
/ 
                    

CREATE TABLE SAL_INVOICES_ITEMS_S
(
  DOCUMENT_ID       NUMBER(15)                  NOT NULL,
  DEPARTMENT_ID     NUMBER(15)                  NOT NULL,
  ARRANGMENT_NO     NUMBER(15)                  NOT NULL,
  SERIAL_NUMBER     VARCHAR2(25 BYTE)           NOT NULL,
  NOTES             VARCHAR2(100 BYTE),
  CREATED_BY        VARCHAR2(25 BYTE),
  CREATION_DATE     DATE,
  CREATION_MACHINE  VARCHAR2(25 BYTE),
  UPDATED_BY        VARCHAR2(25 BYTE),
  UPDATED_DATE      DATE,
  UPDATED_MACHINE   VARCHAR2(25 BYTE)
)
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;

COMMENT ON TABLE SAL_INVOICES_ITEMS_S IS 'Created By Sameh Noshi';


CREATE UNIQUE INDEX PK_SERIAL_F_0007 ON SAL_INVOICES_ITEMS_S
(DOCUMENT_ID, DEPARTMENT_ID, ARRANGMENT_NO, SERIAL_NUMBER)
LOGGING
NOPARALLEL;


CREATE UNIQUE INDEX UK_SERIAL_F_0007 ON SAL_INVOICES_ITEMS_S
(DOCUMENT_ID, SERIAL_NUMBER)
LOGGING
NOPARALLEL;


ALTER TABLE SAL_INVOICES_ITEMS_S ADD (
  CONSTRAINT PK_SERIAL_F_0007
 PRIMARY KEY
 (DOCUMENT_ID, DEPARTMENT_ID, ARRANGMENT_NO, SERIAL_NUMBER));

ALTER TABLE SAL_INVOICES_ITEMS_S ADD (
  CONSTRAINT UK_SERIAL_F_0007
 UNIQUE (DOCUMENT_ID, SERIAL_NUMBER));


ALTER TABLE SAL_INVOICES_ITEMS_S ADD (
  CONSTRAINT FK_SERIAL_F_0007 
 FOREIGN KEY (DOCUMENT_ID, DEPARTMENT_ID, ARRANGMENT_NO) 
 REFERENCES SAL_INVOICES_ITEMS (DOCUMENT_ID,DEPARTMENT_ID,ARRANGMENT_NO)
    ON DELETE CASCADE);
    
    
    
CREATE TABLE SAL_RETURNES_ITEMS_S
(
  DOCUMENT_ID       NUMBER(15)                  NOT NULL,
  DEPARTMENT_ID     NUMBER(15)                  NOT NULL,
  ARRANGMENT_NO     NUMBER(15)                  NOT NULL,
  SERIAL_NUMBER     VARCHAR2(25 BYTE)           NOT NULL,
  NOTES             VARCHAR2(100 BYTE),
  CREATED_BY        VARCHAR2(25 BYTE),
  CREATION_DATE     DATE,
  CREATION_MACHINE  VARCHAR2(25 BYTE),
  UPDATED_BY        VARCHAR2(25 BYTE),
  UPDATED_DATE      DATE,
  UPDATED_MACHINE   VARCHAR2(25 BYTE)
)
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;

COMMENT ON TABLE SAL_RETURNES_ITEMS_S IS 'Created By Sameh Noshi';


CREATE UNIQUE INDEX PK_SERIAL_F_0008 ON SAL_RETURNES_ITEMS_S
(DOCUMENT_ID, DEPARTMENT_ID, ARRANGMENT_NO, SERIAL_NUMBER)
LOGGING
NOPARALLEL;


CREATE UNIQUE INDEX UK_SERIAL_F_0008 ON SAL_RETURNES_ITEMS_S
(DOCUMENT_ID, SERIAL_NUMBER)
LOGGING
NOPARALLEL;


ALTER TABLE SAL_RETURNES_ITEMS_S ADD (
  CONSTRAINT PK_SERIAL_F_0008
 PRIMARY KEY
 (DOCUMENT_ID, DEPARTMENT_ID, ARRANGMENT_NO, SERIAL_NUMBER));

ALTER TABLE SAL_RETURNES_ITEMS_S ADD (
  CONSTRAINT UK_SERIAL_F_0008
 UNIQUE (DOCUMENT_ID, SERIAL_NUMBER));


ALTER TABLE SAL_RETURNES_ITEMS_S ADD (
  CONSTRAINT FK_SERIAL_F_0008 
 FOREIGN KEY (DOCUMENT_ID, DEPARTMENT_ID, ARRANGMENT_NO) 
 REFERENCES SAL_RETURNES_ITEMS (DOCUMENT_ID,DEPARTMENT_ID,ARRANGMENT_NO)
    ON DELETE CASCADE);    
