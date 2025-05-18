-- Database Indexing Strategy for User, Booking, and Property tables
-- Created: May 18, 2025

-- =============================================
-- BEFORE ADDING INDEXES: Performance Measurement
-- =============================================
-- Run EXPLAIN on your most common queries before adding indexes
-- Example:
/*
EXPLAIN ANALYZE
SELECT u.name, b.check_in_date, b.check_out_date, p.title, p.price
FROM users u
JOIN bookings b ON u.id = b.user_id
JOIN properties p ON b.property_id = p.id
WHERE b.status = 'confirmed'
AND b.check_in_date >= '2025-06-01'
ORDER BY b.created_at DESC;
*/

-- =============================================
-- User Table Indexes
-- =============================================

-- Primary key is usually indexed by default, but included for completeness
-- ALTER TABLE users ADD PRIMARY KEY (id);

-- Index for email lookups (user authentication)
CREATE INDEX idx_users_email ON users (email);

-- Index for user creation date (reporting/sorting)
CREATE INDEX idx_users_created_at ON users (created_at);

-- =============================================
-- Booking Table Indexes
-- =============================================

-- Foreign key indexes for JOIN operations
CREATE INDEX idx_bookings_user_id ON bookings (user_id);
CREATE INDEX idx_bookings_property_id ON bookings (property_id);

-- Index for booking status filtering
CREATE INDEX idx_bookings_status ON bookings (status);

-- Composite index for date range queries (useful for availability searches)
CREATE INDEX idx_bookings_dates ON bookings (check_in_date, check_out_date);

-- Index for sorting by booking creation date
CREATE INDEX idx_bookings_created_at ON bookings (created_at);

-- Composite index for common query pattern (status + dates)
CREATE INDEX idx_bookings_status_dates ON bookings (status, check_in_date, check_out_date);

-- =============================================
-- Property Table Indexes
-- =============================================

-- Index for property owner lookups
CREATE INDEX idx_properties_owner_id ON properties (owner_id);

-- Index for location-based searches
CREATE INDEX idx_properties_location ON properties (location);  -- Adjust column name if different

-- Index for price filtering
CREATE INDEX idx_properties_price ON properties (price);

-- Index for property type filtering
CREATE INDEX idx_properties_type ON properties (property_type);

-- Index for availability filtering
CREATE INDEX idx_properties_availability ON properties (is_available);

-- Composite index for common filtering combination
CREATE INDEX idx_properties_location_price ON properties (location, price);
CREATE INDEX idx_properties_type_price ON properties (property_type, price);
CREATE INDEX idx_properties_available_location ON properties (is_available, location);

-- =============================================
-- AFTER ADDING INDEXES: Performance Measurement
-- =============================================
-- Run EXPLAIN on the same queries after adding indexes to compare performance
-- Example:
/*
EXPLAIN ANALYZE
SELECT u.name, b.check_in_date, b.check_out_date, p.title, p.price
FROM users u
JOIN bookings b ON u.id = b.user_id
JOIN properties p ON b.property_id = p.id
WHERE b.status = 'confirmed'
AND b.check_in_date >= '2025-06-01'
ORDER BY b.created_at DESC;
*/

-- Note: Monitor index usage with:
/*
SELECT
    indexname,
    idx_scan as number_of_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY number_of_scans DESC;
*/

-- If some indexes aren't being used or not providing significant benefit,
-- consider dropping them to reduce overhead on write operations:
/*
DROP INDEX idx_name;
*/
