**Schema (PostgreSQL v13)**
# Case Study Questions


## 1. What is the total amount each customer spent at the restaurant?

### **Query**
```SQL
SELECT 
  s.customer_id,
  SUM(price) AS tot_amount_spent
FROM dannys_diner.menu m 
  JOIN dannys_diner.sales s ON s.product_id=m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;
```
### **Answer**
| customer_id | tot_amount_spent |
| ----------- | ---------------- |
| A           | 76               |
| B           | 74               |
| C           | 36               |

---
<br/>

## 2. How many days has each customer visited the restaurant?

### **Query**
```sql
SELECT 
  customer_id,
  COUNT(DISTINCT order_date) AS num_days
FROM dannys_diner.sales 
GROUP BY customer_id
ORDER BY customer_id;
```
### **Answer**

| customer_id | num_days |
| ----------- | -------- |
| A           | 4        |
| B           | 6        |
| C           | 2        |

---
<br/>

### 3. What was the first item from the menu purchased by each customer?

### **Query**
```sql
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
```
### **Answer**
| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

---
<br/>

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

### **Query**
```sql
SELECT 
  m.product_name,
  COUNT(s.product_id) AS num_times_purchased
FROM dannys_diner.sales s 
  JOIN dannys_diner.menu m ON s.product_id=m.product_id
GROUP BY m.product_name
ORDER BY num_times_purchased DESC
LIMIT 1;
```

### **Answer**
| product_name | num_times_purchased |
| ------------ | ------------------- |
| ramen        | 8                   |

---
<br/>

### 5. Which item was the most popular for each customer?

### **Query**
```sql
WITH popular_dishes AS(
  SELECT
    customer_id,
    product_id,
    COUNT(product_id) AS num_orders,
    DENSE_RANK() OVER(PARTITION BY customer_id 
                      ORDER BY COUNT(product_id) DESC) AS rank
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
```

### **Answer**
| customer_id | product_name | num_orders |
| ----------- | ------------ | ---------- |
| A           | ramen        | 3          |
| B           | sushi        | 2          |
| B           | curry        | 2          |
| B           | ramen        | 2          |
| C           | ramen        | 3          |

---
<br/>

### 6. Which item was purchased first by the customer after they became a member?

### **Query**
```sql
WITH items AS(
  SELECT 
      s.customer_id,
      product_name,
      DENSE_RANK() OVER(PARTITION BY s.customer_id 
                        ORDER BY order_date) AS ranked
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
```

### **Answer**
| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| B           | sushi        |

---
<br/>

### 7. Which item was purchased just before the customer became a member?

### **Query**
```sql
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
```
### **Answer**

| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| A           | curry        |
| B           | sushi        |

---
<br/>

### 8. What is the total items and amount spent for each member before they became a member?

### **Query**
```sql
SELECT 
  s.customer_id,
  COUNT(s.product_id) AS num_items,
  SUM(price) AS spent_before_member
FROM dannys_diner.sales s
  JOIN dannys_diner.menu m ON s.product_id=m.product_id
  JOIN dannys_diner.members b ON s.customer_id=b.customer_id 
                              AND s.order_date < b.join_date
GROUP BY s.customer_id;
```

### **Answer**
| customer_id | num_items | spent_before_member |
| ----------- | --------- | ------------------- |
| B           | 3         | 40                  |
| A           | 2         | 25                  |

---
<br/>

### 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

### **Query**
```sql
SELECT
  customer_id,
  SUM(CASE WHEN product_name='sushi' THEN 2*price*10 ELSE price*10 END) AS tot_points
FROM dannys_diner.sales s
  JOIN dannys_diner.menu m ON s.product_id=m.product_id
GROUP BY customer_id
ORDER BY customer_id;
```

### **Answer**
| customer_id | tot_points |
| ----------- | ---------- |
| A           | 860        |
| B           | 940        |
| C           | 360        |

---
<br/>

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

