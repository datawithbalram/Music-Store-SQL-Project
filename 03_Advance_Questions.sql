--Q1. Find best selling artist and determine how much each customer
--has spent on that artist?
--Write a query to return customer name, artist name and total
--spent.

--this is cte (temporay table)
with best_selling_artist as (
select artist.artist_id as artist_id,artist.name as artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track on track.track_id=invoice_line.track_id
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
group by 1
order by 3 desc
limit 1
)
-- main query including cte
select c.customer_id,c.first_name,c.last_name,bsa.artist_name,
sum(il.unit_price*quantity) as amount_spent
from invoice i
join customer c on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id=il.track_id
join album alb on alb.album_id=t.album_id
join best_selling_artist bsa on bsa.artist_id=alb.artist_id
group by 1,2,3,4
order by 5 desc;

--OR ANOTHER QUESTION WITHOUT CTE

--Q1. Find how much amount spent by each customer on artists?
--Write a query to return customer name, artist name and total
--spent.

select c.customer_id,c.first_name,c.last_name,ar.name as artist_name,
sum(il.unit_price*quantity) as total_spent
from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id=il.track_id
join album alb on alb.album_id=t.album_id
join artist ar on ar.artist_id=alb.artist_id
group by 1,2,3,4
order by 5 desc;

--Q2. We want to find out the most popular music Genre for 
--each country. We determine the most popular Genre as the Genre
--with the highest amount of purchases. Write a query that returns
--each country along with the top Genre. For countries where the 
--maximum number of purchases is shared return all Genres.

--METHOD 1 — ROW_NUMBER() Method
-- =========================================================
-- STEP 1:
-- Calculate the purchase count for each country and genre
-- Also assign a rank based on the purchase count
-- =========================================================

WITH popular_genre AS (

    SELECT

        -- Count the number of purchase records in each group
        COUNT(*) AS purchases,


        -- Customer country
        customer.country,


        -- Genre name
        genre.name,


        -- Genre id
        genre.genre_id,


        -- Rank genres within each country
-- The genre with the highest purchase count gets rank 1
        ROW_NUMBER() OVER(

            PARTITION BY customer.country

            ORDER BY COUNT(*) DESC

        ) AS rowno


    -- This is where the actual purchase data is stored
    FROM invoice_line


    -- invoice_line → invoice
    JOIN invoice

        ON invoice.invoice_id =
           invoice_line.invoice_id


    -- invoice → customer
    JOIN customer

        ON customer.customer_id =
           invoice.customer_id


    -- invoice_line → track
    JOIN track

        ON track.track_id =
           invoice_line.track_id


    -- track → genre
    JOIN genre

        ON genre.genre_id =
           track.genre_id


    -- Country + Genre wise grouping
    GROUP BY

        customer.country,
        genre.name,
        genre.genre_id
)



-- =========================================================
-- STEP 2:
-- Retain only the top-ranked genres (row number 1)
-- =========================================================

SELECT *

FROM popular_genre


-- Top-selling genre in each country
WHERE rowno = 1;



--Now METHOD 2 — Tie Handling Method (Better Method)
-- =========================================================
-- STEP 1:
-- Calculate the purchase count for each country and genre
-- =========================================================

WITH sales_per_country AS (

    SELECT

        -- Count rows in each group
        -- Each row = one purchase
        COUNT(*) AS purchases_per_genre,


        -- Customer country
        customer.country,


        -- Genre name
        genre.name,


        -- Genre id
        genre.genre_id


    FROM invoice_line


    -- invoice_line → invoice
    JOIN invoice

        ON invoice.invoice_id =
           invoice_line.invoice_id


    -- invoice → customer
    JOIN customer

        ON customer.customer_id =
           invoice.customer_id


    -- invoice_line → track
    JOIN track

        ON track.track_id =
           invoice_line.track_id


    -- track → genre
    JOIN genre

        ON genre.genre_id =
           track.genre_id


    -- Country + Genre wise grouping
    GROUP BY

        customer.country,
        genre.name,
        genre.genre_id
),



-- =========================================================
-- STEP 2:
-- Calculate the highest purchase count for each country
-- =========================================================

max_genre_per_country AS (

    SELECT

        -- Highest purchases value
        MAX(purchases_per_genre)
        AS max_genre_number,


        -- Country
        country

    FROM sales_per_country


-- Separate maximum value for each country
    GROUP BY country
)



-- =========================================================
-- STEP 3:
-- Keep only those genres
-- where purchases = maximum purchases
-- =========================================================

SELECT

    sales_per_country.*

FROM sales_per_country



-- Join for matching country values
JOIN max_genre_per_country

    ON sales_per_country.country =
       max_genre_per_country.country



-- Keep only the genres that have the highest purchase count
WHERE sales_per_country.purchases_per_genre =

      max_genre_per_country.max_genre_number;

--Q3. Write a query that determines the customer that has the most
--on music foe rach country. Write a query that returns the
--country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared , provide
--all customers who spent this amount.

-- =========================================================
-- QUESTION:
--
-- Find the customer that has spent the most on music
-- for each country.
--
-- If multiple customers have same maximum spending,
-- return all of them.
-- =========================================================



-- =========================================================
-- STEP 1:
-- Calculate the total spend of each customer
-- grouped by country
-- =========================================================

WITH customer_with_country AS (

    SELECT

        -- Customer country
        customer.country,


        -- Customer id
        customer.customer_id,


        -- Customer first name
        customer.first_name,


        -- Customer last name
        customer.last_name,


        -- Total spending
        --
-- A single customer may have multiple invoices
-- So we use SUM to aggregate the total spend

        SUM(invoice.total) AS total_spending


    -- Customer table se start
    FROM customer


    -- Joining invoice table
-- To calculate customer spending
    JOIN invoice

        ON invoice.customer_id =
           customer.customer_id


    -- Country + Customer wise grouping
    --
    -- Example:
    --
    -- India + Rahul
    -- USA + John

    GROUP BY

        customer.country,
        customer.customer_id,
        customer.first_name,
        customer.last_name
),



-- =========================================================
-- STEP 2:
-- Calculate the highest total spending per country
-- =========================================================

country_max_spending AS (

    SELECT

        -- Highest spending value
        MAX(total_spending) AS max_spending,


        -- Country
        country

    FROM customer_with_country


   -- Separate maximum spending for each country
    GROUP BY country
)



-- =========================================================
-- STEP 3:
-- Keep only those customers
-- whose spending equals the maximum spending of their country
-- =========================================================

SELECT

    customer_with_country.country,
    customer_with_country.first_name,
    customer_with_country.last_name,
    customer_with_country.total_spending

FROM customer_with_country



-- Join to match countries
JOIN country_max_spending

    ON customer_with_country.country =
       country_max_spending.country



-- Only customers with maximum spending
WHERE customer_with_country.total_spending =

      country_max_spending.max_spending;

