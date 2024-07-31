-- 1)Retrieve the total number of orders placed.
    SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
  
-- 2)Calculate the total revenue generated from pizza sales.
     SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM
    orders_details od
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id;
	
-- 3)Identify the highest-priced pizza.
SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- 4)Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(od.order_detail_id) AS order_count
FROM
    pizzas p
        JOIN
    orders_details od ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY order_count DESC;

-- 5)List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, SUM(od.quantity) AS quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    orders_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 5;

-- 6)Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) AS quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    orders_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category;

-- 7)Determine the distribution of orders by hour of the day.

select hour(order_time), count(order_id) from orders
group by hour(order_time); 

-- 8)Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- 9)Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity))
FROM
    (SELECT 
        order_date, SUM(quantity) AS quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY order_date) AS order_quantity;

-- 10)Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, SUM(od.quantity * p.price) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    orders_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- 11)Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category,
    (SUM(od.quantity * p.price) / (SELECT 
            ROUND(SUM(od.quantity * p.price), 2) AS total_sales
        FROM
            orders_details od
                JOIN
            pizzas p ON p.pizza_id = od.pizza_id)) * 100 AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    orders_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY revenue DESC;

-- 12)Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over(order by order_date) as cum_revenue 
from
(SELECT 
    o.order_date, SUM(od.quantity * p.price) AS revenue
FROM
    orders_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
    join orders o on o.order_id=od.order_id
    group by o.order_date) as sales  ;
    
-- 13)Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name,revenue from
(select category,name,revenue,
rank() over(partition by category order by revenue desc) as rn 
from
(SELECT 
    pt.category, pt.name,
    SUM(od.quantity * p.price) AS revenue
        FROM
            pizza_types pt
                JOIN
            pizzas p ON pt.pizza_type_id = p.pizza_type_id

    join orders_details od on od.pizza_id=p.pizza_id
    GROUP BY pt.category,pt.name) as a) as b
    where rn <=3;



  
  