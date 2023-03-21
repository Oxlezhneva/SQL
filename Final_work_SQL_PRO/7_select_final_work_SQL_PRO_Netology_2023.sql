--select запросы и т.д.

--таблицы
select * from account;

select * from contact;

select * from "user";

select * from courier;

select * from table_fo_test.name_for_test;

select * from table_fo_test.last_name_for_test;

select * from table_fo_test.city_for_test;

select * from table_fo_test.account_name_for_test;

--функции
select * from get_courier();

select * from get_users();

select * from get_accounts();

select * from get_contacts('59a5f98e-5b2d-4c70-97b9-c5a093ae5aed');

select * from get_contacts(null);   --get_contacts(account_id)

--процедуры
call  insert_test_data(100);

call add_courier('Москва', 'Баку', 'Протокол', '82fdc5d3-8d58-4958-9a03-50f9dfb62279',
				'ab31b42e-9117-45fd-8603-460492aff8cc', 'Какое-то описание и комменатрии', '847b3bf0-c7f9-4322-8684-13095ac49809')  --add_courier(from_place, where_place, name, account_id, contact_id, description, user_id)

call change_status('Выполняется', '33edc47d-b7e0-4c13-bd1a-3ef399a66652');  --change_status(status, id)

call erase_test_data();
--представление
select * from courier_statistic;

--удаление
delete from table_fo_test.name_for_test;

delete from table_fo_test.last_name_for_test;

delete from table_fo_test.city_for_test;

delete from table_fo_test.account_name_for_test;

delete from courier cascade;

delete from contact;

delete from account;

delete from "user";