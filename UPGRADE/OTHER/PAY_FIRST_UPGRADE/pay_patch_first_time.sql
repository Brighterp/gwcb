----------
CREATE OR REPLACE FUNCTION CALCULATE_EQUATION_VALUE(
  wequ_no IN NUMBER ,
  wequ_val IN NUMBER ,
  wemp_no IN NUMBER ,
  wbranch   IN NUMBER ,
  wmonth IN DATE ,
  wfrom  IN DATE ,
  wto    IN DATE ,
  wpayment IN NUMBER,
  wcalc_type  NUMBER)
RETURN NUMBER IS
Begin
/*********************************************************************************/
/*           This Function Has Been Created By Ahlam Abdullah Gomah              */
/*********************************************************************************/

--- wcalc_type   1 FOR BASIC DATA , 2 FOR CALCULATED DATA
    declare
              type out_values is
              table of number(15,2) index by binary_integer;
              curval   out_values;
              prvval        out_values;
              stcs   out_values;
          --    currat   out_values;
      v1    number(15,2) := 0;
      v2    number(15,2) := 0;
      v3    number(15,2) := 0;
      v4    number(15,2) := 0;
      v5    number(15,2) := 0;
      v6    number(15,2) := 0;
      v7    number(15,2) := 0;
      v8    number(15,2) := 0;
      v9    number(15,2) := 0;
    E   NUMBER(15,2) := 0;
      E1    NUMBER(15,2) := 0;
        absent number(15,2);
        punish number(15,2);
        sick   number(15,2);
        vac    number(15,2);
        wf    date;
        wt     date;
              /************ BEGIN PROCEDURES ***********************/
              /************ BEGIN EQU_VARIABLES ********************/
              procedure EQU_variables IS
                   CURSOR eq_variables  IS
                      SELECT   LINE_NO  SER,
                      ENTITLE_DEDUCT_ID    BAND_CODE ,
                      ENTITLE_DEDUCT_FLAG  BAND_FLAG
                      FROM  PAY_EQUATION_DETAIL
                      WHERE EQUATION_ID = wequ_no;
--------------------------data from basic salary
                   CURSOR eq_values(wflag  number,wcode NUMBER) IS
                      SELECT nvl(AMOUNT ,0)  value
                      FROM   EMP_ENTITLE_DEDUCT_MIRROR
                      where  EMPLOYEE_ID      = wemp_no
                      and    TO_CHAR(SAL_MONTH,'MM-RRRR') = TO_CHAR(wmonth,'MM-RRRR')
                      and    PAYMENT_NUMBER   = wpayment
                      and    ENTITLE_DEDUCT_FLAG   = wflag
                      and    ENTITLE_DEDUCT_ID     = wcode
                      order by EMPLOYEE_ID ,SAL_MONTH ;

                   CURSOR eq_values_p(wflag  number,wcode NUMBER) IS
                      SELECT nvl(AMOUNT ,0)  value
                      FROM   EMP_ENTITLE_DEDUCT_MIRROR
                      where  EMPLOYEE_ID      = wemp_no
                      and    TO_CHAR(SAL_MONTH,'MM-RRRR') = TO_CHAR(wmonth,'MM-RRRR')
                      and    PAYMENT_NUMBER   = wpayment
                      and    ENTITLE_DEDUCT_FLAG   = wflag
                      and    ENTITLE_DEDUCT_ID     = wcode
                      order by EMPLOYEE_ID ,SAL_MONTH ;

                   CURSOR eq_rates(wflag  number,wcode NUMBER) IS
                      SELECT nvl(ENTITLE_DEDUCT_VALUE ,0)  value
                      FROM   EMP_ENTITLE_DEDUCT_MIRROR
                      where  EMPLOYEE_ID      = wemp_no
                      and    SAL_MONTH       = wmonth
                      and    PAYMENT_NUMBER   = wpayment
                      and    ENTITLE_DEDUCT_FLAG   = wflag
                      and    ENTITLE_DEDUCT_ID     = wcode
                      order by EMPLOYEE_ID ,SAL_MONTH ;

                   CURSOR eq_prevs(wflag  number,wcode NUMBER,wprv_month DATE) IS
                      SELECT nvl(ENTITLE_DEDUCT_VALUE  ,0)  value
                      FROM   EMP_ENTITLE_DEDUCT_MIRROR
                      where  EMPLOYEE_ID      = wemp_no
                      and    TO_CHAR(SAL_MONTH,'MM-RRRR') = TO_CHAR(wprv_month,'MM-RRRR')
                      and    PAYMENT_NUMBER   = wpayment
                      and    ENTITLE_DEDUCT_FLAG   = wflag
                      and    ENTITLE_DEDUCT_ID     = wcode
                      order by EMPLOYEE_ID ,SAL_MONTH ;
--------------------------------------data from calculated month
                   CURSOR eq_values_cal(wflag  number,wcode NUMBER) IS
                      SELECT nvl(AMOUNT ,0)  value
                      FROM   EMPLOYEE_MONTH_TRANS
                      where  EMPLOYEE_ID      = wemp_no
                      and    TO_CHAR(MONTH,'MM-RRRR') = TO_CHAR(wmonth,'MM-RRRR')
                      and    PAYMENT_NUMBER   = wpayment
                      and    ENTITLE_DEDUCT_FLAG   = wflag
                      and    ENTITLE_DEDUCT_ID     = wcode
                      order by EMPLOYEE_ID ,MONTH ;

                   CURSOR eq_values_p_cal(wflag  number,wcode NUMBER) IS
                      SELECT nvl(AMOUNT ,0)  value
                      FROM   EMPLOYEE_MONTH_TRANS
                      where  EMPLOYEE_ID      = wemp_no
                      and    TO_CHAR(MONTH,'MM-RRRR') = TO_CHAR(wmonth,'MM-RRRR')
                      and    PAYMENT_NUMBER   = wpayment
                      and    ENTITLE_DEDUCT_FLAG   = wflag
                      and    ENTITLE_DEDUCT_ID     = wcode
                      order by EMPLOYEE_ID ,MONTH ;

                   CURSOR eq_rates_cal(wflag  number,wcode NUMBER) IS
                      SELECT nvl(ENTITLE_DEDUCT_VALUE ,0)  value
                      FROM   EMPLOYEE_MONTH_TRANS
                      where  EMPLOYEE_ID      = wemp_no
                      and    TO_CHAR(MONTH,'MM-RRRR') = TO_CHAR(wmonth,'MM-RRRR')
                      and    PAYMENT_NUMBER   = wpayment
                      and    ENTITLE_DEDUCT_FLAG   = wflag
                      and    ENTITLE_DEDUCT_ID     = wcode
                      order by EMPLOYEE_ID ,MONTH ;

                   CURSOR eq_prevs_cal(wflag  number,wcode NUMBER,wprv_month DATE) IS
                      SELECT nvl(ENTITLE_DEDUCT_VALUE  ,0)  value
                      FROM   EMPLOYEE_MONTH_TRANS
                      where  EMPLOYEE_ID      = wemp_no
                      and    TO_CHAR(MONTH,'MM-RRRR') = TO_CHAR(wprv_month,'MM-RRRR')
                      and    PAYMENT_NUMBER   = wpayment
                      and    ENTITLE_DEDUCT_FLAG   = wflag
                      and    ENTITLE_DEDUCT_ID     = wcode
                      order by EMPLOYEE_ID ,MONTH ;
                   cur     eq_values%rowtype;
                   cur_p   eq_values_p%rowtype;
                   j     integer:=0;
                   final number(15,2);
          old_mnth DATE;
