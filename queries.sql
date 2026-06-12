/*Напишите запрос, который считает общее количество покупателей из таблицы customers. Назовите колонку customers_count*/
select count(customer_id) as customers_count from customers;

/*Первый отчет о десятке лучших продавцов. Таблица состоит из трех колонок - данных о продавце, 
 * суммарной выручке с проданных товаров и количестве проведенных сделок, и отсортирована по убыванию выручки:
 * seller — имя и фамилия продавца
 * operations - количество проведенных сделок
 * income — суммарная выручка продавца за все время*/
select concat(e.first_name, ' ', e.last_name) as seller, 
	count(s.sales_id) as operations,
	floor(sum(s.quantity*p.price)) as income
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id 
inner join products as p on p.product_id = s.product_id 
group by e.employee_id, e.first_name, e.last_name
order by income desc limit 10;

/*Второй отчет содержит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам. 
 * Таблица отсортирована по выручке по возрастанию.
 * seller — имя и фамилия продавца
 * average_income — средняя выручка продавца за сделку с округлением до целого*/
select concat(e.first_name, ' ', e.last_name) as seller,
	floor(avg(s.quantity*p.price)) as average_income
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id 
inner join products as p on p.product_id = s.product_id 
group by e.employee_id, e.first_name, e.last_name
having avg(s.quantity*p.price) < (
	select avg(s2.quantity*p2.price) 
	from sales as s2
	inner join products as p2 on p2.product_id = s2.product_id 
)
order by average_income asc;

/*Третий отчет содержит информацию о выручке по дням недели. 
 * Каждая запись содержит имя и фамилию продавца, день недели и суммарную выручку. 
 * Отсортируйте данные по порядковому номеру дня недели и seller
 * seller — имя и фамилия продавца
 * day_of_week — название дня недели на английском языке
 * income — суммарная выручка продавца в определенный день недели, округленная до целого числа*/
select concat(e.first_name, ' ', e.last_name) as seller,
	trim(to_char(s.sale_date, 'Day')) as day_of_week,
	floor(sum(s.quantity*p.price)) as income
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id 
inner join products as p on p.product_id = s.product_id 
group by e.employee_id, e.first_name, e.last_name, extract(DOW from s.sale_date), trim(to_char(s.sale_date, 'Day'))
order by extract(DOW from s.sale_date), seller;
     
/*АПервый отчет - нализ покупателей. количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+. 
 * Итоговая таблица должна быть отсортирована по возрастным группам и содержать следующие поля:
 * age_category - возрастная группа
 * age_count - количество человек в группе
 */
select 
	case 
		when c.age between 16 and 25 then '16-25'
		when c.age between 26 and 40 then '26-40'
		when c.age > 40 then '40+'
	end as age_category,
	count(c.customer_id) as age_count
from customers c
group by age_category
order by age_category;

/*Во втором отчете предоставьте данные по количеству уникальных покупателей и выручке, которую они принесли. 
 * Сгруппируйте данные по дате, которая представлена в числовом виде ГОД-МЕСЯЦ. 
 * Итоговая таблица должна быть отсортирована по дате по возрастанию и содержать следующие поля:
 * selling_month - дата в указанном формате
 * total_customers - количество покупателей
 * income - принесенная выручка*/
select to_char(s.sale_date, 'YYYY-MM') as selling_month, 
	count(distinct s.customer_id) as total_customers, 
	floor(sum(quantity*price)) as income
from sales s
inner join products p on s.product_id = p.product_id
group by selling_month
order by selling_month;

/*Третий отчет следует составить о покупателях, первая покупка которых была в ходе проведения акций 
 *(акционные товары отпускали со стоимостью равной 0). Итоговая таблица должна быть отсортирована по id покупателя. 
 *Таблица состоит из следующих полей:
 *customer - имя и фамилия покупателя
 *sale_date - дата покупки
 *seller - имя и фамилия продавца*/
select concat(c.first_name, ' ', c.last_name) as customer,
	sale_date,
	concat(e.first_name, ' ', e.last_name) as seller
from (
	select *, row_number() over(partition by s.customer_id order by s.sale_date ) as rn
	from sales s
	) as first_sales
inner join customers c on first_sales.customer_id = c.customer_id
inner join employees e on first_sales.sales_person_id = e.employee_id
inner join products p on first_sales.product_id = p.product_id
where rn=1 and p.price = 0
order by first_sales.customer_id;

