-- Q2: How does median price differ by room type?
WITH ranked AS (
    SELECT room_type AS room_type,
           price,
           ROW_NUMBER() OVER (PARTITION BY room_type ORDER BY price) AS rn,
           COUNT(*)     OVER (PARTITION BY room_type)               AS cnt
    FROM listings
),
medians AS (
    SELECT room_type,
           AVG(price) AS median_price
    FROM ranked
    WHERE rn IN ((cnt + 1) / 2, (cnt + 2) / 2)
    GROUP BY room_type
)
SELECT l.room_type              AS room_type,
       COUNT(*)                              AS n_listings,
       m.median_price,
       ROUND(AVG(l.review_scores_rating), 2) AS avg_rating
FROM listings AS l
JOIN medians  AS m ON m.room_type = l.room_type
GROUP BY l.room_type, m.median_price
ORDER BY median_price DESC;