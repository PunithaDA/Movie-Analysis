-- 1--
SELECT table_name, table_rows
 FROM INFORMATION_SCHEMA.TABLES
 WHERE TABLE_SCHEMA = 'rsvp';
 
 -- 2--
WITH null_info
	 AS (SELECT 'id' AS 'Column_Name', Count(*) AS Null_Values
         FROM   movies
         WHERE  id IS NULL
         UNION ALL
         SELECT 'title' AS 'Column_Name', Count(*) AS Null_Values
         FROM   movies
         WHERE  title IS NULL
         UNION ALL
         SELECT 'year' AS 'Column_Name', Count(*) AS Null_Values
         FROM   movies
         WHERE  year IS NULL
         UNION ALL
         SELECT 'date_published' AS 'Column_Name', Count(*) AS Null_Values
         FROM   movies
         WHERE  date_published IS NULL
         UNION ALL
         SELECT 'duration' AS 'Column_Name', Count(*) AS Null_Values
         FROM   movies
         WHERE  duration IS NULL
         UNION ALL
         SELECT 'country' AS 'Column_Name', Count(*) AS Null_Values
         FROM   movies
         WHERE  country IS NULL
         UNION ALL
         SELECT 'worlwide_gross_income' AS 'Column_Name', Count(*) AS Null_Values
         FROM   movies
         WHERE  worlwide_gross_income IS NULL
         UNION ALL
         SELECT 'languages' AS 'Column_Name', Count(*) AS Null_Values
         FROM   movies
         WHERE  languages IS NULL
         UNION ALL
         SELECT 'production_company' AS 'Column_Name', Count(*) AS Null_Values
         FROM   movies
         WHERE  production_company IS NULL)
SELECT column_name
FROM   null_info
WHERE Null_Values > 0
ORDER  BY null_values DESC; 

-- 3--
select Year, count(title) as number_of_movies from movies group by Year;

-- 3-- 
SELECT MONTH(date_published) AS month_num, COUNT(id) AS number_of_movies
FROM movies
GROUP BY month_num
ORDER By month_num;

-- 4--
select count(title) as MovieCount from movies
where country = 'USA' or country = 'India' and Year = 2019;
-- 5--
SELECT distinct genre FROM genre order by genre;


SELECT count(movie_id) as ID, genre as GEN FROM genre group by genre;

-- 6--
SELECT g.genre, COUNT(m.id) AS num_of_movie
FROM genre g
INNER JOIN movies m ON g.movie_id = m.id
GROUP BY genre
ORDER BY COUNT(id) DESC
LIMIT 1;

-- 7--
WITH one_genre AS
(
SELECT movie_id, COUNT(distinct genre) AS number_of_genre FROM genre
GROUP BY movie_id
HAVING number_of_genre=1
)
SELECT COUNT(*) AS number_of_movies
FROM one_genre;

-- 8--
select g.genre , (duration) as avg_duration from movies m 
join genre g on g.movie_id=m.id;
-- 8--
select g.genre , avg(duration) as avg_duration from movies m 
join genre g on g.movie_id=m.id
group by genre
order by avg_duration DESC;

-- 9--
With genredetail
As
(select g.genre, count(title) as movie_count,rank() over (order by count(title) desc ) genre_rank from movies m
join genre g on g.movie_id=m.id
-- where genre = 'Thriller'
group by g.genre)
SELECT * from genredetail
where genre = 'Thriller';
-- 10
select min(avg_rating) as min_avg_ratings,max(avg_rating)as max_avg_ratings,
min(total_votes) as min_total_votes ,max(total_votes) as max_total_votes,
min(median_rating) as min_median_rating,max(median_rating) as max_median_rating from ratings;

-- 11--
WITH top_avg_rating_rank
AS
(
SELECT
m.title AS title, r.avg_rating as avg_rating,
DENSE_RANK() OVER(ORDER BY r.avg_rating DESC) movie_rank
FROM movies m
INNER JOIN ratings r
ON m.id = r.movie_id
)
SELECT * FROM top_avg_rating_rank WHERE movie_rank<=10;


-- 12--
select median_rating, count(movie_id) as movie_count from ratings
group by median_rating
order by median_rating
;

-- 13--
With HitProducer
AS
(
select production_company,count(movie_id) as movie_count,
rank() over (order by count(movie_id)) as Prod_comp_rank
from ratings r
inner join movies m
 on r.movie_id = m.id
where r.avg_rating > 8 
group by production_company
)
SELECT * from HitProducer
WHERE Prod_comp_rank = 1
;
-- 14--
SELECT g.genre,
       COUNT(m.id) AS movie_count
FROM genre g
INNER JOIN movies m ON g.movie_id = m.id
INNER JOIN ratings r ON m.id = r.movie_id
WHERE MONTH(m.date_published) = 3
       AND  m.year = 2017
       AND m.country = 'USA'
       AND r.total_votes > 1000
GROUP BY g.genre
ORDER BY movie_count DESC;

-- 15--
select movies.title,ratings.avg_rating, genre.genre from 
movies
inner join ratings on movies.id=ratings.movie_id
inner join genre on movies.id=genre.movie_id
where movies.title like 'the%' and  avg_rating > 8
order by avg_rating desc;


-- 16
SELECT COUNT(id) as MovieReleased from movies m
INNER JOIN ratings r ON m.id = r.movie_id
WHERE r.median_rating = 8 AND date_published BETWEEN '01-04-2018' AND '01-04-2019'
GROUP BY median_rating;
;

-- 17--

