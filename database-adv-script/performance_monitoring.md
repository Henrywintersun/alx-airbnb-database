
# 🚀 Database Performance Monitoring and Refinement

This guide helps you continuously monitor and refine database performance using SQL tools like `EXPLAIN`, `SHOW PROFILE`, and schema adjustments in MySQL.

---

## ✅ Step 1: Analyze Frequently Used Queries

### 🔍 Query 1: Bookings by User and Date

```sql
EXPLAIN SELECT * FROM bookings WHERE user_id = 101 ORDER BY booking_date DESC;
```

### 🔍 Query 2: Join Bookings, Users, and Properties

```sql
EXPLAIN
SELECT u.name, p.title, b.booking_date
FROM bookings b
JOIN users u ON u.user_id = b.user_id
JOIN properties p ON p.property_id = b.property_id
WHERE b.status = 'confirmed'
ORDER BY b.booking_date DESC;
```

### Optional: Enable Profiling

```sql
SET PROFILING = 1;
-- Run your query
SHOW PROFILES;
SHOW PROFILE FOR QUERY 1;
```

---

## 🔎 Step 2: Identify Bottlenecks

Look out for these in `EXPLAIN`:

- `type = ALL`: Full table scan (bad)
- `rows`: High value means inefficiency
- `Extra`: "Using temporary" or "Using filesort" signals inefficiencies

---

## 🛠️ Step 3: Apply Improvements

### ✅ Add Indexes

```sql
-- Composite index for filtering and sorting
CREATE INDEX idx_bookings_user_id_date ON bookings(user_id, booking_date);

-- Composite index for property filtering and sorting
CREATE INDEX idx_properties_location_price ON properties(location, price_per_night);

-- Indexes for JOIN optimization
CREATE INDEX idx_users_user_id ON users(user_id);
CREATE INDEX idx_properties_property_id ON properties(property_id);
```

### ✅ Schema Adjustments

- Ensure data types of JOIN columns match
- Avoid nullable foreign keys unless necessary

---

## 📈 Step 4: Measure Improvements

Repeat the performance tests:

```sql
EXPLAIN SELECT * FROM bookings WHERE user_id = 101 ORDER BY booking_date DESC;
SHOW PROFILE FOR QUERY 1;
```

Compare row estimates and access type.

---

## 📋 Performance Report

| Query | Optimization Action | Before | After | Improvement |
|-------|---------------------|--------|-------|-------------|
| Bookings by user/date | Added composite index | `ALL`, 5K rows | `range`, ~50 rows | 99% reduction |
| JOIN query | Indexed JOIN keys | `ALL`, temp sort | `ref`, indexed sort | Filesort eliminated |

---

**✅ Tip:** Always run `ANALYZE TABLE` after creating new indexes to update optimizer statistics.
