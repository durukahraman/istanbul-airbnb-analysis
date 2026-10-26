-- Q1: For districts with at least 30 active listings,
--     what are the listing count, median price and average rating?
WITH ranked AS (
    SELECT neighbourhood_cleansed AS district,
           price,
           ROW_NUMBER() OVER (PARTITION BY neighbourhood_cleansed ORDER BY price) AS rn,
           COUNT(*)     OVER (PARTITION BY neighbourhood_cleansed)               AS cnt
    FROM listings
),
medians AS (
    SELECT district,
           AVG(price) AS median_price
    FROM ranked
    WHERE rn IN ((cnt + 1) / 2, (cnt + 2) / 2)
    GROUP BY district
)
SELECT l.neighbourhood_cleansed              AS district,
       COUNT(*)                              AS n_listings,
       m.median_price,
       ROUND(AVG(l.review_scores_rating), 2) AS avg_rating
FROM listings AS l
JOIN medians  AS m ON m.district = l.neighbourhood_cleansed
GROUP BY l.neighbourhood_cleansed, m.median_price
HAVING COUNT(*) >= 30
ORDER BY n_listings DESC;