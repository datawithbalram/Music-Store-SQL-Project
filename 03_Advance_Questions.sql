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
-- Har country + genre ka purchases count nikaal rahe hain
-- Saath me ranking bhi de rahe hain
-- =========================================================

WITH popular_genre AS (

    SELECT

        -- Har group me kitni purchase rows hain
        COUNT(*) AS purchases,


        -- Customer country
        customer.country,


        -- Genre name
        genre.name,


        -- Genre id
        genre.genre_id,


        -- Har country ke andar ranking
        --
        -- Highest purchases ko row number 1 milega

        ROW_NUMBER() OVER(

            PARTITION BY customer.country

            ORDER BY COUNT(*) DESC

        ) AS rowno


    -- Actual purchases yaha stored hote hain
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
-- Sirf row number 1 waale genres rakho
-- =========================================================

SELECT *

FROM popular_genre


-- Har country ka top ranked genre
WHERE rowno = 1;

--METHOD 2 — Tie Handling Method (Better Method)
-- =========================================================
-- STEP 1:
-- Har country + genre ka purchases count nikaal rahe hain
-- =========================================================

WITH sales_per_country AS (

    SELECT

        -- Har group ki rows count
        -- Har row = purchase
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
-- Har country ka maximum purchases nikaal rahe hain
-- =========================================================

max_genre_per_country AS (

    SELECT

        -- Highest purchases value
        MAX(purchases_per_genre)
        AS max_genre_number,


        -- Country
        country

    FROM sales_per_country


    -- Har country ka alag maximum
    GROUP BY country
)



-- =========================================================
-- STEP 3:
-- Sirf wahi genres rakho
-- jinka purchases = maximum purchases
-- =========================================================

SELECT

    sales_per_country.*

FROM sales_per_country



-- Country matching ke liye join
JOIN max_genre_per_country

    ON sales_per_country.country =
       max_genre_per_country.country



-- Sirf maximum purchases waale genres
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
-- Har customer ne total kitna spend kiya
-- wo nikaal rahe hain country-wise
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
        -- Ek customer ki multiple invoices ho sakti hain
        -- Isliye SUM use kar rahe hain

        SUM(invoice.total) AS total_spending


    -- Customer table se start
    FROM customer


    -- Invoice join
    --
    -- Taaki spending mile
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
-- Har country ka maximum spending nikaal rahe hain
-- =========================================================

country_max_spending AS (

    SELECT

        -- Highest spending value
        MAX(total_spending) AS max_spending,


        -- Country
        country

    FROM customer_with_country


    -- Har country ka alag maximum
    GROUP BY country
)



-- =========================================================
-- STEP 3:
-- Sirf wahi customers rakho
-- jinka spending = country ka maximum spending
-- =========================================================

SELECT

    customer_with_country.country,
    customer_with_country.first_name,
    customer_with_country.last_name,
    customer_with_country.total_spending

FROM customer_with_country



-- Country matching ke liye join
JOIN country_max_spending

    ON customer_with_country.country =
       country_max_spending.country



-- Sirf maximum spending waale customers
WHERE customer_with_country.total_spending =

      country_max_spending.max_spending;

