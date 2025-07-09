#  Stuff’d Insights – SQL-Based Food Delivery Analytics

**Stuff’d Insights** is a SQL-driven data analysis project modeled on a fictional quick-service restaurant (QSR) that specializes in delivering stuffed rolls and wraps. The project focuses on uncovering operational and customer insights using real-world inspired datasets and structured SQL queries.



##  Project Overview

This project simulates the backend of a food delivery business and analyzes:

- Customer ordering behavior
- Roll types and customizations
- Driver delivery performance
- Cancellations and delivery time analysis
- Ingredient usage and recipe structure

All analysis is done purely in **SQL**, using multiple joins, window functions, conditional aggregations, and common table expressions (CTEs).



##  Datasets Used

| Table Name        | Description                                      |
|-------------------|--------------------------------------------------|
| `customer_orders` | Contains customer orders and customizations      |
| `driver_order`    | Delivery logs including pickup time & status     |
| `driver`          | Driver registration information                  |
| `rolls`           | Types of rolls (Veg, Non-Veg)                    |
| `rolls_recipes`   | Ingredient mappings for each roll                |
| `ingredients`     | Master list of all ingredients used              |



##  Key Questions Answered

1. How many rolls were ordered in total?
2. How many unique customers placed orders?
3. What is the success rate of deliveries per driver?
4. Which type of roll is more popular (veg/non-veg)?
5. What is the maximum number of rolls delivered in a single order?
6. How many orders had changes (exclusions or additions)?
7. Peak order times by hour and by day of the week
8. Average pickup time by driver
9. Relationship between number of rolls and prep time
10. Delivery trends (speed vs. load)
11. Customer-level distance and speed metrics
12. Successful delivery percentage per driver



##  SQL Techniques Used

- **Joins** (INNER, LEFT)
- **Window Functions** (`ROW_NUMBER()`, `RANK()`)
- **String Functions** (`TRIM`, `REPLACE`, `CAST`)
- **Date & Time Functions** (`TIMESTAMPDIFF`, `HOUR`, `DAYNAME`)
- **CTEs** for structured multi-step logic
- **Conditional Aggregation** for grouped metrics
- **Data Cleaning** inside queries



##  Sample Insight

> 🚴 Drivers with higher delivery loads tend to show slower average delivery speed.  
> 📈 Orders with multiple customizations take longer to prepare and are more likely to be delayed.




