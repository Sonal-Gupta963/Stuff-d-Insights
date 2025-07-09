DROP TABLE IF EXISTS driver;

CREATE TABLE driver (
    driver_id INT,
    reg_date DATE
);

INSERT INTO driver(driver_id, reg_date) 
VALUES 
(1, '2021-01-01'),
(2, '2021-03-01'),
(3, '2021-08-01'),
(4, '2025-12-01');

SELECT * FROM driver;


-- Drop and recreate ingredients table
DROP TABLE IF EXISTS ingredients;
CREATE TABLE ingredients(ingredients_id INTEGER, ingredients_name VARCHAR(60)); 

INSERT INTO ingredients(ingredients_id, ingredients_name) 
VALUES 
(1, 'BBQ Chicken'),
(2, 'Chilli Sauce'),
(3, 'Chicken'),
(4, 'Cheese'),
(5, 'Kebab'),
(6, 'Mushrooms'),
(7, 'Onions'),
(8, 'Egg'),
(9, 'Peppers'),
(10, 'schezwan sauce'),
(11, 'Tomatoes'),
(12, 'Tomato Sauce');

-- Drop and recreate rolls table
DROP TABLE IF EXISTS rolls;
CREATE TABLE rolls(roll_id INTEGER, roll_name VARCHAR(30)); 

INSERT INTO rolls(roll_id, roll_name) 
VALUES 
(1, 'Non Veg Roll'),
(2, 'Veg Roll');

-- Drop and recreate rolls_recipes table
DROP TABLE IF EXISTS rolls_recipes;
CREATE TABLE rolls_recipes(roll_id INTEGER, ingredients VARCHAR(24)); 

INSERT INTO rolls_recipes(roll_id, ingredients) 
VALUES 
(1, '1,2,3,4,5,6,8,10'),
(2, '4,6,7,9,11,12');

-- Drop and recreate driver_order table with fixed datetime format
DROP TABLE IF EXISTS driver_order;
CREATE TABLE driver_order(
    order_id INTEGER,
    driver_id INTEGER,
    pickup_time DATETIME,
    distance VARCHAR(7),
    duration VARCHAR(10),
    cancellation VARCHAR(23)
);

INSERT INTO driver_order(order_id, driver_id, pickup_time, distance, duration, cancellation) 
VALUES
(1, 1, '2021-01-01 18:15:34', '20km', '32 minutes', ''),
(2, 1, '2021-01-01 19:10:54', '20km', '27 minutes', ''),
(3, 1, '2021-01-03 00:12:37', '13.4km', '20 mins', 'NaN'),
(4, 2, '2021-01-04 13:53:03', '23.4', '40', 'NaN'),
(5, 3, '2021-01-08 21:10:57', '10', '15', 'NaN'),
(6, 3, NULL, NULL, NULL, 'Cancellation'),
(7, 2, '2021-01-08 21:30:45', '25km', '25mins', NULL),
(8, 2, '2021-01-10 00:15:02', '23.4 km', '15 minute', NULL),
(9, 2, NULL, NULL, NULL, 'Customer Cancellation'),
(10, 1, '2021-01-11 18:50:20', '10km', '10minutes', NULL);

-- Drop and recreate customer_orders table with fixed datetime format
DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders(
    order_id INTEGER,
    customer_id INTEGER,
    roll_id INTEGER,
    not_include_items VARCHAR(4),
    extra_items_included VARCHAR(4),
    order_date DATETIME
);

INSERT INTO customer_orders(order_id, customer_id, roll_id, not_include_items, extra_items_included, order_date)
VALUES 
(1, 101, 1, '', '', '2021-01-01 18:05:02'),
(2, 101, 1, '', '', '2021-01-01 19:00:52'),
(3, 102, 1, '', '', '2021-01-02 23:51:23'),
(3, 102, 2, '', 'NaN', '2021-01-02 23:51:23'),
(4, 103, 1, '4', '', '2021-01-04 13:23:46'),
(4, 103, 1, '4', '', '2021-01-04 13:23:46'),
(4, 103, 2, '4', '', '2021-01-04 13:23:46'),
(5, 104, 1, NULL, '1', '2021-01-08 21:00:29'),
(6, 101, 2, NULL, NULL, '2021-01-08 21:03:13'),
(7, 105, 2, NULL, '1', '2021-01-08 21:20:29'),
(8, 102, 1, NULL, NULL, '2021-01-09 23:54:33'),
(9, 103, 1, '4', '1,5', '2021-01-10 11:22:59'),
(10, 104, 1, NULL, NULL, '2021-01-11 18:34:49'),
(10, 104, 1, '2,6', '1,4', '2021-01-11 18:34:49');

