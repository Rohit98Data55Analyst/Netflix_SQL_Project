🎬 Netflix Data Analysis using SQL Server
📌 Problem Statement

With the growing content library on Netflix, it becomes challenging to analyze large volumes of data manually. Business users often need insights like the most popular content categories, trends in TV shows vs. movies, top actors, and release patterns. Without proper data cleaning and analysis, deriving such insights is difficult and time-consuming.

🎯 Objective

The objective of this project is to perform data cleaning, transformation, and exploration on the Netflix dataset using SQL Server. The goal is to answer important business questions like:

Which year released the maximum shows?

Who are the top actors in Netflix content?

What are the most popular genres/categories?

How many TV shows have more than 5 seasons?

What are the top countries contributing to Netflix content?

🛠️ Steps Performed

Data Cleaning

Removed NULL values.

Standardized date formats and duration column.

Split multiple values in the listed_in (genres) column into separate rows.

Data Transformation

Extracted numerical values from text fields (e.g., "2 Seasons" → 2).

Used functions like CHARINDEX, SUBSTRING, and PATINDEX for text operations.

Created new derived fields like shift of the day (morning, afternoon, evening).

Data Analysis (Queries Solved)

Find total content released by year and top release years.

Average number of contents released per year by country.

Top actors/actresses in Netflix shows.

Unique genres/categories distribution.

Top 5 years with maximum releases.

TV shows with more than 5 seasons.

📊 Tools & Technology

Database: SQL Server

Language: T-SQL

Functions Used: STRING_SPLIT, SUBSTRING, PATINDEX, DATEDIFF, DATEPART, CHARINDEX, CAST/CONVERT.

✅ Outcome

This project provides ready-to-use SQL queries for Netflix data exploration. Business users can quickly identify trends, content preferences, top actors, and countries contributing to Netflix’s library.
