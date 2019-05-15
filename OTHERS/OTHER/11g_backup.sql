declare
   sql_str_v               varchar(2000);
begin
   for i in (
select owner, table_name 
from all_tables 
 WHERE owner = &DB_USER)
   loop
           sql_str_v := 'alter table '||i.owner||'.'|| i.table_name ||' allocate extent ';
           dbms_output.put_line(sql_str_v);
           execute immediate sql_str_v;
   end loop;
end;
/
