/*==============================================================*/
/* Table: SUPPLIERS_GROUPS_MAIN_B                               */
/*==============================================================*/
create table SUPPLIERS_GROUPS_MAIN_B  (
   SUPPLIERS_GROUPS_MAIN_ID NUMBER (15)                     not null,
   BRANCH_ID            NUMBER (15)                     not null,
   constraint PK_PUR_0082 primary key (SUPPLIERS_GROUPS_MAIN_ID, BRANCH_ID)
);

comment on table SUPPLIERS_GROUPS_MAIN_B is
'Created By Sameh Noshi';

alter table SUPPLIERS_GROUPS_MAIN_B
   add constraint FK_PUR_0179 foreign key (BRANCH_ID)
      references BRANCHES (BRANCH_ID);

alter table SUPPLIERS_GROUPS_MAIN_B
   add constraint FK_PUR_0180 foreign key (SUPPLIERS_GROUPS_MAIN_ID)
      references SUPPLIERS_GROUPS_MAIN (SUPPLIERS_GROUPS_MAIN_ID);


/*==============================================================*/
/* Table: SUPPLIERS_GROUPS_B                                    */
/*==============================================================*/
create table SUPPLIERS_GROUPS_B  (
   SUPPLIERS_GROUPS_ID  NUMBER (15)                     not null,
   BRANCH_ID            NUMBER (15)                     not null,
   constraint PK_PUR_0083 primary key (SUPPLIERS_GROUPS_ID, BRANCH_ID)
);

comment on table SUPPLIERS_GROUPS_B is
'Created By Sameh Noshi';

alter table SUPPLIERS_GROUPS_B
   add constraint FK_PUR_0181 foreign key (BRANCH_ID)
      references BRANCHES (BRANCH_ID);

alter table SUPPLIERS_GROUPS_B
   add constraint FK_PUR_0182 foreign key (SUPPLIERS_GROUPS_ID)
      references SUPPLIERS_GROUPS (SUPPLIERS_GROUPS_ID);



/*==============================================================*/
/* Table: SUPPLIERS_B                                           */
/*==============================================================*/
create table SUPPLIERS_B  (
   SUPPLIER_ID          NUMBER (15)                     not null,
   BRANCH_ID            NUMBER (15)                     not null,
   constraint PK_PUR_0084 primary key (SUPPLIER_ID, BRANCH_ID)
);

comment on table SUPPLIERS_B is
'Created By Sameh Noshi';

alter table SUPPLIERS_B
   add constraint FK_PUR_0183 foreign key (SUPPLIER_ID)
      references SUPPLIERS (SUPPLIER_ID);

alter table SUPPLIERS_B
   add constraint FK_PUR_0184 foreign key (BRANCH_ID)
      references BRANCHES (BRANCH_ID);
