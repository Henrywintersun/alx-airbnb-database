-- database_index.sql
-- This Create indexes on frequently used columns to improve performance

-- Index on users table for commonly filtered/joined column
CREATE INDEX idx_users_user_id ON users(user_id);

-- Index on bookings table
CREATE INDEX idx_bookings_user_id ON bookings(user_id);
CREATE INDEX idx_bookings_property_id ON bookings(property_id);
CREATE INDEX idx_bookings_booking_date ON bookings(booking_date);

-- Index on properties table
CREATE INDEX idx_properties_property_id ON properties(property_id);
CREATE INDEX idx_properties_location ON properties(location);

-- Example usage: Measuring query performance before and after indexing
-- Use EXPLAIN or EXPLAIN ANALYZE in your MySQL CLI or SQL client:

-- BEFORE INDEXING
-- EXPLAIN SELECT * FROM bookings WHERE user_id = 123;

-- AFTER INDEXING
-- EXPLAIN SELECT * FROM bookings WHERE user_id = 123;
