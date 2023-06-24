----First, I created a schema called "dtf" to store the tables for analysis. Three tables are included in this schema: 
----menu (incl. product id for each dish, product name for each dish, main categories for each dish & selling price for each dish),
----orders (incl. dates when the order was placed, order id for each order & total price for each order)
----order_details (incl. order id for each order record, item id for the dish ordered & price for each dish ordered)

----Then, I cleaned the data first, and conducted the analysis



/*Data Cleansing*/
---1. For menu table
--Find null value
SELECT product_id,product_name,category,price
FROM dtf.menu
WHERE product_id IS NULL
      OR product_name IS NULL
	  OR category IS NULL
	  OR price IS NULL;
--No null value returned

--Find min & max of product_id and price
SELECT MIN(product_id), MAX(product_id),
	   MIN(price), MAX(price)
FROM dtf.menu;
--Both product_id & price have reasonable values

--See whether the product_id is unique
SELECT COUNT(product_id),
       COUNT(DISTINCT product_id)
FROM dtf.menu;
--product_id is unique

--See whether the values in 'product_name' column are reasonable
SELECT DISTINCT product_name
FROM dtf.menu;
--All the products name are reasonable

--See whether the values in 'category' column are reasonable
SELECT DISTINCT category
FROM dtf.menu;
--All the category names are reasonable

---2. For orders table
--Find null value
SELECT order_date,order_id,total_price
FROM dtf.orders
WHERE order_date IS NULL
      OR order_id IS NULL
	  OR total_price IS NULL;
--No null value returned

--Take a glance at the begining date & end date of order records
SELECT MIN(order_date) begin_date,
       MAX(order_date) end_date
FROM dtf.orders;
--The records started from Jan 1st, 2023, and ended on May 17th, 2023
--And since the records for the last week (i.e. May 14th-May 20th, Sunday as the first day of week) is incomplete, I will omit these records for the analysis to prevent bias

--Find if there are unreasonable values for the order_date column
SELECT DISTINCT order_date
FROM dtf.orders;
--No unreasonable values returned

--Find min & max of order_id, & total_price
SELECT MIN(order_id), MAX(order_id),
	   MIN(total_price), MAX(total_price)
FROM dtf.orders;
--The two columns have reasonable values

--See whether the order_id is unique
SELECT COUNT(order_id),
       COUNT(DISTINCT order_id)
FROM dtf.orders;
--order_id is unique

---3. For order_detail table
--Find null value
SELECT order_id,item_id,price
FROM dtf.order_details
WHERE order_id IS NULL
      OR item_id IS NULL
	  OR price IS NULL;
--No null value returned

--Find min & max of order_id, item_id & price
SELECT MIN(order_id), MAX(order_id),
       MIN(item_id), MIN(item_id),
	   MIN(price), MAX(price)
FROM dtf.order_details;
--All the three columns have reasonable values


/*General Sales Analysis*/
---General Performance Reviews
SELECT COUNT(DISTINCT o.order_id) orders,
       COUNT(od.item_id) dishes_sold,
	   SUM(o.total_price) total_revenue
FROM dtf.order_details od
LEFT JOIN dtf.orders o
ON od.order_id=o.order_id
WHERE o.order_date<'2023-05-14';
--Up until May 13th, 2023, DTF received NT$12M in revenue by selling more than 14K dishes.
--And obviously, the customers often orders more than one dish in each order, since there are only 3,742 orders on records


---Dive deeper in the dishes that DTF sold
---1. How many dishes are typically in an order?
SELECT ROUND(COUNT(od.item_id)::numeric/COUNT(DISTINCT o.order_id)::numeric,2) dishes_per_order
FROM dtf.order_details od
LEFT JOIN dtf.orders o
ON od.order_id=o.order_id
WHERE o.order_date<'2023-05-14';
--On average, customers will order nearly 4 dishes (3.83 to be precise) in each order

---2. Who's the best seller?
--First, let's take a look at the number of orders and total revenue for each type of dishes
SELECT me.category dishes_category,
       COUNT(od.item_id) num_of_orders,
	   SUM(od.price) revenue
FROM dtf.order_details od
LEFT JOIN dtf.menu me
ON od.item_id=me.product_id
LEFT JOIN dtf.orders o
ON od.order_id=o.order_id
WHERE o.order_date<'2023-05-14'
GROUP BY 1
ORDER BY 2 DESC;
/*ORDER BY 3 DESC;*/

--Then, the same two aspects for each dishes
SELECT me.product_name dishes,
       COUNT(od.item_id) num_of_orders,
	   SUM(od.price) revenue
