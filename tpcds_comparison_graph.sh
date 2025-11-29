#!/bin/bash
# tpcds_comparison_graph.sh - Generate comparison graphs from benchmark results

INPUT_SF10="project_results/data/tpcds_comparison.txt"
INPUT_SF100="project_results/data/tpcds_sf100.txt"
OUTPUT_DIR="project_results/visualizations"

# Create output directory
mkdir -p $OUTPUT_DIR

# Python script to generate graphs
python3 << 'EOF'
import re
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path

# Representative queries (15 queries covering different performance patterns)
# High Speedup: Q03, Q32, Q37, Q62, Q90, Q96
# Medium Speedup: Q05, Q07, Q08, Q49, Q77
# Low Speedup: Q04, Q14, Q22, Q67
# GPU Slower: Q74
SELECTED_QUERIES = ['03', '04', '05', '07', '08', '14', '22', '32', '37', '49', '62', '67', '74', '77', '90', '96']

def parse_results(filepath):
    """Parse benchmark results file"""
    data = {}
    try:
        with open(filepath, 'r') as f:
            content = f.read()
            
        # Find the Results Comparison section
        match = re.search(r'Results Comparison.*?Query\s+CPU\(ms\)\s+GPU\(ms\)\s+Speedup\s+(?:Saved\(ms\)\s+)?Match\n-+\n(.*?)(?:\n\n|Match Legend)', content, re.DOTALL)
        if not match:
            print(f"Warning: Could not find results section in {filepath}")
            return data
            
        lines = match.group(1).strip().split('\n')
        
        for line in lines:
            parts = line.split()
            if len(parts) >= 4:
                query = parts[0]
                cpu_time = int(parts[1])
                gpu_time = int(parts[2])
                saved_time = cpu_time - gpu_time
                
                data[query] = {
                    'cpu': cpu_time,
                    'gpu': gpu_time,
                    'saved': saved_time
                }
    except Exception as e:
        print(f"Error parsing {filepath}: {e}")
    
    return data

def plot_execution_time(data, title, output_file, dataset_name):
    """Plot CPU vs GPU execution time"""
    queries = [q for q in SELECTED_QUERIES if q in data]
    if not queries:
        print(f"Warning: No data found for {dataset_name}")
        return
        
    cpu_times = [data[q]['cpu'] for q in queries]
    gpu_times = [data[q]['gpu'] for q in queries]
    
    x = np.arange(len(queries))
    width = 0.35
    
    fig, ax = plt.subplots(figsize=(14, 6))
    bars1 = ax.bar(x - width/2, cpu_times, width, label='CPU', color='#ef4444', alpha=0.8)
    bars2 = ax.bar(x + width/2, gpu_times, width, label='GPU', color='#3b82f6', alpha=0.8)
    
    ax.set_xlabel('Query Number', fontsize=12, fontweight='bold')
    ax.set_ylabel('Execution Time (ms)', fontsize=12, fontweight='bold')
    ax.set_title(title, fontsize=14, fontweight='bold', pad=20)
    ax.set_xticks(x)
    ax.set_xticklabels([f'Q{q}' for q in queries], rotation=45, ha='right')
    ax.legend(fontsize=11)
    ax.grid(axis='y', alpha=0.3, linestyle='--')
    
    # Add value labels on bars for queries with significant differences
    for i, (q, cpu, gpu) in enumerate(zip(queries, cpu_times, gpu_times)):
        if cpu > 1000 or gpu > 1000:  # Label large values
            ax.text(i - width/2, cpu + max(cpu_times)*0.02, f'{cpu}', 
                   ha='center', va='bottom', fontsize=8)
            ax.text(i + width/2, gpu + max(gpu_times)*0.02, f'{gpu}', 
                   ha='center', va='bottom', fontsize=8)
    
    plt.tight_layout()
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"Saved: {output_file}")
    plt.close()

def plot_time_saved(sf10_data, sf100_data, output_file):
    """Plot time saved comparison between SF10 and SF100"""
    queries = [q for q in SELECTED_QUERIES if q in sf10_data and q in sf100_data]
    if not queries:
        print("Warning: No matching data found for time saved plot")
        return
        
    sf10_saved = [sf10_data[q]['saved'] for q in queries]
    sf100_saved = [sf100_data[q]['saved'] for q in queries]
    
    x = np.arange(len(queries))
    width = 0.35
    
    fig, ax = plt.subplots(figsize=(14, 6))
    bars1 = ax.bar(x - width/2, sf10_saved, width, label='SF10 (2.9GB)', color='#3b82f6', alpha=0.8)
    bars2 = ax.bar(x + width/2, sf100_saved, width, label='SF100 (100GB)', color='#10b981', alpha=0.8)
    
    ax.set_xlabel('Query Number', fontsize=12, fontweight='bold')
    ax.set_ylabel('Time Saved by GPU (ms)', fontsize=12, fontweight='bold')
    ax.set_title('Time Saved: SF10 vs SF100', fontsize=14, fontweight='bold', pad=20)
    ax.set_xticks(x)
    ax.set_xticklabels([f'Q{q}' for q in queries], rotation=45, ha='right')
    ax.legend(fontsize=11)
    ax.grid(axis='y', alpha=0.3, linestyle='--')
    ax.axhline(y=0, color='red', linestyle='--', linewidth=1, alpha=0.5)
    
    # Highlight queries with negative savings (GPU slower)
    for i, (q, s10, s100) in enumerate(zip(queries, sf10_saved, sf100_saved)):
        if s100 < 0:
            ax.text(i + width/2, s100 - max(sf100_saved)*0.05, f'{s100}', 
                   ha='center', va='top', fontsize=8, color='red', fontweight='bold')
    
    plt.tight_layout()
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"Saved: {output_file}")
    plt.close()

# Main execution
print("Parsing benchmark results...")
sf10_data = parse_results('project_results/data/tpcds_comparison.txt')
sf100_data = parse_results('project_results/data/tpcds_sf100.txt')

print(f"SF10 queries found: {len(sf10_data)}")
print(f"SF100 queries found: {len(sf100_data)}")

if not sf10_data or not sf100_data:
    print("Error: Could not parse data files. Please check file paths and format.")
    exit(1)

print("\nGenerating graphs...")

# Graph 1: SF10 CPU vs GPU Execution Time
plot_execution_time(
    sf10_data,
    'TPC-DS SF10: CPU vs GPU Execution Time (15 Representative Queries)',
    'project_results/visualizations/sf10_cpu_vs_gpu.png',
    'SF10'
)

# Graph 2: SF100 CPU vs GPU Execution Time
plot_execution_time(
    sf100_data,
    'TPC-DS SF100: CPU vs GPU Execution Time (15 Representative Queries)',
    'project_results/visualizations/sf100_cpu_vs_gpu.png',
    'SF100'
)

# Graph 3: Time Saved Comparison
plot_time_saved(
    sf10_data,
    sf100_data,
    'project_results/visualizations/time_saved_comparison.png'
)

print("\nAll graphs generated successfully!")
print(f"Output directory: project_results/visualizations/")

EOF