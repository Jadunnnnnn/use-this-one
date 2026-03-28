-- ============================================================
-- MS3083 Assignment 3
-- Name: Jaden Dunn   Date: 2026-03-28
-- ============================================================

-- SECTION 1: Schema

CREATE SCHEMA IF NOT EXISTS dunn;

-- Optional cleanup so the script can run top to bottom more than once
DROP TABLE IF EXISTS dunn."PURCHASE_ORDER" CASCADE;
DROP TABLE IF EXISTS dunn."INVENTORY" CASCADE;
DROP TABLE IF EXISTS dunn."SUPPLIER" CASCADE;
DROP TABLE IF EXISTS dunn."LOCATION" CASCADE;
DROP TABLE IF EXISTS dunn."INGREDIENT" CASCADE;

-- SECTION 2: Table Creation

CREATE TABLE dunn."INGREDIENT" (
    ingredient_id SERIAL PRIMARY KEY,
    ingredient_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_of_measure VARCHAR(30) NOT NULL,
    unit_cost NUMERIC(10,2) NOT NULL,
    is_active BOOLEAN NOT NULL,
    expiration_days INTEGER NOT NULL,
    brand VARCHAR(100) NOT NULL,
    storage_type VARCHAR(30) NOT NULL
);

CREATE TABLE dunn."LOCATION" (
    location_id SERIAL PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL,
    location_type VARCHAR(30) NOT NULL,
    capacity_units INTEGER NOT NULL,
    is_active BOOLEAN NOT NULL,
    temperature INTEGER NOT NULL,
    manager_name VARCHAR(100) NOT NULL
);

CREATE TABLE dunn."SUPPLIER" (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100) NOT NULL,
    contact_phone VARCHAR(20) NOT NULL,
    lead_time_days INTEGER NOT NULL,
    is_active BOOLEAN NOT NULL,
    address VARCHAR(100) NOT NULL,
    rating CHAR(1) NOT NULL
);

CREATE TABLE dunn."INVENTORY" (
    inventory_id SERIAL PRIMARY KEY,
    ingredient_id INTEGER NOT NULL REFERENCES dunn."INGREDIENT"(ingredient_id),
    location_id INTEGER NOT NULL REFERENCES dunn."LOCATION"(location_id),
    qty_on_hand INTEGER NOT NULL,
    reorder_point INTEGER NOT NULL,
    reorder_qty INTEGER NOT NULL,
    last_updated TIMESTAMP NOT NULL,
    safety_stock INTEGER NOT NULL,
    notes VARCHAR(255),
    inventory_value NUMERIC(12,2) NOT NULL,
    stock_status VARCHAR(20) NOT NULL
);

