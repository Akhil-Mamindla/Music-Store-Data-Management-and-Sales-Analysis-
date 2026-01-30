create database SQL_Project;
use SQL_Project;

-- 1. Genre and MediaType
CREATE TABLE Genre (
	genre_id INT PRIMARY KEY,
	name VARCHAR(120)
);

CREATE TABLE MediaType (
	media_type_id INT PRIMARY KEY,
	name VARCHAR(120)
);

-- 2. Employee
CREATE TABLE Employee (
	employee_id INT PRIMARY KEY,
	last_name VARCHAR(120),
	first_name VARCHAR(120),
	title VARCHAR(120),
	reports_to INT,
  levels VARCHAR(255),
	birthdate DATE,
	hire_date DATE,
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100)
);

-- 3. Customer
CREATE TABLE Customer (
	customer_id INT PRIMARY KEY,
	first_name VARCHAR(120),
	last_name VARCHAR(120),
	company VARCHAR(120),
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100),
	support_rep_id INT,
	FOREIGN KEY (support_rep_id) REFERENCES Employee(employee_id)
);

-- 4. Artist
CREATE TABLE Artist (
	artist_id INT PRIMARY KEY,
	name VARCHAR(120)
);

-- 5. Album
CREATE TABLE Album (
	album_id INT PRIMARY KEY,
	title VARCHAR(160),
	artist_id INT,
	FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
);

-- 6. Track
CREATE TABLE Track (
	track_id INT PRIMARY KEY,
	name VARCHAR(200),
	album_id INT,
	media_type_id INT,
	genre_id INT,
	composer VARCHAR(220),
	milliseconds INT,
	bytes INT,
	unit_price DECIMAL(10,2),
	FOREIGN KEY (album_id) REFERENCES Album(album_id),
	FOREIGN KEY (media_type_id) REFERENCES MediaType(media_type_id),
	FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
);

-- 7. Invoice
CREATE TABLE Invoice (
	invoice_id INT PRIMARY KEY,
	customer_id INT,
	invoice_date DATE,
	billing_address VARCHAR(255),
	billing_city VARCHAR(100),
	billing_state VARCHAR(100),
	billing_country VARCHAR(100),
	billing_postal_code VARCHAR(20),
	total DECIMAL(10,2),
	FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

-- 8. InvoiceLine
CREATE TABLE InvoiceLine (
	invoice_line_id INT PRIMARY KEY,
	invoice_id INT,
	track_id INT,
	unit_price DECIMAL(10,2),
	quantity INT,
	FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id),
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
);

-- 9. Playlist
CREATE TABLE Playlist (
 	playlist_id INT PRIMARY KEY,
	name VARCHAR(255)
);

-- 10. PlaylistTrack
CREATE TABLE PlaylistTrack (
	playlist_id INT,
	track_id INT,
	PRIMARY KEY (playlist_id, track_id),
	FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id),
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
);


select * from Genre;
select * from mediatype;
select * from employee;
select * from customer;
select * from artist;
select * from album;
select * from track;
select * from invoice;
select * from invoiceline;
select * from playlist;
select * from playlisttrack;

-- 1. Who is the senior most employee based on job title? 
select concat(first_name , last_name) as employee_name from employee
order by levels desc
limit 1;

-- 2. Which countries have the most Invoices?
select billing_country, count(*) as total_invoice from invoice
group by billing_country
order by total_invoice desc
limit 1 ;

-- 3. What are the top 3 values of total invoice?
select total  from invoice 
order by total desc
limit 3;

-- 4. Which city has the best customers?  -We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
select sum(total),billing_city from invoice
group by billing_city 
limit 1;

-- 5. Who is the best customer? - The customer who has spent the most money will be declared the best customer.Write a query that returns the person who has spent the most money
select customer.customer_id,customer.first_name,customer.last_name,sum(invoice.total) as total_spent
from customer
join invoice on
customer.customer_id = invoice.customer_id
group by customer.customer_id,customer.first_name,customer.last_name
order by total_spent desc
limit 1;

-- 6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A.
select c.email,c.first_name,c.last_name from customer c
join invoice i on 
c.customer_id = i.customer_id
join invoiceline il on
i.invoice_id = il.invoice_id
join track t on 
il.track_id = t.track_id
join genre g on
t.genre_id = g.genre_id
group by c.email,c.first_name,c.last_name
order by email;
 
 -- 7. Let's invite the artists who have written the most rock music in our dataset.Write a query that returns the Artist name and total track count of the top 10 rock bands
 select ar.name, count(track_id) as total_track_count from artist ar
join album a on
 ar.artist_id =a.artist_id
 join track t on
 t.album_id = a.album_id
 join genre g on
 g.genre_id = t.genre_id
 group by ar.name
 order by total_track_count desc
 limit 10;
 
 -- 8. Return all the track names that have a song length longer than the average song length.- Return the Name and Milliseconds for each track. Order by the song length, with the longest songs listed first
 select name,milliseconds from track
where milliseconds>(select avg(milliseconds) from track)
order by milliseconds desc;

 -- 9. Find how much amount is spent by each customer on artists? Write a query to return customer name, artist name and total spent 
 select concat(c. first_name,c.last_name) as Customer_name,ar.name as Artist_name, sum(i.total) as Total_spent from customer c
 join invoice i on
 i.customer_id = c.customer_id
 join invoiceline il on
 il.invoice_id = i.invoice_id
 join track t on
 t.track_id = il.track_id
 join album al on 
 al.album_id = t.album_id
 join artist ar on
 ar.artist_id = al.artist_id
 group by Customer_name,Artist_name
 order by total_spent desc;
 
 -- 10. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases.
     -- Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared, return all Genres
 
 WITH genre_purchases AS (
    SELECT
        i.billing_country AS country,
        g.name AS genre,
        COUNT(il.invoice_line_id) AS purchases
    FROM invoice i
    JOIN invoiceline il
        ON i.invoice_id = il.invoice_id
    JOIN track t
        ON il.track_id = t.track_id
    JOIN genre g
        ON t.genre_id = g.genre_id
    GROUP BY i.billing_country, g.name
),
ranked_genres AS (
    SELECT
        country,
        genre,
        purchases,
        RANK() OVER (
            PARTITION BY country
            ORDER BY purchases DESC
        ) AS rnk
    FROM genre_purchases
)
SELECT
    country,
    genre,
    purchases
FROM ranked_genres
WHERE rnk = 1
ORDER BY country;
 
 -- 11. Write a query that determines the customer that has spent the most on music for each country. 
    -- Write a query that returns the country along with the top customer and how much they spent. 
    --  For countries where the top amount spent is shared, provide all customers who spent this amount
    
WITH customer_spending AS (
    SELECT
        c.customer_id,
       concat(c.first_name,
        c.last_name)as Name,
        c.country,
        SUM(i.total) AS total_spent
    FROM customer c
    JOIN invoice i
        ON c.customer_id = i.customer_id
    GROUP BY
        c.customer_id,
        Name,
        c.country
),
ranked_customers AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY country
            ORDER BY total_spent DESC
        ) AS rank_in_country
    FROM customer_spending
)
SELECT
    country,
    Name,
    total_spent
FROM ranked_customers
WHERE rank_in_country = 1
ORDER BY country;

 