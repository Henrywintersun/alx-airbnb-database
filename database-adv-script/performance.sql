
-- Initial Complex Query with Multiple Joins
-- This query retrieves all bookings with user details, property details, and payment information

-- Original Complex Query
EXPLAIN ANALYZE
SELECT 
    b.id AS booking_id,
    b.check_in_date,
    b.check_out_date,
    b.status,
    b.created_at AS booking_date,
    u.id AS user_id,
    u.name AS user_name,
    u.email AS user_email,
    u.phone AS user_phone,
    p.id AS property_id,
    p.title AS property_title,
    p.description AS property_description,
    p.price AS property_price,
    p.location AS property_location,
    p.property_type,
    p.max_guests,
    pm.id AS payment_id,
    pm.amount AS payment_amount,
    pm.payment_date,
    pm.payment_method,
    pm.status AS payment_status,
    pr.id AS review_id,
    pr.rating,
    pr.comment AS review_comment,
    pr.created_at AS review_date
FROM 
    bookings b
LEFT JOIN 
    users u ON b.user_id = u.id
LEFT JOIN 
    properties p ON b.property_id = p.id
LEFT JOIN 
    payments pm ON b.id = pm.booking_id
LEFT JOIN 
    property_reviews pr ON b.id = pr.booking_id
WHERE 
    b.created_at >= '2025-01-01'
ORDER BY 
    b.created_at DESC;

-- Performance Analysis:
-- The above query has several potential performance issues:
-- 1. Multiple LEFT JOINs can be expensive, especially with large tables
-- 2. We're retrieving ALL columns from multiple large tables
-- 3. The WHERE clause on created_at needs appropriate indexing
-- 4. The ORDER BY could be slow without proper indexing
-- 5. The property_reviews join might be unnecessary in many cases

-- ===============================================
-- OPTIMIZED QUERY 1: Basic Optimization
-- ===============================================

-- Refactored Query - Basic Optimization
EXPLAIN ANALYZE
SELECT 
    b.id AS booking_id,
    b.check_in_date,
    b.check_out_date,
    b.status,
    b.created_at AS booking_date,
    u.id AS user_id,
    u.name AS user_name,
    u.email AS user_email,
    p.id AS property_id,
    p.title AS property_title,
    p.location AS property_location,
    p.price AS property_price,
    pm.id AS payment_id,
    pm.amount AS payment_amount,
    pm.payment_method,
    pm.status AS payment_status
FROM 
    bookings b
INNER JOIN 
    users u ON b.user_id = u.id
INNER JOIN 
    properties p ON b.property_id = p.id
LEFT JOIN 
    payments pm ON b.id = pm.booking_id
WHERE 
    b.created_at >= '2025-01-01'
ORDER BY 
    b.created_at DESC;

-- Optimization notes:
-- 1. Changed unnecessary LEFT JOINs to INNER JOINs where appropriate (users and properties)
-- 2. Removed the property_reviews join completely
-- 3. Selected only the specific columns we need rather than all columns
-- 4. Kept the LEFT JOIN for payments as some bookings might not have payments

-- ===============================================
-- OPTIMIZED QUERY 2: Using Windowing Function
-- ===============================================

-- Further Optimization - Using Windowing for Latest Payment Only
EXPLAIN ANALYZE
WITH ranked_payments AS (
    SELECT 
        booking_id,
        id AS payment_id,
        amount AS payment_amount,
        payment_method,
        status AS payment_status,
        ROW_NUMBER() OVER (PARTITION BY booking_id ORDER BY payment_date DESC) AS rn
    FROM 
        payments
)
SELECT 
    b.id AS booking_id,
    b.check_in_date,
    b.check_out_date,
    b.status,
    b.created_at AS booking_date,
    u.id AS user_id,
    u.name AS user_name,
    u.email AS user_email,
    p.id AS property_id,
    p.title AS property_title,
    p.location AS property_location,
    p.price AS property_price,
    rp.payment_id,
    rp.payment_amount,
    rp.payment_method,
    rp.payment_status
