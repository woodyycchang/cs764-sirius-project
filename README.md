# Sirius GPU Database — Benchmarking & Correctness Study (CS 764, Fall 2025)

Benchmarking and bug-discovery work on [Sirius](https://github.com/sirius-db/sirius),
the GPU-native SQL engine co-developed by NVIDIA and UW-Madison. This work led to
[7 merged upstream pull requests](https://github.com/sirius-db/sirius/pulls?q=is%3Apr+author%3Awoodyycchang+is%3Amerged)
fixing DECIMAL overflow, NULL handling, sign extension, and GPU aggregation corruption.

## What's here
- **TPC-H**: all 22 queries running on GPU, verified against CPU baseline (SF1)
- **TPC-DS**: 24-table setup (19M rows), CPU-vs-GPU comparison at SF10/SF100 — see `project_results/`
- **Bug discovery**: the DECIMAL `SUM()` aggregation error (a $1B sum silently became -$10M)
  first isolated here, then fixed upstream in
  [#118](https://github.com/sirius-db/sirius/pull/118) and [#410](https://github.com/sirius-db/sirius/pull/410)
- Reproducible setup scripts (`setup_sirius.sh`, `run_tpcds_benchmark.sh`)
- Benchmarks ran across two environments: Chameleon Cloud (Quadro RTX 6000, documented
  in `project_results/`) and a 4x Tesla V100 cluster

Team: Ayesha Shafique, Nida Tanveer, Woody Chang, Xuechun Jin.
