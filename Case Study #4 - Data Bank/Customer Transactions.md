# Customer Transactions

## 1. What is the unique count and total amount for each transaction type?
```sql
SELECT
    txn_type,
    COUNT(*) AS num_txns,
    SUM(txn_amount) AS total_txn_amt
FROM data_bank.customer_transactions
GROUP BY txn_type;
```
| txn_type   | num_txns | total_txn_amt |
| ---------- | -------- | ------------- |
| purchase   | 1617     | 806537        |
| deposit    | 2671     | 1359168       |
| withdrawal | 1580     | 793003        |
<br/>

## 2. What is the average total historical deposit counts and amounts for all customers?
```sql
WITH customer_txn AS(
    SELECT
    customer_id,
    COUNT(*) AS num_deposits,
    SUM(txn_amount) AS total_amt_deposited
    FROM data_bank.customer_transactions
    WHERE txn_type='deposit'
    GROUP BY customer_id)
SELECT
    ROUND(AVG(num_deposits), 2) AS avg_deposit_cnt_per_customer,
    ROUND(AVG(total_amt_deposited), 2) AS avg_amt_deposited_per_customer
FROM customer_txn;
```
| avg_deposit_cnt_per_customer | avg_amt_deposited_per_customer |
| ---------------------------- | ------------------------------ |
| 5.34                         | 2718.34                        |
<br/>

## 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
```sql
WITH transactions AS(
    SELECT
    EXTRACT(YEAR FROM txn_date) AS yr,
    EXTRACT(MONTH FROM txn_date) AS month_num,
    TO_CHAR(txn_date, 'Month') AS month_name,
    customer_id,
    SUM(CASE WHEN txn_type='deposit' THEN 1 ELSE 0 END) AS deposit,
    SUM(CASE WHEN txn_type='purchase' THEN 1 ELSE 0 END) AS purchase,
    SUM(CASE WHEN txn_type='withdrawal' THEN 1 ELSE 0 END) AS withdrawal
    FROM data_bank.customer_transactions
    GROUP BY yr, month_num, month_name, customer_id)
SELECT
    yr,
    month_name,
    COUNT(customer_id) AS customers_who_qualify
FROM transactions
WHERE deposit > 1 AND (withdrawal = 1 OR purchase = 1)
GROUP BY yr, month_num, month_name
ORDER BY yr, month_num;
```
| yr   | month_name | customers_who_qualify |
| ---- | ---------- | --------------------- |
| 2020 | January    | 115                   |
| 2020 | February   | 108                   |
| 2020 | March      | 113                   |
| 2020 | April      | 50                    |
<br/>

