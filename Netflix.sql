DROP TABLE

IF EXISTS "netflix";
	CREATE TABLE "netflix" (
		show_id VARCHAR(6)
		,"type" VARCHAR(10)
		,title VARCHAR(150)
		,director VARCHAR(208)
		,"cast" VARCHAR(1000)
		,country VARCHAR(150)
		,date_added VARCHAR(50)
		,release_year INT
		,rating VARCHAR(10)
		,duration VARCHAR(15)
		,listed_in VARCHAR(90)
		,description VARCHAR(250)
		);

SELECT *
FROM netflix LIMIT 10;

-- 1.  Count the number of movies vs tv shows. ALso show them as percentage of total
SELECT type
	,COUNT(*) AS Total_count
	,(ROUND(COUNT(*) / SUM(COUNT(*)) OVER (), 2) * 100)::INT AS percentage_total
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;

---------------------------------------------------------------------
---------------------------------------------------------------------

-- 2. Find the most common rating for the movies and tv shows
SELECT type
	,rating
FROM (
	SELECT type
		,rating
		,count(*) AS total_
		,ROW_NUMBER() OVER (
			PARTITION BY type ORDER BY count(*) DESC
			)
	FROM netflix
	GROUP BY 1
		,2
	ORDER BY 1
		,3 DESC
	) t1
WHERE row_number = 1

SELECT rating
	,COUNT(*)
FROM netflix
GROUP BY 1
ORDER BY 2 DESC LIMIT 1;

---------------------------------------------------------------------
---------------------------------------------------------------------

-- 3. List all the movies that released in 2020
SELECT title
FROM netflix
WHERE type = 'Movie'
	AND release_year = 2020

---------------------------------------------------------------------
---------------------------------------------------------------------

-- 4. Find the top 5 countries with most content on netflix
SELECT country_
	,count(*)
FROM (
	SELECT show_id
		,regexp_split_to_table(country, ', ') AS country_
	FROM netflix
	) t1
GROUP BY 1
ORDER BY 2 DESC LIMIT 5;

---------------------------------------------------------------------
---------------------------------------------------------------------

-- 5. Movies with the highest duration
SELECT title
	,duration
FROM netflix
WHERE type = 'Movie'
	AND SPLIT_PART(duration, ' ', 1) = (
		SELECT MAX(SPLIT_PART(duration, ' ', 1))
		FROM netflix
		WHERE type = 'Movie'
		)

---------------------------------------------------------------------
---------------------------------------------------------------------

-- 6. Content added in last 5 years
SELECT title
	,date_added::DATE
FROM netflix
WHERE date_added IS NOT NULL
	AND date_added::DATE > CURRENT_DATE - INTERVAL '5' year
ORDER BY 2

---------------------------------------------------------------------
---------------------------------------------------------------------

-- 7. All the movies / shows directed by ' Rajiv Chilaka'
SELECT title
	,director
FROM netflix
WHERE director ILIKE '%RAJIV Chilaka%'

---------------------------------------------------------------------
---------------------------------------------------------------------

-- 8. All the shows with more than 5 seasons
SELECT title
	,duration
FROM netflix
WHERE type LIKE '%TV%'
	AND Split_part(duration, ' ', 1)::INT > 5

---------------------------------------------------------------------
---------------------------------------------------------------------

-- 9. Count the number of content items in each genre
SELECT genre
	,count(*)
FROM (
	SELECT title
		,TRIM(regexp_split_to_table(listed_in, ',')) AS genre
	FROM netflix
	) t1
GROUP BY 1
ORDER BY 2 DESC

---------------------------------------------------------------------
---------------------------------------------------------------------

-- 10. For each year, Find what percentage of content released that year for India.
SELECT DATE_PART('year', date_added::DATE)
	,COUNT(*) AS total_content
	,ROUND((count(*) / (SUm(COunt(*)) OVER ())) * 100, 2) AS per_total
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 1 DESC

---------------------------------------------------------------------
---------------------------------------------------------------------

-- 11. List all the movies which are documentaries
SELECT title
	,listed_in
FROM netflix
WHERE listed_in ILIKE '%Docu%'
	AND type ILIKE '%Movie%'

---------------------------------------------------------------------
---------------------------------------------------------------------

-- 12. In how many movies did salman khan act in last 10 years
SELECT title
FROM netflix
WHERE "cast" ILIKE '%Salman%Khan%'
	AND release_year > DATE_PART('year', CURRENT_DATE)::INT - 10

---------------------------------------------------------------------
---------------------------------------------------------------------

--13. Top 10 actors who have appreared in the highest number of movies produced in India.
SELECT *
FROM netflix LIMIT 10;

SELECT cast_
	,count(*) AS total_movies
FROM (
	SELECT show_id
		,regexp_split_to_table("cast", ', ') AS cast_
	FROM netflix
	WHERE country ILIKE '%India%'
		AND type = 'Movie'
	) t1
GROUP BY 1
ORDER BY 2 DESC LIMIT 10;

---------------------------------------------------------------------
---------------------------------------------------------------------

-- 14.If we categories movies containing killing or violence as "bad" and the rest as "Good", how many movies make up each category.
SELECT category
	,count(*) as total
	,ROUND((count(*) / SUM(COUNT(*)) OVER () * 100), 2) as percentage
FROM (
	SELECT title
		,CASE 
			WHEN description ILIKE '%kill%'
				OR description ILIKE '%violence%'
				THEN 'Bad'
			ELSE 'Good'
			END category
	FROM netflix
	) t1
GROUP BY 1
ORDER BY 2 DESC