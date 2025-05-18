-- Non-Correlated Subquery : To find all properties where the average rating is greater than 4.0
SELECT 
    property_id, 
    property_name
FROM 
    properties
WHERE 
    property_id IN (
        SELECT 
            property_id
        FROM 
            reviews
        GROUP BY 
            property_id
        HAVING 
            AVG(rating) > 4.0
    );


-- Correlated Subquery : To find users who have made more than 3 bookings
-- Script: property_rankings.sql
-- Purpose: Use window functions to rank properties by number of bookings

-- Using RANK() to allow for ties in booking counts
SELECT 
    property_id,
    property_name,
    total_bookings,
    RANK() OVER (ORDER BY total_bookings DESC) AS booking_rank
FROM (
    SELECT 
        p.property_id,
        p.property_name,
        COUNT(b.booking_id) AS total_bookings
    FROM 
        properties p
    LEFT JOIN 
        bookings b ON p.property_id = b.property_id
    GROUP BY 
        p.property_id, p.property_name
) AS property_summary_with_rank;

-- ------------------------------------------------------------

-- Using ROW_NUMBER() for strict unique ranking
SELECT 
    property_id,
    property_name,
    total_bookings,
    ROW_NUMBER() OVER (ORDER BY total_bookings DESC) AS booking_rank
FROM (
    SELECT 
        p.property_id,
        p.property_name,
        COUNT(b.booking_id) AS total_bookings
    FROM 
        properties p
    LEFT JOIN 
        bookings b ON p.property_id = b.property_id
    GROUP BY 
        p.property_id, p.property_name
) AS property_summary_with_row_number;
