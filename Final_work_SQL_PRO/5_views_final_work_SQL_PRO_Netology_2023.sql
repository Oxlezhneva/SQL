--представление

--Нужно реализовать представление courier_statistic, со следующей структурой:
--account_id --идентификатор контрагента
--account --название контрагента
--count_courier --количество заказов на курьера для каждого контрагента
--count_complete --количество завершенных заказов для каждого контрагента
--count_canceled --количество отмененных заказов для каждого контрагента
--percent_relative_prev_month -- процентное изменение количества заказов текущего месяца к предыдущему месяцу для каждого контрагента, если получаете деление на 0, то в результат вывести 0.
--count_where_place --количество мест доставки для каждого контрагента
--count_contact --количество контактов по контрагенту, которым доставляются документы
--cansel_user_array --массив с идентификаторами сотрудников, по которым были заказы со статусом "Отменен" для каждого контрагента
create view courier_statistic as
with cte1 as (
		select account_id, count(id) count_now
		from courier
		where date_trunc('month',created_date)::date = date_trunc('month', current_date)::date
		group by account_id),
	cte2 as (
		select account_id, count(id) count_last_mounth
		from courier
		where date_trunc('month',created_date)::date = date_trunc('month', current_date - interval '1' month)::date
		group by account_id),
	cte3 as (
	 	select account_id, count(id) count_canceled, array_agg(distinct user_id) array_user from courier
  		where status = 'Отменен'
		group by account_id),
	cte4 as (
		select account_id, count(id) count_complete from courier 
    where status = 'Выполнено'
    group by account_id)
select cr.account_id,
		act.name account,
		count(cr.id) count_courier,
		coalesce(cte4.count_complete,0) count_complete,
		coalesce(cte3.count_canceled,0) count_canceled,
		coalesce(((coalesce(cte1.count_now,0)-coalesce(cte2.count_last_mounth,0))/cte2.count_last_mounth)*100, 0) percent_relative_prev_month,
		count(distinct cr.where_place) count_where_place,
		count(distinct cr.contact_id) count_contact,
		cte3.array_user cansel_user_array	
from courier cr	
left join cte1 on cr.account_id = cte1.account_id
left join cte2 on cr.account_id = cte2.account_id
left join cte3 on cr.account_id = cte3.account_id
left join cte4 on cr.account_id = cte4.account_id
left join account act on  cr.account_id = act.id
group by cr.account_id, cte1.count_now,cte2.count_last_mounth,act.name,cte3.count_canceled, cte3.array_user,cte4.count_complete;

