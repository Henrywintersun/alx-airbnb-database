
-- ============================================================================
-- IMPLEMENTING TABLE PARTITIONING FOR THE BOOKING TABLE
-- ============================================================================

-- Assuming PostgreSQL as the database system
-- This script implements range partitioning by date (quarter)

-- 1. Create a new partitioned table
CREATE TABLE bookings_partitioned (
    id SERIAL,
    user_id INTEGER NOT NULL,
    property_id INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    guests INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    special_requests TEXT,
    PRIMARY KEY (id, start_date)
) PARTITION BY RANGE (start_date);

-- 2. Create partitions by quarter (assuming we need data from 2023-2026)
-- 2023 Quarters
CREATE TABLE bookings_2023_q1 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2023-01-01') TO ('2023-04-01');
    
CREATE TABLE bookings_2023_q2 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2023-04-01') TO ('2023-07-01');
    
CREATE TABLE bookings_2023_q3 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2023-07-01') TO ('2023-10-01');
    
CREATE TABLE bookings_2023_q4 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2023-10-01') TO ('2024-01-01');

-- 2024 Quarters
CREATE TABLE bookings_2024_q1 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');
    
CREATE TABLE bookings_2024_q2 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');
    
CREATE TABLE bookings_2024_q3 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2024-07-01') TO ('2024-10-01');
    
CREATE TABLE bookings_2024_q4 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2024-10-01') TO ('2025-01-01');

-- 2025 Quarters (current year)
CREATE TABLE bookings_2025_q1 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2025-01-01') TO ('2025-04-01');
    
CREATE TABLE bookings_2025_q2 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2025-04-01') TO ('2025-07-01');
    
CREATE TABLE bookings_2025_q3 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2025-07-01') TO ('2025-10-01');
    
CREATE TABLE bookings_2025_q4 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2025-10-01') TO ('2026-01-01');

-- 2026 Quarters (future bookings)
CREATE TABLE bookings_2026_q1 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2026-01-01') TO ('2026-04-01');
    
CREATE TABLE bookings_2026_q2 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2026-04-01') TO ('2026-07-01');
    
CREATE TABLE bookings_2026_q3 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2026-07-01') TO ('2026-10-01');
    
CREATE TABLE bookings_2026_q4 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2026-10-01') TO ('2027-01-01');

-- 3. Create a default partition for any data outside our defined ranges
CREATE TABLE bookings_default PARTITION OF bookings_partitioned DEFAULT;

-- 4. Create indexes on each partition for better performance
-- Note: With partitioning, indexes should be created on each partition
-- This will be done automatically when creating an index on the parent table

-- Create indexes on the parent table (will be inherited by all partitions)
CREATE INDEX idx_bookings_part_user_id ON bookings_partitioned(user_id);
CREATE INDEX idx_bookings_part_property_id ON bookings_partitioned(property_id);
CREATE INDEX idx_bookings_part_status ON bookings_partitioned(status);
CREATE INDEX idx_bookings_part_date_range ON bookings_partitioned(start_date, end_date);
CREATE INDEX idx_bookings_part_created_at ON bookings_partitioned(created_at);

-- 5. Migrating existing data (assuming we have an existing bookings table)
-- For a large table, we would migrate data in smaller batches to avoid locking
-- This is just a sample - in production you'd likely use a more sophisticated migration strategy

-- Example of migrating a single quarter's data:
INSERT INTO bookings_partitioned 
    (id, user_id, property_id, start_date, end_date, status, 
     total_price, guests, created_at, updated_at, special_requests)
SELECT 
    id, user_id, property_id, start_date, end_date, status, 
    total_price, guests, created_at, updated_at, special_requests
FROM 
    bookings
WHERE 
    start_date >= '2023-01-01' AND start_date < '2023-04-01';

-- 6. Add foreign key constraints after data migration
ALTER TABLE bookings_partitioned 
    ADD CONSTRAINT fk_bookings_part_user_id 
    FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE bookings_partitioned 
    ADD CONSTRAINT fk_bookings_part_property_id 
    FOREIGN KEY (property_id) REFERENCES properties(id);

