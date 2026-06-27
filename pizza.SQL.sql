CREATE DATABASE PIZZASALES;
USE PIZZASALES;

CREATE TABLE ORDERS(
ORDER_ID INT NOT NULL,
ORDER_DATE DATE NOT NULL,
ORDER_TIME TIME NOT NULL,
primary key(ORDER_ID)

);

CREATE TABLE ORDER_DETAILS(
ORDER_DETAIL_ID INT NOT NULL,
ORDER_ID INT NOT NULL,
PIZZA_ID TEXT NOT NULL,
QUANTITY INT NOT NULL,
PRIMARY KEY(ORDER_DETAIL_ID)

);

-- Retrieve the total number of orders placed
SELECT
     COUNT(ORDER_ID) AS 'TOTAL_ORDERS' 
FROM ORDERS;

-- Calculate the total revenue generated from pizza sales.
SELECT 
     ROUND(SUM(QUANTITY*PRICE) ,2)AS 'TOTAL_SALE ' 
FROM pizzasales.order_details P1 
JOIN
    pizzasales.pizzas P2 ON P1.PIZZA_ID = P2.PIZZA_ID;


-- Identify the highest-priced pizza.
SELECT  
     P1.NAME,P2.PRICE
FROM pizzasales.pizza_types P1 
JOIN 
    pizzasales.pizzas P2 ON P1.PIZZA_TYPE_ID = P2.PIZZA_TYPE_ID
ORDER BY P2.PRICE DESC LIMIT 1 ;


-- Identify the most common pizza size ordered.
SELECT  
     SIZE ,COUNT(ORDER_DETAIL_ID) AS 'ORDER_PER_SIZE'
FROM pizzasales.order_details P1
JOIN 
    pizzasales.pizzas P2 ON P1.PIZZA_ID = P2.PIZZA_ID
GROUP BY SIZE
ORDER BY ORDER_PER_SIZE DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
     NAME,SUM(QUANTITY) AS 'TOTAL_ORDERS'
FROM pizzasales.order_details P1 
JOIN 
    pizzasales.pizzas P2 ON P1.PIZZA_ID = P2.PIZZA_ID
JOIN 
    pizzasales.pizza_types P3 ON P2.PIZZA_TYPE_ID = P3.PIZZA_TYPE_ID
GROUP BY NAME 
ORDER BY TOTAL_ORDERS DESC LIMIT 5;






-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
     CATEGORY ,SUM(QUANTITY)
FROM pizzasales.order_details P1 
JOIN 
    pizzasales.pizzas P2 ON P1.PIZZA_ID = P2.PIZZA_ID
JOIN 
    pizzasales.pizza_types P3 ON P2.PIZZA_TYPE_ID = P3.PIZZA_TYPE_ID
GROUP BY CATEGORY
ORDER BY SUM(QUANTITY) DESC LIMIT 5;

-- Determine the distribution of orders by hour of the day.
SELECT
     HOUR(ORDER_TIME),COUNT(ORDER_ID)
FROM pizzasales.orders
GROUP BY  HOUR(ORDER_TIME)
ORDER BY COUNT(ORDER_ID) DESC;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
	CATEGORY,COUNT(NAME)
FROM pizzasales.pizza_types 
GROUP BY CATEGORY;
     
-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
      ROUND(AVG(QUANTITY),2 )AS AVG_PIZZA_ORDER_PER_DAY
FROM
(SELECT 
     ORDER_DATE ,SUM(QUANTITY) AS QUANTITY
FROM pizzasales.orders P1
JOIN
pizzasales.order_details P2 ON P1.ORDER_ID = P2.ORDER_ID
GROUP BY ORDER_DATE) AS ORDER_QUANTITY;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
      NAME,SUM(QUANTITY* PRICE) AS REVENUE
FROM pizzasales.order_details P1
JOIN
pizzasales.pizzas P2 ON P1.PIZZA_ID = P2.PIZZA_ID
JOIN
pizzasales.pizza_types P3 ON P2.PIZZA_TYPE_ID = P3.PIZZA_TYPE_ID
GROUP BY NAME
ORDER BY REVENUE DESC LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
      CATEGORY,ROUND(SUM(QUANTITY* PRICE) /(SELECT 
      ROUND(SUM(QUANTITY* PRICE))
FROM pizzasales.order_details P1
JOIN
pizzasales.pizzas P2 ON P1.PIZZA_ID = P2.PIZZA_ID)*100) AS PERCENTAGE
FROM pizzasales.order_details P1
JOIN
pizzasales.pizzas P2 ON P1.PIZZA_ID = P2.PIZZA_ID
JOIN
pizzasales.pizza_types P3 ON P2.PIZZA_TYPE_ID = P3.PIZZA_TYPE_ID
GROUP BY CATEGORY
ORDER BY PERCENTAGE DESC ;



-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT 
    NAME,
    CATEGORY,
    TOTAL_REVENUE,
    RANK() OVER (PARTITION BY CATEGORY ORDER BY TOTAL_REVENUE DESC) AS RANKING
FROM (
    SELECT 
        NAME,
        CATEGORY,
        SUM(QUANTITY * PRICE) AS TOTAL_REVENUE
    FROM pizzasales.order_details P1
    JOIN pizzasales.pizzas P2 
        ON P1.PIZZA_ID = P2.PIZZA_ID
    JOIN pizzasales.pizza_types P3 
        ON P2.PIZZA_TYPE_ID = P3.PIZZA_TYPE_ID
    GROUP BY NAME,CATEGOY
    
) t;