/*********************************** End R ********************************************/
  begin
    old_mnth := ADD_MONTHS(wmonth , - 1) ;
    IF wcalc_type =  1 THEN
      for i in eq_variables
      loop
          j := j + 1;
          curval(I.SER) := 0;
          cur.value := 0;
          begin
            open  eq_values(i.band_flag,i.BAND_CODE);
            fetch eq_values into cur;
            close eq_values;
          exception when no_data_found
          then
              cur.value := 0;
          end ;
          curval(I.SER) := cur.value;
      end loop;

      for i in eq_variables
      loop
          j := j + 1;
          prvval(I.SER) := 0;
           cur.value := 0;
          begin
            open  eq_prevs(i.band_flag,i.BAND_CODE,old_mnth);
            fetch eq_prevs into cur;
            close eq_prevs;
          exception when no_data_found
          then
              cur.value := 0;
          end ;
          prvval(I.SER) := cur.value;
      end loop;

    ELSIF  wcalc_type =  2 THEN
      for i in eq_variables
      loop
          j := j + 1;
          curval(I.SER) := 0;
           cur.value := 0;
          begin
            open  eq_values_cal(i.band_flag,i.BAND_CODE);
            fetch eq_values_cal into cur;
            close eq_values_cal;
          exception when no_data_found
          then
              cur.value := 0;
          end;
          curval(I.SER) := cur.value;
      end loop;

      for i in eq_variables
      loop
          j := j + 1;
          prvval(I.SER) := 0;
           cur.value := 0;
          begin
            open  eq_prevs_cal(i.band_flag,i.BAND_CODE,old_mnth);
            fetch eq_prevs_cal into cur;
            close eq_prevs_cal;
          exception when no_data_found
          then
              cur.value := 0;
          end ;
         prvval(I.SER) := cur.value;
      end loop;
    END IF;  --- wcalc_type =  1
/*********************************** End R ********************************************/
  end;
  /************ END EQU_VARIABLES **********************/
  /************ BEGIN INSURANCE_VALUES *****************/
  procedure insurance_values is

    cursor  emp_def_data is    --- employee data
     select  nvl( FIXED_INSURANCE_VALUE,0)    FIX,
     nvl( VAR_INSURANCE_VALUE,0)      VARY,
     trunc(months_between(wmonth,HIREDATE) / 12 ,0) working_years,
     SOCIAL_STATUS  social_no,EMP_JOB_ID  job_no,EMP_DEPARTMENT_ID section_no,GROSS_SALARY ,
     PAY_CONTRACT_DEFINITION.USER_CODE  cont_no,
     trunc((months_between(wmonth,BIRTHDATE) /12)) emp_age,EMP_STATUS status_code , citizen
     from EMPLOYEES , PAY_CONTRACT_DEFINITION 
     where EMPLOYEE_ID = wemp_no
     and PAY_CONTRACT_DEFINITION.CONTRACT_ID = EMPLOYEES.CONTRACT_ID ;
     
    cursor insur_values(wmn  date) is   -- tax detail data
     select  nvl(INSURANCE_11_VALUE,0)       INSUR11,
     nvl(INSURANCE_26_VALUE,0)      INSUR26,
     nvl(INSURANCE_14_VALUE,0)      INSUR14,
     nvl(INSURANCE_24_VALUE,0)       INSUR24,
     nvl(TAX_ON_COMPANY_VALUE,0)   TAX_ON_COMP,
     nvl(TAX_ON_EMPLOYEE_VALUE,0)    TAX_ON_EMP,
     nvl(SOCIAL_EXCEPTION_VALUE,0)  SOCIAL_VALUE,
     nvl(TOTAL_ENTITLE_VALUE,0)      TOT_ESTH,
     nvl(TOTAL_DEDUCT_VALUE,0)      TOT_ESTK,
     NVL(TAX_CONTAINER , 0 ) TAX_CONTAINER
     from PAY_EMPLOYEE_TAX_HISTORY A1
     where A1.EMPLOYEE_ID    = wemp_no
     and TO_CHAR(a1.SAL_MONTH,'MM-RRRR')= TO_CHAR(wmn ,'MM-RRRR')
     and PAYMENT_NUMBER      = wpayment;

    cursor basic_entitle(wmn   date) is   ---  all fixed entilte
    select nvl(sum(AMOUNT),0) sum_val
    from   EMP_ENTITLE_DEDUCT_MIRROR A,ENTITLE_DEDUCT B
    where EMPLOYEE_ID = wemp_no
    and   TO_CHAR(SAL_MONTH,'MM-RRRR') = TO_CHAR(wmn,'MM-RRRR')
    and   A.ENTITLE_DEDUCT_ID = B.ENTITLE_DEDUCT_ID
    and   A.ENTITLE_DEDUCT_FLAG = B.ENTITLE_DEDUCT_FLAG
    and   to_char(B.ENTITLE_DEDUCT_TYPE) like ('1%');

    cursor basic_deduct(wmn  date) is   ---  all fixed entilte
    select nvl(sum(AMOUNT),0) sum_val
    from   EMP_ENTITLE_DEDUCT_MIRROR A,ENTITLE_DEDUCT B
    where EMPLOYEE_ID = wemp_no
    and   TO_CHAR(SAL_MONTH,'MM-RRRR') = TO_CHAR(wmn,'MM-RRRR')
    and   A.ENTITLE_DEDUCT_ID = B.ENTITLE_DEDUCT_ID
    and   A.ENTITLE_DEDUCT_FLAG = B.ENTITLE_DEDUCT_FLAG
    and   to_char(B.ENTITLE_DEDUCT_TYPE) like ('2%');

    cursor get_due1(wmn   date, wtype  char) is   ---- all   basic , fixed   entilte
    select nvl(sum(AMOUNT),0) sum_val
    from   EMP_ENTITLE_DEDUCT_MIRROR A,ENTITLE_DEDUCT B
    where EMPLOYEE_ID = wemp_no
    and   TO_CHAR(SAL_MONTH,'MM-RRRR') = TO_CHAR(wmn,'MM-RRRR')
    and   A.ENTITLE_DEDUCT_ID = B.ENTITLE_DEDUCT_ID
    and   A.ENTITLE_DEDUCT_FLAG = B.ENTITLE_DEDUCT_FLAG
    and   B.ENTITLE_DEDUCT_TYPE = wtype;

    cursor loan_due1(wmn date) is   ---- all   loan , fixed   entilte
    select sum(A.AMOUNT)
    from   EMPLOYEE_LOAN_DTL A ,EMPLOYEE_LOAN  B
    where  A.EMPLOYEE_LOAN_ID = B.EMPLOYEE_LOAN_ID
    AND    B.EMPLOYEE_ID      = wemp_no
    and    to_char(MONTH,'MM-yyyy') =  TO_CHAR(wmn,'MM-YYYY')
    and    POST_FLAG = 1
    group by B.EMPLOYEE_ID ;

