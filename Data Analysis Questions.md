#  Data Analysis Questions

## 1. How many customers has Foodie-Fi ever had?
```sql
SELECT 
    COUNT(DISTINCT customer_id) AS num_customers
FROM foodie_fi.subscriptions;
```
| num_customers |
| ------------- |
| 1000          |
<br/>

## 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
```sql
SELECT 
    TO_CHAR(start_date, 'Month') AS month_name,
    COUNT(DISTINCT customer_id) AS num_trial_start
FROM foodie_fi.subscriptions
WHERE plan_id=0
GROUP BY month_name, EXTRACT(MONTH FROM start_date)
ORDER BY EXTRACT(MONTH FROM start_date);
```
| month_name | num_trial_start |
| ---------- | --------------- |
| January    | 88              |
| February   | 68              |
| March      | 94              |
| April      | 81              |
| May        | 88              |
| June       | 79              |
| July       | 89              |
| August     | 88              |
| September  | 87              |
| October    | 79              |
| November   | 75              |
| December   | 84              |
<br/>

## 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
```sql
    SELECT
    	plan_name,
        COUNT(DISTINCT customer_id) AS num_customers
    FROM foodie_fi.subscriptions s 
    	JOIN foodie_fi.plans p ON p.plan_id=s.plan_id
    WHERE EXTRACT(YEAR FROM start_date) > 2020
    GROUP BY plan_name, p.plan_id
    ORDER BY p.plan_id;
```
| plan_name     | num_customers |
| ------------- | ------------- |
| basic monthly | 8             |
| pro monthly   | 60            |
| pro annual    | 63            |
| churn         | 71            |
<br/>

## 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
```sql
WITH churners AS(
    SELECT
        (SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions) AS total,
        COUNT(DISTINCT customer_id) AS churned
    FROM foodie_fi.subscriptions
    WHERE plan_id=4)
SELECT *,
    ROUND(churned * 100.0/total, 1) AS churn_rate
FROM churners;
```
| total | churned | churn_rate |
| ----- | ------- | ---------- |
| 1000  | 307     | 30.7       |
<br/>

## 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
```sql
WITH customer_plans AS(
    SELECT 
    customer_id,
    start_date,
    plan_id,
    LEAD(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_plan_id
    FROM foodie_fi.subscriptions),
    churners AS(
    SELECT
        (SELECT COUNT(DISTINCT(customer_id)) AS churned_after_trial FROM customer_plans WHERE plan_id=0 AND next_plan_id=4) AS churners_after_trial,
    (SELECT COUNT(DISTINCT(customer_id)) AS churned_after_trial FROM foodie_fi.subscriptions WHERE plan_id=4) AS total_churners,
    (SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions) AS total_cust)
SELECT 
    total_cust,
    total_churners,
    churners_after_trial,
    ROUND(100.0 * churners_after_trial/total_churners) AS pct_trial_churn_churners,
    ROUND(100.0 * churners_after_trial/total_cust) AS pct_trial_churn_total
FROM churners;
```
| total_cust | total_churners | churners_after_trial | pct_trial_churn_churners | pct_trial_churn_total |
| ---------- | -------------- | -------------------- | ------------------------ | --------------------- |
| 1000       | 307            | 92                   | 30                       | 9                     |

<br/>

## 6. What is the number and percentage of customer plans after their initial free trial?
```sql
WITH next_plan AS(
    SELECT
    customer_id,
    plan_id,
    LEAD(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_plan
    FROM foodie_fi.subscriptions),
    customers AS(
    SELECT
    next_plan,
    COUNT(*) AS num_customers
    FROM next_plan
    WHERE plan_id=0
    GROUP BY next_plan)
SELECT
    plan_name,
    num_customers,
    ROUND(num_customers * 100.0/(SELECT SUM(num_customers) FROM customers), 1) AS pct_customers 
FROM customers c
    JOIN foodie_fi.plans p ON c.next_plan=p.plan_id;
```
| plan_name     | num_customers | pct_customers |
| ------------- | ------------- | ------------- |
| basic monthly | 546           | 54.6          |
| pro monthly   | 325           | 32.5          |
| pro annual    | 37            | 3.7           |
| churn         | 92            | 9.2           |

