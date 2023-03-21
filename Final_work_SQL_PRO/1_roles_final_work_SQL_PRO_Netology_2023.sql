--����

--create role  netocourier with login password '';

revoke all privileges on database "postgres" from netocourier;
revoke all privileges on database "postgres" from public;
revoke all privileges on schema public from public;
revoke all privileges on schema public from netocourier;
revoke all privileges on schema pg_catalog from public;
revoke all privileges on schema pg_catalog from netocourier;
revoke all privileges on schema information_schema from public;
revoke all privileges on schema information_schema from netocourier;

revoke all privileges on database postgres from netocourier cascade;
revoke all privileges on database postgres from public cascade;

revoke all on all tables in schema public from netocourier;
revoke all on all tables in schema public from public;
revoke all on all tables in schema pg_catalog from netocourier;
revoke all on all tables in schema pg_catalog from public;
revoke all on all tables in schema information_schema from netocourier;
revoke all on all tables in schema information_schema from public;

grant connect on database "postgres" to netocourier;
grant usage on schema public to netocourier;
grant usage on schema pg_catalog to  netocourier;
grant usage on schema information_schema to  netocourier;
grant usage on schema table_fo_test to netocourier;

grant create on schema public to netocourier;
grant create on schema table_fo_test to netocourier;

grant select on all tables in schema pg_catalog to netocourier;
grant select on all tables in schema information_schema to netocourier;
grant select, insert, update on all tables in schema public to netocourier; 
grant select, insert, update on all tables in schema table_fo_test to netocourier; 

grant usage, select on all sequences in schema public to netocourier;
grant usage, select on all sequences in schema table_fo_test to netocourier;

grant delete on table courier,contact,"user",account,courier_statistic, 
	table_fo_test.city_for_test,table_fo_test.last_name_for_test,table_fo_test.name_for_test,table_fo_test.account_name_for_test  
to netocourier;

