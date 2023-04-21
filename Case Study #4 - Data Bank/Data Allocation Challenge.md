# Data Allocation Challenge
To test out a few different hypotheses - the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options:

        Option 1: data is allocated based off the amount of money at the end of the previous month
        Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
        Option 3: data is updated real-time

For this multi-part challenge question - you have been requested to generate the following data elements to help the Data Bank team estimate how much data will need to be provisioned for each option:

        running customer balance column that includes the impact each transaction
        customer balance at the end of each month
        minimum, average and maximum values of the running balance for each customer

Using all of the data available - how much data would have been required for each option on a monthly basis?

Create a Temprorary table ``closing_bal`` which contains the closing balance of all the customers:

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


CREATE TEMP TABLE closing_bal AS(
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
  ```
<br/>


### (i) data is allocated based off the amount of money at the end of the previous month
```sql
WITH positive_balance AS(
  SELECT
  	customer_id,
  	month_end,
    CASE WHEN closing_balance > 0 THEN closing_balance ELSE 0 END AS data_usage
  FROM closing_bal),
  prev_month_closing AS(
  SELECT
    *,
    LAG(data_usage) OVER(PARTITION BY customer_id ORDER BY month_end) AS prev_closing
  FROM positive_balance)
SELECT
	month_end,
    SUM(prev_closing) AS data_required
FROM prev_month_closing
GROUP BY month_end
ORDER BY month_end;
```
| month_end   | data_required |
|-------------|---------------|
| 2020-01-31  | null          |
| 2020-02-29  | 235595        |
| 2020-03-31  | 261508        |
| 2020-04-30  | 260971        |

<br/>

### (ii) data is allocated on the average amount of money kept in the account in the previous 30 days
```sql
WITH RECURSIVE dates AS(
  SELECT
  	customer_id,
    '2020-01-01'::DATE AS txn_date
  FROM data_bank.customer_transactions
  
  UNION
  
  SELECT
  	customer_id,
  	(txn_date::DATE + INTERVAL '1 DAY')::DATE AS txn_date
  FROM dates
  WHERE txn_date < '2020-04-30'),
  net_transaction AS(
    SELECT
    	customer_id,
    	txn_date,
    	CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END AS cashflow
    FROM data_bank.customer_transactions),
  running_balance AS(
    SELECT
    	customer_id,
    	txn_date,
    	SUM(cashflow) OVER(PARTITION BY customer_id ORDER BY txn_date) AS balance_on_date
    FROM net_transaction),
  total_bal AS(
    SELECT
    	customer_id,
    	txn_date,
   		balance_on_date
    FROM running_balance RIGHT JOIN dates USING(customer_id, txn_date)),
  running_bal AS(
    SELECT
    	customer_id,
    	txn_date,
    	COALESCE(balance_on_date, FIRST_VALUE(balance_on_date) OVER(PARTITION BY grouped ORDER BY txn_date)) AS balance_on_date
	FROM (SELECT customer_id,
          		txn_date,
          		balance_on_date,
          		SUM(balance_on_date) OVER(PARTITION BY customer_id ORDER BY txn_date) AS grouped FROM total_bal) t),
	moving_avg AS(
      SELECT
        customer_id,
        txn_date,
      	AVG(balance_on_date) OVER(PARTITION BY customer_id ORDER BY txn_date ROWS BETWEEN 30 PRECEDING AND CURRENT ROW) AS rolling_avg
      FROM running_bal),
    max_data_per_person AS(
       SELECT 
          EXTRACT(MONTH FROM txn_date) AS month_num,
          customer_id,
          MAX(rolling_avg) AS max_data_req
      FROM moving_avg
      GROUP BY month_num, customer_id)
SELECT 
	month_num,
    ROUND(SUM(COALESCE(max_data_req, 0)), 2) AS data_req
FROM max_data_per_person
GROUP BY month_num
ORDER BY month_num;      
```
| month_num | data_req   |
|-----------|------------|
| 1         | 301748.19  |
| 2         | 326470.95  |
| 3         | 346418.84  |
| 4         | 333960.65  |

<br/>


### (iii) data is updated real-time
```sql
WITH net_txn AS(
  SELECT
  	customer_id,
  	txn_date,
 	CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END AS txn_net_amt
  FROM data_bank.customer_transactions),
  running_balance AS(
    SELECT
      customer_id,
      txn_date,
      SUM(txn_net_amt) OVER(PARTITION BY customer_id ORDER BY txn_date) AS running_balance
    FROM net_txn),
  max_data_req AS(
    SELECT
    	customer_id,
        EXTRACT(MONTH FROM txn_date) AS month_num,
    	MAX(running_balance) AS max_data
    FROM running_balance
    GROUP BY customer_id, month_num)
SELECT
	month_num,
    SUM(CASE WHEN max_data > 0 THEN max_data ELSE 0 END) AS data_req
FROM max_data_req
GROUP BY month_num
ORDER BY month_num;
```
| month_num | data_req |
|-----------|----------|
| 1         | 356618   |
| 2         | 352135   |
| 3         | 346904   |
| 4         | 183192   |

<br/>

### minimum, average and maximum values of the daily running balance for each customer 
```sql
WITH RECURSIVE dates AS(
  SELECT
  	customer_id,
    '2020-01-01'::DATE AS txn_date
  FROM data_bank.customer_transactions
  
  UNION
  
  SELECT
  	customer_id,
  	(txn_date::DATE + INTERVAL '1 DAY')::DATE AS txn_date
  FROM dates
  WHERE txn_date < '2020-04-30'),
  net_transaction AS(
    SELECT
    	customer_id,
    	txn_date,
    	CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END AS cashflow
    FROM data_bank.customer_transactions),
  running_balance AS(
    SELECT
    	customer_id,
    	txn_date,
    	SUM(cashflow) OVER(PARTITION BY customer_id ORDER BY txn_date) AS balance_on_date
    FROM net_transaction),
  total_bal AS(
    SELECT
    	customer_id,
    	txn_date,
   		balance_on_date
    FROM running_balance RIGHT JOIN dates USING(customer_id, txn_date)),
  running_bal AS(
    SELECT
    	customer_id,
    	txn_date,
    	COALESCE(balance_on_date, FIRST_VALUE(balance_on_date) OVER(PARTITION BY grouped ORDER BY txn_date)) AS balance_on_date
	FROM (SELECT customer_id,
          		txn_date,
          		balance_on_date,
          		SUM(balance_on_date) OVER(PARTITION BY customer_id ORDER BY txn_date) AS grouped FROM total_bal) t)
SELECT
	customer_id,
    MIN(CASE WHEN balance_on_date > 0 THEN balance_on_date ELSE NULL END) AS min_balance,
    ROUND(AVG(CASE WHEN balance_on_date > 0 THEN balance_on_date ELSE 0 END), 2) AS avg_balance,
    MAX(CASE WHEN balance_on_date > 0 THEN balance_on_date ELSE NULL END) AS max_balance
FROM running_bal
GROUP BY customer_id
ORDER BY customer_id; 
```
Sample Answer:-
| customer_id | min_balance | avg_balance | max_balance |
| ----------- | ----------- | ----------- | ----------- |
| 1           | 12          | 164.03      | 312         |
| 2           | 549         | 559.08      | 610         |
| 3           | 124         | 42.21       | 144         |
| 4           | 458         | 701.81      | 848         |
| 5           | 68          | 473.57      | 1780        |
| 6           | 11          | 562.02      | 2197        |
| 7           | 887         | 1818.89     | 3539        |
| 8           | 207         | 185.36      | 1363        |
| 9           | 608         | 885.38      | 2030        |
| 10          | 556         | 9.04        | 556         |

<br/>