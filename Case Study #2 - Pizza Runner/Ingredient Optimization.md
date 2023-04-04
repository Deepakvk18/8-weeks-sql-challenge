# Ingredient Optimization

## 1. What are the standard ingredients for each pizza?
```sql
WITH toppings_cte AS(
    SELECT
    pizza_id,
    REGEXP_SPLIT_TO_TABLE(toppings, ', ')::INTEGER AS topping_id
    FROM pizza_runner.pizza_recipes
)
SELECT
    pizza_name,
    STRING_AGG(topping_name, ', ')
FROM toppings_cte c 
    JOIN pizza_runner.pizza_names n ON c.pizza_id=n.pizza_id
    JOIN pizza_runner.pizza_toppings t ON t.topping_id=c.topping_id
GROUP BY pizza_name;
```
| pizza_name | string_agg                                                            |
| ---------- | --------------------------------------------------------------------- |
| Meatlovers | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| Vegetarian | Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce            |
<br/>

## 2. What was the most commonly added extra?
```sql
WITH extra_toppings AS(
    SELECT
        REGEXP_SPLIT_TO_TABLE(extras, ', ')::INTEGER AS extra,
        COUNT(order_id) AS num_times_ordered
    FROM pizza_runner.customer_orders
    GROUP BY 1)
SELECT
    topping_name AS extra,
    num_times_ordered
FROM extra_toppings t 
    JOIN pizza_runner.pizza_toppings p ON t.extra=p.topping_id
ORDER BY num_times_ordered DESC;
```
| extra   | num_times_ordered |
| ------- | ----------------- |
| Bacon   | 4                 |
| Cheese  | 1                 |
| Chicken | 1                 |
<br/>

## 3. What was the most common exclusion?
```sql
WITH exclusion_toppings AS(
      SELECT
          REGEXP_SPLIT_TO_TABLE(exclusions, ', ')::INTEGER AS exclusions,
          COUNT(order_id) AS num_times_ordered
      FROM pizza_runner.customer_orders
      GROUP BY 1)
    SELECT
    	topping_name AS exclusion,
        num_times_ordered
    FROM exclusion_toppings t 
    	JOIN pizza_runner.pizza_toppings p ON t.exclusions=p.topping_id
    ORDER BY num_times_ordered DESC;
```
| exclusion | num_times_ordered |
| --------- | ----------------- |
| Cheese    | 4                 |
| BBQ Sauce | 1                 |
| Mushrooms | 1                 |
<br/>

## 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
            Meat Lovers
            Meat Lovers - Exclude Beef
            Meat Lovers - Extra Bacon
            Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
```sql
CREATE TEMP TABLE exclusions AS
    WITH orders AS(
    SELECT
        order_id,
        pizza_id,
        extras,
        exclusions,
        COUNT(pizza_id) AS num_pizzas
    FROM pizza_runner.customer_orders 
    GROUP BY order_id, pizza_id, extras, exclusions
        
    ),
    exclusion_split AS(
    SELECT
        order_id,
        pizza_id,
        REGEXP_SPLIT_TO_TABLE(exclusions, ', ')::INTEGER AS exclusions,
        num_pizzas
    FROM orders)
    SELECT 
        order_id,
        pizza_id,
        STRING_AGG(topping_name, ', ') AS exclusions,
        MAX(num_pizzas) AS num_pizzas
    FROM exclusion_split s
        JOIN pizza_runner.pizza_toppings t ON t.topping_id=s.exclusions
    GROUP BY order_id, pizza_id;

CREATE TEMP TABLE extras AS
    WITH orders AS(
    SELECT
        order_id,
        pizza_id,
        extras,
        exclusions,
        COUNT(pizza_id) AS num_pizzas
    FROM pizza_runner.customer_orders 
    GROUP BY order_id, pizza_id, extras, exclusions
        
    ),
    extra_split AS(
    SELECT
        order_id,
        pizza_id,
        REGEXP_SPLIT_TO_TABLE(extras, ', ')::INTEGER AS extras,
        num_pizzas
    FROM orders)
    SELECT 
        order_id,
        pizza_id,
        STRING_AGG(topping_name, ', ') AS extras,
        MAX(num_pizzas) AS num_pizzas
    FROM extra_split s
        JOIN pizza_runner.pizza_toppings t ON t.topping_id=s.extras
    GROUP BY order_id, pizza_id;

WITH order_details AS(
SELECT
    c.order_id,
    pizza_name,
    x.exclusions,
    r.extras,
    COALESCE(x.num_pizzas, 1) AS num_pizzas
FROM pizza_runner.customer_orders c
    LEFT JOIN exclusions x ON x.order_id=c.order_id AND x.pizza_id=c.pizza_id
    LEFT JOIN extras r ON r.order_id=c.order_id AND r.pizza_id=c.pizza_id
    JOIN pizza_runner.pizza_names n ON n.pizza_id=c.pizza_id
)
SELECT 
    order_id,
    pizza_name || 
        CASE WHEN exclusions IS NOT NULL THEN ' Exclude - ' || exclusions ELSE '' END ||
        CASE WHEN extras IS NOT NULL THEN ' Extra - ' || extras ELSE '' END AS description
FROM order_details
ORDER BY order_id;
```
| order_id | description                                                     |
| -------- | --------------------------------------------------------------- |
| 1        | Meatlovers                                                      |
| 2        | Meatlovers                                                      |
| 3        | Meatlovers                                                      |
| 3        | Vegetarian                                                      |
| 4        | Vegetarian Exclude - Cheese                                     |
| 4        | Meatlovers Exclude - Cheese                                     |
| 4        | Meatlovers Exclude - Cheese                                     |
| 5        | Meatlovers Extra - Bacon                                        |
| 6        | Vegetarian                                                      |
| 7        | Vegetarian Extra - Bacon                                        |
| 8        | Meatlovers                                                      |
| 9        | Meatlovers Exclude - Cheese Extra - Bacon, Chicken              |
| 10       | Meatlovers Exclude - BBQ Sauce, Mushrooms Extra - Bacon, Cheese |
| 10       | Meatlovers Exclude - BBQ Sauce, Mushrooms Extra - Bacon, Cheese |
<br/>

## 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
                For example: "Meat Lovers: 2xBacon, Beef, ... , Salami 
<br/>

## 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?