**Schema (PostgreSQL v13)**

    CREATE SCHEMA dannys_diner;
    SET search_path = dannys_diner;
    
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

---

**Query #1**

    SELECT 
        	s.customer_id,
            SUM(price) AS tot_amount_spent
        FROM dannys_diner.menu m 
        	JOIN dannys_diner.sales s ON s.product_id=m.product_id
        GROUP BY s.customer_id
        ORDER BY s.customer_id;

| customer_id | tot_amount_spent |
| ----------- | ---------------- |
| A           | 76               |
| B           | 74               |
| C           | 36               |

---
**Query #2**

    SELECT 
        	customer_id,
            COUNT(DISTINCT order_date) AS num_days
        FROM dannys_diner.sales 
        GROUP BY customer_id
        ORDER BY customer_id;

| customer_id | num_days |
| ----------- | -------- |
| A           | 4        |
| B           | 6        |
| C           | 2        |

---
**Query #3**

    WITH first_dish AS(
          SELECT *,
          	DENSE_RANK() OVER(PARTITION BY customer_id 
                              ORDER BY order_date) AS prod_rank
          FROM dannys_diner.sales)
        SELECT
        	customer_id,
            product_name
        FROM first_dish d 
        	JOIN dannys_diner.menu m ON d.product_id=m.product_id
        WHERE prod_rank=1
        GROUP BY customer_id, product_name
        ORDER BY customer_id;

| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

---
**Query #4**

    SELECT 
        	m.product_name,
            COUNT(s.product_id) AS num_times_purchased
        FROM dannys_diner.sales s 
        	JOIN dannys_diner.menu m ON s.product_id=m.product_id
        GROUP BY m.product_name
        ORDER BY num_times_purchased DESC
        LIMIT 1;

| product_name | num_times_purchased |
| ------------ | ------------------- |
| ramen        | 8                   |

---
**Query #5**

    WITH popular_dishes AS(
          SELECT
          	customer_id,
          	product_id,
          	COUNT(product_id) AS num_orders,
          	DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(product_id) DESC) AS rank
          FROM dannys_diner.sales
          GROUP BY customer_id, product_id)
        SELECT 
        	customer_id,
            product_name,
            num_orders
        FROM popular_dishes d
        	JOIN dannys_diner.menu m ON m.product_id=d.product_id
        WHERE rank=1
        ORDER BY customer_id;

| customer_id | product_name | num_orders |
| ----------- | ------------ | ---------- |
| A           | ramen        | 3          |
| B           | sushi        | 2          |
| B           | curry        | 2          |
| B           | ramen        | 2          |
| C           | ramen        | 3          |

---
**Query #6**

    WITH items AS(
      SELECT 
          s.customer_id,
          product_name,
          DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date) AS ranked
      FROM dannys_diner.sales s
          JOIN dannys_diner.menu m ON s.product_id=m.product_id
      	  JOIN dannys_diner.members b ON s.customer_id=b.customer_id 
      			AND s.order_date >=b.join_date
      ORDER BY order_date)
    SELECT 
    	customer_id,
        product_name
    FROM items
    WHERE ranked=1;

| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| B           | sushi        |

---
**Query #7**

    WITH items AS(
      SELECT 
          s.customer_id,
          product_name,
          RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date DESC) AS ranked
      FROM dannys_diner.sales s
          JOIN dannys_diner.menu m ON s.product_id=m.product_id
      	  JOIN dannys_diner.members b ON s.customer_id=b.customer_id 
      			AND s.order_date < b.join_date
      ORDER BY order_date)
    SELECT 
    	customer_id,
        product_name
    FROM items
    WHERE ranked=1;

| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| A           | curry        |
| B           | sushi        |

---
**Query #8**

    SELECT 
          s.customer_id,
          COUNT(s.product_id) AS num_items,
          SUM(price) AS spent_before_member
      FROM dannys_diner.sales s
          JOIN dannys_diner.menu m ON s.product_id=m.product_id
      	  JOIN dannys_diner.members b ON s.customer_id=b.customer_id 
      			AND s.order_date < b.join_date
    GROUP BY s.customer_id;

| customer_id | num_items | spent_before_member |
| ----------- | --------- | ------------------- |
| B           | 3         | 40                  |
| A           | 2         | 25                  |

---
**Query #9**

    SELECT
    	customer_id,
        SUM(CASE WHEN product_name='sushi' THEN 2*price*10 ELSE price*10 END) AS tot_points
    FROM dannys_diner.sales s
    	JOIN dannys_diner.menu m ON s.product_id=m.product_id
    GROUP BY customer_id
    ORDER BY customer_id;

| customer_id | tot_points |
| ----------- | ---------- |
| A           | 860        |
| B           | 940        |
| C           | 360        |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/2rM8RAnq7h5LLDTzZiRWcd/138)
