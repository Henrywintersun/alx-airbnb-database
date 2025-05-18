--Sample Schema (MySQL)
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE properties (
    property_id INT PRIMARY KEY,
    property_name VARCHAR(100)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    user_id INT,
    property_id INT,
    booking_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (property_id) REFERENCES properties(property_id)
);

CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    property_id INT,
    rating INT,
    comment TEXT,
    FOREIGN KEY (property_id) REFERENCES properties(property_id)
);

-- Sample Data
-- USERS
INSERT INTO users (user_id, name, email) VALUES
(1, 'Alice', 'alice@example.com'),
(2, 'Bob', 'bob@example.com'),
(3, 'Charlie', 'charlie@example.com');

-- PROPERTIES
INSERT INTO properties (property_id, property_name) VALUES
(101, 'Ocean View'),
(102, 'Mountain Cabin'),
(103, 'City Loft');

-- BOOKINGS
INSERT INTO bookings (booking_id, user_id, property_id, booking_date) VALUES
(1001, 1, 101, '2025-01-15'),
(1002, 2, 102, '2025-02-10');

-- REVIEWS
INSERT INTO reviews (review_id, property_id, rating, comment) VALUES
(201, 101, 5, 'Amazing view!'),
(202, 102, 4, 'Cozy and quiet.');

-- INNER JOIN: Bookings and Users
SELECT 
    bookings.booking_id,
    bookings.property_id,
    bookings.booking_date,
    users.user_id,
    users.name,
    users.email
FROM 
    bookings
INNER JOIN users ON bookings.user_id = users.user_id;


-- LEFT JOIN: To retrieve all properties and their reviews
SELECT 
    properties.property_id,
    properties.property_name,
    reviews.review_id,
    reviews.rating,
    reviews.comment
FROM 
    properties
LEFT JOIN reviews ON properties.property_id = reviews.property_id;



-- FULL OUTER JOIN (simulating using UNION in MySQL): To retrieve Users and all bookings
SELECT 
    users.user_id,
    users.name,
    bookings.booking_id,
    bookings.property_id,
    bookings.booking_date
FROM 
    users
LEFT JOIN bookings ON users.user_id = bookings.user_id

UNION

-- RIGHT JOIN: Bookings without valid users
SELECT 
    users.user_id,
    users.name,
    bookings.booking_id,
    bookings.property_id,
    bookings.booking_date
FROM 
    users
RIGHT JOIN bookings ON users.user_id = bookings.user_id;


-- LEFT JOIN: Retrieve all properties and their reviews, including properties that have no reviews.
-- Get all properties and their reviews (if available), ordered by property_id
SELECT 
    properties.property_id,
    properties.property_name,
    reviews.review_id,
    reviews.rating,
    reviews.comment
FROM 
    properties
LEFT JOIN reviews ON properties.property_id = reviews.property_id
ORDER BY properties.property_id;

