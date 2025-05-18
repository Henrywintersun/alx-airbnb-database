-- Script: database_index.sql
-- Purpose: Create indexes on frequently used columns to improve performance,
-- and measure query performance before and after indexing

-- =============================
-- Step 1: Measure query performance BEFORE indexing
-- =============================
-- Example: Query on bookings.user_id
EXPLAIN SELECT * FROM bookings WHERE user_id = 123;

-- =============================
-- Step 2: Conditionally create indexes (manual check using information_schema)
-- =============================

-- users.user_id
SELECT IF(
  EXISTS (
    SELECT 1 FROM information_schema.statistics 
    WHERE table_schema = DATABASE() AND table_name = 'users' AND index_name = 'idx_users_user_id'
  ),
  'Index exists',
  'CREATE INDEX idx_users_user_id ON users(user_id);'
);

-- bookings.user_id
SELECT IF(
  EXISTS (
    SELECT 1 FROM information_schema.statistics 
    WHERE table_schema = DATABASE() AND table_name = 'bookings' AND index_name = 'idx_bookings_user_id'
  ),
  'Index exists',
  'CREATE INDEX idx_bookings_user_id ON bookings(user_id);'
);

-- bookings.property_id
SELECT IF(
  EXISTS (
    SELECT 1 FROM information_schema.statistics 
    WHERE table_schema = DATABASE() AND table_name = 'bookings' AND index_name = 'idx_bookings_property_id'
  ),
  'Index exists',
  'CREATE INDEX idx_bookings_property_id ON bookings(property_id);'
);

-- bookings.booking_date
SELECT IF(
  EXISTS (
    SELECT 1 FROM information_schema.statistics 
    WHERE table_schema = DATABASE() AND table_name = 'bookings' AND index_name = 'idx_bookings_booking_date'
  ),
  'Index exists',
  'CREATE INDEX idx_bookings_booking_date ON bookings(booking_date);'
);

-- properties.property_id
SELECT IF(
  EXISTS (
    SELECT 1 FROM information_schema.statistics 
    WHERE table_schema = DATABASE() AND table_name = 'properties' AND index_name = 'idx_properties_property_id'
  ),
  'Index exists',
  'CREATE INDEX idx_properties_property_id ON properties(property_id);'
);

-- properties.location
SELECT IF(
  EXISTS (
    SELECT 1 FROM information_schema.statistics 
    WHERE table_schema = DATABASE() AND table_name = 'properties' AND index_name = 'idx_properties_location'
  ),
  'Index exists',
  'CREATE INDEX idx_properties_location ON properties(location);'
);

-- =============================
-- Step 3: Measure query performance AFTER indexing
-- =============================
EXPLAIN SELECT * FROM bookings WHERE user_id = 123;
