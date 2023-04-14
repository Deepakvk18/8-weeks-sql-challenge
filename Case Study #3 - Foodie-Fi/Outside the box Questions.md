# Outside The Box Questions
The following are open ended questions which might be asked during a technical interview for this case study - there are no right or wrong answers, but answers that make sense from both a technical and a business perspective make an amazing impression!

## 1. How would you calculate the rate of growth for Foodie-Fi?

Rate of growth of Foodie Fi can be looked upon from different perspectives. We can determine growth rate based on growth of revenue, or increase in the number of paying customers. 

We can also look into both since if the customers starts downgrading their plans, it would affect the revenue. 

### Revenue:
I have created a temp table which is used in the challenge payment question with alias subs.


```sql
SELECT
	TO_CHAR(payment_date::DATE, 'Month') AS month_name,
    SUM(amount) AS revenue
FROM subs
WHERE EXTRACT(YEAR FROM payment_date::DATE)=2020
GROUP BY 1, EXTRACT(MONTH FROM payment_date::DATE)
ORDER BY EXTRACT(MONTH FROM payment_date::DATE);
```

| month_name | revenue   |
|------------|-----------|
| January    | 1252.20   |
| February   | 2584.00   |
| March      | 4015.10   |
| April      | 5456.90   |
| May        | 6669.40   |
| June       | 7932.20   |
| July       | 9384.40   |
| August     | 11085.10  |
| September  | 11831.70  |
| October    | 13811.30  |
| November   | 11701.30  |
| December   | 12685.00 |

### Paying Customers
```sql
SELECT
	TO_CHAR(payment_date::DATE, 'Month') AS month_name,
    COUNT(DISTINCT customer_id) AS paying_customers
FROM subs
WHERE EXTRACT(YEAR FROM payment_date::DATE)=2020
GROUP BY 1, EXTRACT(MONTH FROM payment_date::DATE)
ORDER BY EXTRACT(MONTH FROM payment_date::DATE);
```
| Month Name | paying_customers |
|------------|-------|
| January    | 60    |
| February   | 115   |
| March      | 186   |
| April      | 232   |
| May        | 289   |
| June       | 334   |
| July       | 376   |
| August     | 433   |
| September  | 458   |
| October    | 499   |
| November   | 507   |
| December   | 570   |

It can be seen that both the number of paying customers and the revenue increased gradually in 2020.

<br/>

## 2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?

Churn Rate = No of customers who churned/Total number of customers
Revenue
No of customers 
Paying customers percentage
Percentage of customers downgrading their plans
Percentage of customers who declined after free trial
Percentage of customers who subscribed after free trial


<br/>

## 3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?

<br/>

## 4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?

<br/>

## 5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?

<br/>