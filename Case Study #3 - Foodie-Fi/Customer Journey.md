# Customer Journey

## 1. Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

| customer_id | plan_id | start_date  |
|-------------|---------|-------------|
| 1           | 0       | 2020-08-01  |
| 1           | 1       | 2020-08-08  |
| 2           | 0       | 2020-09-20  |
| 2           | 3       | 2020-09-27  |
| 11          | 0       | 2020-11-19  |
| 11          | 4       | 2020-11-26  |
| 13          | 0       | 2020-12-15  |
| 13          | 1       | 2020-12-22  |
| 13          | 2       | 2021-03-29  |
| 15          | 0       | 2020-03-17  |
| 15          | 2       | 2020-03-24  |
| 15          | 4       | 2020-04-29  |
| 16          | 0       | 2020-05-31  |
| 16          | 1       | 2020-06-07  |
| 16          | 3       | 2020-10-21  |
| 18          | 0       | 2020-07-06  |
| 18          | 2       | 2020-07-13  |
| 19          | 0       | 2020-06-22  |
| 19          | 2       | 2020-06-29  |
| 19          | 3       | 2020-08-29  |
<br/>

### Answer:-

Let me write a query to present plan name instead of plan id.

```sql
SELECT
    customer_id,
    plan_name,
    TO_CHAR(start_date, 'YYYY-MM-DD') AS start_date
FROM foodie_fi.subscriptions s 
    JOIN foodie_fi.plans p ON s.plan_id=p.plan_id
WHERE customer_id IN (1, 2, 11, 13, 15, 16, 18, 19)
ORDER BY customer_id, start_date;
```
| customer_id | plan_name     | start_date |
| ----------- | ------------- | ---------- |
| 1           | trial         | 2020-08-01 |
| 1           | basic monthly | 2020-08-08 |
| 2           | trial         | 2020-09-20 |
| 2           | pro annual    | 2020-09-27 |
| 11          | trial         | 2020-11-19 |
| 11          | churn         | 2020-11-26 |
| 13          | trial         | 2020-12-15 |
| 13          | basic monthly | 2020-12-22 |
| 13          | pro monthly   | 2021-03-29 |
| 15          | trial         | 2020-03-17 |
| 15          | pro monthly   | 2020-03-24 |
| 15          | churn         | 2020-04-29 |
| 16          | trial         | 2020-05-31 |
| 16          | basic monthly | 2020-06-07 |
| 16          | pro annual    | 2020-10-21 |
| 18          | trial         | 2020-07-06 |
| 18          | pro monthly   | 2020-07-13 |
| 19          | trial         | 2020-06-22 |
| 19          | pro monthly   | 2020-06-29 |
| 19          | pro annual    | 2020-08-29 |


Each and every user undergoes a unique journey with Foodie Fi. 

For example, let us look at the journey of Customer with customer id 1:

| customer_id | plan_name     | start_date |
| ----------- | ------------- | ---------- |
| 1           | trial         | 2020-08-01 |
| 1           | basic monthly | 2020-08-08 |

        * He started off with free trial and probably liked the product so he purchased the basic monthly pack straight away.
<br/>

| customer_id | plan_name     | start_date |
| ----------- | ------------- | ---------- |
| 2           | trial         | 2020-09-20 |
| 2           | pro annual    | 2020-09-27 |

        * On the other hand, customers like 2 loved the product and purchased the most expensive package after the free trial

<br/>
| customer_id | plan_name     | start_date |
| ----------- | ------------- | ---------- |
| 11          | trial         | 2020-11-19 |
| 11          | churn         | 2020-11-26 |

        * There will also be people like 3, who disliked the product after free trial and so they did not decide to purchase the subscription
<br/>
| customer_id | plan_name     | start_date |
| ----------- | ------------- | ---------- |
| 13          | trial         | 2020-12-15 |
| 13          | basic monthly | 2020-12-22 |
| 13          | pro monthly   | 2021-03-29 |
| 16          | trial         | 2020-05-31 |
| 16          | basic monthly | 2020-06-07 |
| 16          | pro annual    | 2020-10-21 |
| 19          | trial         | 2020-06-22 |
| 19          | pro monthly   | 2020-06-29 |
| 19          | pro annual    | 2020-08-29 |
        
        * People like 13, 16 & 19 tend to go sequentially to decide to purchase the plans each time they feel like the service provides value to them
<br/>
| customer_id | plan_name     | start_date |
| ----------- | ------------- | ---------- |
| 15          | trial         | 2020-03-17 |
| 15          | pro monthly   | 2020-03-24 |
| 15          | churn         | 2020-04-29 |

        * 15 on the other hand, decided that the service is not useful to him/her depending on the service provided by Foodie fi.
<br/>

### What does a customer journey looks like?

![image](https://user-images.githubusercontent.com/103412614/231981572-1ad8c4c2-c6b1-4295-9837-41bd37266401.png)
