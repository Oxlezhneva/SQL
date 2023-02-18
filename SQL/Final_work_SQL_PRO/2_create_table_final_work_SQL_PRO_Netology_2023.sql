--�������� ������

--������ ������������
create table if not exists account( 
id uuid  default uuid_generate_v4 () primary key,
name varchar(150) not null); --�������� �����������

--������ ��������� ������������
create table if not exists contact ( 
id uuid default uuid_generate_v4 () primary key,
last_name varchar(150) not null,  --������� ��������
first_name varchar(150) not null, --��� ��������
account_id uuid references account(id)); --id �����������

 --����������
create table if not exists "user"(
id uuid default uuid_generate_v4 () primary key,
last_name varchar(150) not null, --������� ����������
first_name varchar(150) not null, --��� ����������
dismissed boolean default false); --������ ��� ���, �������� �� ��������� "���"

create type request_state as enum ('� �������', '�����������', '���������', '�������'); --��� ���� status ������� courier

--������ �� ������� �� �������
create table if not exists courier (
id uuid default uuid_generate_v4 () primary key,
from_place varchar(150) not null, --������
where_place varchar(150) not null, --����
name varchar(150) not null, --�������� ���������
account_id uuid references account(id), --id �����������
contact_id uuid references contact(id), --id �������� 
description text default '�����-�� �������� � �����������', --��������
user_id uuid references "user"(id),  --id ���������� �����������
status request_state default '� �������',  -- ������� '� �������', '�����������', '���������', '�������'. �� ��������� '� �������'
created_date date not null default now()); --���� �������� ������, �������� �� ��������� now()

--������� ��� ������:
--�����
create table if not exists table_fo_test.name_for_test( 
id serial,
name varchar(150) not null);

--�������
create table if not exists table_fo_test.last_name_for_test( 
id serial,
name varchar(150) not null);

--������(�����)
create table if not exists table_fo_test.city_for_test( 
id serial,
name varchar(150) not null);

--�����������
create table if not exists table_fo_test.account_name_for_test( 
id serial,
name varchar(150) not null);
