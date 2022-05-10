-- Data with Danny

-- SQL Case Study 1 : Danny's Dinner

-- SQL Problems

-- Q1. What is the total amount each customer spent at the restaurant?

select s.customer_id as 'customer', sum(m2.price) as 'total_amount' 
from 
menu m2 join sales s on s.product_id = m2.product_id
group by s.customer_id;

-- Q2. How many days has each customer visited the restaurant?

select s.customer_id, count(distinct s.order_date) as no_of_days
from 
sales s
group by s.customer_id;

-- Q3. What was the first item from the menu purchased by each customer?

select A.customer_id,A.product_name
from
(
select distinct s.customer_id, s.order_date, m.product_name,
rank() over 
(
partition by s.customer_id
order by s.order_date
) as 'rank'
from sales s join menu m on s.product_id = m.product_id) A
where A.rank = 1;


-- Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select top 1 m.product_id, max(m.product_name) as 'Product Name', count(s.product_id) as 'No_of_Purchase'
from 
sales s join menu m on s.product_id = m.product_id
group by m.product_id
order by No_of_Purchase desc;

-- Q5. Which item was the most popular for each customer?

select A.customer_id, A.product_name, A.popularity
from
(select s.customer_id, m.product_name, count(m.product_id) as 'popularity',
rank() over 
(
partition by s.customer_id
order by count(m.product_id) desc
) as 'rank'
from sales s join menu m on s.product_id = m.product_id
group by s.customer_id,m.product_name) A
where A.rank = 1;

-- Q6. Which item was purchased first by the customer after they became a member?

select A.customer_id,A.product_name, A.order_date from
(
select 
s.customer_id,
s.order_date,
s.product_id,
m2.product_name,
rank() over 
(
partition by s.customer_id 
order by S.order_date
) as 'rank'
from sales s join menu m2 on s.product_id = m2.product_id
where s.order_date >= (select m.join_date from members m where m.customer_id = s.customer_id) 
) A
where A.rank = 1;

-- Q7. Which item was purchased just before the customer became a member?

select A.customer_id,A.product_name,A.order_date from
(
select 
s.customer_id,
s.order_date,
s.product_id,
m2.product_name,
rank() over 
(
partition by s.customer_id 
order by S.order_date desc
) as 'rank'
from sales s join menu m2 on s.product_id = m2.product_id
where s.order_date < (select m.join_date from members m where m.customer_id = s.customer_id) 
) A
where A.rank = 1;

-- Q8. What is the total items and amount spent for each member before they became a member?

select s.customer_id, count(s.product_id), sum(m2.price)
from 
sales s join menu m2 on s.product_id = m2.product_id
where s.order_date < (select m.join_date from members m where m.customer_id = s.customer_id)
group by s.customer_id;

-- Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select A.customer_id, sum(A.price*A.unit_points) as 'total_points'
from
(
select s.customer_id, s.product_id, m.product_name, m.price,
case when m.product_name = 'sushi' then 20 else 10 end as unit_points
from sales s join menu m on s.product_id = m.product_id
) A
group by A.customer_id;

-- Q10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi 
--      How many points do customer A and B have at the end of January?

select A.customer_id, sum(A.price*A.unit_points) as 'total_points'
from
(
select s.customer_id, s.product_id, m.product_name, m.price,
case when m.product_name = 'sushi' and s.order_date >= (select m1.join_date from members m1 where m1.customer_id = s.customer_id)
		  and s.order_date < (select dateadd(day,7,m2.join_date) from members m2 where m2.customer_id = s.customer_id) then 10 
	 when m.product_name <> 'sushi' and s.order_date >= (select m1.join_date from members m1 where m1.customer_id = s.customer_id)
	      and s.order_date < (select dateadd(day,7,m2.join_date) from members m2 where m2.customer_id = s.customer_id) then 20
	 else 20 
	 end as unit_points
from 
sales s join menu m on s.product_id = m.product_id
where s.order_date <= '2021-01-31'
) A
group by A.customer_id;


