# Pricings And Ratings

## 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
```sql
SELECT 
    SUM(CASE WHEN pizza_name='Meatlovers' THEN 12
            WHEN pizza_name='Vegetarian' THEN 10 END) AS total_revenue
FROM pizza_runner.customer_orders c 
    JOIN pizza_runner.runner_orders r ON c.order_id=r.order_id
    JOIN pizza_runner.pizza_names n ON n.pizza_id=c.pizza_id
WHERE cancellation IS NULL;
```
| total_revenue |
| ------------- |
| 138           |
<br/>

## 2. What if there was an additional $1 charge for any pizza extras? Eg.Add cheese is $1 extra
```sql
 WITH charges AS(
    SELECT
        pizza_name,
        CASE WHEN pizza_name='Meatlovers' THEN 12
            WHEN pizza_name='Vegetarian' THEN 10 END AS pizza_cost,
        ARRAY_LENGTH(STRING_TO_ARRAY(extras, ', ')::int[], 1) AS extra_cost
    FROM pizza_runner.customer_orders c
        JOIN pizza_runner.pizza_names n ON c.pizza_id=n.pizza_id
        JOIN pizza_runner.runner_orders rr ON rr.order_id=c.order_id
    WHERE cancellation IS NULL)
SELECT
    pizza_name,
    SUM(pizza_cost) + SUM(extra_cost) AS total_cost
FROM charges
GROUP BY pizza_name;
```
| pizza_name | total_cost |
| ---------- | ---------- |
| Meatlovers | 111        |
| Vegetarian | 31         |
<br/>

## 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
```sql
CREATE TABLE pizza_runner.runner_ratings(
    "order_id" INT PRIMARY KEY,
    "rating" FLOAT);

INSERT INTO pizza_runner.runner_ratings
("order_id", "rating") VALUES
(1, 4.5),
(2, 4),
(3, 3),
(4, 3.5),
(5, 5),
(7, 4),
(9, 4),
(10, 3.5);
```

## 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
                            customer_id
                            order_id
                            runner_id
                            rating
                            order_time
                            pickup_time
                            Time between order and pickup
                            Delivery duration
                            Average speed
                            Total number of pizzas

```sql
WITH orders AS(
    SELECT
    order_id,
    COUNT(pizza_id) AS num_pizzas
    FROM pizza_runner.customer_orders
    GROUP BY order_id)
SELECT DISTINCT
    customer_id,
    o.order_id,
    runner_id,
    rating,
    pickup_time,
    EXTRACT(MINUTE FROM  pickup_time::TIMESTAMP - order_time::TIMESTAMP) AS pickup_delta,
    SUBSTRING(duration FROM '[0-9.]+')::NUMERIC AS delivery_duration,
    ROUND(SUBSTRING(distance FROM '[0-9.]+')::NUMERIC / SUBSTRING(duration FROM '[0-9.]+')::NUMERIC, 2) * 60 AS avg_speed,
    num_pizzas
FROM orders o
    LEFT JOIN pizza_runner.customer_orders c ON c.order_id=o.order_id
    LEFT JOIN pizza_runner.runner_orders r ON r.order_id=o.order_id
    LEFT JOIN pizza_runner.runner_ratings rr ON rr.order_id=o.order_id
ORDER BY order_id;
```
| customer_id | order_id | runner_id | rating | pickup_time         | pickup_delta | delivery_duration | avg_speed | num_pizzas |
| ----------- | -------- | --------- | ------ | ------------------- | ------------ | ----------------- | --------- | ---------- |
| 101         | 1        | 1         | 4.5    | 2020-01-01 18:15:34 | 10           | 32                | 37.80     | 1          |
| 101         | 2        | 1         | 4      | 2020-01-01 19:10:54 | 10           | 27                | 44.40     | 1          |
| 102         | 3        | 1         | 3      | 2020-01-03 00:12:37 | 21           | 20                | 40.20     | 2          |
| 103         | 4        | 2         | 3.5    | 2020-01-04 13:53:03 | 29           | 40                | 35.40     | 3          |
| 104         | 5        | 3         | 5      | 2020-01-08 21:10:57 | 10           | 15                | 40.20     | 1          |
| 101         | 6        | 3         |        |                     |              |                   |           | 1          |
| 105         | 7        | 2         | 4      | 2020-01-08 21:30:45 | 10           | 25                | 60.00     | 1          |
| 102         | 8        | 2         |        | 2020-01-10 00:15:02 | 20           | 15                | 93.60     | 1          |
| 103         | 9        | 2         | 4      |                     |              |                   |           | 1          |
| 104         | 10       | 1         | 3.5    | 2020-01-11 18:50:20 | 15           | 10                | 60.00     | 2          |
<br/>

## 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
```sql
WITH expenses AS(
    SELECT  
        r.order_id,
        SUM(CASE WHEN pizza_id=1 THEN 12
            WHEN pizza_id=2 THEN 10 END) AS total_revenue,
        ROUND(AVG(SUBSTRING(distance FROM '[0-9.]+')::NUMERIC) * 0.3, 2) AS runner_expense
    FROM pizza_runner.runner_orders r 
        JOIN pizza_runner.customer_orders c ON c.order_id=r.order_id
    GROUP BY r.order_id)
SELECT
    SUM(total_revenue-runner_expense) AS net_revenue
FROM expenses;
```
| net_revenue |
| ----------- |
| 94.44       |
<br/>
<br/>

# Bonus Questions

## 1. If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
```sql
INSERT INTO pizza_runner.pizza_names
("pizza_id", "pizza_name")
VALUES
(3, 'SupremePizza');

INSERT INTO pizza_runner.pizza_recipes
("pizza_id", "toppings")
VALUES
(3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');
```