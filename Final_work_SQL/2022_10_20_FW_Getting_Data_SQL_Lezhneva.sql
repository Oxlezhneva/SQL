--Приложение №2

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--ЗАДАНИЕ №1
-- В каких городах больше одного аэропорта?

select
	city->>'ru' "Название города",
	count(airport_name) "Количество аэропортов"
from airports_data
group by city
having 	count(airport_name) > 1;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--ЗАДАНИЕ №2
--В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета? (Использовать подзапрос)

select
	distinct airport_name->>'ru' "Название аэропорта"
from airports_data a
join flights f on a.airport_code = f.arrival_airport
join aircrafts_data ad on f.aircraft_code = ad.aircraft_code
where range = (select max(range) from aircrafts_data)
order by 1;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--ЗАДАНИЕ №3
--Вывести 10 рейсов с максимальным временем задержки вылета. (Использовать limit)

select
	flight_id "Номер рейса",
	actual_departure - scheduled_departure "Время задержки рейса"
from flights
where actual_departure is not null
order by 2 desc
limit 10;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--ЗАДАНИЕ №4
--Были ли брони, по которым не были получены посадочные талоны?	(Верный тип JOIN)

select
	count(distinct(b.book_ref)) "Кол-во брони без посад. талонов"
from bookings b
join tickets t on b.book_ref = t.book_ref
left join boarding_passes bp on	t.ticket_no = bp.ticket_no
where boarding_no is null;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--ЗАДАНИЕ №5
--	Найдите количество свободных мест для каждого рейса, их % отношение к общему количеству мест в самолете. 
--	Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров из каждого аэропорта на каждый день.
--	Т.е. в этом столбце должна отражаться накопительная сумма - сколько человек уже вылетело из данного аэропорта на этом или более ранних
--	рейсах в течении дня
--	(Оконная функция; подзапросы или/и cte)

with cte1 as (
	select
		f.flight_id,
		f.aircraft_code,
		f.departure_airport,
		f.actual_departure,
		count(bp.boarding_no) boarding_pass
	from flights f
	join boarding_passes bp on f.flight_id = bp.flight_id
	where f.actual_departure is not null
	group by f.flight_id),
cte2 as (
	select
		s.aircraft_code,
		count(s.seat_no) quantity_seats
	from seats s
	group by aircraft_code)
select
	cte1.flight_id "Порядковый номер рейса",
	cte1.departure_airport "Аэропорт вылета",
	cte1.actual_departure::date "День вылета",
	cte2.quantity_seats-cte1.boarding_pass "Свободные места",
	round(((cte2.quantity_seats-cte1.boarding_pass)/ cte2.quantity_seats::numeric)* 100) "Свободные места, %",
	SUM(cte1.boarding_pass) over (partition by cte1.departure_airport,
	cte1.actual_departure::date
order by cte1.actual_departure) as "Суммарное накопление пассажиров"
from cte1
join cte2 on cte1 .aircraft_code = cte2.aircraft_code;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--ЗАДАНИЕ №6
--	Найдите процентное соотношение перелетов по типам самолетов от общего количества (Подзапрос или окно; оператор ROUND)
	
select
	ad.model->>'ru' "Тип самолета",
	count(f.flight_id) "Общее кол-во перелетов",
	round((count(f.flight_id) /
		(select count(f.flight_id) 
		from flights f 
		where actual_departure is not null)::numeric * 100)) "Cоотношение перелетов, %"
from flights f
join aircrafts_data ad on f.aircraft_code = ad.aircraft_code
where f.actual_departure is not null
group by ad.model
order by 3 desc;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--ЗАДАНИЕ №7
--Были ли города, в которые можно добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?	(CTE)

with business as (
	select 
		flight_id,
		min(amount) b_min
	from ticket_flights
	where fare_conditions = 'Business'
	group by flight_id),
economy as (
	select 
		flight_id,
		max(amount) e_max
	from ticket_flights
	where fare_conditions = 'Economy'
	group by flight_id)
select
	distinct ad.city->>'ru' "Города. Стоимость бизнес < эконом"
from economy e
join business b on e.flight_id = b.flight_id
join flights f on b.flight_id = f.flight_id
join airports_data ad on f.arrival_airport = ad.airport_code
where b_min < e_max
order by 1;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--ЗАДАНИЕ №8
--Между какими городами нет прямых рейсов?	Декартово произведение в предложении FROM; 
--самостоятельно созданные представления (если облачное подключение, то без представления); оператор EXCEPT		

select
	distinct ad1.city->>'ru' "Название города",
	ad2.city->>'ru' "Название города"
from airports_data ad1,	airports_data ad2
where ad1.city != ad2.city
except		
select 
	distinct ad.city->>'ru',
	a.city->>'ru'
from flights f
join airports_data ad on f.departure_airport = ad.airport_code
join airports_data a on f.arrival_airport = a.airport_code;	

---------------------------------------------------------------------------------------------------------------------------------------------------------------------	
--ЗАДАНИЕ №9
--Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните с допустимой максимальной дальностью перелетов в самолетах,
--обслуживающих эти рейс*	Оператор RADIANS или использование sind/cosd; CASE

select distinct	
	a.model->>'ru' "Модель самолета",
	a.range "Макс. дальность полета, км",
	ad1.airport_name->>'ru' "Аэропорт вылета",
	ad1.city->>'ru' "Город",
	ad2.airport_name->>'ru' "Аэропорт прилета",
	ad2.city->>'ru' "Город",
	round((acos(sind(ad1.coordinates[1])* sind(ad2.coordinates[1]) + cosd(ad1.coordinates[1])* cosd(ad2.coordinates[1])* cosd(ad1.coordinates[0] - ad2.coordinates[0])))* 6371)::dec "S, между аэропортами, км.",
case
	when a.range > round((acos(sind(ad1.coordinates[1])* sind(ad2.coordinates[1]) + cosd(ad1.coordinates[1])* cosd(ad2.coordinates[1])* cosd(ad1.coordinates[0] - ad2.coordinates[0])))* 6371)::dec then 'Долетит'
	when a.range < round((acos(sind(ad1.coordinates[1])* sind(ad2.coordinates[1]) + cosd(ad1.coordinates[1])* cosd(ad2.coordinates[1])* cosd(ad1.coordinates[0] - ad2.coordinates[0])))* 6371)::dec then 'Не долетит'
	else 'Неизвестно' 
end "Долетит ли самолет?"
from flights f
join airports_data ad1 on f.departure_airport = ad1.airport_code
join airports_data ad2 on f.arrival_airport = ad2.airport_code
join aircrafts_data a on f.aircraft_code = a.aircraft_code
order by 7, 6;	
	