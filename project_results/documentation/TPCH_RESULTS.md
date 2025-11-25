# TPC-H SF1 Benchmark Results

**Date:** November 25, 2025
**Environment:** Chameleon Cloud - Quadro RTX 6000 (24GB)
**Dataset:** TPC-H Scale Factor 1 (6M rows)

## Completion Status
- ✅ All 22 TPC-H queries executed successfully
- ✅ GPU execution verified
- ✅ Results match CPU baseline

## Data Loaded
- customer: 150,000 rows
- lineitem: 6,001,215 rows
- orders: 1,500,000 rows
- part: 200,000 rows
- partsupp, supplier, nation, region: loaded

## Query Performance Range
- Fastest: 2.12ms
- Slowest: 996.20ms
- Average: ~200ms

## Files
- `tpch-queries.sql` - All 22 queries
- `sirius_*.log` - Complete execution logs
- `tpch_query_times.txt` - Extracted timing results
