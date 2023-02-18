--создание таблиц

--список контрагентов
create table if not exists account( 
id uuid  default uuid_generate_v4 () primary key,
name varchar(150) not null); --название контрагента

--список контактов контрагентов
create table if not exists contact ( 
id uuid default uuid_generate_v4 () primary key,
last_name varchar(150) not null,  --фамили€ контакта
first_name varchar(150) not null, --им€ контакта
account_id uuid references account(id)); --id контрагента

 --сотрудники
create table if not exists "user"(
id uuid default uuid_generate_v4 () primary key,
last_name varchar(150) not null, --фамили€ сотрудника
first_name varchar(150) not null, --им€ сотрудника
dismissed boolean default false); --уволен или нет, значение по умолчанию "нет"

create type request_state as enum ('¬ очереди', '¬ыполн€етс€', '¬ыполнено', 'ќтменен'); --дл€ пол€ status таблицы courier

--данные по за€вкам на курьера
create table if not exists courier (
id uuid default uuid_generate_v4 () primary key,
from_place varchar(150) not null, --откуда
where_place varchar(150) not null, --куда
name varchar(150) not null, --название документа
account_id uuid references account(id), --id контрагента
contact_id uuid references contact(id), --id контакта 
description text default ' акое-то описание и комменатрии', --описание
user_id uuid references "user"(id),  --id сотрудника отправител€
status request_state default '¬ очереди',  -- статусы '¬ очереди', '¬ыполн€етс€', '¬ыполнено', 'ќтменен'. ѕо умолчанию '¬ очереди'
created_date date not null default now()); --дата создани€ за€вки, значение по умолчанию now()

--таблицы дл€ тестов:
--имена
create table if not exists table_fo_test.name_for_test( 
id serial,
name varchar(150) not null);

--фамилии
create table if not exists table_fo_test.last_name_for_test( 
id serial,
name varchar(150) not null);

--города(места)
create table if not exists table_fo_test.city_for_test( 
id serial,
name varchar(150) not null);

--контрагенты
create table if not exists table_fo_test.account_name_for_test( 
id serial,
name varchar(150) not null);
