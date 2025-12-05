# TPC-DS Dataset Generation and Sirius Usage Guide

A concise guide for generating TPC-DS datasets and running queries with Sirius GPU acceleration.

---

## Prerequisites

- Sirius built and installed in `~/sirius/build/release/`
- NVIDIA GPU with sufficient memory (24GB recommended)
- DuckDB with Sirius extension loaded

---

## Quick Start

### 1. Generate TPC-DS Dataset

Navigate to the Sirius build directory and generate the dataset:

```bash
cd ~/sirius/build/release

./duckdb tpcds_sf1.duckdb << 'EOF'
INSTALL tpcds;
LOAD tpcds;
CALL dsdgen(sf=1);
EOF
```

**What this does:**
- Creates `tpcds_sf1.duckdb` database file
- Generates 24 TPC-DS tables (~1GB data)
- Takes approximately 5-10 minutes

**Verify generation:**
```bash
./duckdb tpcds_sf1.duckdb -c "SHOW TABLES;"
./duckdb tpcds_sf1.duckdb -c "SELECT COUNT(*) FROM store_sales;"
```

Expected output: ~2.8 million rows in `store_sales`

---

## Running Queries

### CPU Execution (DuckDB Baseline)

```bash
./duckdb tpcds_sf1.duckdb -c "
SELECT d_year, COUNT(*) as num_sales 
FROM store_sales, date_dim 
WHERE ss_sold_date_sk = d_date_sk 
GROUP BY d_year;
"
```

### GPU Execution (Sirius Acceleration)

```bash
./duckdb tpcds_sf1.duckdb << 'EOF'
call gpu_buffer_init('8 GB', '4 GB');
call gpu_processing("
SELECT d_year, COUNT(*) as num_sales 
FROM store_sales, date_dim 
WHERE ss_sold_date_sk = d_date_sk 
GROUP BY d_year
");
EOF
```

**Note:** Query must be on a single line within `gpu_processing()`.

---

## Scale Factors

TPC-DS supports different data sizes via scale factors:

| Scale Factor | Data Size | Rows (approx) | Generation Time |
|--------------|-----------|---------------|-----------------|
| SF1          | ~1GB      | 6M            | 5-10 min        |
| SF10         | ~3GB      | 29M           | 15-20 min       |
| SF100        | ~26GB     | 288M          | 30-60 min       |

**To generate different scale factors:**

```bash
# SF10 (2.82GB)
./duckdb tpcds_sf10.duckdb << 'EOF'
INSTALL tpcds;
LOAD tpcds;
CALL dsdgen(sf=10);
EOF

# SF100 (26.17GB)
./duckdb tpcds_sf100.duckdb << 'EOF'
INSTALL tpcds;
LOAD tpcds;
CALL dsdgen(sf=100);
EOF
```

---

## Complete Example: CPU vs GPU Comparison

```bash
cd ~/sirius/build/release

# Step 1: Generate dataset
./duckdb tpcds_sf1.duckdb << 'EOF'
INSTALL tpcds;
LOAD tpcds;
CALL dsdgen(sf=1);
EOF

# Step 2: Define test query
QUERY="SELECT d_year, COUNT(*) as sales FROM store_sales, date_dim WHERE ss_sold_date_sk = d_date_sk GROUP BY d_year"

# Step 3: Run on CPU
echo "=== CPU Execution ==="
time ./duckdb tpcds_sf1.duckdb -c "$QUERY"

# Step 4: Run on GPU
echo "=== GPU Execution ==="
time ./duckdb tpcds_sf1.duckdb << EOF
call gpu_buffer_init('8 GB', '4 GB');
call gpu_processing("$QUERY");
EOF
```

---

## TPC-DS Schema

The dataset includes 24 tables:

**Fact Tables:**
- `store_sales`, `store_returns`
- `catalog_sales`, `catalog_returns`
- `web_sales`, `web_returns`
- `inventory`

**Dimension Tables:**
- `date_dim`, `time_dim`
- `item`, `customer`, `customer_demographics`, `customer_address`
- `store`, `call_center`, `catalog_page`, `web_page`, `web_site`
- `warehouse`, `promotion`, `household_demographics`
- `income_band`, `reason`, `ship_mode`

**Primary fact table:** `store_sales` contains the majority of rows.

---

## GPU Buffer Configuration