CREATE TABLE dunn."PURCHASE_ORDER" (
    poid SERIAL PRIMARY KEY,
    supplier_id INTEGER NOT NULL REFERENCES dunn."SUPPLIER"(supplier_id),
    ingredient_id INTEGER NOT NULL REFERENCES dunn."INGREDIENT"(ingredient_id),
    order_date DATE NOT NULL,
    expected_delivery DATE NOT NULL,
    qty_ordered INTEGER NOT NULL,
    total_cost NUMERIC(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    order_priority VARCHAR(20) NOT NULL
);

-- SECTION 3: Data Insertion

INSERT INTO dunn."INGREDIENT"
    (ingredient_name, category, unit_of_measure, unit_cost, is_active, expiration_days, brand, storage_type)
VALUES
    ('Chicken Breast', 'Protein', 'lbs', 2.50, TRUE, 5, 'Tyson', 'Refrigerated'),
    ('Canola Oil', 'Oil', 'gallons', 18.00, TRUE, 365, 'Crisco', 'Dry Storage'),
    ('Flour', 'Dry Goods', 'lbs', 0.75, TRUE, 180, 'Gold Medal', 'Dry Storage'),
    ('Cane''s Sauce', 'Sauce', 'cases', 25.00, TRUE, 30, 'Canes', 'Refrigerated'),
    ('French Fries', 'Frozen', 'cases', 15.00, TRUE, 120, 'Lamb Weston', 'Freezer');

INSERT INTO dunn."LOCATION"
    (location_name, location_type, capacity_units, is_active, temperature, manager_name)
VALUES
    ('Walk-In Fridge A', 'Refrigerated', 500, TRUE, 38, 'Manager A'),
    ('Freezer B', 'Freezer', 300, TRUE, 0, 'Manager B'),
    ('Dry Storage Room', 'Dry Storage', 800, TRUE, 72, 'Manager C');

INSERT INTO dunn."SUPPLIER"
    (supplier_name, contact_email, contact_phone, lead_time_days, is_active, address, rating)
VALUES
    ('Tyson Foods', 'contact@tyson.com', '210-555-1111', 3, TRUE, 'TX', 'A'),
    ('Crisco Supply', 'info@crisco.com', '210-555-2222', 5, TRUE, 'TX', 'B'),
    ('Gold Medal Co.', 'support@goldmedal.com', '210-555-3333', 4, TRUE, 'TX', 'A');

INSERT INTO dunn."INVENTORY"
    (ingredient_id, location_id, qty_on_hand, reorder_point, reorder_qty, last_updated, safety_stock, notes, inventory_value, stock_status)
VALUES
    (1, 1, 200, 100, 150, '2026-03-01 10:00:00', 50, 'Fresh stock', 500.00, 'OK'),
    (2, 3, 100, 50, 75, '2026-03-02 11:30:00', 25, 'Bulk oil', 1800.00, 'OK'),
    (3, 3, 300, 150, 200, '2026-03-03 09:15:00', 75, 'Baking supply', 225.00, 'OK'),
    (4, 1, 50, 30, 60, '2026-03-04 14:45:00', 20, 'Sauce', 1250.00, 'OK'),
    (5, 2, 120, 60, 100, '2026-03-05 16:20:00', 40, 'Frozen fries', 1800.00, 'OK');

INSERT INTO dunn."PURCHASE_ORDER"
    (supplier_id, ingredient_id, order_date, expected_delivery, qty_ordered, total_cost, status, payment_method, order_priority)
VALUES
    (1, 1, '2026-03-01', '2026-03-04', 150, 375.00, 'Pending', 'Card', 'High'),
    (2, 2, '2026-03-02', '2026-03-07', 75, 1350.00, 'Received', 'Card', 'Medium'),
    (3, 3, '2026-03-03', '2026-03-06', 200, 150.00, 'Pending', 'Invoice', 'Low'),
    (1, 4, '2026-03-04', '2026-03-08', 60, 1500.00, 'Cancelled', 'Card', 'High'),
    (2, 5, '2026-03-05', '2026-03-09', 100, 1500.00, 'Pending', 'Invoice', 'Medium');

-- SECTION 4: Verification Queries  (Q1 through Q6)

-- VERIFY: Row counts
SELECT COUNT(*) AS ingredient_count FROM dunn."INGREDIENT";
SELECT COUNT(*) AS location_count FROM dunn."LOCATION";
SELECT COUNT(*) AS supplier_count FROM dunn."SUPPLIER";
SELECT COUNT(*) AS inventory_count FROM dunn."INVENTORY";
SELECT COUNT(*) AS purchase_order_count FROM dunn."PURCHASE_ORDER";

-- VERIFY: Full ingredient list
SELECT *
FROM dunn."INGREDIENT"
ORDER BY ingredient_name ASC;

-- VERIFY: Inventory with ingredient names
SELECT
    i.ingredient_name,
    inv.qty_on_hand,
    (inv.last_updated::DATE + i.expiration_days) AS expiration_date,
    inv.location_id
FROM dunn."INVENTORY" AS inv
JOIN dunn."INGREDIENT" AS i
    ON inv.ingredient_id = i.ingredient_id
ORDER BY i.ingredient_name;

-- VERIFY: Inventory with location names
SELECT
    inv.ingredient_id,
    inv.qty_on_hand,
    l.location_name,
    l.location_type AS storage_type
FROM dunn."INVENTORY" AS inv
JOIN dunn."LOCATION" AS l
    ON inv.location_id = l.location_id
ORDER BY l.location_name, inv.ingredient_id;

-- VERIFY: Purchase orders with supplier and ingredient
SELECT
    s.supplier_name,
    i.ingredient_name,
    po.order_date,
    po.qty_ordered,
    po.status AS order_status
FROM dunn."PURCHASE_ORDER" AS po
JOIN dunn."SUPPLIER" AS s
    ON po.supplier_id = s.supplier_id
JOIN dunn."INGREDIENT" AS i
    ON po.ingredient_id = i.ingredient_id
ORDER BY po.order_date, s.supplier_name;

-- VERIFY: Foreign key enforcement
-- INSERT INTO dunn."INVENTORY"
--     (ingredient_id, location_id, qty_on_hand, reorder_point, reorder_qty, last_updated, safety_stock, notes, inventory_value, stock_status)
-- VALUES
--     (9999, 1, 25, 10, 20, '2026-03-10 08:00:00', 5, 'Bad test row', 62.50, 'Reorder');
-- PostgreSQL would reject this insert with a foreign key constraint error because ingredient_id 9999 does not exist in the parent INGREDIENT table.

-- SECTION 5: Reflection

/*
==========================================================
  REFLECTION  —  MS3083 Assignment 3
  Name: Jaden Dunn
==========================================================

Q1 — Data Type Decision:
  One data type decision that made me stop and think was the choice for unit_cost, inventory_value, and total_cost.
  My options were to store them as INTEGER, FLOAT, or NUMERIC.
  I chose NUMERIC(10,2) and NUMERIC(12,2) because these columns represent money, and money should be stored with exact precision.
  Using INTEGER would remove the cents, and FLOAT could introduce rounding errors, so NUMERIC was the safest and most accurate choice.

Q2 — INVENTORY Foreign Keys Explained:
  INVENTORY has two foreign keys: ingredient_id and location_id.
  The ingredient_id foreign key makes sure every inventory record points to a real ingredient that already exists in the INGREDIENT table, so I cannot track stock for a made-up item.
  The location_id foreign key makes sure every inventory record points to a real storage location in the LOCATION table, so I cannot assign inventory to a place that does not exist.
  In business terms, these rules prevent bad records and make sure the database always shows a real item in a real location.

Q3 — How the Three-Table JOIN Works:
  In Q5, the PURCHASE_ORDER table is the starting table because it contains both foreign keys needed for the report.
  First, I join PURCHASE_ORDER to SUPPLIER by matching supplier_id so each order can show the supplier name instead of only a numeric ID.
  Next, I join PURCHASE_ORDER to INGREDIENT by matching ingredient_id so each order also shows the ingredient name tied to that purchase.
  The join order does not really change the final result here because both joins use keys from PURCHASE_ORDER, but the logic is easier to read when I start with the order table and then connect it to the descriptive parent tables.

Q4 — Scaling to New Locations:
  If Raising Cane's opened five new restaurant locations, I would add five new rows to the LOCATION table.
  I would also add new INVENTORY rows for each ingredient stored at those new locations, because inventory is tracked by both item and place.
  The current design would handle that without needing any new columns, since the table structure already supports adding more rows as the business grows.
  If this were managed with separate Excel files instead of related tables, it would be much easier to create duplicates, mismatched IDs, and inconsistent updates across files.
*/
