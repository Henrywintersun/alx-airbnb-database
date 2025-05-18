-- USERS TABLE INDEXES

CREATE INDEX idx_users_user_id ON users(user_id);
CREATE INDEX idx_users_email ON users(email);

-- BOOKINGS TABLE INDEXES

CREATE INDEX idx_bookings_user_id ON bookings(user_id);
CREATE INDEX idx_bookings_property_id ON bookings(property_id);
CREATE INDEX idx_bookings_booking_date ON bookings(booking_date);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_user_date ON bookings(user_id, booking_date);

-- PROPERTIES TABLE INDEXES

CREATE INDEX idx_properties_property_id ON properties(property_id);
CREATE INDEX idx_properties_location ON properties(location);
CREATE INDEX idx_properties_price ON properties(price_per_night);
CREATE INDEX idx_properties_host_id ON properties(host_id);
CREATE INDEX idx_properties_location_price ON properties(location, price_per_night);

-- PERFORMANCE MEASUREMENT EXAMPLES

-- Before/after indexing
EXPLAIN SELECT * FROM bookings WHERE user_id = 123 ORDER BY booking_date DESC;

EXPLAIN
SELECT u.name, p.title, b.booking_date
FROM bookings b
JOIN users u ON u.user_id = b.user_id
JOIN properties p ON p.property_id = b.property_id
WHERE b.status = 'confirmed'
ORDER BY b.booking_date DESC;