FROM 
    bookings b
INNER JOIN 
    users u ON b.user_id = u.id
INNER JOIN 
    properties p ON b.property_id = p.id
LEFT JOIN 
    ranked_payments rp ON b.id = rp.booking_id AND rp.rn = 1
WHERE 
    b.created_at >= '2025-01-01'
ORDER BY 
    b.created_at DESC
LIMIT 100;  -- Adding a LIMIT is usually good practice for large result sets

-- Optimization notes:
-- 1. Used a CTE with windowing function to get only the most recent payment per booking
-- 2. Added a LIMIT clause to restrict the result set size
-- 3. Kept only the essential columns needed for the business logic

-- ===============================================
-- OPTIMIZED QUERY 3: Using Pagination
-- ===============================================

-- Even better optimization - Adding pagination with keyset pagination
EXPLAIN ANALYZE
WITH ranked_payments AS (
    SELECT 
        booking_id,
        id AS payment_id,
        amount AS payment_amount,
        payment_method,
        status AS payment_status,
        ROW_NUMBER() OVER (PARTITION BY booking_id ORDER BY payment_date DESC) AS rn
    FROM 
        payments
)
SELECT 
    b.id AS booking_id,
    b.check_in_date,
    b.check_out_date,
    b.status,
    b.created_at AS booking_date,
    u.id AS user_id,
    u.name AS user_name,
    u.email AS user_email,
    p.id AS property_id,
    p.title AS property_title,
    p.location AS property_location,
    p.price AS property_price,
    rp.payment_id,
    rp.payment_amount,
    rp.payment_method,
    rp.payment_status
FROM 
    bookings b
INNER JOIN 
    users u ON b.user_id = u.id
INNER JOIN 
    properties p ON b.property_id = p.id
LEFT JOIN 
    ranked_payments rp ON b.id = rp.booking_id AND rp.rn = 1
WHERE 
    b.created_at >= '2025-01-01'
    AND b.created_at < '2025-02-01'  -- Narrowing the date range
    AND (b.created_at, b.id) < ('2025-01-15', 5000)  -- Keyset pagination
ORDER BY 
    b.created_at DESC, b.id DESC
LIMIT 50;

-- Optimization notes:
-- 1. Added keyset pagination which is more efficient than OFFSET/LIMIT pagination
-- 2. Narrowed the date range to reduce the result set
-- 3. Limited to 50 results per "page"
-- 4. Added secondary ordering column (id) to ensure deterministic ordering
-- 5. For production, you would replace the keyset values with parameters

-- ===============================================
-- Recommended Indexes to Support These Queries
-- ===============================================

-- Add these indexes to support the optimized queries above
CREATE INDEX idx_bookings_created_at ON bookings (created_at DESC);
CREATE INDEX idx_bookings_pagination ON bookings (created_at DESC, id DESC);
CREATE INDEX idx_bookings_user_id ON bookings (user_id);
CREATE INDEX idx_bookings_property_id ON bookings (property_id);
CREATE INDEX idx_payments_booking_id_date ON payments (booking_id, payment_date DESC);

-- ===============================================
-- Performance Measurement
-- ===============================================

-- You can compare the execution plans before and after optimization
-- The key metrics to watch for are:
-- 1. Total execution time
-- 2. Number of rows processed
-- 3. Whether the query is using indexes effectively (look for "Index Scan" vs "Seq Scan")
-- 4. Join algorithms used (Hash Join, Nested Loop, etc.)
-- 5. Estimated costs

-- Monitor real-world performance by adding this before and after your queries:
-- \timing on

-- For production use, consider:
-- 1. Using prepared statements with parameters
-- 2. Implementing proper caching strategies
-- 3. Adding appropriate field-level indexes based on actual query patterns
-- 4. Using materialized views for complex aggregations that don't change frequently
