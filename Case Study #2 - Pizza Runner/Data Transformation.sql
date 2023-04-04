 UPDATE pizza_runner.runner_orders 
 SET pickup_time=NULL 
 WHERE pickup_time='null' or pickup_time='';
 
 UPDATE pizza_runner.runner_orders 
 SET distance=NULL 
 WHERE distance='null' or distance='';
 
 UPDATE pizza_runner.runner_orders 
 SET duration=NULL 
 WHERE duration='null' or duration='';
 
 UPDATE pizza_runner.runner_orders 
 SET cancellation=NULL 
 WHERE cancellation='null' or cancellation='';
 
 UPDATE pizza_runner.customer_orders 
 SET extras=NULL 
 WHERE extras='null' or extras='';
 
 UPDATE pizza_runner.customer_orders 
 SET exclusions=NULL 
 WHERE exclusions='null' or exclusions='';