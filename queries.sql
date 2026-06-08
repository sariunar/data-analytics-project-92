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
     