Adjust GPU memory allocation based on available resources:

```bash
# Default (8GB device, 4GB pinned)
call gpu_buffer_init('8 GB', '4 GB');

# Smaller configuration (for limited GPU memory)
call gpu_buffer_init('4 GB', '2 GB');

# Larger configuration (for 24GB+ GPUs)
call gpu_buffer_init('16 GB', '8 GB');
```

**Format:** `gpu_buffer_init('device_memory', 'pinned_memory')`

---

## Troubleshooting

### Issue: "table not found"

**Cause:** Dataset not generated  
**Solution:** Run `dsdgen()` to create tables

```bash
./duckdb tpcds_sf1.duckdb -c "SHOW TABLES;"
# If empty, run: INSTALL tpcds; LOAD tpcds; CALL dsdgen(sf=1);
```

### Issue: "GPU out of memory"

**Cause:** Insufficient GPU memory  
**Solutions:**
1. Use smaller scale factor (SF1 instead of SF10)
2. Reduce buffer size: `gpu_buffer_init('4 GB', '2 GB')`
3. Simplify query or reduce result set

### Issue: "Error in GPUExecuteQuery"

**Cause:** Query contains unsupported operations  
**Solution:** Check Sirius documentation for supported SQL features. Known issues:
- `AVG()` on DECIMAL types not supported
- `SUM()` may have correctness issues (verify results against CPU)

### Issue: DuckDB not found

**Cause:** Wrong directory  
**Solution:** Ensure you're in the correct build directory

```bash
cd ~/sirius/build/release
ls -l duckdb  # Should exist
```

---

## TPC-DS Query Reference

The TPC-DS benchmark includes 99 standard queries. Commonly tested queries include:

**Join-heavy queries:** Q03, Q07, Q32, Q49, Q62, Q90, Q96  
**Aggregation queries:** Q05, Q08, Q22, Q37, Q77  
**Complex queries:** Q04, Q14, Q67, Q74

Full query specifications: [TPC-DS Documentation](https://www.tpc.org/tpc_documents_current_versions/pdf/tpc-ds_v3.2.0.pdf)

---

## Performance Benchmarking Tips

1. **Run cold cache tests:** Restart DuckDB between measurements
2. **Use `time` command:** Measure actual execution time
3. **Compare same queries:** Ensure identical SQL for CPU vs GPU
4. **Validate results:** Verify GPU results match CPU baseline
5. **Multiple runs:** Average results from 3-5 runs for consistency

**Example benchmarking script:**

```bash
#!/bin/bash
QUERY="SELECT COUNT(*) FROM store_sales"

echo "CPU Baseline:"
for i in {1..3}; do
  time ./duckdb tpcds_sf1.duckdb -c "$QUERY"
done

echo "GPU Sirius:"
for i in {1..3}; do
  time ./duckdb tpcds_sf1.duckdb << EOF
call gpu_buffer_init('8 GB', '4 GB');
call gpu_processing("$QUERY");
EOF
done
```

---

## Summary

**Three-step workflow:**

1. **Generate dataset:** `CALL dsdgen(sf=1)`
2. **Run on CPU:** `./duckdb database.duckdb -c "QUERY"`
3. **Run on GPU:** Use `gpu_processing("QUERY")`

**No manual downloads required** - DuckDB's TPC-DS extension generates all data automatically.

---

## Additional Resources

- [Sirius GitHub Repository](https://github.com/UWHustle/Sirius)
- [TPC-DS Benchmark Specification](https://www.tpc.org/tpcds/)
- [DuckDB Documentation](https://duckdb.org/docs/)

---

## Quick Command Reference

```bash
# Setup
cd ~/sirius/build/release
./duckdb tpcds_sf1.duckdb -c "INSTALL tpcds; LOAD tpcds; CALL dsdgen(sf=1);"

# Check data
./duckdb tpcds_sf1.duckdb -c "SHOW TABLES;"
./duckdb tpcds_sf1.duckdb -c "SELECT COUNT(*) FROM store_sales;"

# CPU query
./duckdb tpcds_sf1.duckdb -c "YOUR_QUERY"

# GPU query
./duckdb tpcds_sf1.duckdb << 'EOF'
call gpu_buffer_init('8 GB', '4 GB');
call gpu_processing("YOUR_QUERY");
EOF
```

---

*Last updated: December 2024*
