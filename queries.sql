--Данный запрос выдает общее количество покупателей из таблицы customers 
select count(customer_id) as customers_count
from customers;


--Данный запрос выводит имена и фамилии продавцов, количество сделанных ими продаж и выручку
--Результат отсортирован по выручке, выведены топ-10 продавцов по выручке
select
    concat(first_name, ' ', last_name) as seller,
    count(sales_id) as operations,
    round(sum(price * quantity), 0) as income
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id
inner join products as p on s.product_id = p.product_id
group by concat(first_name, ' ', last_name)
order by income desc
limit 10;


--Данный запрос выводит имена имена и фамилии продавцов, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам, и их среднюю выручку
--Результат отсортирован по средней выручке
with tab as (
    select avg(price * quantity) as total_avg
    from sales as s
    inner join products as p on s.product_id = p.product_id
)

select
    concat(first_name, ' ', last_name) as seller,
    round(avg(price * quantity), 0) as average_income
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id
inner join products as p on s.product_id = p.product_id
group by concat(first_name, ' ', last_name)
having avg(price * quantity) < (select total_avg from tab)
order by average_income;


--Данный запрос выводит имена и фамилии продавцов, названия дней недели и выручка
--Результат отсортирован по номерам дней недели и именам и фамилиям продавцов
with tab as (
    select
        concat(first_name, ' ', last_name) as seller,
        to_char(sale_date, 'Day') as day_of_week,
        round(sum(price * quantity), 0) as income,
        extract(isodow from sale_date) as day_number
    from employees as e
    inner join sales as s on e.employee_id = s.sales_person_id
    inner join products as p on s.product_id = p.product_id
    group by
        concat(first_name, ' ', last_name),
        to_char(sale_date, 'Day'),
        extract(isodow from sale_date)
    order by day_number, seller
)

select
    seller,
    day_of_week,
    income
from tab;


--Данный запрос разбивает покупателей на 3 возрастные группы (16-25, 26-40 и 40+) и выводит эти группы и количество покупателей в них
--Результат отсортирован по возрастным группам
with tab as (
    select
        age,
        case
            when age between 16 and 25 then '16-25'
            when age between 26 and 40 then '26-40'
            else '40+'
        end as age_category
    from customers
)

select
    age_category,
    count(age) as age_count
from tab
group by age_category
order by age_category;


--Данный запрос выводит месяцы продаж, количество уникальных покупателей в каждом месяце и принесенную ими выручку
--Результат отсортирован по месяцам продаж
select
    to_char(sale_date, 'YYYY-MM') as selling_month,
    count(distinct c.customer_id) as total_customers,
    round(sum(quantity * price), 0) as income
from sales as s
inner join customers as c on s.customer_id = c.customer_id
inner join products as p on s.product_id = p.product_id
group by to_char(sale_date, 'YYYY-MM')
order by selling_month;


--Данный запрос выводит имена и фамилии покупателей, первая покупка которых была равна 0, дату этой продажи и продавцов
--Результат отсортирован по id покупателей
with tab as (
    select
        s.sale_date,
        p.price,
        concat(c.first_name, ' ', c.last_name) as customer,
        concat(e.first_name, ' ', e.last_name) as seller,
        row_number()
            over (
                partition by concat(c.first_name, ' ', c.last_name)
                order by sale_date
            )
        as sale_number
    from sales as s
    inner join customers as c on s.customer_id = c.customer_id
    inner join products as p on s.product_id = p.product_id
    inner join employees as e on s.sales_person_id = e.employee_id
    order by concat(c.first_name, ' ', c.last_name), sale_date
)

select
    customer,
    sale_date,
    seller
from tab
where price = 0 and sale_number = 1;