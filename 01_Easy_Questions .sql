--Q1. Who is the senior most employee based on  the job title?

select* from employee
order by levels desc
limit 1;

--Q2. Which countries have the most invoices?

select count(*) as num_of_invoices,billing_country
from invoice
group by billing_country
order by num_of_invoices desc;
-- Group BY groups rows having same values into one group
--COUNT(*) counts all rows 
-- count(column_name)=counts only non-NULL values
--Both gives same result only when the column has no NULL values


--Q3. What are top three values of total invoices? 

select total from invoice
order by total desc
limit 3;

--Q4. Which city has the best customers? We would like to throw a
--promotional Music Festival in the city we made the most money.
--Write a query that returns one city that has the highest sum of 
--invoice totals. Return bolth the city name & sum of all invoice
--totals.

select sum(total) as invoice_total, billing_city 
from invoice
group by billing_city
order by invoice_total desc
limit 1;

--Q.5 Who is the best customer? The customer who has spent the most 
--money will be declared the best customer. Write a query that returns
--the person who has spent the most money.

select customer.customer_id, customer.first_name ,customer.last_name,
sum(invoice.total)as total
from customer
join invoice on customer.customer_id=invoice.customer_id
group by customer.customer_id
order by total desc
limit 1;
-- total column contains amount of each individual invoice
-- SUM(total) adds all invoice amounts for each customer
-- GROUP BY customer_id creates separate group for each customer
-- Used to find the customer who spent the most money
