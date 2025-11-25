import matplotlib.pyplot as plt
import numpy as np

# TPC-DS Query Performance
queries = ['Q1', 'Q2', 'Q3', 'Q4', 'Q5', 'Q6', 'Q7', 'Q8']
times_ms = [20, 41, 77, 24, 144, 89, 18, 31]
tables_joined = [2, 3, 4, 2, 4, 4, 3, 3]

# Graph 1: Execution Time by Query
plt.figure(figsize=(10, 6))
plt.bar(queries, times_ms, color='steelblue')
plt.xlabel('Query', fontsize=12)
plt.ylabel('Execution Time (ms)', fontsize=12)
plt.title('TPC-DS Query Execution Times on GPU', fontsize=14, fontweight='bold')
plt.grid(axis='y', alpha=0.3)
for i, v in enumerate(times_ms):
    plt.text(i, v + 5, str(v) + 'ms', ha='center', fontsize=10)
plt.tight_layout()
plt.savefig('project_results/tpcds_execution_times.png', dpi=300)
print("✅ Created: tpcds_execution_times.png")

# Graph 2: Complexity vs Performance
plt.figure(figsize=(10, 6))
scatter = plt.scatter(tables_joined, times_ms, s=200, c=times_ms, cmap='viridis', alpha=0.7)
for i, query in enumerate(queries):
    plt.annotate(query, (tables_joined[i], times_ms[i]), 
                ha='center', va='center', fontweight='bold')
plt.xlabel('Number of Tables Joined', fontsize=12)
plt.ylabel('Execution Time (ms)', fontsize=12)
plt.title('Query Complexity vs Execution Time', fontsize=14, fontweight='bold')
plt.colorbar(scatter, label='Execution Time (ms)')
plt.grid(alpha=0.3)
plt.tight_layout()
plt.savefig('project_results/tpcds_complexity_analysis.png', dpi=300)
print("✅ Created: tpcds_complexity_analysis.png")

# Graph 3: TPC-H vs TPC-DS Comparison
plt.figure(figsize=(10, 6))
benchmarks = ['TPC-H\n(22 queries)', 'TPC-DS\n(8 queries)']
avg_times = [200, 56]  # Average execution times
max_times = [996, 144]
min_times = [2, 18]

x = np.arange(len(benchmarks))
width = 0.25

plt.bar(x - width, avg_times, width, label='Average', color='steelblue')
plt.bar(x, max_times, width, label='Maximum', color='coral')
plt.bar(x + width, min_times, width, label='Minimum', color='lightgreen')

plt.xlabel('Benchmark', fontsize=12)
plt.ylabel('Execution Time (ms)', fontsize=12)
plt.title('TPC-H vs TPC-DS Performance Comparison', fontsize=14, fontweight='bold')
plt.xticks(x, benchmarks)
plt.legend()
plt.grid(axis='y', alpha=0.3)
plt.tight_layout()
plt.savefig('project_results/tpch_vs_tpcds_comparison.png', dpi=300)
print("✅ Created: tpch_vs_tpcds_comparison.png")

print("\n✅ All graphs created successfully!")
