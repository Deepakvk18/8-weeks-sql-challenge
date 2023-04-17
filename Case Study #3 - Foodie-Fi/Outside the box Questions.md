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

* Churn Rate = No of customers who churned/Total number of customers
* Revenue
* No of customers 
* Paying customers percentage
* Percentage of customers downgrading their plans
* Percentage of customers who declined after free trial
* Percentage of customers who subscribed after free trial
* Engagement Rate
* Average daily usage by the customer

<br/>

## 3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?
1. What is the reason for the customer to downgrade their plan? 
2. If a customer is upgrading their plan, what influences them the most in making their decision? 
3. What might be the reason for the customer to churn after subscribing to the expensive plan? 
4. What is the plan after which most of the customers churned?
5. What is the difference in usage statistics for churned customers Vs regular paying customers? 
6. What is the difference in the engagement rate of the churned customers vs the regularly paying customers? 
7. What is the number of support requests raised by churned customers vs the regularly paying customers? 
<br/>

## 4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?
1. The platform is easy to use. 
2. I was able to find what I was searching for. 
3. I am satisfied with the service Foodie Fi has given me. 
4. The support provided by Foodie Fi is excellent. 
5. I can upgrade, downgrade and cancel my subscription easily. 
6. I feel that the Foodie Fi service is worth the money. 
7. I feel that Foodie Fi has the best food content. 
8. Foodie Fi has improved my way of consuming food. 
9. Can you select the reason for Unsubscribing from Foodie Fi? 
        a. Cost 
        b. Not enough content 
        c. Absence of my favorite food influencer in the platform 
        d. The quality of the content is not up to the mark
        e. Bad user interface of the app 
        f. Other(please mention) 
10. If you think we should improve anything in the platform,  please mention it. 
<br/>

## 5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?

1. Develop a Machine Learning model with usage stats, engagement rate, and customer demographics to predict the churn probability and send personalized promotional offers to customers more likely to churn. We can validate this hypothesis by offering discounts to a few churned customers and Observing their actions. 
2. Analyze the demographics of the paying customers who did not churn in the past and design a digital marketing strategy to target that demographic group. 
3. Create loyalty programs, giveaway contests, etc., and keep existing customers engaged with the platform. We can validate this hypothesis by creating a campaign at a smaller level and scaling the campaign depending on the outcome. 
4. Improve the quality of content by collaborating with food influencers and promoting the platform through Instagram, Facebook, and blogs. These platforms may serve as the Free version of our platform, and we can measure the campaign effectiveness by the engagement rate and follower count. Increasing engagement rate and follower count means more potential customers are interested in our services. 
5. Create a forum in the platform where users share unique recipes and dishes, write restaurant reviews, and enable influencers to create a community of Foodies. We can validate this hypothesis by conducting surveys/polls with existing customers. 
6. Increase the user experience of the platform. Some customers might decide not to subscribe due to bad UI/UX. So, creating a better user interface and easy-to-navigate pages will help reduce the churn rate to an extent. We can validate this hypothesis by collecting data through exit surveys and analyzing the data. 
<br/>