# Customer Node Exploration

## 1. How many unique nodes are there on the Data Bank system?
```sql
SELECT
    COUNT(DISTINCT node_id) AS num_unique_nodes
FROM data_bank.customer_nodes;
```
| num_unique_nodes |
| ---------------- |
| 5                |
<br/>

## 2. What is the number of nodes per region?
```sql
SELECT
    region_name,
    COUNT(node_id) AS num_nodes
FROM data_bank.customer_nodes n
    JOIN data_bank.regions r ON n.region_id=r.region_id
GROUP BY region_name;
```
| region_name | num_nodes |
| ----------- | --------- |
| America     | 735       |
| Australia   | 770       |
| Africa      | 714       |
| Asia        | 665       |
| Europe      | 616       |
<br/>

## 3. How many customers are allocated to each region?
```sql
SELECT
    region_name,
    COUNT(DISTINCT customer_id) AS num_customers
FROM data_bank.customer_nodes n
    JOIN data_bank.regions r ON n.region_id=r.region_id
GROUP BY region_name;
```
| region_name | num_customers |
| ----------- | ------------- |
| Africa      | 102           |
| America     | 105           |
| Asia        | 95            |
| Australia   | 110           |
| Europe      | 88            |
<br/>

## 4. How many days on average are customers reallocated to a different node?
```sql
SELECT
    ROUND(AVG(end_date - start_date), 2) AS avg_allocation_days
FROM data_bank.customer_nodes
WHERE end_date != '9999-12-31';
```
| avg_allocation_days |
| ------------------- |
| 14.63               |
<br/>

## 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
```sql
WITH allocation_days AS(
  SELECT
  *,
  end_date - start_date AS allocated_days
  FROM data_bank.customer_nodes n
  JOIN data_bank.regions r ON n.region_id=r.region_id
  WHERE end_date != '9999-12-31')
SELECT
  region_name,
  PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY allocated_days) AS median,
  PERCENTILE_CONT(0.80) WITHIN GROUP (ORDER BY allocated_days) AS percentile_80,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY allocated_days) AS percentile_95
FROM allocation_days
GROUP BY region_name;

```
| region_name | median | percentile_80 | percentile_95 |
|-------------|--------|---------------|----------------|
| Africa      | 15     | 24            | 28             |
| America     | 15     | 23            | 28             |
| Asia        | 15     | 23            | 28             |
| Australia   | 15     | 23            | 28             |
| Europe      | 15     | 24            | 28             |

<br/>
