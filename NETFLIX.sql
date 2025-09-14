-- ****** NETFLIX ADVANCED SQL PROJECT STARTS ******

SELECT * FROM netflix_title;

-- ****** DATA CLEANING STARTS ******

-- ** HOW MANY RECORDS IN GIVEN DATASET **
SELECT COUNT(*)Total_records
FROM netflix_title;

-- ** CHECK IF ANY NULL VALUE IN OUR DATASET STARTS **
SELECT *
FROM netflix_title
WHERE  show_id IS NULL OR type IS NULL 
       OR title IS NULL OR director IS NULL 
	   OR cast IS NULL OR country IS NULL 
	   OR date_added IS NULL OR release_year IS NULL
	   OR rating IS NULL OR duration IS NULL OR listed_in IS NULL
	   OR description IS NULL;

-- ** DELETES RECORDS WITH NULL VALUE **
DELETE FROM netflix_title
WHERE  show_id IS NULL OR type IS NULL 
       OR title IS NULL OR director IS NULL 
	   OR cast IS NULL OR country IS NULL 
	   OR date_added IS NULL OR release_year IS NULL
	   OR rating IS NULL OR duration IS NULL OR listed_in IS NULL
	   OR description IS NULL;
-- ** CHECK IF ANY NULL VALUE IN OUR DATASET ENDS **

-- ** MINIMIZE THE COLUMN'S VALUE'S LENGTH STARTS **
ALTER TABLE netflix_title
ALTER COLUMN description VARCHAR(255);

ALTER TABLE netflix_title
ALTER COLUMN listed_in VARCHAR(100);

ALTER TABLE netflix_title
ALTER COLUMN duration VARCHAR(15);

ALTER TABLE netflix_title
ALTER COLUMN rating VARCHAR(10);

ALTER TABLE netflix_title
ALTER COLUMN release_year INT;

ALTER TABLE netflix_title
ALTER COLUMN country VARCHAR(150);

ALTER TABLE netflix_title
ALTER COLUMN date_added VARCHAR(50);

ALTER TABLE netflix_title
ALTER COLUMN cast VARCHAR(800);

ALTER TABLE netflix_title
ALTER COLUMN director VARCHAR(255);

ALTER TABLE netflix_title
ALTER COLUMN title NVARCHAR(155);

ALTER TABLE netflix_title
ALTER COLUMN type NVARCHAR(20);

-- ** MINIMIZE THE COLUMN'S VALUE'S LENGTH ENDS **

-- ** IN OUR TABLE I HAVE MULTIPLE COUNTRY NAME IN SINGLE CELL , IN ORDER TO SPLIT COUNTRY NAME IN DIFFERENT ROW , I AM GOING TO DO THIS **

-- ** STEP 1:CREATE A NEW TABLE WITH SAME COLUMN NAME **
CREATE TABLE NormalizedTable1 (
    show_id  VARCHAR(15),
    type VARCHAR(20),
    title VARCHAR(155),
	director VARCHAR(255),
	cast VARCHAR(800),
	country VARCHAR(100),
	date_added VARCHAR(50),
	release_year INT,
	 rating VARCHAR(10),
	 duration VARCHAR(30),
	 listed_in VARCHAR(100),
	 description VARCHAR(255)
);

-- ** STEP 2: THEN WE INSERT SPLIT DATA ON NEW TABLE FROM OLD TABLE **
INSERT INTO NormalizedTable1 (show_id,type,title,director,cast,country,date_added,release_year,rating,duration,listed_in,description)
SELECT 
    t.show_id,
    t.type,
    t.title,
	t.director,
	t.cast,
	LTRIM(RTRIM(value)) AS country,
	t.date_added,
	t.release_year,
	t.rating,
	t.duration,
	t.listed_in,
	t.description
   
FROM netflix_title t
CROSS APPLY STRING_SPLIT(t.country, ',');

-- ** STEP 3:  DROP OLD TABLE & RENAME NEW ONE WITH OLD TABLE NAME **
DROP TABLE netflix_title;
EXEC SP_RENAME 'NormalizedTable1', 'netflix_title';



-- ****** DATA CLEANING ENDS ******

-- ****** DATA EXPLORATION STARTS ****** 

-- ** HOW MANY DISTINCT DIRECTORS ARE THERE ? **
SELECT COUNT(DISTINCT(director))Total_directors
FROM netflix_title;

-- ** HOW MANY TYPES OF SHOW ARE THERE ? **
SELECT COUNT(DISTINCT(type))Total_types_show
FROM netflix_title;
SELECT DISTINCT(type)show_types
FROM netflix_title;

-- ** HOW MANY SHOWS ARE RELEASE IN EACH YEAR ? ** 
SELECT release_year, COUNT(release_year)Total_shows
FROM netflix_title
GROUP BY release_year
ORDER BY release_year;

-- ** IN WHICH YEAR MAXIMUM SHOWS ARE RELEASED ? **
SELECT TOP 1 *
FROM (
   SELECT release_year, COUNT(release_year)Total_shows
   FROM netflix_title
   GROUP BY release_year
) AS T1
ORDER BY Total_showS DESC;

-- ****** DATA EXPLORATION ENDS ****** 

-- ****** SOLUTIONS FOR BUSINESS PROBLEMS  STARTS******

--** Q.1. WRITE THE SQL QUERY TO FIND THE NO. OF TV SHOWS AND MOVIES ? **
SELECT type , COUNT(type)Total_show
FROM netflix_title
GROUP BY type ;

