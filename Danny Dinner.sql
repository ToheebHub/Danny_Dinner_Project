CREATE TABLE sales (
"customer_id" VARCHAR(1),
"order_date" DATE,
"product_id" INTEGER
);
INSERT INTO sales
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
('B', '2021-02-01', '3'),
('C', '2021-01-01', '3'),
('C', '2021-01-01', '3'),
('C', '2021-01-07', '3');


CREATE TABLE menu (
"product_id" INTEGER,
"product_name" VARCHAR(5),
"price" INTEGER
);
INSERT INTO menu
("product_id", "product_name", "price")
VALUES
('1', 'sushi', '10'),
('2', 'curry', '15'),
('3', 'ramen', '12');


CREATE TABLE members (
"customer_id" VARCHAR(1),
"join_date" DATE
);
INSERT INTO members
("customer_id", "join_date")
VALUES
('A', '2021-01-07'),
('B', '2021-01-09');


select * from sales

select * from  menu 

select * from members 


1. What is the total amount each customer spent at the restaurant?
Select s.customer_id,  sum(m.price ) as total_spent
from sales s
join menu m
on s.product_id = m.product_id
group by s.customer_id

2. How many days has each customer visited the restaurant?
select customer_id, count(distinct order_date) as number_of_days
from sales
group by customer_id


3. What was the first item from the menu purchased by each customer?
with cte as (
select s.customer_id, s.order_date, m.product_name, DENSE_RANK() OVER( PARTITION BY s.customer_id
ORDER BY s.order_date) as rank
from sales s
join menu m
on s.product_id = m.product_id 
)
select customer_id, product_name
from cte
where rank = 1

4. What is the most purchased item on the menu and how many times was it purchased by
all customers?

select top 1 m.product_name,
count(s.product_id) as most_purchased
from menu m
join sales s
on m.product_id = s.product_id
group by m.product_name
order by most_purchased desc

5. Which item was the most popular for each customer?
with cte as(
    select s.customer_id, m.product_name, COUNT(m.product_id) as order_count,
	DENSE_RANK() OVER(PARTITION by s.customer_id order by count(s.customer_id) desc) as rank
    from sales s
    join menu m
    on s.product_id = m.product_id
    group by s.customer_id, m.product_name
)
select customer_id, product_name
from cte
where rank = 1;


with cte as (
select s.customer_id, s.order_date, m.product_name,  s.customer_id
ORDER BY s.order_date) as rank
from sales s
join menu m
on s.product_id = m.product_id 


6. Which item was purchased first by the customer after they became a member?
with cte as (
    select s.customer_id,s.product_id, DENSE_RANK() OVER(PARTITION by s.customer_id ORDER BY s.order_date) as rank
	from sales s
    join members e
	on s.customer_id = e.customer_id
	and s.order_date > e.join_date
)
   select c.customer_id, me.product_name
	from cte c
	join menu me
	on c.product_id = me.product_id
	where rank = 1

7. Which item was purchased just before the customer became a member?
with cte as (
    select s.customer_id,s.product_id, DENSE_RANK() OVER(PARTITION by s.customer_id ORDER BY s.order_date) as rank
	from sales s
    join members e
	on s.customer_id = e.customer_id
	and s.order_date < e.join_date
)
   select c.customer_id, me.product_name
	from cte c
	join menu me
	on c.product_id = me.product_id
	where rank = 1