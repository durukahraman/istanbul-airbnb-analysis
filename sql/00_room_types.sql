-- Q0: How many active listings are there per room type?
SELECT room_type,
       COUNT(*) AS n_listings
FROM listings
GROUP BY room_type
ORDER BY n_listings DESC;