# CS764 Sirius GPU Database Benchmark Project

**Team:** Ayesha Shafique, Nida Tanveer, Woody Chang, Xuechun Jin  
**Date:** November 25, 2025

## Project Overview
Comprehensive benchmarking of Sirius GPU-native SQL engine on TPC-H and TPC-DS benchmarks, with focus on performance analysis and correctness verification.

## Contributions

### Setup & Infrastructure (Woody)
- Chameleon Cloud GPU environment (Quadro RTX 6000)
- Resolved build issues: conda paths, spdlog, substrait
- Created reproducible setup documentation

### TPC-H Benchmark (Woody)
- Complete: All 22 queries working on GPU
- Performance: 2ms - 996ms execution times
- Correctness: Verified against CPU baseline
- Dataset: SF1 (6M rows, 1GB)

### TPC-DS Benchmark (Woody)
- Setup: 24 tables, 19M rows, 1.2GB
- Queries: 8 representative queries created
- Testing: CPU vs GPU comparison
- **Bug Discovery:** Critical SUM() aggregation error

### JOB Benchmark (Ayesha)
- 

## Major Findings

### 1. Performance Characteristics
- Small datasets (SF1): CPU faster (overhead dominates)
- GPU overhead: ~150ms initialization + data transfer
- Recommendation: SF10+ for GPU benefits

### 2. Critical Bug Discovered
**SUM() Aggregation Error:**
- Produces incorrect results on DECIMAL columns
- Error magnitude: 100,000%
- Affects all monetary aggregations
- COUNT() and JOIN operations work correctly

### 3. Sirius Limitations
- No AVG() support (graceful CPU fallback)
- Limited aggregation function coverage
- Requires larger datasets for benefit

## Recommendations
1. Fix SUM() aggregation bug before production use
2. Test on SF10/SF100 for proper performance evaluation
3. Expand aggregation function support
4. Add comprehensive correctness testing

## Lessons Learned
- GPU acceleration not universally beneficial
- Correctness testing as important as performance
- Small datasets expose overhead vs computation trade-offs
- Open-source projects need extensive validation