-- View tables
SELECT * FROM customer_orders;
SELECT * FROM driver_order;
SELECT * FROM ingredients;
SELECT * FROM driver;
SELECT * FROM rolls;
SELECT * FROM rolls_recipes;

-- ques 1 :- how many rolls were ordered
select count(*)  total_rolls 
from customer_orders ;

-- ques 2 :- how many unique customer orders were made
select count(distinct customer_id)  unique_cust from customer_orders;


-- ques 3 :- how many successfull orders were made by each driver
select driver_id , count(distinct order_id)
from driver_order
where cancellation not in ('cancellation' , 'customer cancellation')
group by driver_id;


-- ques 4 :- how many each type of roll was delivered
select roll_id , count(roll_id) 
from customer_orders 
where order_id in 
(
select order_id from
(select * , case when cancellation in   ('cancellation' , 'customer cancellation') then 'c' else 'nc' end as order_cancel_details
from driver_order) a
where order_cancel_details = 'nc')
group by roll_id;


-- ques 5 :- how many veg and non-veg rolls were ordered by the customer
select a.* , b.roll_name from
(select customer_id ,roll_id, count(roll_id) 
from customer_orders
group by customer_id , roll_id) a inner join rolls b
on a.roll_id = b.roll_id;


-- ques 6 :- what was the maximum number of rolls delivered in a single order
select * from(
select * , rank() over(order by cnt desc) rnk from
(select order_id,count(roll_id) cnt from(
select  * 
from customer_orders 
where order_id in
(
select order_id from
(select * , case when cancellation in   ('cancellation' , 'customer cancellation') then 'c' else 'nc' end as order_cancel_details
from driver_order) a
where order_cancel_details = 'nc')) b
group by order_id )c ) d
where rnk =1 ;


-- ques 7 :- for each customer, how many delievered rolls had at least 1 change and how many had no changes

WITH temp_cust_orders (
    order_id,
    customer_id,
    roll_id,
    new_not_include_items,
    new_extra_items_included,
    order_date
) AS (
    SELECT 
        order_id,
        customer_id,
        roll_id,
        CASE 
            WHEN TRIM(not_include_items) IS NULL OR TRIM(not_include_items) = '' THEN '0'
            ELSE not_include_items
        END AS new_not_include_items,
        CASE 
            WHEN TRIM(extra_items_included) IS NULL 
                 OR TRIM(extra_items_included) = '' 
                 OR LOWER(TRIM(extra_items_included)) IN ('nan', 'null') THEN '0'
            ELSE extra_items_included
        END AS new_extra_items_included,
        order_date
    FROM customer_orders
)
-- select * from temp_cust_orders;
, temp_driver_orders (
       order_id, 
       driver_id,
       pickup_time, 
       distance, 
       duration,
       cancellation)  as
(
	select order_id , driver_id ,pickup_time, distance, duration, 
			case when cancellation  in ('Cancellation' , 'customer Cancellation') then 0 else 1 end as new_cancellation
    from driver_order
)     
-- select * from temp_driver_orders;
-- -- final query
select customer_id, chng_no_chng,count(order_id) atleast_one_change from
(select * , case when new_not_include_items = '0' and new_extra_items_included = '0' then 'no_change' else 'change' end as chng_no_chng
from temp_cust_orders 
where order_id in (select order_id 
					from temp_driver_orders
                    where cancellation!=0
				  )
) a
group  by customer_id, chng_no_chng;


--  ques 8 :- how many rolls were deivered that had both exclusions and extras
WITH temp_cust_orders (
    order_id,
    customer_id,
    roll_id,
    new_not_include_items,
    new_extra_items_included,
    order_date
) AS (
    SELECT 
        order_id,
        customer_id,
        roll_id,
        CASE 
            WHEN TRIM(not_include_items) IS NULL OR TRIM(not_include_items) = '' THEN '0'
            ELSE not_include_items
        END AS new_not_include_items,
        CASE 
            WHEN TRIM(extra_items_included) IS NULL 
                 OR TRIM(extra_items_included) = '' 
                 OR LOWER(TRIM(extra_items_included)) IN ('nan', 'null') THEN '0'
            ELSE extra_items_included
        END AS new_extra_items_included,
        order_date
    FROM customer_orders
)
-- select * from temp_cust_orders;
, temp_driver_orders (
       order_id, 
       driver_id,
       pickup_time, 
       distance, 
       duration,
       cancellation)  as