-- ** Q.2. FIND THE MOST COMMON RATING FOR TV AND MOVIE ? **
SELECT type,rating,Total_rating
FROM (
        SELECT type,rating, count(rating)Total_rating,
               RANK() OVER(PARTITION BY type ORDER BY count(rating) DESC)AS RANK
        FROM netflix_title
        GROUP BY type,rating
		) AS T1
WHERE rank = 1;

-- ** Q.3. LIST ALL MOVIES RELEASED IN SPECIFIC YEAR(EG. 2020). **
SELECT type , title , release_year 
FROM netflix_title
where release_year = '2020' 
      AND type = 'movie' ;

-- ** Q.4.  FIND THE TOP 5 COUNTRIES WITH THE MOST CONTENT ON NETFLIX. **
SELECT top 5 country , count(country)most_content
FROM netflix_title
GROUP BY country
ORDER BY count(country) DESC;

-- ** Q.5. FIND THE LONGEST MOVIES. **
SELECT TOP 1 type , 
       title, 
	   duration,
       CAST(REPLACE(duration, 'min', '') AS INT) AS duration_in_minutes
FROM netflix_title
WHERE type = 'movie'
ORDER BY  CAST(REPLACE(duration, 'min', '')  AS INT) DESC;


-- ** Q.6. FIND CONTENT ADDED IN THE LAST 5 YEARS . **
SELECT * 
FROM netflix_title
--WHERE YEAR(date_added) > 2016; -- according to data
WHERE date_added >= DATEADD(YEAR, -5, GETDATE()); -- according to current date


--** Q.7. FIND ALL MOVIES/TVs FROM DIRECTOR 'RAJIV CHILAKA'.
SELECT type as Movies_TVs ,title,director
FROM netflix_title
WHERE director LIKE '%Rajiv chilaka%';


-- ** Q.8. LIST ALL TVs SHOWS WITH MORE THAN 5 SEASONS **
SELECT  *
FROM netflix_title
WHERE type ='TV Show' AND 
     CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1 ) AS INT) > 5 ;

--Q.9. ** COUNT THE NUMBER OF CONTENTS IN EACH GENRE .**
SELECT listed_in , 
       COUNT(listed_in)No_of_Content
FROM
   (
   SELECT 
         LTRIM(RTRIM(VALUE)) AS listed_in
   FROM netflix_title t
   CROSS APPLY STRING_SPLIT(t.listed_in,',')
   ) AS T1
GROUP BY listed_in
ORDER BY No_of_Content DESC;

-- ** Q.10. FIND THE EACH YEAR AND AVERAGE NO. OF CONTENTS RELEASED BY THE INDIA ON NETFLIX .RETURN TOP 5 YEARS FOR AVERAGE NO. OF CONTENT **
SELECT release_year ,
           COUNT(release_year)Total_contents
FROM netflix_title
WHERE country = 'India'
GROUP BY release_year ;

-- ** AVG NO. OF CONTENT RELEASED BY INDIA IS **

SELECT
       AVG(Total_contents)avg_contents_of_all_year
FROM(
       SELECT release_year ,
           COUNT(release_year)Total_contents
       FROM netflix_title
       WHERE country = 'India'
       GROUP BY release_year
   ) T1
   ;

-- ** RETURNS OF TOP 5 YEARS AVG CONTENT FOR INDIA **
SELECT
       AVG(Total_contents)top_5year_avg_contents
FROM(
       SELECT TOP 5 release_year ,
           COUNT(release_year)Total_contents
       FROM netflix_title
       WHERE country = 'India'
       GROUP BY release_year
	   ORDER BY Total_contents DESC
   ) T1
   ;


-- ** Q.11. LIST ALL THE MOVIES WHICH ARE DOCUMENTRIES . **
SELECT t.type,t.title,
       LTRIM(RTRIM(VALUE)) AS listed_in
FROM netflix_title t
CROSS APPLY STRING_SPLIT(t.listed_in,',') 
WHERE listed_in = 'Documentaries';

-- ** Q.12. HOW MANY MOVIES ACTOR SALMAAN KHAN APPEARS IN LAST 10 YEARS? **
exec sp_rename 'netflix_title.cast' , 'casting' , 'column';
SELECT * 
FROM netflix_title 
WHERE casting LIKE '%Salman Khan%' -- WE CAN'T USE CAST COLUMN NAME HERE BECAUSE CAST IS THE CLAUSE IN SQL SERVER 
      AND DATEDIFF(YEAR, date_added, GETDATE()) <= 10; 

-- ** Q.13. FIND THE TOP 10 ACTORS WHO PRODUCES THE HIGHEST NO. OF MOVIES IN INDIA .
SELECT TOP 10
       LTRIM(RTRIM(VALUE)) AS Actors,
	   count(*)as Total_Movies
FROM netflix_title as t
CROSS APPLY STRING_SPLIT(t.casting,',')
WHERE type = 'Movie' AND country = 'India'
GROUP BY  LTRIM(RTRIM(VALUE))
order by Total_Movies DESC;

-- ** Q. 14. CATEGORISE THE DATA BASED ON "kill" and "violence" WORDS IN THE DESCRIPTION COLUMN . 
--- LABEL CONTENT CONTIANING THESE KEYWORDS AS 'BAD' AND OTHER AS 'GOOD' .  COUNT HOW MANY CONTENT FALL IN EACH CATEGORY . **
SELECT Category_of_Content,
       COUNT(*)AS Total_contents
FROM (
       SELECT CASE
                WHEN description like '%kill%' OR description like '%violence%' THEN 'Bad'
		        ELSE 'Good'
             END AS Category_of_Content
       FROM netflix_title
	   ) AS T
GROUP BY Category_of_Content ;
-- ****** SOLUTIONS FOR BUSINESS PROBLEMS  ENDS ******
