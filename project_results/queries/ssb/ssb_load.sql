-- SSB (Star Schema Benchmark) Table Creation and Data Loading for DuckDB
-- Make sure to run this from the directory containing your .tbl files

-- Create the DATE dimension table
CREATE TABLE date (
    d_datekey INTEGER NOT NULL,
    d_date CHAR(18) NOT NULL,
    d_dayofweek CHAR(9) NOT NULL,
    d_month CHAR(9) NOT NULL,
    d_year INTEGER NOT NULL,
    d_yearmonthnum INTEGER NOT NULL,
    d_yearmonth CHAR(7) NOT NULL,
    d_daynuminweek INTEGER NOT NULL,
    d_daynuminmonth INTEGER NOT NULL,
    d_daynuminyear INTEGER NOT NULL,
    d_monthnuminyear INTEGER NOT NULL,
    d_weeknuminyear INTEGER NOT NULL,
    d_sellingseason CHAR(12) NOT NULL,
    d_lastdayinweekfl INTEGER NOT NULL,
    d_lastdayinmonthfl INTEGER NOT NULL,
    d_holidayfl INTEGER NOT NULL,
    d_weekdayfl INTEGER NOT NULL,
    PRIMARY KEY (d_datekey)
);

-- Create the CUSTOMER dimension table
CREATE TABLE customer (
    c_custkey INTEGER NOT NULL,
    c_name VARCHAR(25) NOT NULL,
    c_address VARCHAR(25) NOT NULL,
    c_city CHAR(10) NOT NULL,
    c_nation CHAR(15) NOT NULL,
    c_region CHAR(12) NOT NULL,
    c_phone CHAR(15) NOT NULL,
    c_mktsegment CHAR(10) NOT NULL,
    PRIMARY KEY (c_custkey)
);

-- Create the SUPPLIER dimension table
CREATE TABLE supplier (
    s_suppkey INTEGER NOT NULL,
    s_name CHAR(25) NOT NULL,
    s_address VARCHAR(25) NOT NULL,
    s_city CHAR(10) NOT NULL,
    s_nation CHAR(15) NOT NULL,
    s_region CHAR(12) NOT NULL,
    s_phone CHAR(15) NOT NULL,
    PRIMARY KEY (s_suppkey)
);

-- Create the PART dimension table
CREATE TABLE part (
    p_partkey INTEGER NOT NULL,
    p_name VARCHAR(22) NOT NULL,
    p_mfgr CHAR(6) NOT NULL,
    p_category CHAR(7) NOT NULL,
    p_brand CHAR(9) NOT NULL,
    p_color VARCHAR(11) NOT NULL,
    p_type VARCHAR(25) NOT NULL,
    p_size INTEGER NOT NULL,
    p_container CHAR(10) NOT NULL,
    PRIMARY KEY (p_partkey)
);

-- Create the LINEORDER fact table
CREATE TABLE lineorder (
    lo_orderkey INTEGER NOT NULL,
    lo_linenumber INTEGER NOT NULL,
    lo_custkey INTEGER NOT NULL,
    lo_partkey INTEGER NOT NULL,
    lo_suppkey INTEGER NOT NULL,
    lo_orderdate INTEGER NOT NULL,
    lo_orderpriority CHAR(15) NOT NULL,
    lo_shippriority CHAR(1) NOT NULL,
    lo_quantity INTEGER NOT NULL,
    lo_extendedprice INTEGER NOT NULL,
    lo_ordtotalprice INTEGER NOT NULL,
    lo_discount INTEGER NOT NULL,
    lo_revenue INTEGER NOT NULL,
    lo_supplycost INTEGER NOT NULL,
    lo_tax INTEGER NOT NULL,
    lo_commitdate INTEGER NOT NULL,
    lo_shipmode CHAR(10) NOT NULL,
    PRIMARY KEY (lo_orderkey, lo_linenumber)
);

-- Load data from .tbl files
-- Note: Update the file paths if your .tbl files are in a different directory

COPY date FROM 'ssb-data/date.tbl' (DELIMITER '|');
COPY customer FROM 'ssb-data/customer.tbl' (DELIMITER '|');
COPY supplier FROM 'ssb-data/supplier.tbl' (DELIMITER '|');
COPY part FROM 'ssb-data/part.tbl' (DELIMITER '|');
COPY lineorder FROM 'ssb-data/lineorder.tbl' (DELIMITER '|');

-- Verify data loaded correctly
SELECT 'date' AS table_name, COUNT(*) AS row_count FROM date
UNION ALL
SELECT 'customer', COUNT(*) FROM customer
UNION ALL
SELECT 'supplier', COUNT(*) FROM supplier
UNION ALL
SELECT 'part', COUNT(*) FROM part
UNION ALL
SELECT 'lineorder', COUNT(*) FROM lineorder;

-- Optional: Create indexes for better query performance
-- Uncomment if you want to add indexes

-- CREATE INDEX idx_lo_custkey ON lineorder(lo_custkey);
-- CREATE INDEX idx_lo_partkey ON lineorder(lo_partkey);
-- CREATE INDEX idx_lo_suppkey ON lineorder(lo_suppkey);
-- CREATE INDEX idx_lo_orderdate ON lineorder(lo_orderdate);
-- CREATE INDEX idx_lo_commitdate ON lineorder(lo_commitdate);