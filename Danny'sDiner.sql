create schema Dannys_diner;
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);
INSERT INTO sales
  (customer_id, order_date,product_id)
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
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  #What is the total amount each customer spent at the restaurant?
  select customer_id, sum(price) as total_amount
  From Menu M
  Join Sales S on M.product_id = S.product_id
  group by customer_id;
  
  -- How many days has each customer visited the restaurant?
  select customer_id, count( distinct order_date) as numberofvisits
  From Sales
  group by customer_id;
  
  -- What was the first item from the menu purchased by each customer?
 select customer_id,filtered.Product_id,product_name
 From(select *, row_number()over(partition by customer_id order by order_date) as first_item
  FRom sales) as filtered
  join menu m  on filtered.product_id = m.product_id
  where first_item = 1;
  
  -- What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT m.product_name, COUNT(s.product_id) AS purchase_count
FROM Sales s
JOIN Menu m ON s.product_id = m.product_id
GROUP BY m.product_id, m.product_name
ORDER BY purchase_count DESC
LIMIT 1;

-- Which item was the most popular for each customer?
with cte as (
    select s.customer_id,m.product_name, rank() over(partition by s.customer_id order by count(s.product_id) desc) as ranked
    from sales s
    join menu m on s.product_id = m.product_id
    group by s.customer_id,s.product_id, m.product_name)
    
    select customer_id, Product_name
    from cte
    where ranked =1;
    
    -- Which item was purchased first by the customer after they became a member?
   select distinct customer_id, product_name 
   From( select   s.customer_id, 
    m.product_name, 
    s.order_date, row_number() over(partition by s.customer_id order by s.order_date) as rn
    From sales s
    Join menu m on s.product_id= m.product_id
    join members mm on s.customer_id= mm.customer_id
    where s.order_date >= mm. join_date) as filtered
    where rn=1;
    
    -- Which item was purchased just before the customer became a member?
Select distinct customer_id, product_name
From(select s.customer_id, 
    m.product_name, 
    s.order_date,join_date, row_number() over(partition by s.customer_id order by s.order_date) as rn
    From sales s
    Join menu m on s.product_id= m.product_id
    join members mm on s.customer_id= mm.customer_id
    where s.order_date < mm. join_date) as filtered;
    
    #What is the total items and amount spent for each member before they became a member?
    select s.customer_id,SUM(PRICE) AS TOTAL, count(s.product_id) as total_purchased
    From sales s
    Join menu m on s.product_id= m.product_id
    join members mm on s.customer_id= mm.customer_id
    where s.order_date < mm.join_date
    GROUP BY s.customer_id
    order by s.customer_id;
    
    -- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
   select customer_id,sum(points) as Total_points
   From(select s.customer_id, 
    m.product_name, 
    s.order_date, price, (case when product_name = "sushi" then price*20
    else price*10 end) as points
    From sales s
    Join menu m on s.product_id= m.product_id
    join members mm on s.customer_id= mm.customer_id
    where s.order_date >= mm. join_date) as filtered
    Group by customer_id
    order by customer_id;
    
    /*In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?*/
    select customer_id, sum(points) as total_points
    From(select s.customer_id, 
    m.product_name, 
    s.order_date, price, (case when s.order_date>= join_date and s.order_date<=Date_add(join_date, interval 6 Day) then price*20
    end) as points
    From sales s
    Join menu m on s.product_id= m.product_id
    join members mm on s.customer_id= mm.customer_id
    where s.order_date >= mm. join_date) as filtered
    where order_date <= '2021-01-31'
    group by customer_id
    order by customer_id;
 
    


 
  
  