(
	select order_id , driver_id ,pickup_time, distance, duration, 
			case when cancellation  in ('Cancellation' , 'customer Cancellation') then 0 else 1 end as new_cancellation
    from driver_order
)     
-- select * from temp_driver_orders;
-- -- final query
select chng_no_chng , count(chng_no_chng)  as num_of_rolls  from
(select * , case when new_not_include_items != '0' and new_extra_items_included != '0' then 'both_incl_excl' else 'either_1_incl_excl' end as chng_no_chng
from temp_cust_orders 
where order_id in (select order_id 
					from temp_driver_orders
                    where cancellation!=0
				  )
)a
group by chng_no_chng;


-- ques 9 :- what was the total number of the rolls ordered for each hour of the day

select hours_bucket , count(hours_bucket) cnt 
from
(select * , concat(cast(hour(order_date) as char) , '-' , cast(hour(order_date)+1 as char) ) hours_bucket
from customer_orders) a
group by hours_bucket;


-- ques 10 :- what was the number of orders for each day of the week
select day_of_the_week , count(distinct order_id) as num_of_orders
from
(select * ,dayname(order_date) as day_of_the_week
from customer_orders) a
group by day_of_the_week;


-- ques 11 :- what was the average time in minutes it took for each driver to arrive at the fasoos HQ to pickup the order


select driver_id , sum(diff) / count(order_id) as avg_time
 from
(select * from(
select * , row_number() over(partition by order_id order by diff) rnk from
(select a.order_id , a.customer_id,a.roll_id,a.not_include_items, a.extra_items_included,a.order_date,
       b.driver_id ,b.pickup_time,b.distance ,b.duration ,b.cancellation , TIMESTAMPDIFF(MINUTE, a.order_date, b.pickup_time) AS diff
from customer_orders a 
inner join driver_order b
on a.order_id = b.order_id
where b.pickup_time is not null) a ) b 
where rnk =1)c
group by driver_id;


-- ques 12 :- Is there any relationship between the number of rolls and how long the order takes to prepare

select order_id , count(roll_id) cnt , round(sum(diff) / count(roll_id) ,0)as avg_tym
 from
(select a.order_id , a.customer_id,a.roll_id,a.not_include_items, a.extra_items_included,a.order_date,
       b.driver_id ,b.pickup_time,b.distance ,b.duration ,b.cancellation , TIMESTAMPDIFF(MINUTE, a.order_date, b.pickup_time) AS diff
from customer_orders a 
inner join driver_order b
on a.order_id = b.order_id
where b.pickup_time is not null) a
group by order_id;


-- ques 13 :- what was the average distance travelled for each customer

select customer_id , sum(distance)/count(order_id)  avg_distance from
(select * from
(select * , row_number() over(partition by order_id order by diff) rnk from
(select a.order_id , a.customer_id,a.roll_id,a.not_include_items, a.extra_items_included,a.order_date,
       b.driver_id ,b.pickup_time,cast(trim(replace(lower(b.distance) ,'km' , '')) as decimal) distance,b.duration ,b.cancellation , TIMESTAMPDIFF(MINUTE, a.order_date, b.pickup_time) AS diff
from customer_orders a 
inner join driver_order b
on a.order_id = b.order_id
where b.pickup_time is not null)a ) b
where rnk =1) c
group by customer_id ;


-- ques 14 :-  what was the  difference between the longest and the shortest delivery times for all orders

select max(duration_) - min(duration_)  difference from
(select  case when duration LIKE '%min%' THEN LEFT(duration, LOCATE('m', duration) - 1)   else duration end as duration_          --  can use left(duration, 2)  _duration_
from driver_order
where duration is not null) a;


-- ques 15 :- what was the average speed for each driver for each delivery and do you notice  any trend for these values

-- speed= dist/time

select a.order_id , a.driver_id , round(a.distance / a.duration_ , 2)  speed , b.cnt from
(select case 
			when duration LIKE '%min%' 
            THEN LEFT(duration, LOCATE('m', duration) - 1)   
            else duration 
            end as duration_  ,
		cast(trim(replace(lower(distance) ,'km' , '')) as decimal) distance , 
        order_id , driver_id
from driver_order
where distance is not null) a inner join (select order_id , count(roll_id) cnt  from customer_orders group by order_id) b on a.order_id = b.order_id ;
--  >>got the trend as when the no. of rolls increased ... the avg speed is decreasing 


-- ques 16 :- what is the successful delivery  percentage for each driver
  
-- sdp= total orders succesfully delievered / total orders taken 
select driver_id ,(sum_/cnt) *100 as successful_percentage from
(select driver_id , sum(succesfully_delivered) sum_ , count(driver_id) cnt from
(select driver_id , case 
						when lower(cancellation) like '%cancel%' 
                        then 0 
                        else 1 
                        end as succesfully_delivered
from driver_order) a
group by driver_id ) b;

