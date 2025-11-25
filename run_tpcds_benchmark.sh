#!/bin/bash

echo "========================================"
echo "TPC-DS Benchmark Test Suite"
echo "========================================"
echo ""

# Function to test a query
test_query() {
    local query_name=$1
    local query_file=$2
    
    echo "Testing: $query_name"
    echo "------------------------"
    
    # Run on GPU
    echo "GPU execution:"
    ./build/release/duckdb -unsigned tpcds_sf1.duckdb << SQL
call gpu_buffer_init('8 GB', '4 GB');
.timer on
.read $query_file
SQL
    
    echo ""
    echo ""
}

# Test each query
test_query "Query 1: Simple Aggregation" "tpcds_queries/q01_simple_agg.sql"
test_query "Query 2: Join + Aggregation" "tpcds_queries/q02_join_agg.sql"
test_query "Query 3: Multi-way Join" "tpcds_queries/q03_multiway_join.sql"
test_query "Query 4: Complex Filter" "tpcds_queries/q04_complex_filter.sql"
test_query "Query 5: Customer Analysis" "tpcds_queries/q05_customer.sql"
test_query "Query 6: Inventory Analysis" "tpcds_queries/q06_inventory.sql"
test_query "Query 7: Returns Analysis" "tpcds_queries/q07_returns.sql"
test_query "Query 8: Web Sales" "tpcds_queries/q08_web_sales.sql"

echo "========================================"
echo "Benchmark Complete!"
echo "========================================"