-------------------DATA FROM CALCULATED MONTH  
    cursor basic_entitle_1(wmn   date) is   ---  all fixed entilte
    select nvl(sum(AMOUNT),0) sum_val
    from   EMPLOYEE_MONTH_TRANS A,ENTITLE_DEDUCT B
    where EMPLOYEE_ID = wemp_no
    and   TO_CHAR(MONTH,'MM-RRRR') = TO_CHAR(wmn,'MM-RRRR')
    and   A.ENTITLE_DEDUCT_ID = B.ENTITLE_DEDUCT_ID
    and   A.ENTITLE_DEDUCT_FLAG = B.ENTITLE_DEDUCT_FLAG
    and   to_char(B.ENTITLE_DEDUCT_TYPE) like ('1%');

    cursor basic_deduct_1(wmn  date) is   ---  all fixed entilte
    select nvl(sum(AMOUNT),0) sum_val
    from   EMPLOYEE_MONTH_TRANS A,ENTITLE_DEDUCT B
    where EMPLOYEE_ID = wemp_no
    and   TO_CHAR(MONTH,'MM-RRRR') = TO_CHAR(wmn,'MM-RRRR')
    and   A.ENTITLE_DEDUCT_ID = B.ENTITLE_DEDUCT_ID
    and   A.ENTITLE_DEDUCT_FLAG = B.ENTITLE_DEDUCT_FLAG
    and   to_char(B.ENTITLE_DEDUCT_TYPE) like ('2%');

    cursor get_due1_1(wmn   date,wtype  char) is   ---- all   basic , fixed   entilte
    select nvl(sum(AMOUNT),0) sum_val
    from   EMPLOYEE_MONTH_TRANS A,ENTITLE_DEDUCT B
    where EMPLOYEE_ID = wemp_no
    and   TO_CHAR(MONTH,'MM-RRRR') = TO_CHAR(wmn,'MM-RRRR')
    and   A.ENTITLE_DEDUCT_ID = B.ENTITLE_DEDUCT_ID
    and   A.ENTITLE_DEDUCT_FLAG = B.ENTITLE_DEDUCT_FLAG
    and   B.ENTITLE_DEDUCT_TYPE = wtype;
---------------------------------------------------------------------
    cur_emp_def_data        emp_def_data%rowtype;
    cur_insur_values   insur_values%rowtype;
    rec_basic_due           basic_entitle%rowtype;
    rec_basic_due1         get_due1%rowtype;
    wdamga_items number(15,2);
    old_basic            number(15,2) := 0; --payroll.l_value%type;
    old_mnth            DATE;

  begin
     old_mnth := ADD_MONTHS(wmonth , - 1) ;
    /********************/
    open  emp_def_data;
    fetch emp_def_data into cur_emp_def_data;

    stcs(81) := cur_emp_def_data.cont_no;
    stcs(82) := cur_emp_def_data.status_code;
    stcs(83) := cur_emp_def_data.job_no;
    stcs(84) := cur_emp_def_data.emp_age;
    stcs(85) := cur_emp_def_data.social_no;
    stcs(86) := cur_emp_def_data.section_no;
    stcs(87) := cur_emp_def_data.citizen;
    stcs(88) := cur_emp_def_data.working_years;
    stcs(89)  := cur_emp_def_data.fix;
    stcs(90)  := cur_emp_def_data.vary;
    stcs(91)  := cur_emp_def_data.gross_salary;
    close emp_def_data;

    open  insur_values(wmonth);
    fetch insur_values into cur_insur_values;

    stcs(55)  := cur_insur_values.insur14 ;
    stcs(56)  := cur_insur_values.insur11;
    stcs(8)  := cur_insur_values.insur11  + cur_insur_values.insur14;
    stcs(57)  := cur_insur_values.insur26 ;
    stcs(58)  := cur_insur_values.insur24 ;
    stcs(9)  := cur_insur_values.insur26  + cur_insur_values.insur24;
    stcs(59)  := cur_insur_values.TAX_ON_EMP;
    stcs(60)  := cur_insur_values.TAX_ON_COMP;
    stcs(67)  := cur_insur_values.TAX_CONTAINER;
    stcs(69)  := cur_insur_values.SOCIAL_VALUE;
    close insur_values;

    open insur_values(old_mnth);
    fetch insur_values into cur_insur_values;
    stcs(61)  := cur_insur_values.insur14 ;
    stcs(62)  := cur_insur_values.insur11;
    stcs(18)  := cur_insur_values.insur11  + cur_insur_values.insur14;
    stcs(63)  := cur_insur_values.insur26 ;
    stcs(64)  := cur_insur_values.insur24 ;
    stcs(19)  := cur_insur_values.insur26  + cur_insur_values.insur24;
    stcs(65)  := cur_insur_values.TAX_ON_EMP;
    stcs(66)  := cur_insur_values.TAX_ON_COMP;
    stcs(70)  := cur_insur_values.TAX_CONTAINER;
    stcs(72)  := cur_insur_values.SOCIAL_VALUE;
    close insur_values;

    if wcalc_type = 1 then
        open basic_entitle(wmonth);  -- all cur  entitle
        fetch basic_entitle into rec_basic_due;
        stcs(51) := rec_basic_due.sum_val;
        close basic_entitle;


        open basic_entitle(old_mnth);  -- all last  entitle
        fetch basic_entitle into rec_basic_due;
        stcs(52) := rec_basic_due.sum_val;
        close basic_entitle;


        open basic_deduct(wmonth);  -- all cur  deduct
        fetch basic_deduct into rec_basic_due;
        stcs(53) := rec_basic_due.sum_val;
        close basic_deduct;


        open basic_deduct(old_mnth);  -- all last  deduct
        fetch basic_deduct into rec_basic_due;
        stcs(54) := rec_basic_due.sum_val;
        close basic_deduct;


        open get_due1(wmonth,'11');
        fetch get_due1 into rec_basic_due1;
        stcs(1) := rec_basic_due1.sum_val;
        close get_due1;

        open get_due1(old_mnth,'11');
        fetch get_due1 into rec_basic_due1;
        stcs(11) := rec_basic_due1.sum_val;
        old_basic := rec_basic_due1.sum_val;
        close get_due1;

        open  get_due1(wmonth,'12');
        fetch get_due1 into rec_basic_due1;
        stcs(2) := rec_basic_due1.sum_val;
        close get_due1;

        open get_due1(old_mnth,'12');
        fetch get_due1 into rec_basic_due1;
        stcs(12) := rec_basic_due1.sum_val;
        close get_due1;

        open get_due1(wmonth,'13');
        fetch get_due1 into rec_basic_due1;
        stcs(3) := rec_basic_due1.sum_val;
        close get_due1;

        open get_due1(old_mnth,'13');
        fetch get_due1 into rec_basic_due1;
        stcs(13) := rec_basic_due1.sum_val;
        close get_due1;
    elsif wcalc_type = 2 then
        open basic_entitle_1(wmonth);  -- all cur  entitle
        fetch basic_entitle_1 into rec_basic_due;
        stcs(51) := rec_basic_due.sum_val;
        close basic_entitle_1;

        open basic_entitle_1(old_mnth);  -- all last  entitle
        fetch basic_entitle_1 into rec_basic_due;
        stcs(52) := rec_basic_due.sum_val;
        close basic_entitle_1;

        open basic_deduct_1(wmonth);  -- all cur  deduct
        fetch basic_deduct_1 into rec_basic_due;
        stcs(53) := rec_basic_due.sum_val;
        close basic_deduct_1;

        open basic_deduct_1(old_mnth);  -- all last  deduct
        fetch basic_deduct_1 into rec_basic_due;
        stcs(54) := rec_basic_due.sum_val;
        close basic_deduct_1;

        open get_due1_1(wmonth,'11');
        fetch get_due1_1 into rec_basic_due1;
        stcs(1) := rec_basic_due1.sum_val;
        close get_due1_1;

        open get_due1_1(old_mnth,'11');
        fetch get_due1_1 into rec_basic_due1;
        stcs(11) := rec_basic_due1.sum_val;
        old_basic := rec_basic_due1.sum_val;
        close get_due1_1;

        open get_due1_1(wmonth,'12');
        fetch get_due1_1 into rec_basic_due1;
        stcs(2) := rec_basic_due1.sum_val;
        close get_due1_1;

        open get_due1_1(old_mnth,'12');
        fetch get_due1_1 into rec_basic_due1;
        stcs(12) := rec_basic_due1.sum_val;
        close get_due1_1;

        open get_due1_1(wmonth,'13');
        fetch get_due1_1 into rec_basic_due1;
        stcs(3) := rec_basic_due1.sum_val;
        close get_due1_1;

        open get_due1_1(old_mnth,'13');
        fetch get_due1_1 into rec_basic_due1;
        stcs(13) := rec_basic_due1.sum_val;
        close get_due1_1;
    end if;

    open get_due1(wmonth,'15');
    fetch get_due1 into rec_basic_due1;
    stcs(4) := rec_basic_due1.sum_val;
    close get_due1;

    open get_due1(old_mnth,'15');
    fetch get_due1 into rec_basic_due1;
    stcs(14) := rec_basic_due1.sum_val;
    close get_due1;

    open get_due1(wmonth,'16');
    fetch get_due1 into rec_basic_due1;
    stcs(5) := rec_basic_due1.sum_val;
    close get_due1;

    open get_due1(old_mnth,'16');
    fetch get_due1 into rec_basic_due1;
    stcs(15) := rec_basic_due1.sum_val;
    close get_due1;

    open get_due1(wmonth,'17');
    fetch get_due1 into rec_basic_due1;
    stcs(6) := rec_basic_due1.sum_val;
    close get_due1;

    open get_due1(old_mnth,'17');
    fetch get_due1 into rec_basic_due1;
    stcs(16) := rec_basic_due1.sum_val;
    close get_due1;

    open get_due1(wmonth,'21');
    fetch get_due1 into rec_basic_due1;
    stcs(7) := rec_basic_due1.sum_val;
    close get_due1;

    open get_due1(old_mnth,'21');
    fetch get_due1 into rec_basic_due1;
    stcs(17) := rec_basic_due1.sum_val;
    close get_due1;

    open loan_due1(wmonth);
    fetch loan_due1 into rec_basic_due1;
    stcs(10) := rec_basic_due1.sum_val;
    close loan_due1;

    open loan_due1(old_mnth);
    fetch loan_due1 into rec_basic_due1;
    stcs(20) := rec_basic_due1.sum_val;
    close loan_due1;
    end;
    /************ END INSURANCE_VALUES   AHLAM *******************/
   procedure time_attend_values is    --??? ??? ????? ???????  ?????
