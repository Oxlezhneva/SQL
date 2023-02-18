--�������

--����� ����������� ������� get_courier(), ������� ���������� ������� �������� ��������� ���������:
--id --������������� ������
--from_place --������
--where_place --����
--name --�������� ���������
--account_id --������������� �����������
--account --�������� �����������
--contact_id --������������� ��������
--contact --������� � ��� �������� ����� ������
--description --��������
--user_id --������������� ����������
--user --������� � ��� ���������� ����� ������
--status --������ ������
--created_date --���� �������� ������
--���������� ���������� ������ ���� ������ �� �������, ����� �� ���� �� �������� � ��������.
--�����! ���� �������� �������� ������������ �������� ������� ����� ���������� �� ��������� ����, �� ���������� �������� �� �����.
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

--����� ����������� ������� get_users(), ������� ���������� ������� �������� ��������� ���������:
--user --������� � ��� ���������� ����� ������ 
--��������� ������ ���� �����������! ���������� ������ ���� �� ������� ����������
create or replace function get_users() returns table ("user" text) as $$ 
begin
	return query select concat(last_name, ' ', first_name)
	from "user"	
	where dismissed is false 
	order by last_name;
end;
$$ language plpgsql;

--����� ����������� ������� get_accounts(), ������� ���������� ������� �������� ��������� ���������:
--account --�������� ����������� 
--���������� ������ ���� �� �������� �����������.
create or replace function get_accounts() returns table (account varchar) as $$ 
begin
	return query select "name"
	from account		
	order by "name";
end;
$$ language plpgsql;

--����� ����������� ������� get_contacts(account_id), ������� ��������� �� ���� ������������� �����������
--� ���������� ������� � ���������� ����������� ����������� �������� ��������� ���������:
--contact --������� � ��� �������� ����� ������ 
--���������� ������ ���� �� ������� ��������. ���� � ������� ������ �������������� ����������� ������� null,
--����� ������� ������ '�������� �����������'.
create or replace function get_contacts(account_ids uuid) returns table (contact text) as $$ 
begin
	if account_ids is not null and account_ids in (select id from account)
		then return query select concat(last_name, ' ', first_name)
		from contact c
		right join account ac on c.account_id = ac.id
		where ac.id = account_ids
		order by last_name;	
	else raise exception '�������� �����������.';
	end if;
end;
$$ language plpgsql;
