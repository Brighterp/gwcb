
ALTER TABLE PAY_PROVISION_SETUP_H ADD 
(
  NEXT1_RULE_YEARS  NUMBER(2)             ,
  NEXT1_RULE_DAYS   NUMBER(2)             ,
  NEXT2_RULE_YEARS  NUMBER(2)             ,
  NEXT2_RULE_DAYS   NUMBER(2)             ,
  NEXT3_RULE_YEARS  NUMBER(2)             ,
  NEXT3_RULE_DAYS   NUMBER(2)             
) ;


ALTER TABLE PAY_PROVISION_SETUP_H ADD FIRST_YEAR_COMPLETE NUMBER(1) DEFAULT 2 ;