FROM dtf.order_details od
LEFT JOIN dtf.menu me
ON od.item_id=me.product_id
LEFT JOIN dtf.orders o
ON od.order_id=o.order_id
WHERE o.order_date<'2023-05-14'
GROUP BY 1
ORDER BY 2 DESC;
/*ORDER BY 3 DESC;*/
--Xiaolongbao is the most ordered type of dishes, and brings the most revenue among all the other dishes types (NT$1.01M)
--Pork Xiaolongbao is ordered slightly more times than the other dishes (911 dishes), while Crab Roe and Pork Xiaolongbao brings the most revenue (NT$323k)


/*Trend Analysis*/
---Find weekly order & revenue trends
SELECT MIN(DATE(order_date)) week_start_date,
       COUNT(order_id) orders,
	   SUM(total_price) revenue
FROM dtf.orders
WHERE order_date<'2023-05-14'
GROUP BY DATE_PART('week',order_date)
ORDER BY 1;
--Before the new feature was introduced, DTF has less than 200 orders each week and receieve NT$131k-144k revenue
--However, after the introduction of the new feature, DTF has more than 200 orders per week and gain more than NT$183k each week
--Therefore, the new feature seems to boost sales quite effectively


---Are there any busy days in a week?
SELECT DATE_PART('dow', order_date) day_of_week,
       COUNT(order_id) orders
FROM dtf.orders
WHERE order_date<'2023-05-14'
GROUP BY 1
ORDER BY 1;
--Fridays turn out to be the least busiest days for DTF with 510 total orders in this 5-month period. 


/*Comparison between dishes sold & revenue of each product before the new feature was lauched and after the launch*/
---First, let's take a look on the dish type prospective
--Since there are less records after the introduction of the new feature, I limited the time period of the dataset to one month before the introduction and one month after the introduction to make them comparable
WITH bef AS(
	 SELECT me.category dish_type,
            COUNT(od.item_id) dishes_sold,
            SUM(od.price) revenue
     FROM dtf.order_details od
     LEFT JOIN dtf.menu me
     ON od.item_id=me.product_id
     LEFT JOIN dtf.orders o
     ON o.order_id=od.order_id
     WHERE o.order_date BETWEEN '2023-03-01' AND '2023-03-31'   --One month before the introduction  
     GROUP BY 1),

    aft AS (
	SELECT me.category dish_type,
           COUNT(od.item_id) dishes_sold,
           SUM(od.price) revenue
    FROM dtf.order_details od
    LEFT JOIN dtf.menu me
    ON od.item_id=me.product_id
    LEFT JOIN dtf.orders o
    ON o.order_id=od.order_id
    WHERE o.order_date BETWEEN '2023-04-01' AND '2023-04-30'    --One month after the introduction
    GROUP BY 1)
	
SELECT bef.dish_type,
       bef.dishes_sold dishes_sold_bef,
	   aft.dishes_sold dishes_sold_aft,
	   bef.revenue revenue_bef,
	   aft.revenue revenue_aft
FROM bef
JOIN aft
ON bef.dish_type=aft.dish_type
ORDER BY 1;
--After the introduction of the new feature, the number of dishes sold and the revenue has increased for all categories
--Both Xiaolongbao and Dumplings & Shao Mai have dramatic increase in the number of dishes sold and the revenue
--But still, Xiaolongbao remains the most popular type of dishes among all the categories, and Dumplings & Shao Mai remains the second

---Then, let's drill down to see whether there are changes in the number of dishes sold & revenue for each dishes of each category
--1. Xiaolongbao
WITH x_bef AS(
     SELECT me.product_name dish_name,
            COUNT(od.item_id) dishes_sold,
            SUM(od.price) revenue
     FROM dtf.order_details od
     LEFT JOIN dtf.menu me
     ON od.item_id=me.product_id
     LEFT JOIN dtf.orders o
     ON o.order_id=od.order_id
     WHERE o.order_date BETWEEN '2023-03-01' AND '2023-03-31'   --One month before the introduction
	       AND me.category='Xiaolongbao'
     GROUP BY 1),
	 
	x_aft AS (
	SELECT me.product_name dish_name,
           COUNT(od.item_id) dishes_sold,
           SUM(od.price) revenue
    FROM dtf.order_details od
    LEFT JOIN dtf.menu me
    ON od.item_id=me.product_id
    LEFT JOIN dtf.orders o
    ON o.order_id=od.order_id
    WHERE o.order_date BETWEEN '2023-04-01' AND '2023-04-30'    --One month after the introduction
		  AND me.category='Xiaolongbao'
    GROUP BY 1)

SELECT x_bef.dish_name,
       x_bef.dishes_sold dishes_sold_bef,
	   x_aft.dishes_sold dishes_sold_aft,
	   ROUND((x_aft.dishes_sold-x_bef.dishes_sold)::numeric/x_bef.dishes_sold::numeric,4) dishes_sold_increment,
	   x_bef.revenue revenue_bef,
	   x_aft.revenue revenue_aft,
	   ROUND((x_aft.revenue-x_bef.revenue)::numeric/x_bef.revenue::numeric,4) revenue_increment
