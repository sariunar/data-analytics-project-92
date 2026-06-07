/*Напишите запрос, который считает общее количество покупателей из таблицы customers. 
 * Назовите колонку customers_count*/
select count(customer_id) as customers_count from customers;