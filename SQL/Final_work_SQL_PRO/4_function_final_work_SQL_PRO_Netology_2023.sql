--функции

--Нужно реализовать функцию get_courier(), которая возвращает таблицу согласно следующей структуры:
--id --идентификатор заявки
--from_place --откуда
--where_place --куда
--name --название документа
--account_id --идентификатор контрагента
--account --название контрагента
--contact_id --идентификатор контакта
--contact --фамилия и имя контакта через пробел
--description --описание
--user_id --идентификатор сотрудника
--user --фамилия и имя сотрудника через пробел
--status --статус заявки
--created_date --дата создания заявки
--Сортировка результата должна быть сперва по статусу, затем по дате от большего к меньшему.
--Важно! Если названия столбцов возвращаемой функцией таблицы будут отличаться от указанных выше, то приложение работать не будет.
create or replace function get_courier() returns table
	(id uuid, from_place varchar, where_place varchar, "name" varchar, account_id uuid, account varchar,
	contact_id uuid, contact text, description text, user_id uuid, "user" text, status request_state, created_date date) AS $$ 
begin
	return query select c.id, c.from_place, c.where_place, c.name, c.account_id, ac.name, c.contact_id, concat(ct.last_name, ' ', ct.first_name),
	c.description, c.user_id, concat(us.last_name, ' ', us.first_name), c.status, c.created_date
	from courier c 
	left join contact ct on c.contact_id = ct.id
	left join "user" us on c.user_id = us.id
	left join account ac on c.account_id = ac.id
	order by c.status, c.created_date desc;
end;
$$ language plpgsql;

--Нужно реализовать функцию get_users(), которая возвращает таблицу согласно следующей структуры:
--user --фамилия и имя сотрудника через пробел 
--Сотрудник должен быть действующим! Сортировка должна быть по фамилии сотрудника
create or replace function get_users() returns table ("user" text) as $$ 
begin
	return query select concat(last_name, ' ', first_name)
	from "user"	
	where dismissed is false 
	order by last_name;
end;
$$ language plpgsql;

--Нужно реализовать функцию get_accounts(), которая возвращает таблицу согласно следующей структуры:
--account --название контрагента 
--Сортировка должна быть по названию контрагента.
create or replace function get_accounts() returns table (account varchar) as $$ 
begin
	return query select "name"
	from account		
	order by "name";
end;
$$ language plpgsql;

--Нужно реализовать функцию get_contacts(account_id), которая принимает на вход идентификатор контрагента
--и возвращает таблицу с контактами переданного контрагента согласно следующей структуры:
--contact --фамилия и имя контакта через пробел 
--Сортировка должна быть по фамилии контакта. Если в функцию вместо идентификатора контрагента передан null,
--нужно вернуть строку 'Выберите контрагента'.
create or replace function get_contacts(account_ids uuid) returns table (contact text) as $$ 
begin
	if account_ids is not null and account_ids in (select id from account)
		then return query select concat(last_name, ' ', first_name)
		from contact c
		right join account ac on c.account_id = ac.id
		where ac.id = account_ids
		order by last_name;	
	else raise exception 'Выберите контрагента.';
	end if;
end;
$$ language plpgsql;
