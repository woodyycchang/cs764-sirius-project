# TPC-DS SF1 Benchmark Results

**Date:** November 25, 2025  
**Environment:** Chameleon Cloud - Quadro RTX 6000 (24GB)

## Dataset
- Scale Factor: 1
- Total Tables: 24
- Total Rows: 19,112,855
- Size: 1.2GB

## Queries Tested
Created 8 representative TPC-DS queries testing:
- Simple aggregations
- Multi-way joins (2, 3, 4 tables)
- Complex filtering
- Customer demographics
- Inventory analysis
- Returns analysis
- Web sales

## Key Findings

### Correctness Issues
**CRITICAL BUG:** SUM() aggregation on DECIMAL columns returns incorrect results
- Test: Query summing $1.02B in sales
- CPU: $1,019,954,026.32 (correct)
- GPU: -$10,838,124.72 (incorrect, ~100,000% error)
- Impact: All monetary aggregations produce wrong results

### Supported Operations
✅ COUNT() - Works correctly
✅ JOIN - Works correctly  
✅ FILTER - Works correctly
❌ SUM(decimal) - Returns wrong values
❌ AVG() - Not supported (falls back to CPU)

### Performance
On SF1 dataset, GPU is slower than CPU:
- Query 1: CPU 26ms vs GPU 173ms (6.6x slower)
- Query 2: CPU 41ms vs GPU 185ms (4.5x slower)
- Reason: Data transfer overhead exceeds computation benefit

## Conclusion
Sirius GPU engine requires larger datasets (SF10+) to overcome initialization and data transfer overhead. Critical correctness bug in SUM() aggregation prevents production use for TPC-DS workloads.