-- ============================================================================
-- PERFORMANCE TESTING QUERIES
-- ============================================================================

-- 1. Query to test performance before partitioning (on original table)
EXPLAIN ANALYZE
SELECT *
FROM bookings
WHERE start_date BETWEEN '2025-05-01' AND '2025-05-31'
ORDER BY start_date;

-- 2. The same query on the partitioned table
EXPLAIN ANALYZE
SELECT *
FROM bookings_partitioned
WHERE start_date BETWEEN '2025-05-01' AND '2025-05-31'
ORDER BY start_date;

-- 3. Test query for retrieving data across multiple partitions
EXPLAIN ANALYZE
SELECT *
FROM bookings_partitioned
WHERE start_date BETWEEN '2025-03-15' AND '2025-07-15'  -- Spans Q1 and Q2
ORDER BY start_date;

-- 4. Test query for filtering by date and other columns
EXPLAIN ANALYZE
SELECT 
    b.id, b.start_date, b.end_date, b.status, b.total_price,
    u.name as user_name, p.title as property_title
FROM 
    bookings_partitioned b
JOIN 
    users u ON b.user_id = u.id
JOIN 
    properties p ON b.property_id = p.id
WHERE 
    b.start_date BETWEEN '2025-05-01' AND '2025-05-31'
    AND b.status = 'confirmed'
ORDER BY 
    b.start_date;

-- 5. Test aggregation query
EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('month', start_date) as booking_month,
    COUNT(*) as total_bookings,
    SUM(total_price) as total_revenue,
    AVG(total_price) as avg_booking_value
FROM 
    bookings_partitioned
WHERE 
    start_date BETWEEN '2025-01-01' AND '2025-12-31'
    AND status = 'completed'
GROUP BY 
    DATE_TRUNC('month', start_date)
ORDER BY 
    booking_month;

-- ============================================================================
-- PARTITION MAINTENANCE
-- ============================================================================

-- Creating new partitions for future quarters (example)
CREATE TABLE bookings_2027_q1 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2027-01-01') TO ('2027-04-01');

-- Detaching old partitions (example)
-- ALTER TABLE bookings_partitioned DETACH PARTITION bookings_2023_q1;

-- Moving old data to archive (example)
-- CREATE TABLE bookings_archive_2023_q1 (LIKE bookings_2023_q1 INCLUDING ALL);
-- INSERT INTO bookings_archive_2023_q1 SELECT * FROM bookings_2023_q1;
-- DROP TABLE bookings_2023_q1;

-- Automatic partition creation using a function (PostgreSQL 11+)
-- This is just a conceptual example - implementation would depend on your specific needs
/*
CREATE OR REPLACE FUNCTION create_future_booking_partitions()
RETURNS void AS $$
DECLARE
    next_quarter date;
    partition_name text;
    start_date date;
    end_date date;
BEGIN
    -- Get the latest partition end date
    SELECT MAX(pg_catalog.pg_get_expr(relpartbound, c.oid))
    INTO end_date
    FROM pg_catalog.pg_class c
    JOIN pg_catalog.pg_inherits i ON c.oid = i.inhrelid
    JOIN pg_catalog.pg_class p ON i.inhparent = p.oid
    WHERE p.relname = 'bookings_partitioned';
    
    -- Create next partition
    next_quarter := end_date;
    start_date := next_quarter;
    end_date := start_date + interval '3 months';
    partition_name := 'bookings_' || to_char(start_date, 'YYYY') || '_q' || 
                     EXTRACT(QUARTER FROM start_date)::text;
    
    EXECUTE format(
        'CREATE TABLE %I PARTITION OF bookings_partitioned
         FOR VALUES FROM (%L) TO (%L)',
        partition_name, start_date, end_date
    );
    
    -- Create indexes on the new partition
    EXECUTE format(
        'CREATE INDEX %I ON %I (user_id)',
        'idx_' || partition_name || '_user_id', partition_name
    );
    
    EXECUTE format(
        'CREATE INDEX %I ON %I (property_id)',
        'idx_' || partition_name || '_property_id', partition_name
    );
END;
$$ LANGUAGE plpgsql;
*/