-- HERE WE WILL  find time_att data , all vacation data
    cursor get_formal_vacation(vf date,vt date) is
        select DECODE( SIGN(TO_DATE - vt) , 1 , (vt - FROM_DATE),(TO_DATE - FROM_DATE))
        from FORMAL_VACATION
        where  FROM_DATE  between vf and vt
        and    BRANCH_ID = wbranch;

    cursor get_perm_hours(vf date,vt date) is
      select sum(to_number(to_char(TO_DATE,'hh24')) + to_number(to_char(TO_DATE,'mi'))/60 -
            to_number(to_char(FROM_DATE,'hh24')) - to_number(to_char(FROM_DATE,'mi'))/60)
      from EMPLOYEE_PERMISSION
      where EMPLOYEE_ID = wemp_no
      and   PERMISSION_DATE between nvl(vf,sysdate) and nvl(vt,sysdate)
      and   nvl(CONFIRMED , 2) = 1    ;

    cursor get_perm_count(vf date,vt date) is
      select count(*)
      from EMPLOYEE_PERMISSION
      where EMPLOYEE_ID = wemp_no
      and   PERMISSION_DATE between nvl(vf,sysdate) and nvl(vt,sysdate)
      and   nvl(CONFIRMED , 2) = 1    ;

    cursor get_misssion_days(vf date,vt date) is
      select sum( TO_DATE - FROM_DATE )
      from EMPLOYEE_MISSION
      where EMPLOYEE_ID = wemp_no
      and   MISSION_DATE between nvl(vf,sysdate) and nvl(vt,sysdate)
      and   nvl(CONFIRMED , 2) = 1    ;

    cursor get_misssion_count(vf date,vt date) is
      select count(*)
      from EMPLOYEE_MISSION
      where EMPLOYEE_ID = wemp_no
      and   MISSION_DATE between nvl(vf,sysdate) and nvl(vt,sysdate)
      and   nvl(CONFIRMED , 2) = 1    ;

   cursor get_vac_days(vf date,vt date, wtype   number) is
      select sum(NO_OF_VAC_DAYS) 
      from   EMPLOYEE_VACATION
      where EMPLOYEE_ID = wemp_no
      and   VACATION_DATE between nvl(vf,sysdate) and nvl(vt,sysdate)
      and   nvl(CONFIRMED , 2) = 1
      and   VACATION_TYPES_ID  = wtype ;
  cursor get_allpaid_days(vf date,vt date) is
      select sum(PAID_DAYS)
      from   EMPLOYEE_VACATION
      where EMPLOYEE_ID = wemp_no
      and   VACATION_DATE between nvl(vf,sysdate) and nvl(vt,sysdate)
      and   nvl(CONFIRMED , 2) = 1
      and   VACATION_TYPES_ID  <> 5 ;

   cursor get_setup is
     select   (nvl(DAYS_PER_MONTH,0)*NVL(HOURS_PER_DAY,0))  HOUR_MONTHLY ,
               FIRST_OFF_DAY, SECOND_OFF_DAY, HOURS_PER_DAY , DAYS_PER_MONTH
     from   BRANCH_SETUP
     where  BRANCH_ID = wbranch ;

    cur_get_setup            get_setup%rowtype;
    my_used    number(15,2);
    wlast_day number;        wd1 date;        wd2 date;        wnew number(15,3);
        wplus number(15,3);        wminus number(15,3);        wperm2 number(15,3);        wf1 date;
  begin

       stcs(41) := TO_NUMBER(TO_CHAR(wto,'dd'));
       wf := wfrom;
       wt := wto;
       wf1 := to_date(('01-01-'||to_char(wmonth,'yyyy')),'dd-mm-yyyy');

    open get_perm_hours(wf,wt);
    fetch get_perm_hours into stcs(37);        --   current  permissions hour
    close get_perm_hours;
    open get_perm_count(wf,wt);
    fetch get_perm_count into stcs(35);        --   current  permissions count
    close get_perm_count;