### **Query**
```sql
SELECT
	s.customer_id,
  SUM(CASE 
        WHEN order_date BETWEEN join_date AND DATE_ADD(join_date, INTERVAL 6 DAY)
        THEN 2*price*10
        WHEN product_name='sushi' THEN 2*price*10 
        ELSE price*10 END) AS tot_points
FROM dannys_diner.sales s
	JOIN dannys_diner.menu m ON s.product_id=m.product_id
  JOIN dannys_diner.members b ON s.customer_id=b.customer_id 
WHERE order_date < '2021-02-01'
GROUP BY s.customer_id
ORDER BY s.customer_id;
```

### **Answer**
| customer_id | tot_points |
| ----------- | ---------- |
| A           | 1370        |
| B           | 820        |

---


# Bonus Questions

The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

### 1. Recreate the following table output using the available data:


### **Query**
```sql
SELECT
  s.customer_id,
    DATE(s.order_date),
    m.product_name,
    m.price,
    CASE WHEN join_date <= s.order_date THEN 'Y' ELSE 'N' END AS member
FROM dannys_diner.sales s
  JOIN dannys_diner.menu m ON s.product_id=m.product_id
    LEFT JOIN dannys_diner.members b ON s.customer_id=b.customer_id
ORDER BY s.customer_id, s.order_date, m.price DESC;
```

### **Answer**

| customer_id | date                     | product_name | price | member |
| ----------- | ------------------------ | ------------ | ----- | ------ |
| A           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |
| A           | 2021-01-01T00:00:00.000Z | sushi        | 10    | N      |
| A           | 2021-01-07T00:00:00.000Z | curry        | 15    | Y      |
| A           | 2021-01-10T00:00:00.000Z | ramen        | 12    | Y      |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      |
| B           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |
| B           | 2021-01-02T00:00:00.000Z | curry        | 15    | N      |
| B           | 2021-01-04T00:00:00.000Z | sushi        | 10    | N      |
| B           | 2021-01-11T00:00:00.000Z | sushi        | 10    | Y      |
| B           | 2021-01-16T00:00:00.000Z | ramen        | 12    | Y      |
| B           | 2021-02-01T00:00:00.000Z | ramen        | 12    | Y      |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |
| C           | 2021-01-07T00:00:00.000Z | ramen        | 12    | N      |

---
<br/>

### 2. Rank All The Things: Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

### **Query**
```sql
WITH summary AS(
  SELECT
      s.customer_id,
      DATE(s.order_date) AS order_date,
      m.product_name,
      m.price,
      CASE WHEN join_date <= s.order_date THEN 'Y' ELSE 'N' END AS member
  FROM dannys_diner.sales s
      JOIN dannys_diner.menu m ON s.product_id=m.product_id
      LEFT JOIN dannys_diner.members b ON s.customer_id=b.customer_id
  ORDER BY s.customer_id, s.order_date, m.price DESC)
SELECT *, 
  CASE
    WHEN member = 'N' then NULL
    ELSE
      RANK () OVER(PARTITION BY customer_id, member
                  ORDER BY order_date) END AS ranking
FROM summary;
```

### **Answer**
| customer_id | order_date               | product_name | price | member | ranking |
| ----------- | ------------------------ | ------------ | ----- | ------ | ------- |
| A           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |         |
| A           | 2021-01-01T00:00:00.000Z | sushi        | 10    | N      |         |
| A           | 2021-01-07T00:00:00.000Z | curry        | 15    | Y      | 1       |
| A           | 2021-01-10T00:00:00.000Z | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |         |
| B           | 2021-01-02T00:00:00.000Z | curry        | 15    | N      |         |
| B           | 2021-01-04T00:00:00.000Z | sushi        | 10    | N      |         |
| B           | 2021-01-11T00:00:00.000Z | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16T00:00:00.000Z | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01T00:00:00.000Z | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |         |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |         |
| C           | 2021-01-07T00:00:00.000Z | ramen        | 12    | N      |         |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/2rM8RAnq7h5LLDTzZiRWcd/138)
