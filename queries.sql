-- ============================================================
-- Movie Recommendation System - SQL Queries
-- Database: movies_db | Table: movies_data
-- Dataset: TMDB 5000 Movies | Platform: Amazon Athena
-- ============================================================


-- ------------------------------------------------------------
-- 1. CREATE TABLE
-- Drop and recreate table with OpenCSVSerde to handle
-- JSON fields embedded inside CSV columns
-- ------------------------------------------------------------

DROP TABLE IF EXISTS movies_data;

CREATE EXTERNAL TABLE movies_data (
  budget              STRING,
  genres              STRING,
  homepage            STRING,
  id                  STRING,
  keywords            STRING,
  original_language   STRING,
  original_title      STRING,
  overview            STRING,
  popularity          STRING,
  production_companies STRING,
  production_countries STRING,
  release_date        STRING,
  revenue             STRING,
  runtime             STRING,
  spoken_languages    STRING,
  status              STRING,
  tagline             STRING,
  title               STRING,
  vote_average        STRING,
  vote_count          STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar'     = '"',
  'escapeChar'    = '\\'
)
STORED AS TEXTFILE
LOCATION 's3://movie-reco-riya-18/raw/'
TBLPROPERTIES ('skip.header.line.count'='1');


-- ------------------------------------------------------------
-- 2. VERIFY TABLE
-- Check that data loaded correctly
-- ------------------------------------------------------------

SELECT * FROM movies_data LIMIT 10;


-- ------------------------------------------------------------
-- 3. CHECK A SPECIFIC MOVIE
-- View genres and keywords for any movie
-- Replace 'Avatar' with any movie title
-- ------------------------------------------------------------

SELECT title, genres, keywords
FROM movies_data
WHERE title = 'Avatar';


-- ------------------------------------------------------------
-- 4. CONTENT-BASED RECOMMENDATION QUERY
-- Recommends top 10 movies similar to 'Avatar'
-- Scoring based on matching genres and keywords
-- Higher score = more similar to the target movie
--
-- HOW TO USE FOR A DIFFERENT MOVIE:
--   Step 1: Run query #3 above to get its genres and keywords
--   Step 2: Replace 'Avatar' in WHERE clause with your movie
--   Step 3: Update the LIKE patterns to match new genres/keywords
-- ------------------------------------------------------------

SELECT
    title,
    vote_average,
    release_date,
    (
      CASE WHEN genres   LIKE '%Action%'           THEN 1 ELSE 0 END +
      CASE WHEN genres   LIKE '%Adventure%'        THEN 1 ELSE 0 END +
      CASE WHEN genres   LIKE '%Fantasy%'          THEN 1 ELSE 0 END +
      CASE WHEN genres   LIKE '%Science Fiction%'  THEN 1 ELSE 0 END +
      CASE WHEN keywords LIKE '%space%'            THEN 1 ELSE 0 END +
      CASE WHEN keywords LIKE '%alien%'            THEN 1 ELSE 0 END +
      CASE WHEN keywords LIKE '%futuristic%'       THEN 1 ELSE 0 END +
      CASE WHEN keywords LIKE '%battle%'           THEN 1 ELSE 0 END +
      CASE WHEN keywords LIKE '%soldier%'          THEN 1 ELSE 0 END
    ) AS similarity_score
FROM movies_data
WHERE title != 'Avatar'
HAVING (
      CASE WHEN genres   LIKE '%Action%'           THEN 1 ELSE 0 END +
      CASE WHEN genres   LIKE '%Adventure%'        THEN 1 ELSE 0 END +
      CASE WHEN genres   LIKE '%Fantasy%'          THEN 1 ELSE 0 END +
      CASE WHEN genres   LIKE '%Science Fiction%'  THEN 1 ELSE 0 END +
      CASE WHEN keywords LIKE '%space%'            THEN 1 ELSE 0 END +
      CASE WHEN keywords LIKE '%alien%'            THEN 1 ELSE 0 END +
      CASE WHEN keywords LIKE '%futuristic%'       THEN 1 ELSE 0 END +
      CASE WHEN keywords LIKE '%battle%'           THEN 1 ELSE 0 END +
      CASE WHEN keywords LIKE '%soldier%'          THEN 1 ELSE 0 END
    ) >= 2
ORDER BY similarity_score DESC, CAST(vote_average AS DOUBLE) DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 5. TOP RATED MOVIES OVERALL
-- Simple query to find highest rated movies in dataset
-- ------------------------------------------------------------

SELECT title, vote_average, vote_count, release_date
FROM movies_data
WHERE CAST(vote_count AS INT) > 500
ORDER BY CAST(vote_average AS DOUBLE) DESC
LIMIT 20;


-- ------------------------------------------------------------
-- 6. MOST POPULAR MOVIES
-- Ranked by popularity score
-- ------------------------------------------------------------

SELECT title, popularity, revenue, runtime
FROM movies_data
ORDER BY CAST(popularity AS DOUBLE) DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 7. SHOW TABLE DEFINITION
-- View the full CREATE TABLE statement Athena is using
-- ------------------------------------------------------------

SHOW CREATE TABLE movies_data;
