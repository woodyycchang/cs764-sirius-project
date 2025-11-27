# JOB Benchmark Results & Setup

## Issues Encountered

During the execution of the Join Order Benchmark (JOB) on Sirius, the following limitations and issues were identified:

1. **Aggregation Limitations**: `MIN` aggregation is currently only supported on `Int` types. It cannot be performed on other types (e.g., `VARCHAR`).
2. **Empty Result Sets**: Sirius terminates with an error if a query returns 0 rows.

## Setup Instructions

### 1. Sirius Setup

Follow the standard Sirius documentation for setup. The recommended approach used for this benchmark was **Option 4 (Pixi manifest)**:

1. Clone the Sirius repository.
2. Navigate into the directory.
3. Run `pixi shell` to set up the environment.
4. Build the project using `make`.
5. Verify the build with `make test`.

### 2. Database Setup (IMDB Dataset)

The JOB benchmark uses the IMDB dataset.

1. **Download Data**:
   Download the dataset from the [Join Order Benchmark repository](https://github.com/gregrahn/join-order-benchmark?tab=readme-ov-file).
   Direct link: [http://event.cwi.nl/da/job/imdb.tgz](http://event.cwi.nl/da/job/imdb.tgz)

   ```bash
   wget http://event.cwi.nl/da/job/imdb.tgz
   tar -xzvf imdb.tgz
   ```
2. **Load Data into DuckDB**:
   A `job_load.sql` script was created to define the schema (tables and datatypes and indexes) and load the CSV files.

   * Start DuckDB with a persistent database file (e.g., `job.db`):
     ```bash
     ./build/release/duckdb job.db
     ```
   * Run the load script inside the DuckDB shell:
     ```sql
     .read path/to/job_load.sql
     ```
   * Upon success, you should see progress bars reaching 100% and the `job.db` file will be populated.

### 3. Sirius Initialization

Initialize the GPU buffer before running queries. Since the JOB benchmark dataset is approximately 3.8 GB and sufficient RAM was available, the caching and processing regions were set to different values. I ran the benchmarkn with 4-8 once and 8-12 again correspondingly.

```sql
call gpu_buffer_init("4 GB", "4 GB");
```

## Benchmark Execution

### Query Modifications

The original SQL queries for the JOB benchmark contain `MIN` aggregations on selected columns, many of which are of type `VARCHAR`. Due to the limitation mentioned above (Sirius not supporting aggregation on `VARCHAR`), the queries were modified.

* **Modification**: A script was used to remove the `MIN` aggregation from all SQL queries.
* **Result**: The modified queries return all matched rows instead of the aggregated minimum. This modification allows the benchmark to run on Sirius and is considered comparable if the CPU baseline uses the same modified queries.

### Failing Queries

The following queries failed to execute successfully even after removal of `MIN`, likely because they return 0 rows (triggering the empty result set error):

* 16b
* 8c
* 2c
* 5b
* 5a
* 10b

## Performance Analysis

### Experimental Configurations

The benchmark was executed under three different configurations with each query run 5 times to evaluate the impact of memory allocation and indexing:

1. **Baseline (4GB/8GB)**:

   * Cache Region: 4 GB
   * Processing Region: 8 GB
   * Data: `modified_job_first_run_4_8`
2. **Increased Memory (8GB/12GB)**:

   * Cache Region: 8 GB
   * Processing Region: 12 GB
   * Data: `modified_job_second_run_8_12`
3. **Indexed (8GB/12GB + Indexes)**:

   * Cache Region: 8 GB
   * Processing Region: 12 GB
   * Indexes: Enabled on columns as described in original JOB repo
   * Data: `modified_job_index_8_12`
