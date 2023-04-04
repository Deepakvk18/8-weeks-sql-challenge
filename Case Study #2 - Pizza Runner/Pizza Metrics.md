# Pizza Metrics

## 1. How many pizzas were ordered?

```sql
SELECT
    COUNT(order_id) AS num_pizzas
FROM pizza_runner.customer_orders;
```

| num_pizzas |
| ---------- |
| 14         |
<br/>

## 2. How many unique customer orders were made?
```sql
SELECT
    COUNT(DISTINCT order_id) AS num_orders
FROM pizza_runner.customer_orders;
```

| num_orders |
| ---------- |
| 10         |
<br/>

## 3. How many successful orders were delivered by each runner?
```sql
SELECT 
    runner_id,
    COUNT(DISTINCT order_id) AS num_orders
FROM pizza_runner.runner_orders
WHERE cancellation is NULL
GROUP BY runner_id
ORDER BY runner_id;
```

| runner_id | num_orders |
| --------- | ---------- |
| 1         | 4          |
| 2         | 3          |
| 3         | 1          |
<br/>

## 4. How many of each type of pizza was delivered?
```sql
SELECT
    pizza_name,
    COUNT(p.pizza_id) AS num_pizza
FROM pizza_runner.customer_orders c
    JOIN pizza_runner.runner_orders r ON c.order_id=r.order_id
    JOIN pizza_runner.pizza_names p ON p.pizza_id=c.pizza_id
WHERE cancellation IS NULL
GROUP BY pizza_name
ORDER BY num_pizza DESC;
```
| pizza_name | num_pizza |
| ---------- | --------- |
| Meatlovers | 9         |
| Vegetarian | 3         |
<br/>

## 5. How many Vegetarian and Meatlovers were ordered by each customer?
```sql
 SELECT
    customer_id,
    pizza_name,
    COUNT(p.pizza_id) AS num_pizza
FROM pizza_runner.customer_orders c
    JOIN pizza_runner.pizza_names p ON p.pizza_id=c.pizza_id
GROUP BY customer_id, pizza_name
ORDER BY customer_id, num_pizza DESC;
```
| customer_id | pizza_name | num_pizza |
| ----------- | ---------- | --------- |
| 101         | Meatlovers | 2         |
| 101         | Vegetarian | 1         |
| 102         | Meatlovers | 2         |
| 102         | Vegetarian | 1         |
| 103         | Meatlovers | 3         |
| 103         | Vegetarian | 1         |
| 104         | Meatlovers | 3         |
| 105         | Vegetarian | 1         |
<br/>

## 6. What was the maximum number of pizzas delivered in a single order?
```sql
WITH orders AS(
    SELECT order_id,
        COUNT(pizza_id) AS num_pizzas_this_order
    FROM pizza_runner.customer_orders 
    GROUP BY order_id)
SELECT MAX(num_pizzas_this_order) AS max_num_pizza_order
FROM orders;
```
| max_num_pizza_order |
| ------------------- |
| 3                   |
<br/>

## 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
```sql
SELECT 
    customer_id,
    SUM(CASE WHEN exclusions IS NULL AND extras IS NULL
        THEN 1 ELSE 0 END) AS num_pizzas_without_change,
    SUM(CASE WHEN exclusions IS NOT NULL OR extras IS NOT NULL
        THEN 1 ELSE 0 END) AS num_pizzas_with_change
FROM pizza_runner.customer_orders
GROUP BY customer_id
ORDER BY customer_id;
```
| customer_id | num_pizzas_without_change | num_pizzas_with_change |
| ----------- | ------------------------- | ---------------------- |
| 101         | 3                         | 0                      |
| 102         | 3                         | 0                      |
| 103         | 0                         | 4                      |
| 104         | 1                         | 2                      |
| 105         | 0                         | 1                      |
<br/>

## 8. How many pizzas were delivered that had both exclusions and extras?
```sql
 SELECT
    COUNT(c.pizza_id) AS pizzas_with_exclu_extras
FROM pizza_runner.customer_orders c 
    JOIN pizza_runner.runner_orders r ON c.order_id=r.order_id
WHERE cancellation IS NOT NULL
    AND (exclusions IS NOT NULL AND extras IS NOT NULL);
```
| pizzas_with_exclu_extras |
| ------------------------ |
| 1                        |
<br/>

## 9. What was the total volume of pizzas ordered for each hour of the day?
```sql
SELECT 
    EXTRACT(HOUR FROM order_time) AS hour_of_the_day,
    COUNT(pizza_id) AS pizzas_volume
FROM pizza_runner.customer_orders
GROUP BY hour_of_the_day
ORDER BY hour_of_the_day;
```
| hour_of_the_day | pizzas_volume |
| --------------- | ------------- |
| 11              | 1             |
| 13              | 3             |
| 18              | 3             |
| 19              | 1             |
| 21              | 3             |
| 23              | 3             |
<br/>

## 10. What was the volume of orders for each day of the week?
```sql
SELECT 
    TO_CHAR(order_time, 'dy') AS day_of_week,
    COUNT(DISTINCT order_id) AS pizzas_volume
FROM pizza_runner.customer_orders
GROUP BY day_of_week
ORDER BY day_of_week;
```
| day_of_week | pizzas_volume |
| ----------- | ------------- |
| fri         | 1             |
| sat         | 2             |
| thu         | 2             |
| wed         | 5             |
<br/>
