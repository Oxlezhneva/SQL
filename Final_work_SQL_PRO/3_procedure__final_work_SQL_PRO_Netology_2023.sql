--процедуры

--Для возможности тестирования приложения необходимо реализовать процедуру insert_test_data(value), которая принимает на вход целочисленное значение.
--Данная процедура должна внести:
--value * 1 строк случайных данных в отношение account.
--value * 2 строк случайных данных в отношение contact.
--value * 1 строк случайных данных в отношение user.
--value * 5 строк случайных данных в отношение courier.
--- Генерация id должна быть через uuid-ossp
--- Генерация символьных полей через конструкцию SELECT repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя',1,(random()*33)::integer),(random()*10)::integer);
--Соблюдайте длину типа varchar. Первый random получает случайный набор символов из строки, второй random дублирует количество символов полученных в substring.
--- Генерация булева типа происходит через 0 и 1 с использованием оператора random.
--- Генерацию даты и времени можно сформировать через select now() - interval '1 day' * round(random() * 1000) as timestamp;
--- Генерацию статусов можно реализовать через enum_range()

--1 вариант с доп.таблицами
create or replace procedure insert_test_data(value int) as $$
declare k uuid; 
begin
	for i in 1..value
		loop 
			insert into account(name)
			select (select "name" from table_fo_test.account_name_for_test  order by random() limit 1);
			insert into "user"(last_name, first_name, dismissed)
			select (select "name" from table_fo_test.last_name_for_test  order by random() limit 1),
				   (select "name" from table_fo_test.name_for_test order by random() limit 1),
		           random()::int::boolean;
		end loop;		
	for k in select id from account		
		loop
			for i in 1..2
				loop
					insert into contact(last_name, first_name, account_id) 
					select (select "name" from table_fo_test.last_name_for_test   order by random()  limit 1),
					(select "name" from table_fo_test.name_for_test  order by random() limit 1),
				   	k;
				end loop;	
			for i in 1..5					
				loop
					insert into courier(from_place, where_place, name, account_id, contact_id, user_id,status,created_date)
					select (select "name" from table_fo_test.city_for_test order by random() limit 1),						   		 
						  (select "name" from table_fo_test.city_for_test order by random() limit 1),
					       (select (array['акт', 'договор', 'реклама', 'приказ', 'протокол'])[floor(random() * 4 + 1)]),
						   k,
						   (select id from contact where account_id = k order by random() limit 1),						   
						   (select id from "user" order by random() limit 1),
						   (enum_range(null::request_state))[(random() * 3 + 1)],
						  now() - interval '1 day'  *round(random()*1000);
				end loop;
		end loop;
end;
$$ language plpgsql;

--Необходимо реализовать процедуру erase_test_data(), которая будет удалять тестовые данные из отношений.
create or replace procedure erase_test_data() as $$
begin
	delete from courier;
	delete from "user";
	delete from contact;
	delete from account;    
end;
$$ language plpgsql;

--Нужно реализовать процедуру add_courier(from_place, where_place, name, account_id, contact_id, description, user_id), 
--которая принимает на вход вышеуказанные аргументы и вносит данные в таблицу courier
--Важно! Последовательность значений должна быть строго соблюдена, иначе приложение работать не будет.
create or replace procedure add_courier(from_place varchar, where_place varchar, name varchar, account_ids uuid, contact_id uuid, description text, user_id uuid) as $$
begin
	if account_ids not in (select id from account) then raise exception 'Такого контрагента нет.';
	elsif user_id not in (select id from "user") then raise exception 'Такого сотрудника нет.';
	else
		if contact_id in (select id from contact where account_id = account_ids)
			then insert into courier(from_place, where_place, name, account_id, contact_id, description, user_id)
	 		values (from_place, where_place, name, account_ids,contact_id,description,user_id);
		else raise exception 'Такого контакта для данного контрагента нет.';
		end if;
	end if;
end;
$$ language plpgsql;

--Нужно реализовать процедуру change_status(status, id), которая будет изменять статус заявки. 
--На вход процедура принимает новое значение статуса и значение идентификатора заявки.
create or replace procedure change_status(status_s request_state, id_d uuid) as $$
begin
	if id_d not in (select id from courier) then raise exception 'Такой заявки нет.';
	else update courier set status = status_s where id = id_d;	
	end if;
end;
$$ language plpgsql;
