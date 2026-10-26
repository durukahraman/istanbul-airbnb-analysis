-- Q3: Do superhosts earn higher prices and ratings? (entire homes only)
WITH ranked AS (
    SELECT host_is_superhost,
           price,
           ROW_NUMBER() OVER (PARTITION BY host_is_superhost ORDER BY price) AS rn,
           COUNT(*)     OVER (PARTITION BY host_is_superhost)               AS cnt
    FROM listings
    WHERE room_type = 'Entire home/apt'          
),
medians AS (
    SELECT host_is_superhost,
           AVG(price) AS median_price
    FROM ranked
    WHERE rn IN ((cnt + 1) / 2, (cnt + 2) / 2)
    GROUP BY host_is_superhost
)
SELECT l.host_is_superhost,
       COUNT(*)                              AS n_listings,
       m.median_price,
       ROUND(AVG(l.review_scores_rating), 2) AS avg_rating
FROM listings AS l
JOIN medians  AS m ON m.host_is_superhost = l.host_is_superhost
WHERE l.room_type = 'Entire home/apt'          
  AND l.host_is_superhost IS NOT NULL           
GROUP BY l.host_is_superhost, m.median_price
ORDER BY m.median_price DESC;