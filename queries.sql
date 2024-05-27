--Запрос выдает общее количество покупателей из таблицы customers.
SELECT COUNT(customer_id) AS customers_count
FROM customers;
--Запрос выводит имена и фамилии продавцов, 
--кол-во сделанных ими продаж и выручку.
--Результат отсортирован по выручке, выведены топ-10 продавцов по выручке.
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM
    employees AS e
INNER JOIN sales AS s ON e.employee_id = s.sales_person_id
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY
    CONCAT(e.first_name, ' ', e.last_name)
ORDER BY
    income DESC
LIMIT 10;
--Запрос выводит продавцов, чья средняя выручка меньше общей средней выручки, 
--и их среднюю выручку.
--Результат отсортирован по средней выручке.
WITH tab AS (
    SELECT AVG(p.price * s.quantity) AS total_avg
    FROM sales AS s
    INNER JOIN products AS p ON s.product_id = p.product_id
)

SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    FLOOR(AVG(p.price * s.quantity)) AS average_income
FROM
    employees AS e
INNER JOIN sales AS s ON e.employee_id = s.sales_person_id
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY
    CONCAT(e.first_name, ' ', e.last_name)
HAVING
    AVG(p.price * s.quantity) < (SELECT total_avg FROM tab)
ORDER BY
    average_income;
--Запрос выводит имена и фамилии продавцов, названия дней недели и выручку.
--Результат отсортирован по номерам дней недели и именам и фамилиям продавцов.
WITH tab AS (
    SELECT
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        TO_CHAR(s.sale_date, 'day') AS day_of_week,
        FLOOR(SUM(p.price * s.quantity)) AS income,
        EXTRACT(ISODOW FROM s.sale_date) AS day_number
    FROM
        employees AS e
    INNER JOIN sales AS s ON e.employee_id = s.sales_person_id
    INNER JOIN products AS p ON s.product_id = p.product_id
    GROUP BY
        e.first_name,
        e.last_name,
        TO_CHAR(s.sale_date, 'day'),
        EXTRACT(ISODOW FROM s.sale_date)
)

SELECT
    seller,
    day_of_week,
    income
FROM
    tab
ORDER BY
    day_number,
    seller;
--Запрос разбивает покупателей на 3 возрастные группы (16-25, 26-40 и 40+)
--и выводит эти группы и количество покупателей в них.
--Результат отсортирован по возрастным группам.
WITH tab AS (
    SELECT
        age,
        CASE
            WHEN age BETWEEN 16 AND 25 THEN '16-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            ELSE '40+'
        END AS age_category
    FROM
        customers
)

SELECT
    age_category,
    COUNT(age) AS age_count
FROM
    tab
GROUP BY
    age_category
ORDER BY
    age_category;
--Запрос выводит месяцы продаж, кол-во уникальных покупателей и выручку.
--Результат отсортирован по месяцам продаж.
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM
    sales AS s
INNER JOIN customers AS c ON s.customer_id = c.customer_id
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY
    TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY
    selling_month;
--Запрос выводит покупателей, первая покупка которых была равна 0, 
--даты и продавцов.
--Результат отсортирован по id покупателей.
WITH tab AS (
    SELECT
        s.sale_date,
        p.price,
        CONCAT(c.first_name, ' ', c.last_name) AS customer,
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id
            ORDER BY s.sale_date
        ) AS sale_number
    FROM
        sales AS s
    INNER JOIN customers AS c ON s.customer_id = c.customer_id
    INNER JOIN products AS p ON s.product_id = p.product_id
    INNER JOIN employees AS e ON s.sales_person_id = e.employee_id
)

SELECT
    tab.customer,
    tab.sale_date,
    tab.seller
FROM
    tab
WHERE
    tab.price = 0
    AND tab.sale_number = 1
ORDER BY
    tab.customer;
