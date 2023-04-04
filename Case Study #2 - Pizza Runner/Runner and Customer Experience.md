# Runner And Customer Experience

## 1. How many runners signed up for each 1 week period?
```sql
SELECT
    DATE_PART('WEEK', registration_date) AS week_num,
    COUNT(runner_id) AS num_runners
FROM pizza_runner.runners
GROUP BY week_num
ORDER BY week_num;
```
| week_num | num_runners |
| -------- | ----------- |
| 1        | 1           |
| 2        | 1           |
| 53       | 2           |
<br/>

## 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
```sql
SELECT
    runner_id,
    ROUND(AVG(EXTRACT (MINUTE FROM  pickup_time::TIMESTAMP - order_time::TIMESTAMP))::NUMERIC, 2) AS avg_time_delta_in_mins
FROM pizza_runner.customer_orders c
    JOIN pizza_runner.runner_orders r ON c.order_id=r.order_id
GROUP BY runner_id
ORDER BY runner_id;
```
| runner_id | avg_time_delta_in_mins |
| --------- | ---------------------- |
| 1         | 15.33                  |
| 2         | 23.40                  |
| 3         | 10.00                  |
<br/>

## 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
```sql
WITH num_pizzas AS(
    SELECT
        c.order_id,
        COUNT(pizza_id) AS num_pizzas,
        ROUND(AVG(EXTRACT(MINUTE FROM  pickup_time::TIMESTAMP - order_time::TIMESTAMP))::NUMERIC, 2) AS time_delta_in_mins
    FROM pizza_runner.customer_orders c
        JOIN pizza_runner.runner_orders r ON c.order_id=r.order_id
    GROUP BY c.order_id
    ORDER BY c.order_id)
SELECT 
    num_pizzas,
    ROUND(AVG(time_delta_in_mins), 2) AS avg_time_delta_in_mins
FROM num_pizzas
GROUP BY num_pizzas
ORDER BY num_pizzas;
```
| num_pizzas | avg_time_delta_in_mins |
| ---------- | ---------------------- |
| 1          | 12.00                  |
| 2          | 18.00                  |
| 3          | 29.00                  |
<br/>

## 4. What was the average distance travelled for each customer?
```sql
SELECT
    customer_id,
    ROUND(AVG(SUBSTRING(distance FROM '[0-9.]+')::NUMERIC), 2) AS avg_distance
FROM pizza_runner.customer_orders c
    JOIN pizza_runner.runner_orders r ON c.order_id=r.order_id
GROUP BY customer_id
ORDER BY customer_id;
```
| customer_id | avg_distance |
| ----------- | ------------ |
| 101         | 20.00        |
| 102         | 16.73        |
| 103         | 23.40        |
| 104         | 10.00        |
| 105         | 25.00        |
<br/>

## 5. What was the difference between the longest and shortest delivery times for all orders?
```sql
WITH travel AS(
    SELECT
        c.order_id,
        SUBSTRING(duration FROM '[0-9]+')::NUMERIC AS duration
    FROM pizza_runner.customer_orders c
        JOIN pizza_runner.runner_orders r ON c.order_id=r.order_id)
SELECT 
    MAX(duration) - MIN(duration) AS diff_bw_longest_and_shortest_duration_in_mins
FROM travel;
```
| diff_bw_longest_and_shortest_duration_in_mins |
| --------------------------------------------- |
| 30                                            |
<br/>

## 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
```sql
WITH order_time_details AS(
    SELECT
        c.order_id,
        runner_id,
        ROUND(AVG(SUBSTRING(duration FROM '[0-9]+')::NUMERIC), 2) AS duration_in_mins,
        ROUND(AVG(SUBSTRING(distance FROM '[0-9.]+')::NUMERIC), 2) AS distance_in_kms
    FROM pizza_runner.customer_orders c 
        JOIN pizza_runner.runner_orders r ON c.order_id=r.order_id
    WHERE cancellation IS NULL
    GROUP BY c.order_id, runner_id)
SELECT *,
    ROUND(distance_in_kms/(duration_in_mins/60), 2) AS speed_in_kmph
FROM order_time_details
ORDER BY runner_id, order_id;
```
| order_id | runner_id | duration_in_mins | distance_in_kms | speed_in_kmph |
| -------- | --------- | ---------------- | --------------- | ------------- |
| 1        | 1         | 32.00            | 20.00           | 37.50         |
| 2        | 1         | 27.00            | 20.00           | 44.44         |
| 3        | 1         | 20.00            | 13.40           | 40.20         |
| 10       | 1         | 10.00            | 10.00           | 60.00         |
| 4        | 2         | 40.00            | 23.40           | 35.10         |
| 7        | 2         | 25.00            | 25.00           | 60.00         |
| 8        | 2         | 15.00            | 23.40           | 93.60         |
| 5        | 3         | 15.00            | 10.00           | 40.00         |
<br/>

## 7. What is the successful delivery percentage for each runner?
```sql
WITH order_count AS(
    SELECT
        runner_id,
        COUNT(order_id) AS total_orders,
        SUM(CASE WHEN cancellation IS NULL THEN 1 ELSE 0 END) AS successful_orders
    FROM pizza_runner.runner_orders
    GROUP BY runner_id)
SELECT
    runner_id,
    ROUND(100.0 * successful_orders/total_orders, 2) AS successful_delivery_pct
FROM order_count
ORDER BY runner_id;
```
| runner_id | successful_delivery_pct |
| --------- | ----------------------- |
| 1         | 100.00                  |
| 2         | 75.00                   |
| 3         | 50.00                   |