FROM x_bef
JOIN x_aft
ON x_bef.dish_name=x_aft.dish_name
ORDER BY 1;
--In general, the new feature boost both number of dishes sold and sales of all dishes in Xiaolongbao 
--Pork Xiaolongbao still remains the most ordered dishes among the four, and Crab Roe and Pork Xiaolongbao still brings the most revenue
--However, if you take a closer look at the increment in orders and sales, Crab Roe and Pork Xiaolongbao benefits the most from this system improvement (48.31% increase in orders & revenue)

--2. Dumplings & Shao Mai
WITH ds_bef AS(
     SELECT me.product_name dish_name,
            COUNT(od.item_id) dishes_sold,
            SUM(od.price) revenue
     FROM dtf.order_details od
     LEFT JOIN dtf.menu me
     ON od.item_id=me.product_id
     LEFT JOIN dtf.orders o
     ON o.order_id=od.order_id
     WHERE o.order_date BETWEEN '2023-03-01' AND '2023-03-31'   --One month before the introduction
	       AND me.category='Dumplings & Shao Mai'
     GROUP BY 1),
	 
	ds_aft AS (
	SELECT me.product_name dish_name,
           COUNT(od.item_id) dishes_sold,
           SUM(od.price) revenue
    FROM dtf.order_details od
    LEFT JOIN dtf.menu me
    ON od.item_id=me.product_id
    LEFT JOIN dtf.orders o
    ON o.order_id=od.order_id
    WHERE o.order_date BETWEEN '2023-04-01' AND '2023-04-30'    --One month after the introduction
		  AND me.category='Dumplings & Shao Mai'
    GROUP BY 1)

SELECT ds_bef.dish_name,
       ds_bef.dishes_sold dishes_sold_bef,
	   ds_aft.dishes_sold dishes_sold_aft,
	   ROUND((ds_aft.dishes_sold-ds_bef.dishes_sold)::numeric/ds_bef.dishes_sold::numeric,4) dishes_sold_increment,
	   ds_bef.revenue revenue_bef,
	   ds_aft.revenue revenue_aft,
	   ROUND((ds_aft.revenue-ds_bef.revenue)::numeric/ds_bef.revenue::numeric,4) revenue_increment
FROM ds_bef
JOIN ds_aft
ON ds_bef.dish_name=ds_aft.dish_name
ORDER BY 1;
--In general, the new feature boost both orders and sales of all dishes in Dumplings & Shao Mai also
--Steamed Vegetable and Ground Pork Dumplings still remains the most ordered dishes among the four, and Steamed Shrimp and Pork Dumplings still brings the most revenue
--However, Steamed Vegetarian Mushroom Dumplings is the biggest winner from this improvement, which gains 37.97% increase in number of dishes sold & revenue

--3. Fried Rice
WITH fr_bef AS(
     SELECT me.product_name dish_name,
            COUNT(od.item_id) dishes_sold,
            SUM(od.price) revenue
     FROM dtf.order_details od
     LEFT JOIN dtf.menu me
     ON od.item_id=me.product_id
     LEFT JOIN dtf.orders o
     ON o.order_id=od.order_id
     WHERE o.order_date BETWEEN '2023-03-01' AND '2023-03-31'   --One month before the introduction
	       AND me.category='Fried Rice'
     GROUP BY 1),
	 
	fr_aft AS (
	SELECT me.product_name dish_name,
           COUNT(od.item_id) dishes_sold,
           SUM(od.price) revenue
    FROM dtf.order_details od
    LEFT JOIN dtf.menu me
    ON od.item_id=me.product_id
    LEFT JOIN dtf.orders o
    ON o.order_id=od.order_id
    WHERE o.order_date BETWEEN '2023-04-01' AND '2023-04-30'    --One month after the introduction
		  AND me.category='Fried Rice'
    GROUP BY 1)

SELECT fr_bef.dish_name,
       fr_bef.dishes_sold dishes_sold_bef,
	   fr_aft.dishes_sold dishes_sold_aft,
	   ROUND((fr_aft.dishes_sold-fr_bef.dishes_sold)::numeric/fr_bef.dishes_sold::numeric,4) dishes_sold_increment,
	   fr_bef.revenue revenue_bef,
	   fr_aft.revenue revenue_aft,
	   ROUND((fr_aft.revenue-fr_bef.revenue)::numeric/fr_bef.revenue::numeric,4) revenue_increment
