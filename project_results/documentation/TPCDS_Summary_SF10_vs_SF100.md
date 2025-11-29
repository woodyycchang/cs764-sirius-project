# TPC-DS Benchmark Summary: SF10 vs SF100

## Dataset Overview

| Metric | SF10 | SF100 |
|--------|------|-------|
| **Database Size** | 2.9 GB | ~100 GB |
| **Rows (store_sales)** | 28.8 million | 288 million |
| **Queries Tested** | 99 TPC-DS queries | 99 TPC-DS queries |

---

## Performance Summary

### SF10 Results

| Metric | CPU | GPU | Speedup |
|--------|-----|-----|---------|
| **Average Time** | 387 ms | 132 ms | 3.46x |
| **Fastest Query** | 155 ms (Q41) | 15 ms (Q90) | - |
| **Slowest Query** | 2,992 ms (Q67) | 1,955 ms (Q67) | - |
| **Best Speedup** | - | - | 12.20x (Q90) |
| **Worst Speedup** | - | - | 1.17x (Q74) |

### SF100 Results

| Metric | CPU | GPU | Speedup |
|--------|-----|-----|---------|
| **Average Time** | 1,847 ms | 1,089 ms | 2.89x |
| **Fastest Query** | 184 ms (Q41) | 32 ms (Q41) | - |
| **Slowest Query** | 23,461 ms (Q67) | 18,725 ms (Q67) | - |
| **Best Speedup** | - | - | 6.83x (Q32) |
| **Worst Speedup** | - | - | 0.96x (Q74) |

---

## Top Time Savers

### SF10 (milliseconds saved)
1. **Q67**: 1,037 ms saved (1.53x speedup)
2. **Q22**: 1,132 ms saved (1.67x speedup)
3. **Q04**: 540 ms saved (1.30x speedup)

### SF100 (milliseconds saved)
1. **Q67**: 4,736 ms saved (1.25x speedup) ⭐
2. **Q22**: 3,909 ms saved (1.82x speedup)
3. **Q23**: 1,335 ms saved (1.22x speedup)

---

## Key Findings

### 1. GPU Provides Consistent Acceleration
- **SF10**: 3.46x average speedup
- **SF100**: 2.89x average speedup
- **97/99 queries** show exact matching results

### 2. Data Scale Impact
- **10x more data** → only **2-7x longer execution time**
- Both CPU and GPU handle large data efficiently
- Complex queries scale worse than simple ones

### 3. Absolute Time Matters More Than Speedup
- Q67 in SF100: Only **1.25x faster** but saves **4.7 seconds**
- Low speedup on big queries = high value in production
- High speedup on fast queries = less practical benefit

### 4. GPU Sweet Spots
**Best for:**
- Simple scans and aggregations (Q32, Q90, Q96: 6-12x faster)
- Multiple queries per session (amortize 9s initialization)
- Large datasets (>10GB)

**Not ideal for:**
- Complex multi-way JOINs (Q14: 1.08x)
- Memory-intensive operations (Q74: 0.96x - **actually slower**)
- Single-shot queries (initialization overhead)

### 5. Production Recommendations

✅ **Use GPU when:**
- Running batch analytical workloads
- Working with large datasets
- Queries involve scans + simple aggregations

❌ **Use CPU when:**
- Running single queries
- Queries have complex JOINs
- Dataset is small (<5GB)

---

## Test Configuration

- **Hardware**: Quadro RTX 6000 (24GB GPU)
- **Software**: DuckDB 1.2.1 + Sirius GPU Extension
- **Date**: November 2025
- **GPU Config**: 8GB cache + 12GB processing buffer

---

*Data source: `project_results/data/tpcds_comparison.txt` and `tpcds_sf100.txt`*