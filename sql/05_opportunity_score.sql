-- Q5: Which districts offer the best revenue potential for entire homes?
--     opportunity_score = price_index x demand_index (Istanbul = 1.00)
WITH entire AS (
    SELECT *
    FROM listings
    WHERE room_type = 'Entire home/apt'
),
ranked AS (
    SELECT neighbourhood_cleansed AS district,
           price,
           ROW_NUMBER() OVER (PARTITION BY neighbourhood_cleansed ORDER BY price) AS rn,
           COUNT(*)     OVER (PARTITION BY neighbourhood_cleansed)               AS cnt
    FROM entire
),
medians AS (
    SELECT district,
           AVG(price) AS median_price
    FROM ranked
    WHERE rn IN ((cnt + 1) / 2, (cnt + 2) / 2)
    GROUP BY district
),
city_ranked AS (
    SELECT price,
           ROW_NUMBER() OVER (ORDER BY price) AS rn,
           COUNT(*)     OVER ()               AS cnt
    FROM entire
),
city AS (
    SELECT (SELECT AVG(price) FROM city_ranked
            WHERE rn IN ((cnt + 1) / 2, (cnt + 2) / 2)) AS city_median_price,
           (SELECT AVG(number_of_reviews_ltm) FROM entire) AS city_avg_reviews
),
district_stats AS (
    SELECT e.neighbourhood_cleansed      AS district,
           COUNT(*)                      AS n_listings,
           m.median_price,
           AVG(e.number_of_reviews_ltm)  AS avg_reviews_ltm,
           AVG(e.review_scores_rating)   AS avg_rating
    FROM entire  AS e
    JOIN medians AS m ON m.district = e.neighbourhood_cleansed
    GROUP BY e.neighbourhood_cleansed, m.median_price
    HAVING COUNT(*) >= 30
),
scored AS (
    SELECT d.*,
           d.median_price    / c.city_median_price AS price_index,
           d.avg_reviews_ltm / c.city_avg_reviews  AS demand_index
    FROM district_stats AS d
    CROSS JOIN city     AS c
)
SELECT RANK() OVER (ORDER BY price_index * demand_index DESC) AS score_rank,
       district,
       n_listings,
       ROUND(median_price)                    AS median_price,
       ROUND(avg_reviews_ltm, 1)              AS avg_reviews_ltm,
       ROUND(avg_rating, 2)                   AS avg_rating,
       ROUND(price_index, 2)                  AS price_index,
       ROUND(demand_index, 2)                 AS demand_index,
       ROUND(price_index * demand_index, 2)   AS opportunity_score
FROM scored
ORDER BY score_rank;
