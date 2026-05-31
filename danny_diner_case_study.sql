
-- Dataset and Problem statement - https://8weeksqlchallenge.com/case-study-1/

CREATE SCHEMA dannys_diner;

-- Create the sales table
CREATE TABLE dannys_diner.sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

-- Ingest sales data
INSERT INTO dannys_diner.sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '2'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

-- Create the menu table
CREATE TABLE dannys_diner.menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

-- Ingest menu data
INSERT INTO dannys_diner.menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');

-- Create the members table
CREATE TABLE dannys_diner.members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

-- Ingest members data
INSERT INTO dannys_diner.members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


-------------------------------------------------------------------
-- SOLUTION QUERIES (BUSINESS ANALYTICS USE CASES)
-------------------------------------------------------------------

-- Q1: What is the total amount each customer spent at the restaurant?
-- Demonstrates: Inner Join & Aggregation
SELECT 
    s.customer_id, 
    SUM(m.price) AS total_sales
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;


-- Q2: How many days has each customer visited the restaurant?
-- Demonstrates: COUNT(DISTINCT) to avoid multi-order day duplicates
SELECT 
    customer_id, 
    COUNT(DISTINCT order_date) AS visit_count
FROM dannys_diner.sales
GROUP BY customer_id;


-- Q3: What was the first item from the menu purchased by each customer?
-- Demonstrates: CTEs, Window Functions (DENSE_RANK), and Row Filtering
WITH ordered_sales AS (
    SELECT 
        s.customer_id, 
        s.order_date, 
        m.product_name,
        DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rank_num
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu m ON s.product_id = m.product_id
)
SELECT 
    customer_id, 
    product_name
FROM ordered_sales
WHERE rank_num = 1
GROUP BY customer_id, product_name;


-- Q4: What is the most purchased item on the menu and how many times was it purchased by all customers?
-- Demonstrates: Global Aggregation & TOP/LIMIT logic
SELECT TOP 1
    m.product_name, 
    COUNT(s.product_id) AS total_purchased
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY total_purchased DESC;


-- Q5: Which item was the most popular for each customer?
-- Demonstrates: Advanced Window Functions partitioning by customer cohorts
WITH favorite_items AS (
    SELECT 
        s.customer_id, 
        m.product_name, 
        COUNT(s.product_id) AS order_count,
        DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC) AS rank_num
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu m ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
)
SELECT 
    customer_id, 
    product_name, 
    order_count
FROM favorite_items
WHERE rank_num = 1;


-- Q6: Which item was purchased first by the customer after they became a member?
-- Demonstrates: Date comparisons across joined relational tables
WITH member_first_order AS (
    SELECT 
        s.customer_id, 
        s.order_date, 
        m.product_name,
        DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rank_num
    FROM dannys_diner.sales s
    JOIN dannys_diner.members mb ON s.customer_id = mb.customer_id
    JOIN dannys_diner.menu m ON s.product_id = m.product_id
    WHERE s.order_date >= mb.join_date
)
SELECT 
    customer_id, 
    product_name
FROM member_first_order
WHERE rank_num = 1;


-- Q7: Which item was purchased just before the customer became a member?
-- Demonstrates: Reverse chronological window ranking before a date milestone
WITH prior_member_orders AS (
    SELECT 
        s.customer_id, 
        s.order_date, 
        m.product_name,
        DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rank_num
    FROM dannys_diner.sales s
    JOIN dannys_diner.members mb ON s.customer_id = mb.customer_id
    JOIN dannys_diner.menu m ON s.product_id = m.product_id
    WHERE s.order_date < mb.join_date
)
SELECT 
    customer_id, 
    product_name,
    order_date
FROM prior_member_orders
WHERE rank_num = 1;


-- Q8: What is the total items and amount spent for each member before they became a member?
-- Demonstrates: Data segmentation before a specific timeline milestone
SELECT 
    s.customer_id, 
    COUNT(s.product_id) AS total_items, 
    SUM(m.price) AS total_spent
FROM dannys_diner.sales s
JOIN dannys_diner.members mb ON s.customer_id = mb.customer_id
JOIN dannys_diner.menu m ON s.product_id = m.product_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;


-- Q9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- Demonstrates: Conditional multi-variable mathematical logic using CASE WHEN
SELECT 
    s.customer_id,
    SUM(
        CASE 
            WHEN m.product_name = 'sushi' THEN m.price * 20
            ELSE m.price * 10
        END
    ) AS total_points
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;


-- Q10: Points calculation including the 1-week 2x loyalty promo period through January 31st
-- Demonstrates: Complex multi-tiered conditional logic and date boundary filtering
WITH promo_dates AS (
    SELECT 
        customer_id, 
        join_date,
        -- FIXED FOR SQL SERVER: Using DATEADD instead of INTERVAL
        DATEADD(day, 6, join_date) AS promo_end_date
    FROM dannys_diner.members
)
SELECT 
    s.customer_id,
    SUM(
        CASE 
            -- Condition 1: Within the first week of joining -> 2x points on EVERYTHING
            -- (Added a check to make sure pd.join_date is not null)
            WHEN pd.join_date IS NOT NULL AND s.order_date BETWEEN pd.join_date AND pd.promo_end_date THEN m.price * 20
            
            -- Condition 2: Outside promo week but item is sushi -> 2x points
            WHEN m.product_name = 'sushi' THEN m.price * 20
            
            -- Condition 3: Standard days and standard items -> 1x points
            ELSE m.price * 10
        END
    ) AS total_points
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
-- FIXED: Changed to LEFT JOIN so customers who aren't members yet aren't accidentally deleted from the results
LEFT JOIN promo_dates pd ON s.customer_id = pd.customer_id
WHERE s.order_date <= '2021-01-31'
GROUP BY s.customer_id
ORDER BY s.customer_id;

