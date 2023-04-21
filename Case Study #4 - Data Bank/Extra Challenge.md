# Extra Challenge

Data Bank wants to try another option which is a bit more difficult to implement - they want to calculate data growth using an interest calculation, just like in a traditional savings account you might have with a bank.

### (i) If the annual interest rate is set at 6% and the Data Bank team wants to reward its customers by increasing their data allocation based off the interest calculated on a daily basis at the end of each day, how much data would be required for this option on a monthly basis?

Considering 365 days in a year:
Daily Interest Rate = (0.06 / 365) = 0.01643 % 

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
  balance AS(
    SELECT 
        customer_id,
        txn_date,
        CASE WHEN balance_on_date > 0 THEN balance_on_date ELSE 0 END AS balance_on_date
    FROM running_bal),
  interest AS(
    SELECT
    	customer_id,
    	txn_date,
    	balance_on_date,
    	0.01643/100.0 * balance_on_date AS interest_accrued_on_date
    FROM balance),
  corrected_balance AS(
    SELECT
    	customer_id,
    	txn_date,
    	balance_on_date + SUM(interest_accrued_on_date) OVER(PARTITION BY customer_id ORDER BY txn_date) AS balance_and_interest
    FROM interest),
  required_data_per_customer AS(
    SELECT
    	customer_id,
    	EXTRACT(MONTH FROM txn_date) AS month_num,
    	MAX(balance_and_interest) AS max_req_data
    FROM corrected_balance
    GROUP BY customer_id, month_num)
SELECT 
	month_num,
    ROUND(SUM(max_req_data), 2) AS req_data
FROM required_data_per_customer
GROUP BY month_num
ORDER BY month_num;
```
| month_num | data_req   |
|-----------|------------|
| 1         | 363236.07  |
| 2         | 432203.88  |
| 3         | 441731.30  |
| 4         | 362733.12  |

<br/>

### (ii) Data Bank wants an initial calculation which does not allow for compounding interest, however they may also be interested in a daily compounding interest calculation so you can try to perform this calculation if you have the stamina!



