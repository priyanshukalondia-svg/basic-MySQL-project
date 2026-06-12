CREATE DATABASE ecommerce_analysis;
USE ecommerce_analysis;
SHOW DATABASES;
CREATE TABLE customers ( customer_id INT PRIMARY KEY, customer_name VARCHAR(100), city VARCHAR(50) , gender VARCHAR(10));
DESCRIBE customers;
CREATE TABLE products (product_id INT PRIMARY KEY, product_name VARCHAR(100), category VARCHAR(50), price DECIMAL(10,2));
SHOW TABLES;
DESCRIBE products;
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);
INSERT INTO customers
VALUES
(1,'Rahul Sharma','Delhi','Male'),
(2,'Priya Singh','Mumbai','Female'),
(3,'Aman Verma','Bangalore','Male'),
(4,'Neha Gupta','Pune','Female'),
(5,'Arjun Mehta','Delhi','Male');
SELECT * FROM customers;
INSERT INTO products
VALUES
(101,'Laptop','Electronics',55000),
(102,'Mouse','Electronics',800),
(103,'Keyboard','Electronics',1500),
(104,'Office Chair','Furniture',7000),
(105,'Study Table','Furniture',12000);
SELECT *  FROM products;
INSERT INTO orders
VALUES
(1001,1,'2025-01-05'),
(1002,2,'2025-01-08'),
(1003,1,'2025-02-10'),
(1004,3,'2025-02-15'),
(1005,5,'2025-03-01');
SELECT * FROM orders;
INSERT INTO order_items
VALUES
(1,1001,101,1),
(2,1001,102,2),
(3,1002,103,1),
(4,1003,101,1),
(5,1004,104,1),
(6,1005,105,1),
(7,1005,102,3);
SELECT * FROM order_items;
SELECT *
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id;
SELECT
p.product_name,
p.price,
oi.quantity,
(p.price * oi.quantity) AS revenue
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id;
SELECT 
product_name , quantity , 
(p.price * oi.quantity) AS revenue
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id;
SELECT
SUM(price * quantity) AS total_revenue
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id;

SELECT
p.product_name,
SUM(p.price * oi.quantity) AS revenue
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 3;

SELECT
c.customer_name,
SUM(p.price * oi.quantity) AS total_spent
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id
GROUP BY c.customer_name
ORDER BY total_spent DESC;

SELECT
c.customer_name,
COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name;

SELECT
c.customer_name,
COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name
HAVING COUNT(o.order_id) > 1;

SELECT *
FROM products
WHERE price >
(
    SELECT AVG(price)
    FROM products
);

SELECT
p.product_name,
SUM(p.price * oi.quantity) AS revenue
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.product_name
HAVING SUM(p.price * oi.quantity) >
(
    SELECT AVG(product_revenue)
    FROM
    (
        SELECT
        SUM(p2.price * oi2.quantity) AS product_revenue
        FROM order_items oi2
        JOIN products p2
        ON oi2.product_id = p2.product_id
        GROUP BY p2.product_name
    ) AS revenue_table
);

SELECT
p.product_name,
SUM(p.price * oi.quantity) AS revenue,
RANK() OVER(
    ORDER BY SUM(p.price * oi.quantity) DESC
) AS product_rank
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.product_name;

SELECT
c.customer_name,
SUM(p.price * oi.quantity) AS total_spent,
RANK() OVER(
    ORDER BY SUM(p.price * oi.quantity) DESC
) AS customer_rank
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name;

SELECT *
FROM
(
    SELECT
    c.customer_name,
    SUM(p.price * oi.quantity) AS total_spent,
    RANK() OVER(
        ORDER BY SUM(p.price * oi.quantity) DESC
    ) AS customer_rank
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY c.customer_id, c.customer_name
) ranked_customers
WHERE customer_rank = 1;

SELECT
p.product_name,
SUM(p.price * oi.quantity) AS revenue,

CASE
    WHEN SUM(p.price * oi.quantity) > 50000
        THEN 'High Revenue'

    WHEN SUM(p.price * oi.quantity) > 10000
        THEN 'Medium Revenue'

    ELSE 'Low Revenue'
END AS revenue_category

FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id

GROUP BY p.product_name;

SELECT
c.customer_name,
SUM(p.price * oi.quantity) AS total_spent,

CASE
    WHEN SUM(p.price * oi.quantity) > 100000
        THEN 'VIP'
    ELSE 'Regular'
END AS customer_type

FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id

JOIN order_items oi
ON o.order_id = oi.order_id

JOIN products p
ON oi.product_id = p.product_id

GROUP BY c.customer_id, c.customer_name;

WITH customer_spending AS
(
    SELECT
    c.customer_name,
    SUM(p.price * oi.quantity) AS total_spent

    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id

    GROUP BY c.customer_id, c.customer_name
)

SELECT
customer_name,
total_spent,
RANK() OVER(
    ORDER BY total_spent DESC
) AS customer_rank
FROM customer_spending;






