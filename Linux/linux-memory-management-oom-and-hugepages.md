# Linux Memory Management: OOM Protection, Overcommit, and Huge Pages

## Overview

This document covers Linux memory management concepts frequently used in production environments to improve application stability, 
prevent unwanted OOM kills, and optimize memory performance for large-memory workloads.

## OOM Killer Process Protection

Linux uses the Out Of Memory (OOM) Killer when the system runs out of available memory.
The `oom_score_adj` parameter controls which processes are preferred or protected during OOM events.

### Value Reference

| Value | Behavior |
|---------|---------|
| -1000 | Never kill (critical process) |
| 0 | Default priority |
| +1000 | Kill first |


## Protecting Critical Processes

Example: Protect a database process from OOM termination

echo -1000 > /proc/<PID>/oom_score_adj

Example:

echo -1000 > /proc/1234/oom_score_adj

## Making Non-Critical Processes Disposable

echo 500 > /proc/5678/oom_score_adj

This allows non-essential jobs to be terminated before critical services.

## Memory Overcommit Configuration

Linux can allocate more virtual memory than physically available.

Check current setting:

cat /proc/sys/vm/overcommit_memory

### Overcommit Modes

| Value | Meaning                  |
| ----- | ------------------------ |
| 0     | Heuristic mode (default) |
| 1     | Always allow allocations |
| 2     | Strict accounting        |


## Recommended Configuration

For database and critical application servers:

vm.overcommit_memory = 2


Benefits:

* Prevents excessive memory allocation
* Reduces unexpected OOM conditions
* Improves memory predictability


## Huge Pages

### Default Linux Memory Page
4 KB

### Huge Page Sizes

2 MB
1 GB


## Why Huge Pages Matter

Huge pages reduce:

* Page table size
* TLB misses
* CPU overhead
* Memory fragmentation

Benefits:

* Faster memory access
* Reduced CPU utilization
* Predictable application latency
* Improved performance for memory-intensive workloads

## Common Workloads Using Huge Pages

* Oracle Database
* PostgreSQL
* Java JVM Applications
* SAP Systems
* High Performance Computing Applications

## Check Current Huge Pages

grep Huge /proc/meminfo

## Configure Huge Pages

sysctl -w vm.nr_hugepages=1024
---

## Important Considerations

Huge page memory is:

* Pre-allocated
* Locked in memory
* Non-swappable

Implications:

* Reduces memory available to kernel
* Reduces filesystem cache availability
* Incorrect sizing may trigger OOM events


## Best Practices

Always:

* Calculate application memory requirements accurately
* Leave sufficient RAM for operating system processes
* Leave memory for filesystem cache
* Validate huge page utilization after configuration
* Monitor memory pressure regularly

## When to Use Huge Pages

Recommended for:

✔ Large memory applications

✔ Stable memory consumption patterns

✔ Performance-sensitive workloads

✔ Enterprise database servers

✔ JVM-based applications

## Validation Commands

Check OOM score:

cat /proc/<PID>/oom_score_adj

Check overcommit:

cat /proc/sys/vm/overcommit_memory

Check huge pages:
grep Huge /proc/meminfo

## Key Learning

### Major Insights

* OOM protection helps preserve critical services during memory exhaustion.
* Overcommit configuration directly impacts memory allocation behavior.
* Huge pages improve performance for large-memory applications.
* Incorrect huge page sizing can reduce available memory and increase OOM risk.
* Database and enterprise workloads benefit significantly from proper memory tuning.

## Skills Demonstrated

* Linux memory management
* OOM killer tuning
* Kernel parameter configuration
* Huge page management
* Database performance optimization
* Production system tuning
* Capacity planning
* Performance troubleshooting

```
```
