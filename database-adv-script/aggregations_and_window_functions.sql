-- Rank properties using RANK() - allows ties
SELECT 
    property_id,
    property_name,
    total_bookings,
    RANK() OVER (ORDER BY total_bookings DESC) AS rank_position
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
) AS ranked_properties;

-- --------------------------------------------------

-- Rank properties using ROW_NUMBER() - no ties, strict ordering
SELECT 
    property_id,
    property_name,
    total_bookings,
    ROW_NUMBER() OVER (ORDER BY total_bookings DESC) AS row_number_position
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
) AS row_numbered_properties;
