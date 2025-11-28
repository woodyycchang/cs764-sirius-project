

DB_FILE="tpcds_sf10.duckdb"
QUERIES_DIR="duckdb/extension/tpcds/dsdgen/queries"
OUTPUT_FILE="project_results/data/tpcds_comparison.txt"
DUCKDB_CMD="./build/release/duckdb"

MAX_QUERIES=99  # Test first 10 queries
GPU_CACHE_SIZE="8GB"
GPU_PROCESSING_SIZE="12GB"

trap 'echo "Interrupted!"; pkill -9 duckdb; exit 130' INT TERM

mkdir -p $(dirname $OUTPUT_FILE)

{
echo "======================================="
echo "TPC-DS SF10: CPU vs GPU (First $MAX_QUERIES queries)"
echo "Date: $(date)"
echo "======================================="
echo ""

# CPU tests
echo "Running CPU tests..."
declare -A cpu_times
declare -A cpu_results

query_num=0
for sqlfile in $QUERIES_DIR/*.sql; do
    ((query_num++))
    [ $query_num -gt $MAX_QUERIES ] && break
    
    query_name=$(basename $sqlfile .sql)
    echo -n "  Query $query_name: "
    
    cpu_output=$(mktemp)
    cpu_start=$(date +%s%3N)
    CUDA_VISIBLE_DEVICES="" $DUCKDB_CMD $DB_FILE < "$sqlfile" > $cpu_output 2>&1
    cpu_end=$(date +%s%3N)
    cpu_time=$((cpu_end - cpu_start))
    cpu_times[$query_name]=$cpu_time
    cpu_results[$query_name]=$(cat $cpu_output)
    rm -f $cpu_output
    
    echo "${cpu_time}ms"
done

echo ""
echo "Running GPU tests (single session)..."

# Create GPU script with markers
gpu_script=$(mktemp)
echo "CALL gpu_buffer_init('$GPU_CACHE_SIZE', '$GPU_PROCESSING_SIZE');" > $gpu_script
echo "SELECT COUNT(*) FROM store_sales;" >> $gpu_script  # warmup
echo ".timer on" >> $gpu_script

query_num=0
for sqlfile in $QUERIES_DIR/*.sql; do
    ((query_num++))
    [ $query_num -gt $MAX_QUERIES ] && break
    
    query_name=$(basename $sqlfile .sql)
    echo ".print '=== QUERY_START: $query_name ==='" >> $gpu_script
    cat "$sqlfile" >> $gpu_script
    echo ";" >> $gpu_script
    echo ".print '=== QUERY_END: $query_name ==='" >> $gpu_script
done

# Run GPU session
gpu_output=$(mktemp)
$DUCKDB_CMD $DB_FILE < $gpu_script > $gpu_output 2>&1

# Parse GPU output and save individual results
declare -A gpu_results
current_query=""
output_buffer=""
in_query=false

while IFS= read -r line; do
    if [[ $line == *"QUERY_START:"* ]]; then
        current_query=$(echo "$line" | sed 's/.*QUERY_START: \(.*\) ===/\1/')
        in_query=true
        output_buffer=""
    elif [[ $line == *"QUERY_END:"* ]]; then
        in_query=false
        if [ -n "$current_query" ]; then
            gpu_results[$current_query]="$output_buffer"
        fi
    elif $in_query; then
        output_buffer="${output_buffer}${line}"$'\n'
    fi
done < $gpu_output

echo ""
echo "======================================="
echo "Results Comparison"
echo "======================================="
printf "%-10s %10s %10s %10s %10s\n" "Query" "CPU(ms)" "GPU(ms)" "Speedup" "Match"
echo "-----------------------------------------------------------"

current_query=""
while IFS= read -r line; do
    if [[ $line == *"QUERY_START:"* ]]; then
        current_query=$(echo "$line" | sed 's/.*QUERY_START: \(.*\) ===/\1/')
    elif [[ $line == *"Run Time"* ]] && [ -n "$current_query" ]; then
        gpu_time=$(echo "$line" | grep -oP 'real \K[0-9.]+')
        gpu_time_ms=$(printf "%.0f" $(echo "$gpu_time * 1000" | bc))
        cpu_time_ms=${cpu_times[$current_query]}
        
        if [ $gpu_time_ms -gt 0 ]; then
            speedup=$(echo "scale=2; $cpu_time_ms / $gpu_time_ms" | bc)
        else
            speedup="N/A"
        fi
        
        # Compare results
        cpu_data=$(echo "${cpu_results[$current_query]}" | grep "│" | grep -v "^\s*│\s*$" | grep -v "rows\|column" | sort)
        gpu_data=$(echo "${gpu_results[$current_query]}" | grep "│" | grep -v "^\s*│\s*$" | grep -v "rows\|column" | sort)
        
        if [ "$cpu_data" == "$gpu_data" ]; then
            match="✓"
        else
            # Check if row counts match
            cpu_rows=$(echo "$cpu_data" | grep -c "│")
            gpu_rows=$(echo "$gpu_data" | grep -c "│")
            if [ "$cpu_rows" -eq "$gpu_rows" ] && [ "$cpu_rows" -gt 0 ]; then
                match="≈"
            else
                match="✗"
            fi
        fi
        
        printf "%-10s %10d %10d %10s %10s\n" "$current_query" "$cpu_time_ms" "$gpu_time_ms" "${speedup}x" "$match"
        
        current_query=""
    fi
done < $gpu_output

echo ""
echo "Match Legend: ✓ = Exact match, ≈ = Same row count, ✗ = Different, ? = Cannot compare"
echo "Note: GPU timing includes per-query overhead but not the one-time 9s initialization"

# Cleanup
rm -f $gpu_script $gpu_output

} | tee $OUTPUT_FILE

echo ""
echo "Results saved to: $OUTPUT_FILE"