select movies.country,sum(ratings.total_votes) as Votes from movies
inner join ratings on movies.id=ratings.movie_id
where movies.country='Germany' or movies.country='Italy'
group by country;

-- 18
SELECT Sum(CASE
             WHEN NAME IS NULL THEN 1
             ELSE 0
           END) AS name_nulls,
       Sum(CASE
             WHEN height IS NULL THEN 1
             ELSE 0
           END) AS height_nulls,
       Sum(CASE
             WHEN date_of_birth IS NULL THEN 1
             ELSE 0
           END) AS date_of_birth_nulls,
       Sum(CASE
             WHEN known_for_movies IS NULL THEN 1
             ELSE 0
           END) AS known_for_movies_nulls
FROM   names; 

-- 19
SELECT n.name AS actor_name,
COUNT(ro.movie_id) AS movie_count FROM role ro
INNER JOIN names n ON n.id = ro.name_id
INNER JOIN ratings r ON r.movie_id = ro.movie_id
WHERE category="actor" AND r.median_rating >= 8
GROUP BY n.name
ORDER BY movie_count DESC
LIMIT 2;

-- 21

SELECT production_company, SUM(total_votes) AS vote_count,
DENSE_RANK() OVER(ORDER BY SUM(total_votes) DESC) AS prod_comp_rank
FROM movies m
INNER JOIN ratings r ON m.id = r.movie_id
GROUP BY production_company
ORDER BY vote_count DESC
LIMIT 3;

-- 22--

WITH ind_actors
     AS (SELECT n.NAME,
                Sum(total_votes) AS total_votes,
                Count(r.movie_id) AS movie_count,
                Round(Sum(total_votes * avg_rating) / Sum(total_votes), 2) AS actor_avg_rating,
                Rank() OVER(ORDER BY Round(Sum(total_votes * avg_rating)/Sum(total_votes), 2) DESC, 
                Sum(total_votes) DESC)  AS actor_rank
         FROM   names n
                INNER JOIN role rm ON n.id = rm.name_id
                INNER JOIN movies m ON rm.movie_id = m.id
                INNER JOIN ratings r ON rm.movie_id = r.movie_id
         WHERE  country = 'India'
         GROUP  BY n.NAME
         HAVING movie_count >= 5)
SELECT * FROM  ind_actors;

-- 23 --

WITH ind_actress
     AS (SELECT n.NAME  AS actress_name,
                Sum(total_votes)   AS  total_votes,
                Count(r.movie_id)  AS movie_count,
                Round(Sum(total_votes * avg_rating) / Sum(total_votes), 2) AS actor_avg_rating,
                Rank() OVER(ORDER BY Round(Sum(total_votes * avg_rating)/Sum(total_votes), 2) DESC,
                Sum(total_votes) DESC)  AS actress_rank
         FROM   names n
                INNER JOIN role rm ON n.id = rm.name_id
                INNER JOIN movies m ON rm.movie_id = m.id
                INNER JOIN ratings r ON rm.movie_id = r.movie_id
         WHERE  country = 'India'
                AND category = 'actress'
                AND languages = 'Hindi'
         GROUP  BY n.NAME
         HAVING movie_count >= 3)
SELECT * FROM   ind_actress
WHERE  actress_rank <= 5;
-- 24 --
SELECT title AS movie_title,
       avg_rating,
       CASE
         WHEN avg_rating > 8 THEN 'Superhit movie'
         WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movie'
         WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movie'
         ELSE 'Flop movie'
       END   Movie_type
FROM   genre g
       INNER JOIN movies m ON g.movie_id = m.id
       INNER JOIN ratings r ON m.id = r.movie_id
WHERE  g.genre = 'Thriller'
ORDER BY movie_title; 

-- 25 -- 


 SELECT     genre,
           Round(Avg(duration))                 AS avg_duration,
           round(sum(Avg(duration)) OVER w1, 1) AS running_total_duration,
           round(avg(avg(duration)) OVER w2, 2) AS moving_avg_duration
FROM       genre g
INNER JOIN movies m
ON         g.movie_id = m.id
GROUP BY   genre 
WINDOW	   w1 AS (ORDER BY genre rows UNBOUNDED PRECEDING),
           w2 AS (ORDER BY genre rows BETWEEN 2 PRECEDING AND 2 following);
-- 27 --
WITH prod_comp_info
     AS (SELECT production_company,
                Count(movie_id) AS movie_count,
                Rank() over(ORDER BY Count(movie_id) DESC) 	AS prod_comp_rank
         FROM   ratings r
				INNER JOIN movies m ON r.movie_id = m.id
         WHERE  production_company IS NOT NULL
                AND median_rating >= 8
                AND Position(',' IN languages) > 0
         GROUP  BY production_company)
SELECT * FROM   prod_comp_info
WHERE  prod_comp_rank <= 2; 

-- 28--

WITH top_actress
     AS (SELECT n.NAME AS actress_name,
                Sum(total_votes) AS total_votes,
                Count(r.movie_id) AS movie_count,
                Round(Sum(total_votes * avg_rating) / Sum(total_votes), 2) 	AS actor_avg_rating,
                Rank() OVER(ORDER BY Count(r.movie_id) DESC)   AS actress_rank
         FROM   names n
                INNER JOIN role rm ON n.id = rm.name_id
                INNER JOIN genre g ON rm.movie_id = g.movie_id
                INNER JOIN ratings r ON rm.movie_id = r.movie_id
         WHERE  category = 'actress'
                AND genre = 'Drama'
                AND avg_rating > 8
         GROUP  BY n.NAME
         )
SELECT * FROM   top_actress
WHERE  actress_rank <= 3;ipjoincsvipjoincsv