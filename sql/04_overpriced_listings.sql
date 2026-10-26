-- Q4: In each district, what share of listings are priced above
--     the district median but rated below the district average?
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
),
scored AS (
    SELECT l.neighbourhood_cleansed AS district,
           l.price,
           l.review_scores_rating,
           m.median_price,
           AVG(l.review_scores_rating) OVER (PARTITION BY l.neighbourhood_cleansed) AS district_avg_rating,
           COUNT(*)                    OVER (PARTITION BY l.neighbourhood_cleansed) AS district_n
    FROM listings AS l
    JOIN medians  AS m ON m.district = l.neighbourhood_cleansed
)
SELECT district,
       district_n                              AS n_listings,
       COUNT(*)                                AS n_overpriced,
       ROUND(100.0 * COUNT(*) / district_n, 1) AS pct_overpriced
FROM scored
WHERE price > median_price
  AND review_scores_rating < district_avg_rating
  AND district_n >= 30
GROUP BY district, district_n
ORDER BY pct_overpriced DESC;