-------------------------------------------------------------------------------

    open get_misssion_days(wf,wt);
    fetch get_misssion_days into stcs(45);        --   current  misssion days
    close get_misssion_days;

    open get_misssion_count(wf,wt);
    fetch get_misssion_count into stcs(47);        --   current  misssion count
    close get_misssion_count;
---------------------------------------------------------------
    OPEN get_setup;
    FETCH get_setup INTO cur_get_setup ;
    CLOSE get_setup;

    stcs(42) := cur_get_setup.DAYS_PER_MONTH;
    stcs(43) := cur_get_setup.FIRST_OFF_DAY;
    stcs(44) := cur_get_setup.SECOND_OFF_DAY;
    stcs(49) := cur_get_setup.HOURS_PER_DAY;
---------------------------------------------------------------

    open get_formal_vacation(wf,wt);
    fetch get_formal_vacation into stcs(39);  --- current formal vacation
    if get_formal_vacation%notfound then
       stcs(39) := 0;
    end if;
    close get_formal_vacation;

    open get_formal_vacation(wf1,wt);   ---- all formal vacation in this year
    fetch get_formal_vacation into stcs(40);
    if get_formal_vacation%notfound then
       stcs(40) := 0;
    end if;
    close get_formal_vacation;
    
    open get_vac_days(wf,wt,1);
    fetch get_vac_days into stcs(23);        --   current  annual vacation days
    close get_vac_days;
    open get_vac_days(wf1,wt,1);
    fetch get_vac_days into stcs(36);        --   all  annual vacation  days in this year
    close get_vac_days;

    open get_vac_days(wf,wt,7);
    fetch get_vac_days into stcs(21);        --   current  normal vacation days
    close get_vac_days;
    open get_vac_days(wf1,wt,7);
    fetch get_vac_days into stcs(28);        --   all  normal vacation  days in this year
    close get_vac_days;

    open get_vac_days(wf,wt,3);
    fetch get_vac_days into stcs(24);        --   current  sick vacation days
    close get_vac_days;
    open get_vac_days(wf1,wt,3);
    fetch get_vac_days into stcs(31);        --   all  sick vacation  days in this year
    close get_vac_days;

    open get_vac_days(wf,wt,2);
    fetch get_vac_days into stcs(22);        --   current  casual vacation days
    close get_vac_days;
    open get_vac_days(wf1,wt,2);
    fetch get_vac_days into stcs(29);        --   all  casual vacation  days in this year
    close get_vac_days;

    open get_vac_days(wf,wt,5);
    fetch get_vac_days into stcs(25);        --   current  notpaid vacation days
    close get_vac_days;
    open get_vac_days(wf1,wt,5);
    fetch get_vac_days into stcs(32);        --   all  notpaid vacation  days in this year
    close get_vac_days;
    
    open get_vac_days(wf,wt,4);
    fetch get_vac_days into stcs(26);        --   current  wade3 vacation days
    close get_vac_days;
    open get_vac_days(wf1,wt,4);
    fetch get_vac_days into stcs(33);        --   all  wade3 vacation  days in this year
    close get_vac_days;
    
    open get_allpaid_days(wf,wt);
    fetch get_allpaid_days into stcs(27);        --   current  allpaid vacation days
    close get_allpaid_days;

    open get_allpaid_days(wf1,wt);
    fetch get_allpaid_days into stcs(34);        --   all  allpaid vacation  days in this year
    close get_allpaid_days;

    end;
              /************ END time_attend_values* ******************/
              /************ END PROCEDURES *************************/
  BEGIN
       insurance_values;
       equ_variables   ;
       time_attend_values;
    /*****************************************************************/
    /****** Not allowed to change any code before this line   *******/
    /*****************************************************************/


              /************ End Of Changed Code ********/
    RETURN nvl(wequ_val,0);
  END;
END CALCULATE_EQUATION_VALUE;
/


-----------
CREATE OR REPLACE FUNCTION SALARY_CALCULATE_EQUATION(
  wequ_no IN NUMBER ,
  wequ_val IN NUMBER ,
  wemp_no IN NUMBER ,
  wmonth IN DATE ,
  wpayment IN NUMBER ,
  wcalc_type  IN NUMBER)
RETURN NUMBER IS
    wfrom   DATE ;
    wto     DATE ;
    wbranch  NUMBER;
    
    OUT_VAL  NUMBER ;

    THE_CLOSE_DAY  NUMBER;
    THE_LAST_DAY   DATE;

    CURSOR GET_DAY IS
    SELECT NVL(CLOSE_DAY,30)
    FROM   BRANCH_SETUP
    WHERE  BRANCH_ID = wbranch ;

    CURSOR GET_TS_DAY IS
    SELECT nvl(CLOSE_DAY,30)
    FROM   TIME_SHEET_CLOSE_DAY
    WHERE  BRANCH_ID  = wbranch
    AND    TO_CHAR(MONTH,'MM-RRRR') = TO_CHAR(wmonth,'MM-RRRR') ;

BEGIN
/*********************************************************************************/
/*           This Function Has Been Created By Ahlam Abdullah Gomah              */
/*********************************************************************************/

--- wcalc_type   1 FOR BASIC DATA , 2 FOR CALCULATED DATA
    BEGIN
        SELECT BRANCH_ID 
        INTO   wbranch 
        FROM   EMPLOYEES 
        WHERE  EMPLOYEE_ID = wemp_no ;
        
        OPEN  GET_TS_DAY ;
        FETCH GET_TS_DAY INTO  THE_CLOSE_DAY ;
        IF GET_TS_DAY%NOTFOUND THEN
            OPEN GET_DAY ;
            FETCH GET_DAY INTO  THE_CLOSE_DAY ;
            CLOSE GET_DAY ;
        END IF;
        CLOSE GET_TS_DAY;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        THE_CLOSE_DAY := 30 ;
    END;

    THE_LAST_DAY := LAST_DAY(wmonth);

    IF  TO_NUMBER(TO_CHAR(THE_LAST_DAY,'DD')) = THE_CLOSE_DAY THEN
        wfrom  := to_date(('01'||'-'||TO_CHAR(wmonth,'mm-yyyy')),'DD-MM-YYYY');
        wto    := to_date((to_char(THE_CLOSE_DAY)||'-'||TO_CHAR(wmonth,'mm-yyyy')),'DD-MM-YYYY');
    ELSE
        IF TO_CHAR(wmonth,'mm') = '03' AND to_char(THE_CLOSE_DAY + 1) > TO_CHAR(LAST_DAY(ADD_MONTHS(wmonth,-1)),'DD') THEN 
            wfrom  := to_date((TO_CHAR(LAST_DAY(ADD_MONTHS(wmonth,-1)),'DD')||'-'||TO_CHAR(ADD_MONTHS(wmonth,-1),'mm-yyyy')),'DD-MM-YYYY');
            wto    := to_date((to_char(THE_CLOSE_DAY)||'-'||TO_CHAR(wmonth,'mm-yyyy')),'DD-MM-YYYY');
        ELSE
            wfrom  := to_date((to_char(THE_CLOSE_DAY + 1)||'-'||TO_CHAR(ADD_MONTHS(wmonth,-1),'mm-yyyy')),'DD-MM-YYYY');
            wto    := to_date((to_char(THE_CLOSE_DAY)||'-'||TO_CHAR(wmonth,'mm-yyyy')),'DD-MM-YYYY');
        END IF;
    END IF;

    OUT_VAL := CALCULATE_EQUATION_VALUE(wequ_no ,wequ_val ,wemp_no ,wbranch , wmonth , wfrom , wto ,wpayment ,wcalc_type );

    RETURN(NVL(OUT_VAL,0));
