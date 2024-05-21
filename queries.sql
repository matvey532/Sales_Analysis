--Данный запрос выдает общее количество покупателей из таблицы customers 
select count(customer_id) as customers_count
from customers;


--Данный запрос выводит имена и фамилии продавцов, количество сделанных ими продаж и выручку
--Результат отсортирован по выручке, выведены топ-10 продавцов по выручке
select 
concat(first_name,' ', last_name) as seller, 
count(sales_id) as operations, 
round(sum(price * quantity), 0) as income
from employees e 
join sales s on e.employee_id = s.sales_person_id
join products p on p.product_id = s.product_id 
group by concat(first_name,' ', last_name)
order by income desc
limit 10;


--Данный запрос выводит имена имена и фамилии продавцов, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам, и их средняя выручка
---Результат отсортирован по средней выручке
with tab as (
select avg(price * quantity) as total_avg
from sales s 
join products p on p.product_id = s.product_id)

select concat(first_name,' ', last_name) as seller, round(avg(price * quantity), 0) as average_income 
from employees e 
join sales s on e.employee_id = s.sales_person_id
join products p on p.product_id = s.product_id
group by concat(first_name,' ', last_name)
having avg(price * quantity) < (select total_avg from tab)
order by average_income;


--Данный запрос выводит имена и фамилии продавцов, названия дней недели и выручка
--Результат отсортирован по номерам дней недели и именам и фамилиям продавцов
with tab as (
select 
concat(first_name,' ', last_name) as seller, 
to_char(sale_date, 'Day') as day_of_week, 
round(sum(price * quantity), 0) as income,
extract (isodow from sale_date) as day_number
from employees e 
join sales s on e.employee_id = s.sales_person_id
join products p on p.product_id = s.product_id
group by concat(first_name,' ', last_name), to_char(sale_date, 'Day'), extract (isodow from sale_date)
order by day_number, seller)

select seller, day_of_week, income
from tab