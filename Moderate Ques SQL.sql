--Q.1 Write query to return the email, first name, last name, & Genre
--of all Rock Music listners. Return your list ordered alphabetically by
--email starting with A.

select distinct email,first_name,last_name
from customer
join invoice
on customer.customer_id=invoice.customer_id
join invoice_line 
on invoice.invoice_id=invoice_line.invoice_id
where track_id in (
select track.track_id 
from track
join genre on 
track.genre_id=genre.genre_id
where genre.name like 'Rock'
)
order by email asc;
-- another method for same ques
select distinct email,first_name,last_name
from customer
join invoice
on customer.customer_id=invoice.customer_id
join invoice_line
on invoice.invoice_id=invoice_line.invoice_id
join track
on invoice_line.track_id=track.track_id
join genre
on track.genre_id=genre.genre_id
where genre.name='Rock'
order by email;

--Q2. let's invite the artists who have written the most rock
--music in our dataset. Write a query that returns the Artist name 
--and total track count of the top 10 rock bands.

select artist.artist_id,artist.name,count(artist.artist_id)
as number_of_songs from track
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10;

--Q3. Return all track names that have a song length longer than
--the average song length. Return the Name and Milliseconds for 
--each track. Ordr by the song length with the longest songs 
--listed first.

select name,milliseconds
from track
where milliseconds>(
select avg(milliseconds) as avg_track_length
from track)
order by milliseconds desc;
