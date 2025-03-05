select * from album;
select * from artist;
select * from customer;
select * from employee;
select * from genre;
select * from invoice;
select * from invoice_line;
select * from media_type;
select * from playlist;
select * from playlist_track;
select * from track;


-- Query 1 who is the senior most employee based on job level
select *
from employee
order by levels desc
limit 1;

--Query 2 which countries have the most invoices
select billing_country as country , count(*) as total_invoices
from invoice
group by billing_country
order by billing_country desc
limit 5;

--Query 3 what are top 3 values of invoice
select total
from invoice
order by total desc
limit 3;

--Query 4 write a query that returns one city with the highest sum of invoice totals.Return 
--both the city name and sum of all invoice totals
select billing_city, sum(total) as total_invoice_value
from invoice
group by billing_city
order by total_invoice_value desc
limit 1;

--Query 5 Who is the best customer? write a query that returns the person 
--who has spent the most money.
select c.customer_id, c.first_name, c.last_name, sum(total) as total_spent 
from customer c
join invoice i
on i.customer_id=c.customer_id
group by c.customer_id, c.first_name, c.last_name
order by total_spent desc
limit 1;

--Query 6 Write a query to return email first name, last name and genre of all rock music listeners.
-- Return your list ordered alphabetically by email in ascending.
select email, first_name, last_name 
from customer 
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join genre on track.genre_id = genre.genre_id
where genre.name = 'Rock'
group by email, first_name, last_name
order by email;

--Query 7 write a query to return the artist name and total track count having rock genre.
select artist.artist_id, artist.name, count(artist.artist_id) as total_track_count
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name = 'Rock'
group by artist.artist_id
order by total_track_count desc
limit 10;

--Query 8 Return all the track names that have a song length longer than the average son length.
-- Return the name and the miliseconds for each track. order by the song length in descending.
select name, milliseconds
from track
where milliseconds > ( 
    select avg(milliseconds) as avg_track_length
    from track)
order by milliseconds desc;

--Query 9 Find how much amount spent by each customer on artists. Write a query to return
--customer name, artist name and total spent.
with best_selling_artist as (
select artist.artist_id as artist_idd, artist.name as artist_name, 
sum(invoice_line.unit_price* invoice_line.quantity) as total_sales
from invoice_line
join track on track.track_id = invoice_line.track_id
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
group by artist_idd
order by total_sales desc
limit 1)

select c.customer_id, c.first_name, c.last_name, bsa.artist_name, sum(il.unit_price*il.quantity) as amount
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id= il.track_id
join album alb on alb.album_id= t.album_id
join best_selling_artist bsa on bsa.artist_idd = alb.artist_id
group by c.customer_id, c.first_name, c.last_name, bsa.artist_name
order by amount desc ;

--Query 10 We want to find out the most popular genre for each country.
-- We will determine the most popular genreas the genre with the highest amount of purchase.
with popular_genre as (
select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as rowno
from invoice_line
join invoice on invoice.invoice_id = invoice_line.invoice_id
join customer on customer.customer_id = invoice.customer_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
group by 2,3,4
order by 2 asc, 1 desc)
select * from popular_genre where rowno=1;
