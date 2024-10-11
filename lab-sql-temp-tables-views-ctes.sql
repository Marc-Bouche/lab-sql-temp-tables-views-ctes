USE sakila;
#Welcome to the Temporary Tables, Views and CTEs lab!

#In this lab, you will be working with the Sakila database on movie rentals. 
#The goal of this lab is to help you practice and gain proficiency in using views, CTEs, and temporary tables in SQL queries.
#Temporary tables are physical tables stored in the database that can store intermediate results for a specific query or stored procedure. 
#Views and CTEs, on the other hand, are virtual tables that do not store data on their own and are derived from one or more tables or views. 
#They can be used to simplify complex queries. Views are also used to provide controlled access to data without granting direct access to the underlying tables.

#Through this lab, you will practice how to create and manipulate temporary tables, views, and CTEs. 
#By the end of the lab, you will have gained proficiency in using these concepts to simplify complex queries and analyze data effectively.

#-------------------------------------------------------------------------------------------------------------------------------------#

#Challenge
#Creating a Customer Summary Report

#In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, 
#including their rental history and payment details.
#The report will be generated using a combination of views, CTEs, and temporary tables.

#Step 1: Create a View
#First, create a view that summarizes rental information for each customer. 
#The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW Rental_information_customers AS
SELECT CONCAT(first_name, ' ', last_name) AS full_name,
       email,
       COUNT(rental.customer_id) AS total_number_rental
FROM rental
INNER JOIN customer USING (customer_id)
GROUP BY full_name, email
ORDER BY total_number_rental DESC;

SELECT*
FROM Rental_information_customers;


#-------------------------------------------------------------------------------------------------------------------------------------#
#Step 2: Create a Temporary Table
#Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
#The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.
#--------------------------------------------MY ANSWER--------------------------------------------#
CREATE TEMPORARY TABLE Total_paid AS
	SELECT SUM(payment.amount),payment.customer_id
	FROM PAYMENT
	INNER JOIN customer USING(customer_id)
	INNER JOIN rental_information_customers USING(email);
    
SELECT *
FROM total_paid;

#--------------------------------------------SOLUTION--------------------------------------------#
CREATE TEMPORARY TABLE total_paid_ AS
	SELECT rental_information_customers.full_name,
		   SUM(payment.amount) AS total_paid_
	FROM rental_information_customers
	INNER JOIN customer USING (email)
	INNER JOIN payment USING (customer_id)
	GROUP BY rental_information_customers.full_name
	ORDER BY total_paid_ DESC;

SELECT *
FROM total_paid_;

#-------------------------------------------------------------------------------------------------------------------------------------#
#Step 3: Create a CTE and the Customer Summary Report
#Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
#The CTE should include the customer's name, email address, rental count, and total amount paid.


WITH new_CTE AS(
SELECT rental_information_customers.full_name, rental_information_customers.email, rental_information_customers.total_number_rental, total_paid_.total_paid_
FROM Rental_information_customers
INNER JOIN total_paid_ USING (full_name)) 
  SELECT * FROM new_CTE;


#-------------------------------------------------------------------------------------------------------------------------------------#
#Next, using the CTE, create the query to generate the final customer summary report, which should include: 
#customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

WITH rental_customer_summary AS (
  SELECT
    rental_information_customers.full_name,
    rental_information_customers.email,
    rental_information_customers.total_number_rental,
    total_paid_.total_paid_
  FROM
    rental_information_customers
  INNER JOIN total_paid_ USING (full_name)
)
SELECT
  full_name,
  email,
  total_number_rental,
  total_paid_,
  total_paid_ / total_number_rental AS average_payment_per_rental
FROM
  rental_customer_summary;