FROM fr_bef
JOIN fr_aft
ON fr_bef.dish_name=fr_aft.dish_name
ORDER BY 1;
--In general, the new feature boost both orders and sales of all dishes in Fried Rice category as well
--Before the introduction, our customers tend to pick Shredded Pork Fried Rice for their orders
--However, after the introduction, Shrimp Fried Rice became DTF customers' favourite
--Despite these changes, Shrimp and Shredded Pork Fried Rice still brings the most revenue in the Fried Rice category

--4. Buns
WITH b_bef AS(
     SELECT me.product_name dish_name,
            COUNT(od.item_id) dishes_sold,
            SUM(od.price) revenue
     FROM dtf.order_details od
     LEFT JOIN dtf.menu me
     ON od.item_id=me.product_id
     LEFT JOIN dtf.orders o
     ON o.order_id=od.order_id
     WHERE o.order_date BETWEEN '2023-03-01' AND '2023-03-31'   --One month before the introduction
	       AND me.category='Buns'
     GROUP BY 1),
	 
	b_aft AS (
	SELECT me.product_name dish_name,
           COUNT(od.item_id) dishes_sold,
           SUM(od.price) revenue
    FROM dtf.order_details od
    LEFT JOIN dtf.menu me
    ON od.item_id=me.product_id
    LEFT JOIN dtf.orders o
    ON o.order_id=od.order_id
    WHERE o.order_date BETWEEN '2023-04-01' AND '2023-04-30'    --One month after the introduction
		  AND me.category='Buns'
    GROUP BY 1)

SELECT b_bef.dish_name,
       b_bef.dishes_sold dishes_sold_bef,
	   b_aft.dishes_sold dishes_sold_aft,
	   ROUND((b_aft.dishes_sold-b_bef.dishes_sold)::numeric/b_bef.dishes_sold::numeric,4) dishes_sold_increment,
	   b_bef.revenue revenue_bef,
	   b_aft.revenue revenue_aft,
	   ROUND((b_aft.revenue-b_bef.revenue)::numeric/b_bef.revenue::numeric,4) revenue_increment
FROM b_bef
JOIN b_aft
ON b_bef.dish_name=b_aft.dish_name
ORDER BY 1;
--In general, the new feature boost both orders and sales of every dishes in Buns as well
--Before the introduction, Pork Buns was DTF customer's second favourite
--However, after the introduction, Vegetarian Mushroom Buns became their new second favourites and new main revenue-driver for the Buns category
--Despite these changes, Vegtable and Ground Pork Buns still remain our best-seller in the Buns category

--5. Desserts
WITH d_bef AS(
     SELECT me.product_name dish_name,
            COUNT(od.item_id) dishes_sold,
            SUM(od.price) revenue
     FROM dtf.order_details od
     LEFT JOIN dtf.menu me
     ON od.item_id=me.product_id
     LEFT JOIN dtf.orders o
     ON o.order_id=od.order_id
     WHERE o.order_date BETWEEN '2023-03-01' AND '2023-03-31'   --One month before the introduction
	       AND me.category='Desserts'
     GROUP BY 1),
	 
	d_aft AS (
	SELECT me.product_name dish_name,
           COUNT(od.item_id) dishes_sold,
           SUM(od.price) revenue
    FROM dtf.order_details od
    LEFT JOIN dtf.menu me
    ON od.item_id=me.product_id
    LEFT JOIN dtf.orders o
    ON o.order_id=od.order_id
    WHERE o.order_date BETWEEN '2023-04-01' AND '2023-04-30'    --One month after the introduction
		  AND me.category='Desserts'
    GROUP BY 1)

SELECT d_bef.dish_name,
       d_bef.dishes_sold dishes_sold_bef,
	   d_aft.dishes_sold dishes_sold_aft,
	   ROUND((d_aft.dishes_sold-d_bef.dishes_sold)::numeric/d_bef.dishes_sold::numeric,4) dishes_sold_increment,
	   d_bef.revenue revenue_bef,
	   d_aft.revenue revenue_aft,
	   ROUND((d_aft.revenue-d_bef.revenue)::numeric/d_bef.revenue::numeric,4) revenue_increment
FROM d_bef
JOIN d_aft
ON d_bef.dish_name=d_aft.dish_name
ORDER BY 1;
--In general, the new system boost both orders and sales of all dishes in Desserts also
--Steamed Red Bean Rick Cake still remains the most ordered dishes and Steamed Red Bean Rice Cake with Walnuts still brings the most revenue
--Also, Steamed Red Bean Rick Cake is the biggest winner from this improvement, which gains 25.41% increase in the number of dishes sold & revenue


/*Merging Table for Data Visualization*/
SELECT od.order_id,
       DATE(o.order_date),
       od.item_id dish_id,
	   me.product_name dish_name,
	   me.category dish_category,
	   od.price
FROM dtf.order_details od
LEFT JOIN dtf.orders o
ON od.order_id=o.order_id
LEFT JOIN dtf.menu me
ON me.product_id=od.item_id;