END;
/

------


UPDATE ENTITLE_DEDUCT SET SUBJECT_TO_INSURANCE = 3 WHERE SUBJECT_TO_INSURANCE = 2 
/

COMMIT
/

UPDATE ENTITLE_DEDUCT  SET REQUIRE_EQUATION = 2 WHERE REQUIRE_EQUATION IS NULL ;


UPDATE ENTITLE_DEDUCT  SET QUERY_ENTITLE_DEDUCT = 2 WHERE QUERY_ENTITLE_DEDUCT IS NULL ;


COMMIT
/
SET DEFINE OFF;
Insert into PAY_CONTRACT_DEFINITION
   (BRANCH_ID, CONTRACT_ID, USER_CODE, PRIMARY_NAME, SECONDARY_NAME, TEMP_CONTRACT, CONTRACT_MONTH_PERIOD)
 Values
   (1, 20000, '1', 'Basic Contract', '⁄ﬁœ œ«∆„', 2, 24 );
COMMIT;


SET DEFINE OFF;
Insert into PAY_PAYMENT
   (PAYMENT_NUMBER, BRANCH_ID, USER_CODE, PRIMARY_NAME, SECONDARY_NAME, SALARY_PAYMENT, PAYMENT_DAY, CREATED_BY, CREATION_DATE, CREATION_MACHINE, UPDATED_BY, UPDATED_DATE, UPDATED_MACHINE)
 Values
   (20000, 1, '1', 'Basic Payment', '’—›Ì… √”«”Ì…', 1, 26, 'ADMIN', TO_DATE('10/19/2010 11:17:10', 'MM/DD/YYYY HH24:MI:SS'), 'WAEL-PC', 'ADMIN', TO_DATE('10/19/2010 12:21:02', 'MM/DD/YYYY HH24:MI:SS'), 'WAEL-PC');
COMMIT;


UPDATE EMPLOYEE_MONTH_TRANS 
SET ENTITLE_DEDUCT_VALUE = AMOUNT , PAYMENT_NUMBER = 20000 ;

commit
/

UPDATE EMPLOYEES_ENTITLE_DEDUCT
 SET  ENTITLE_DEDUCT_VALUE = AMOUNT , PAYMENT_NUMBER = 20000 
/
 
COMMIT
/

UPDATE EMPLOYEES_ENTITLE_DEDUCT
 SET  SAL_MONTH = nvl((select add_months(max(month),1)  from EMPLOYEE_MONTH_TRANS  
 where EMPLOYEE_MONTH_TRANS.EMPLOYEE_ID = EMPLOYEES_ENTITLE_DEDUCT.EMPLOYEE_ID), to_date(to_char(sysdate,'mm-yyyy'),'mm-yyyy'))
/


COMMIT
/


ALTER TABLE EMPLOYEES_ENTITLE_DEDUCT DROP CONSTRAINT  PK_PAY_0016 CASCADE ;

DROP INDEX PK_PAY_0016 ;

COMMIT
/


CREATE UNIQUE INDEX PK_PAY_0016 ON EMPLOYEES_ENTITLE_DEDUCT
(EMPLOYEE_ID, ENTITLE_DEDUCT_ID, ENTITLE_DEDUCT_FLAG , SAL_MONTH ,PAYMENT_NUMBER )
LOGGING
NOPARALLEL
/



ALTER TABLE EMPLOYEES_ENTITLE_DEDUCT ADD (
  CONSTRAINT PK_PAY_0016
 PRIMARY KEY
 (EMPLOYEE_ID, ENTITLE_DEDUCT_ID, ENTITLE_DEDUCT_FLAG, SAL_MONTH ,PAYMENT_NUMBER)
    USING INDEX 
 )
/

COMMIT
/





INSERT INTO EMP_ENTITLE_DEDUCT_MIRROR (EMPLOYEE_ID, ENTITLE_DEDUCT_ID, ENTITLE_DEDUCT_FLAG, AMOUNT, SAL_MONTH, PAYMENT_NUMBER, ENTITLE_DEDUCT_VALUE)
SELECT EMPLOYEE_ID, ENTITLE_DEDUCT_ID, ENTITLE_DEDUCT_FLAG, AMOUNT, SAL_MONTH, PAYMENT_NUMBER, ENTITLE_DEDUCT_VALUE
FROM EMPLOYEES_ENTITLE_DEDUCT ;

COMMIT;

/
CREATE OR REPLACE PROCEDURE COPY_EMP_ENT_DED  IS
CURSOR GET_ALL_MONTHS   IS
                        SELECT DISTINCT MONTH , EMPLOYEE_ID
                        FROM EMPLOYEE_MONTH_TRANS ;

CURSOR GET_DATA (EMP   NUMBER) IS SELECT  *
                                    FROM  EMPLOYEES_ENTITLE_DEDUCT
                                    WHERE EMPLOYEE_ID = EMP
                                    AND   SAL_MONTH = nvl((select add_months(max(month),1)
                                    from EMPLOYEE_MONTH_TRANS
                                    where EMPLOYEE_MONTH_TRANS.EMPLOYEE_ID = EMPLOYEES_ENTITLE_DEDUCT.EMPLOYEE_ID)
                                    , to_date(to_char(sysdate,'mm-yyyy'),'mm-yyyy'));


BEGIN
FOR J IN GET_ALL_MONTHS LOOP
    FOR I IN  GET_DATA(J.EMPLOYEE_ID ) LOOP
        IF J.MONTH <> I.SAL_MONTH THEN
            INSERT INTO EMPLOYEES_ENTITLE_DEDUCT ( EMPLOYEE_ID,
                                                   ENTITLE_DEDUCT_ID,
                                                   ENTITLE_DEDUCT_FLAG,
                                                   AMOUNT,
                                                   CREATED_BY,
                                                   CREATION_DATE,
                                                   CREATION_MACHINE,
                                                   UPDATED_BY,
                                                   UPDATED_DATE,
                                                   UPDATED_MACHINE,
                                                   SAL_MONTH,
                                                   PAYMENT_NUMBER,
                                                   ENTITLE_DEDUCT_VALUE)
                                           VALUES( I.EMPLOYEE_ID,
                                                   I.ENTITLE_DEDUCT_ID,
                                                   I.ENTITLE_DEDUCT_FLAG,
                                                   I.AMOUNT,
                                                   I.CREATED_BY,
                                                   I.CREATION_DATE,
                                                   I.CREATION_MACHINE,
                                                   I.UPDATED_BY,
                                                   I.UPDATED_DATE,
                                                   I.UPDATED_MACHINE,
                                                   TO_DATE('01-'||TO_CHAR(J.MONTH,'MM-RRRR')),
                                                   I.PAYMENT_NUMBER,
                                                   I.ENTITLE_DEDUCT_VALUE) ;
        END IF;
    END LOOP;
