-- ========================================
-- INDEX CREATION AND PERFORMANCE ANALYSIS
-- FOR USERS, BOOKINGS, PROPERTIES TABLES
-- ========================================

-- ========================
-- USERS TABLE
-- ========================

-- Check and create index on user_id
SET @index_name = 'idx_users_user_id';
SET @table_name = 'users';
SET @column_name = 'user_id';
SELECT IF(
  EXISTS (
    SELECT 1 FROM information_schema.statistics
    WHERE table_schema = DATABASE() AND table_name = @table_name AND index_name = @index_name
  ),
  'Index already exists',
  CONCAT('ALTER TABLE ', @table_name, ' ADD INDEX ', @index_name, '(', @column_name, ');')
) AS user_id_index;

-- Check and create index on email
SET @index_name = 'idx_users_email';
SET @column_name = 'email';
SELECT IF(
  EXISTS (
    SELECT 1 FROM information_schema.statistics
    WHERE table_schema = DATABASE() AND table_name = 'users' AND index_name = @index_name
  ),
  'Index already exists',
  'CREATE INDEX idx_users_email ON users(email);'
) AS email_index;

-- ========================
-- BOOKINGS TABLE
-- ========================

-- EXPLAIN query performance BEFORE indexing
EXPLAIN SELECT * FROM bookings WHERE user_id = 123 ORDER BY booking_date DESC;

-- Index on user_id
SELECT IF(
  EXISTS (
    SELECT 1 FROM information_schema.statistics
    WHERE table_schema = DATABASE() AND table_name = 'bookings' AND index_name = 'idx_bookings_user_id'
  ),
  'Index exists',
  'CREATE INDEX idx_bookings_user_id ON bookings(user_id);'
) AS idx_bookings_user_id;

-- Index on property_id
SELECT IF(
  EXISTS (
    SELECT 1 FROM information_schema.statistics
    WHERE table_schema = DATABASE() AND table_name = 'bookings' AND index_name = 'idx_bookings_property_id'
  ),
  'Index exists',
  'CREATE INDEX idx_bookings_property_id ON bookings(property_id);'
) AS idx_bookings_property_id;

-- Index on booking_date
SELECT IF(
  EXISTS (
    SELECT 1 FROM information_schema.statistics
    WHERE table_schema = DATABASE() AND table_name = 'bookings' AND index_name = 'idx_bookings_booking_date'
  ),
  'Index exists',
  'CREATE INDEX idx_bookings_booking_date ON bookings(booking_date);'
) AS idx_bookings_booking_date;

-- Index on status
SELECT IF(
  EXISTS (
    SELECT 1 FROM information_schema.statistics
    WHERE table_schema = DATABASE() AND table_name = 'bookings' AND index_name = 'idx_bookings_status'
  ),
  'Index exists',
  'CREATE INDEX idx_bookings_status ON bookings(status);'
) AS idx_bookings_status;

-- Compound index: user_id, booking_date
SELECT IF(
  EXISTS (
    SELECT 1 FROM information_schema.statistics
    WHERE table_schema = DATABASE() AND table_name = 'bookings' AND index_name = 'idx_bookings_user_date'
  ),
  'Index exists',
  'CREATE INDEX idx_bookings_user_date ON bookings(user_id, booking_date);'
) AS idx_bookings_user_date;

-- EXPLAIN query performance AFTER indexing
EXPLAIN SELECT * FROM bookings WHERE user_id = 123 ORDER BY booking_date DESC;

-- ========================
-- PROPERTIES TABLE
-- ========================

-- Index on property_id
SELECT IF(
  EXISTS (
    SELECT 1 FROM information_schema.statistics
    WHERE table_schema = DATABASE() AND table_name = 'properties' AND index_name = 'idx_properties_property_id'
  ),
  'Index exists',
  'CREATE INDEX idx_properties_property_id ON properties(property_id);'
) AS idx_properties_property_id;

-- Index on location
SELECT IF(
  EXISTS (
    SELECT 1 FROM information_schema.statistics
    WHERE table_schema = DATABASE() AND table_name = 'properties' AND index_name = 'idx_properties_location'
  ),
  'Index exists',
  'CREATE INDEX idx_properties_location ON properties(location);'
) AS idx_properties_location;

-- Index on price_per_night
SELECT IF(
  EXISTS (
    SELECT 1 FROM information_schema.statistics
    WHERE table_schema = DATABASE() AND table_name = 'properties' AND index_name = 'idx_properties_price'
  ),
  'Index exists',
  'CREATE INDEX idx_properties_price ON properties(price_per_night);'
) AS idx_properties_price;

-- Index on host_id
SELECT IF(
  EXISTS (
    SELECT 1 FROM information_schema.statistics
    WHERE table_schema = DATABASE() AND table_name = 'properties' AND index_name = 'idx_properties_host_id'
  ),
  'Index exists',
  'CREATE INDEX idx_properties_host_id ON properties(host_id);'
) AS idx_properties_host_id;

-- Compound index on location and price
SELECT IF(
  EXISTS (
    SELECT 1 FROM information_schema.statistics
    WHERE table_schema = DATABASE() AND table_name = 'properties' AND index_name = 'idx_properties_location_price'
  ),
  'Index exists',
  'CREATE INDEX idx_properties_location_price ON properties(location, price_per_night);'
) AS idx_properties_location_price;

-- Performance test for properties: Measuring Before and After [EXPLAIN or ANALYSE]
EXPLAIN SELECT * FROM bookings WHERE user_id = 101 ORDER BY booking_date DESC;
EXPLAIN
SELECT u.name, p.title, b.booking_date
FROM bookings b
JOIN users u ON u.user_id = b.user_id
JOIN properties p ON p.property_id = b.property_id
WHERE b.status = 'confirmed'
ORDER BY b.booking_date DESC;
EXPLAIN SELECT * FROM properties WHERE location = 'Lagos' ORDER BY price_per_night;