<br/>

## 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
```sql
WITH latest_plans AS(
  SELECT
      *,
      ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY start_date DESC) AS row_num
  FROM foodie_fi.subscriptions
  WHERE start_date < '01-01-2021')
SELECT
    plan_name,
    COUNT(*) AS num_customers,
    ROUND(100.0 * COUNT(*)/(SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions WHERE start_date < '01-01-2021'), 2) AS pct_customers
FROM latest_plans d
    JOIN foodie_fi.plans p ON p.plan_id=d.plan_id
WHERE row_num=1
GROUP BY plan_name, p.plan_id
ORDER BY p.plan_id;
```
| plan_name     | num_customers | pct_customers |
| ------------- | ------------- | ------------- |
| trial         | 19            | 1.9           |
| basic monthly | 224           | 22.4          |
| pro monthly   | 326           | 32.6          |
| pro annual    | 195           | 19.5          |
| churn         | 236           | 23.6          |
<br/>

## 8. How many customers have upgraded to an annual plan in 2020?
```sql
SELECT
    COUNT(DISTINCT customer_id) AS upgraded_to_annual_in_2020
FROM foodie_fi.subscriptions 
WHERE EXTRACT(YEAR FROM start_date)=2020
        AND plan_id=3;
```
| upgraded_to_annual_in_2020 |
| -------------------------- |
| 195                        |
<br/>

## 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
```sql
SELECT
    ROUND(AVG(s2.start_date - s1.start_date), 2) AS avg_days_from_trial_to_annual
FROM foodie_fi.subscriptions s1 
    JOIN foodie_fi.subscriptions s2 ON s1.customer_id=s2.customer_id
    AND s1.plan_id=0 AND s2.plan_id=3;
```
| avg_days_from_trial_to_annual |
| ----------------------------- |
| 104.62                        |

<br/>

## 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
```sql
WITH average AS(
    SELECT
        s2.start_date - s1.start_date AS days_from_trial_to_annual
    FROM foodie_fi.subscriptions s1 
        JOIN foodie_fi.subscriptions s2 ON s1.customer_id=s2.customer_id
        AND s1.plan_id=0 AND s2.plan_id=3),
    grouped AS(
    SELECT
    *,
    CASE WHEN days_from_trial_to_annual >= 0 AND days_from_trial_to_annual <= 30 THEN '0-30'
        WHEN days_from_trial_to_annual >= 31 AND days_from_trial_to_annual <= 60 THEN '31-60'
        WHEN days_from_trial_to_annual >= 61 AND days_from_trial_to_annual <= 90 THEN '61-90'
        WHEN days_from_trial_to_annual >= 91 AND days_from_trial_to_annual <= 120 THEN '90-120'
        WHEN days_from_trial_to_annual >= 121 AND days_from_trial_to_annual <=150 THEN '121-150'
        WHEN days_from_trial_to_annual >= 151 THEN '>150' END AS grp
    FROM average)
SELECT
    grp AS days_from_trial_to_annual,
    COUNT(grp) AS num_customers
FROM grouped
GROUP BY grp;
```
| days_from_trial_to_annual | num_customers |
| ------------------------- | ------------- |
| 0-30                      | 49            |
| 121-150                   | 42            |
| 31-60                     | 24            |
| 61-90                     | 34            |
| 90-120                    | 35            |
| >150                      | 74            |
<br/>

## 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
```sql
WITH next_cte AS(
    SELECT 
    *,
    LEAD(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_plan,
    LEAD(start_date) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_date
    FROM foodie_fi.subscriptions)
SELECT
    COUNT(DISTINCT customer_id) AS downgraded_from_pro_to_basic
FROM next_cte
WHERE plan_id=2 AND next_plan=1
        AND EXTRACT(YEAR FROM start_date)=2020 AND EXTRACT(YEAR FROM next_date)=2020;
```
| downgraded_from_pro_to_basic |
| ---------------------------- |
| 0                            |
<br/>