END LOOP;
COMMIT;
END;
/


EXEC  COPY_EMP_ENT_DED;


COMMIT;

update EMPLOYEES_ENTITLE_DEDUCT
set SAL_MONTH = TO_DATE('01-'||TO_CHAR(SAL_MONTH,'MM-RRRR'))
/

commit
/

ALTER TABLE EMPLOYEE_MONTH_TRANS DROP CONSTRAINT  PK_PAY_0057 CASCADE ;

DROP INDEX PK_PAY_0057 ;

COMMIT
/


CREATE UNIQUE INDEX PK_PAY_0057 ON EMPLOYEE_MONTH_TRANS
 (EMPLOYEE_ID, MONTH, ENTITLE_DEDUCT_ID, ENTITLE_DEDUCT_FLAG ,PAYMENT_NUMBER )
LOGGING
NOPARALLEL
/


ALTER TABLE EMPLOYEE_MONTH_TRANS ADD (
  CONSTRAINT PK_PAY_0057
 PRIMARY KEY
 (EMPLOYEE_ID, MONTH, ENTITLE_DEDUCT_ID, ENTITLE_DEDUCT_FLAG ,PAYMENT_NUMBER )
    USING INDEX )
/
    

COMMIT
/



ALTER TABLE EMPLOYEE_MONTH_TRANS_PRO DROP CONSTRAINT  PK_PAY_0056 CASCADE ;

DROP INDEX PK_PAY_0056 ;

UPDATE EMPLOYEE_MONTH_TRANS_PRO SET PAYMENT_NUMBER = 20000 
/

COMMIT
/

CREATE UNIQUE INDEX PK_PAY_0056 ON EMPLOYEE_MONTH_TRANS_PRO
(EMPLOYEE_ID, MONTH, ENTITLE_DEDUCT_ID, ENTITLE_DEDUCT_FLAG, COST_CENTER_ID ,PAYMENT_NUMBER )
LOGGING
NOPARALLEL
/



ALTER TABLE EMPLOYEE_MONTH_TRANS_PRO ADD (
  CONSTRAINT PK_PAY_0056
 PRIMARY KEY
 (EMPLOYEE_ID, MONTH, ENTITLE_DEDUCT_ID, ENTITLE_DEDUCT_FLAG, COST_CENTER_ID ,PAYMENT_NUMBER)
    USING INDEX )
/

COMMIT
/    


update  ENTITLE_DEDUCT set SUBJECT_TO_INSURANCE = 3 ,  SUBJECT_TO_TAX = 3 ;

commit;

UPDATE BRANCH_SETUP SET CALC_INSURANCE_FLAG  = 2 ,  CALC_TAX_FLAG = 2;

COMMIT
/

UPDATE EMPLOYEES SET  CONTRACT_ID = 20000 ;

COMMIT;


UPDATE EMPLOYEE_VACATION SET NO_OF_VAC_DAYS = PAID_DAYS + NOT_PAID_DAYS 
WHERE PAID_DAYS IS NOT NULL AND  NOT_PAID_DAYS IS NOT NULL ;

COMMIT;



UPDATE FUNCTIONS SET PRIMARY_NAME = 'Payroll System' WHERE FUNCTION_ID = 30
/

COMMIT
/


delete from PROMPTS_LANGUAGES where PROMPTS_ID ='APPOINTED DONE' ;

commit;


SET DEFINE OFF;
Insert into PROMPTS_LANGUAGES
   (LANGUAGE_ID, PROMPT_TEXT, PROMPTS_ID)
 Values
   (2, ' „ «·ﬁ»Ê·', 'APPOINTED DONE');
Insert into PROMPTS_LANGUAGES
   (LANGUAGE_ID, PROMPT_TEXT, PROMPTS_ID)
 Values
   (1, 'Accepted', 'APPOINTED DONE');
COMMIT;

--------------------


DELETE FROM PROMPTS_LANGUAGES WHERE PROMPTS_ID IN ( 'FILE STATUS'  , 'STOP SALARY' );

COMMIT;


-----------------

