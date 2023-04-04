# Introduction

Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”

Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

# Available Data

### Table 1: runners 
  The runners table shows the registration_date for each new runner
### Table 2: customer_orders
  Customer pizza orders are captured in the customer_orders table with 1 row for each individual pizza that is part of the order.
### Table 3: runner_orders
  After each orders are received through the system - they are assigned to a runner - however not all orders are fully completed and can be cancelled by the restaurant or the customer.
### Table 4: pizza_names
  At the moment - Pizza Runner only has 2 pizzas available the Meat Lovers or Vegetarian!
### Table 5: pizza_recipes
  Each pizza_id has a standard set of toppings which are used as part of the pizza recipe.
### Table 6: pizza_toppings
  This table contains all of the topping_name values with their corresponding topping_id value

# Entity Relationship Diagram
![er](https://user-images.githubusercontent.com/103412614/229781921-a595fd80-1ed9-462b-b272-605b3bdb5398.png)



For more details: https://8weeksqlchallenge.com/case-study-2/
