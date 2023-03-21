--���������

--��� ����������� ������������ ���������� ���������� ����������� ��������� insert_test_data(value), ������� ��������� �� ���� ������������� ��������.
--������ ��������� ������ ������:
--value * 1 ����� ��������� ������ � ��������� account.
--value * 2 ����� ��������� ������ � ��������� contact.
--value * 1 ����� ��������� ������ � ��������� user.
--value * 5 ����� ��������� ������ � ��������� courier.
--- ��������� id ������ ���� ����� uuid-ossp
--- ��������� ���������� ����� ����� ����������� SELECT repeat(substring('��������������������������������',1,(random()*33)::integer),(random()*10)::integer);
--���������� ����� ���� varchar. ������ random �������� ��������� ����� �������� �� ������, ������ random ��������� ���������� �������� ���������� � substring.
--- ��������� ������ ���� ���������� ����� 0 � 1 � �������������� ��������� random.
--- ��������� ���� � ������� ����� ������������ ����� select now() - interval '1 day' * round(random() * 1000) as timestamp;
--- ��������� �������� ����� ����������� ����� enum_range()

--1 ������� � ���.���������
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
					       (select (array['���', '�������', '�������', '������', '��������'])[floor(random() * 4 + 1)]),
						   k,
						   (select id from contact where account_id = k order by random() limit 1),						   
						   (select id from "user" order by random() limit 1),
						   (enum_range(null::request_state))[(random() * 3 + 1)],
						  now() - interval '1 day'  *round(random()*1000);
				end loop;
		end loop;
end;
$$ language plpgsql;

--���������� ����������� ��������� erase_test_data(), ������� ����� ������� �������� ������ �� ���������.
create or replace procedure erase_test_data() as $$
begin
	delete from courier;
	delete from "user";
	delete from contact;
	delete from account;    
end;
$$ language plpgsql;

--����� ����������� ��������� add_courier(from_place, where_place, name, account_id, contact_id, description, user_id), 
--������� ��������� �� ���� ������������� ��������� � ������ ������ � ������� courier
--�����! ������������������ �������� ������ ���� ������ ���������, ����� ���������� �������� �� �����.
create or replace procedure add_courier(from_place varchar, where_place varchar, name varchar, account_ids uuid, contact_id uuid, description text, user_id uuid) as $$
begin
	if account_ids not in (select id from account) then raise exception '������ ����������� ���.';
	elsif user_id not in (select id from "user") then raise exception '������ ���������� ���.';
	else
		if contact_id in (select id from contact where account_id = account_ids)
			then insert into courier(from_place, where_place, name, account_id, contact_id, description, user_id)
	 		values (from_place, where_place, name, account_ids,contact_id,description,user_id);
		else raise exception '������ �������� ��� ������� ����������� ���.';
		end if;
	end if;
end;
$$ language plpgsql;

--����� ����������� ��������� change_status(status, id), ������� ����� �������� ������ ������. 
--�� ���� ��������� ��������� ����� �������� ������� � �������� �������������� ������.
create or replace procedure change_status(status_s request_state, id_d uuid) as $$
begin
	if id_d not in (select id from courier) then raise exception '����� ������ ���.';
	else update courier set status = status_s where id = id_d;	
	end if;
end;
$$ language plpgsql;