SET DEFINE OFF;
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (1, 'All Basic Salary - Current', '«Ã„«·Ï «·»‰Êœ «·«”«”Ì… - Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (2, 'All House Allowance - Current', '«Ã„«·Ï „Œ’’ «·”ﬂ‰ - Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (3, 'All Transportaion Allowance - Current', '«Ã„«·Ï „Œ’’ «‰ ﬁ«·«  - Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (4, 'All OverTime - Current', '«Ã„«·Ï «·«÷«›Ï - Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (5, 'All Rewards - Current', '«Ã„«·Ï «·„ﬂ«›√  - Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (6, 'All Production - Current', '«Ã„«·Ï «·«‰ «ÃÌ… - Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (7, 'All Penalties - Current', '«Ã„«·Ï «·Ã“«¡«  - Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (8, 'All Employee Insurance - Current', '«Ã„«·Ï «· √„Ì‰«  ⁄«„· - Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (9, 'All Company Insurance - Current', '«Ã„«·Ï «· √„Ì‰«  ‘—ﬂ… - Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (10, 'All Loan - Current', '«Ã„«·Ï «·”·› - Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (11, 'All Basic Salary - Last', '«Ã„«·Ï «·»‰Êœ «·«”«”Ì… - ”«»ﬁ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (12, 'All House Allowance - Last', '«Ã„«·Ï „Œ’’ «·”ﬂ‰ - ”«»ﬁ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (13, 'All Transportaion Allowance - Last', '«Ã„«·Ï „Œ’’ «‰ ﬁ«·«  - ”«»ﬁ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (14, 'All OverTime - Last', '«Ã„«·Ï «·«÷«›Ï - ”«»ﬁ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (15, 'All Rewards - Last', '«Ã„«·Ï «·„ﬂ«›√  - ”«»ﬁ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (16, 'All Production - Last', '«Ã„«·Ï «·«‰ «ÃÌ… - ”«»ﬁ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (17, 'All Penalties - Last', '«Ã„«·Ï «·Ã“«¡«  - ”«»ﬁ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (18, 'All Employee Insurance - Last', '«Ã„«·Ï «· √„Ì‰«  ⁄«„· - ”«»ﬁ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (19, 'All Company Insurance - Last', '«Ã„«·Ï «· √„Ì‰«  ‘—ﬂ… - ”«»ﬁ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (20, 'All Loan - Last', '«Ã„«·Ï «·”·› - ”«»ﬁ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (21, 'Current Normal Vacation Days', '√Ì«„ «·«Ã«“… «·«⁄ Ì«œÌ… ·Â–« «·‘Â—');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (22, 'Current Casual Vacation Days', '√Ì«„ «·«Ã«“… «·⁄«—÷… ·Â–« «·‘Â—');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (23, 'Current Annual Vacation Days', '√Ì«„ «·«Ã«“… «·”‰ÊÌ… ·Â–« «·‘Â—');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (24, 'Current Sick Vacation Days', '√Ì«„ «·«Ã«“… «·„—÷Ï ·Â–« «·‘Â—');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (25, 'Current All Not Paid Vacation Days', '√Ì«„ «·«Ã«“… »«·Œ’„ ·Â–« «·‘Â—');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (26, 'Current Maternity Vacation Days', '√Ì«„ «Ã«“… «·Ê÷⁄ ·Â–« «·‘Â—');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (27, 'Current Paid Vacation Days', '√Ì«„ «·«Ã«“… «·„œ›Ê⁄… ·Â–« «·‘Â—');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (28, 'All Normal Vacation Days', '√Ì«„ «·«Ã«“… «·«⁄ Ì«œÌ… Õ Ï  «—ÌŒÂ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (29, 'All Casual Vacation Days', '√Ì«„ «·«Ã«“… «·⁄«—÷… Õ Ï  «—ÌŒÂ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (30, 'All Annual Vacation Days', '√Ì«„ «·«Ã«“… «·”‰ÊÌ… Õ Ï  «—ÌŒÂ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (31, 'All Sick Vacation Days', '√Ì«„ «·«Ã«“… «·„—÷Ï Õ Ï  «—ÌŒÂ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (32, 'All Not Paid Vacation Days', '√Ì«„ «·«Ã«“… »«·Œ’„ Õ Ï  «—ÌŒÂ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (33, 'All Maternity Vacation Days', '√Ì«„ «Ã«“… «·Ê÷⁄ Õ Ï  «—ÌŒÂ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (34, 'All Paid Vacation Days', '√Ì«„ «·«Ã«“… «·„œ›Ê⁄… Õ Ï  «—ÌŒÂ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (35, 'Current Permission Count', '⁄œœ «·«–Ê‰ ·Â–« «·‘Â—');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (37, 'Current Permission Hours', '”«⁄«  «·«–Ê‰«  ·Â–« «·‘Â—');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (39, 'Current Formal Vacation', '«·«Ã«“«  «·—”„Ì… ·Â–« «·‘Â—');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (40, 'All Formal Vacation', '«·«Ã«“«  «·—”„Ì… Õ Ï  «—ÌŒÂ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (41, 'Last Day Of Salary Month', '√Œ— ÌÊ„ ›Ï «·‘Â— «·Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (42, 'Days Of The Month', '⁄œœ √Ì«„ «·‘Â—');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (43, 'First Off Day', 'ÌÊ„ ⁄ÿ·… «·«”»Ê⁄ «·«Ê·');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (44, 'Second Off Day', 'ÌÊ„ ⁄ÿ·… «·«”»Ê⁄ «·À«‰Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (45, 'Current Mission Days', '≈Ã„«·Ï «Ì«„ «·„√„Ê—Ì«  ·Â–« «·‘Â—');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (47, 'Current Mission Count', '⁄œœ «·„√„Ê—Ì«  ·Â–« «·‘Â—');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (49, 'Hours Per Day', '”«⁄«  «·⁄„· «·ÌÊ„Ì…');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (51, 'Total Entitlements - Current', '≈Ã„«·Ï «·«” Õﬁ«ﬁ«  - Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (52, 'Total Entitlements - Last', '≈Ã„«·Ï «·«” Õﬁ«ﬁ«  - ”«»ﬁ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (53, 'Total Deductions - Current', '≈Ã„«·Ï «·«” ﬁÿ«⁄«  - Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (54, 'Total Deductions - Last', '≈Ã„«·Ï «·«” ﬁÿ«⁄«  - ”«»ﬁ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (55, 'Fixed Employee Insurance - Current', '«· √„Ì‰«  «·À«» … ⁄·Ï «·„ÊŸ› - Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (56, 'Vary Employee Insurance - Current', '«· √„Ì‰«  «·„ €Ì—… ⁄·Ï «·„ÊŸ› - Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (57, 'Fixed Company Insurance - Current', '«· √„Ì‰«  «·À«» … ⁄·Ï «·‘—ﬂ… - Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (58, 'Vary Company Insurance - Current', '«· √„Ì‰«  «·„ €Ì—… ⁄·Ï «·‘—ﬂ… - Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (59, 'Tax On Employee - Current', '«·÷—Ì»… ⁄·Ï «·„ÊŸ› - Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (60, 'Tax On Company - Current', '«·÷—Ì»… ⁄·Ï «·‘—ﬂ… - Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (61, 'Fixed Employee Insurance - Last', '«· √„Ì‰«  «·À«» … ⁄·Ï «·„ÊŸ› - ”«»ﬁ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (62, 'Vary Employee Insurance - Last', '«· √„Ì‰«  «·„ €Ì—… ⁄·Ï «·„ÊŸ› - ”«»ﬁ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (63, 'Fixed Company Insurance - Last', '«· √„Ì‰«  «·À«» … ⁄·Ï «·‘—ﬂ… - ”«»ﬁ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (64, 'Vary Company Insurance - Last', '«· √„Ì‰«  «·„ €Ì—… ⁄·Ï «·‘—ﬂ… - ”«»ﬁ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (65, 'Tax On Employee - Last', '«·÷—Ì»… ⁄·Ï «·„ÊŸ› - ”«»ﬁ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (66, 'Tax On Company - Last', '«·÷—Ì»… ⁄·Ï «·‘—ﬂ… - ”«»ﬁ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (67, 'Tax Container - Current', '«·Ê⁄«¡ «·÷—Ì»Ï - Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (68, 'Due Exception - Current', '«Ã„«·Ï «·«⁄›«¡«  - Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (69, 'Social Exception - Current', '«·«⁄›«¡ «·«Ã „«⁄Ï - Õ«·Ï');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (70, 'Tax Container - Last', '«·Ê⁄«¡ «·÷—Ì»Ï - ”«»ﬁ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (71, 'Due Exception - Last', '«Ã„«·Ï «·«⁄›«¡«  - ”«»ﬁ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (72, 'Social Exception - Last', '«·«⁄›«¡ «·«Ã „«⁄Ï - ”«»ﬁ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (81, 'Employee Contract Code', 'ﬂÊœ ⁄ﬁœ «·„ÊŸ›');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (82, 'Employee Work Status', 'Õ«·… «·⁄„· ··„ÊŸ›');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (83, 'Employee Job Code', 'ﬂÊœ ÊŸÌ›… «·„ÊŸ›');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (84, 'Employee Age', '⁄„— «·„ÊŸ›');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (85, 'Employee Social Status', '«·Õ«·… «·«Ã „«⁄Ì… ··„ÊŸ›');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (86, 'Employee Department Code', 'ﬂÊœ «œ«—… «·„ÊŸ›');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (87, 'Employee Citizen?', '«·„ÊŸ› „Ê«ÿ‰ø');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (88, 'Employee Working Years', '”‰Ê«  «·«ﬁœ„Ì… ··„ÊŸ›');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (89, 'Employee Insurance Fixed Salary', '«·„— » «· √„Ì‰Ï «·À«» ');
Insert into PAY_EQUATION_STATIC
   (STATIC_CODE, PRIMARY_NAME, SECONDARY_NAME)
 Values
   (90, 'Employee Insurance Vary Salary', '«·„— » «· √„Ì‰Ï «·„ €Ì—');
COMMIT;