## 4. What is the closing balance for each customer at the end of the month?
```sql
CREATE TEMP table dates AS(
  WITH RECURSIVE required_dates AS(
      SELECT
          customer_id,
          '2020-01-31'::DATE AS month_end
      FROM data_bank.customer_transactions

      UNION

      SELECT
          customer_id,
          (DATE_TRUNC('month', month_end) + INTERVAL '2 MONTH' - INTERVAL '1 DAY') ::DATE AS month_end
      FROM required_dates
      WHERE DATE_TRUNC('month', month_end) + INTERVAL '2 MONTH' - INTERVAL '1 DAY' <= '2020-04-30')

  SELECT * FROM required_dates ORDER BY customer_id);
  
WITH monthly_net_txn AS(
  SELECT
  	customer_id,
  	DATE_TRUNC('Month', txn_date) + INTERVAL '1 MONTH' - INTERVAL '1 DAY' AS month_end,
  	SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE - txn_amount END) AS net_amt
  FROM data_bank.customer_transactions
  GROUP BY customer_id, 2),
  net_monthly AS(
  SELECT
    d.customer_id,
    d.month_end,
    COALESCE(net_amt, 0) AS net_amt
  FROM dates d 
    LEFT JOIN monthly_net_txn t 
    USING(customer_id, month_end))
SELECT 
	customer_id,
    TO_CHAR(month_end, 'YYYY-MM-DD') AS month_end,
    net_amt AS net_transaction,
    SUM(net_amt) OVER(PARTITION BY customer_id ORDER BY month_end) AS closing_balance
FROM net_monthly 
ORDER BY customer_id, month_end;
```
Sample Answer:-
| customer_id | month_end  | net_transaction | closing_balance |
| ----------- | ---------- | --------------- | --------------- |
| 1           | 2020-01-31 | 312             | 312             |
| 1           | 2020-02-29 | 0               | 312             |
| 1           | 2020-03-31 | -952            | -640            |
| 1           | 2020-04-30 | 0               | -640            |
| 2           | 2020-01-31 | 549             | 549             |
| 2           | 2020-02-29 | 0               | 549             |
| 2           | 2020-03-31 | 61              | 610             |
| 2           | 2020-04-30 | 0               | 610             |
| 3           | 2020-01-31 | 144             | 144             |
| 3           | 2020-02-29 | -965            | -821            |
| 3           | 2020-03-31 | -401            | -1222           |
| 3           | 2020-04-30 | 493             | -729            |
| 4           | 2020-01-31 | 848             | 848             |
| 4           | 2020-02-29 | 0               | 848             |
| 4           | 2020-03-31 | -193            | 655             |
| 4           | 2020-04-30 | 0               | 655             |
| 5           | 2020-01-31 | 954             | 954             |
| 5           | 2020-02-29 | 0               | 954             |
| 5           | 2020-03-31 | -2877           | -1923           |
| 5           | 2020-04-30 | -490            | -2413           |
<br/>

## 5. What is the percentage of customers who increase their closing balance by more than 5%?
```sql
CREATE TEMP table dates AS(
  WITH RECURSIVE required_dates AS(
      SELECT
          customer_id,
          '2020-01-31'::DATE AS month_end
      FROM data_bank.customer_transactions

      UNION

      SELECT
          customer_id,
          (DATE_TRUNC('month', month_end) + INTERVAL '2 MONTH' - INTERVAL '1 DAY') ::DATE AS month_end
      FROM required_dates
      WHERE DATE_TRUNC('month', month_end) + INTERVAL '2 MONTH' - INTERVAL '1 DAY' <= '2020-04-30')

  SELECT * FROM required_dates ORDER BY customer_id);

CREATE TEMP TABLE closing_balance AS(
  WITH monthly_net_txn AS(
    SELECT
      customer_id,
      DATE_TRUNC('Month', txn_date) + INTERVAL '1 MONTH' - INTERVAL '1 DAY' AS month_end,
      SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE - txn_amount END) AS net_amt
    FROM data_bank.customer_transactions
    GROUP BY customer_id, 2),
    net_monthly AS(
    SELECT
      d.customer_id,
      d.month_end,
      COALESCE(net_amt, 0) AS net_amt
    FROM dates d 
      LEFT JOIN monthly_net_txn t 
      USING(customer_id, month_end))
  SELECT 
      customer_id,
      TO_CHAR(month_end, 'YYYY-MM-DD') AS month_end,
      net_amt AS net_transaction,
      SUM(net_amt) OVER(PARTITION BY customer_id ORDER BY month_end) AS closing_balance
  FROM net_monthly 
  ORDER BY customer_id, month_end);

WITH next_month_balance AS(
  SELECT 
  	customer_id,
  	closing_balance,
  	LEAD(closing_balance) OVER(PARTITION BY customer_id ORDER BY month_end) AS next_month_closing
  FROM closing_balance)
SELECT
	ROUND(100.0 * COUNT(DISTINCT customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM data_bank.customer_transactions), 2) AS pct_qualifying_cust
FROM next_month_balance
WHERE closing_balance != 0 AND 1.0*next_month_closing/closing_balance > 1.05;
```
| pct_qualifying_cust |
| ------------------- |
| 75.80               |
<br/>
