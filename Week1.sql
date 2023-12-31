create database Week1
use Week1

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



--
/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- Q1 : 
select sales.customer_id as ID_KH,
		menu.product_name as Ten_mon,
		sum(menu. price) as Gia 
from sales inner join menu on sales.product_id=menu.product_id
group by menu.product_name,sales.customer_id

--Q2 : 
select customer_id as ID_KH,
		count(distinct(order_date)) as So_ngay_ghe_tham
from sales
group by customer_id
-- Q3 : 
select  menu.product_name as Mon,
		sales.customer_id as ID_KH
from sales inner join menu on sales.product_id=menu.product_id
join 
(select sales.customer_id as ID_KH,
		min (order_date) as ngay_dau_tien
from sales
group by sales.customer_id) as first_sales on sales.customer_id=first_sales.ID_KH
								and sales.order_date=first_sales.ngay_dau_tien
--Q4 : 
select top 1 menu.product_name as Mon,
			count (*) as So_Lan_mua
from menu inner join sales on menu.product_id=sales.product_id
group by menu.product_name
order by So_Lan_mua desc
-- Q5
SELECT 
  s.customer_id as ID_KH,
  m.product_name as Mon_Pho_Bien_Nhat,
  p.max_purchases
FROM 
  (SELECT 
     customer_id, 
     product_id, 
     COUNT(*) as num_purchases
   FROM sales
   GROUP BY customer_id, product_id) as s
INNER JOIN 
  (SELECT 
     customer_id, 
     MAX(num_purchases) as max_purchases
   FROM 
     (SELECT 
        customer_id, 
        product_id, 
        COUNT(*) as num_purchases
      FROM sales
      GROUP BY customer_id, product_id) as sub
   GROUP BY customer_id) as p ON s.customer_id = p.customer_id AND s.num_purchases = p.max_purchases
JOIN menu m ON s.product_id = m.product_id;

--Q6: 
select sales.customer_id as ID_KH,
		menu.product_name as San_pham_dau_tien,
		members.join_date as Ngay_dau_tien
from sales inner join members on sales.customer_id=members.customer_id
inner join menu on menu.product_id=sales.product_id
where sales.order_date >=members.join_date

-- với cte, rank 
WITH CustomerFirstOrder AS (
  SELECT
    sales.customer_id as ID_KH,
    menu.product_name as San_pham_dau_tien,
    sales.order_date as Ngay_mua,
    members.join_date as Ngay_dau_tien_thanh_members,
    RANK() OVER (
      PARTITION BY sales.customer_id 
      ORDER BY sales.order_date ASC
    ) AS purchase_rank
FROM sales inner join members ON sales.customer_id = members.customer_id
			inner join menu  ON sales.product_id = menu.product_id
WHERE sales.order_date >= members.join_date
)
SELECT 
  ID_KH,
  San_pham_dau_tien,
  Ngay_mua,
  Ngay_dau_tien_thanh_members
FROM CustomerFirstOrder
WHERE purchase_rank = 1


--Q7 : 
select sales.customer_id as ID_KH,
		menu.product_name as San_pham_dau_tien,
		members.join_date as Ngay_dau_tien
from sales inner join members on sales.customer_id=members.customer_id
			inner join menu on menu.product_id=sales.product_id
where sales.order_date < members.join_date
and sales.order_date= ( select max(sales2.order_date) from sales as sales2 
							where sales2.customer_id=sales.customer_id
							and sales2.order_date<members.join_date)
group by sales.customer_id,menu.product_name, members.join_date
order by sales.customer_id,members.join_date 


-- với cte, rank
WITH RankedPurchases AS (
  SELECT
    sales.customer_id as ID_KH,
    menu.product_name as San_pham_dau_tien,
    sales.order_date as ngay_mua_gan_nhat,
    members.join_date as Ngay_dau_tien_thanh_member,
    RANK() OVER (
      PARTITION BY sales.customer_id 
      ORDER BY sales.order_date DESC
    ) AS purchase_rank
from sales inner join members on sales.customer_id = members.customer_id
			inner join menu  on sales.product_id = menu.product_id
where sales.order_date < members.join_date
)
SELECT 
  ID_KH,
  San_pham_dau_tien,
  ngay_mua_gan_nhat,
  Ngay_dau_tien_thanh_member
FROM RankedPurchases
WHERE purchase_rank = 1
ORDER BY ID_KH, ngay_mua_gan_nhat,Ngay_dau_tien_thanh_member

-- check 
select * from sales
select * from menu
select * from members

-- Q8 : 
select sales.customer_id as ID_KH,
		count(*) as Tong_so_mat_hang,
		sum(menu.price) as Tong_Chi_Phi
from sales inner join menu on sales.product_id=menu.product_id
		inner join members on sales.customer_id=members.customer_id
where sales.order_date < members.join_date
group by sales.customer_id

--Q9 : 
select
  sales.customer_id as ID_KH,
  SUM(CASE 
        WHEN menu.product_name = 'sushi' THEN menu.price * 20
        ELSE menu.price * 10
      END) as Tong_Diem
FROM sales inner join menu on sales.product_id = menu.product_id
where EXISTS (select * from members where members.customer_id = sales.customer_id)
group by sales.customer_id

--Q10 : 
SELECT 
  sales.customer_id as ID_KH,
  SUM(CASE 
        WHEN sales.order_date BETWEEN members.join_date AND DATEADD(day, 6, members.join_date) THEN menu.price * 20 -- 2x points for all items in the first week
        WHEN menu.product_name = 'sushi' AND sales.order_date > DATEADD(day, 6, members.join_date) THEN menu.price * 20 -- 2x points for sushi after the first week
        ELSE menu.price * 10 -- Regular points for other items after the first week
      END) as Tong_Diem
FROM 
  sales 
JOIN 
  menu  ON sales.product_id = menu.product_id
JOIN 
  members ON sales.customer_id = members.customer_id
WHERE 
  sales.customer_id IN ('A', 'B') AND
  sales.order_date <= '2021-01-31'
GROUP BY sales.customer_id

-- bonus question `1 : 
select
  sales.customer_id ,
  sales.order_date ,
  menu.product_name ,
  menu.price ,
  CASE
		WHEN members.customer_id IS NOT NULL AND sales.order_date >= members.join_date THEN 'Y'
		ELSE 'N'
  end as 'Member'
from sales join menu on sales.product_id = menu.product_id
			left join members  ON sales.customer_id = members.customer_id 
			and sales.order_date >= members.join_date
order by
  sales.customer_id, 
  sales.order_date

select * from menu 
select * from members
select * from sales
-- bonus question 2 :
select
  sales.customer_id ,
  sales.order_date ,
  menu.product_name ,
  menu.price ,
  CASE
		WHEN members.customer_id IS NOT NULL AND sales.order_date >= members.join_date THEN 'Y'
		ELSE 'N'
  end as 'Member',
  case
		when sales.order_date >= members.join_date then
			row_number() over(
				partition by sales.customer_id,
				case when sales.order_date >= members.join_date then 1 else null end
				order by sales.order_date
				)
	end as 'Ranking'
from sales join menu on sales.product_id = menu.product_id
			left join members  ON sales.customer_id = members.customer_id 
			and sales.order_date >= members.join_date
order by
  sales.customer_id, 
  sales.order_date



