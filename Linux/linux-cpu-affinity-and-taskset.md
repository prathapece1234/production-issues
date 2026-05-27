# Linux CPU Affinity and Taskset

## Overview

CPU affinity is the process of binding a process or thread to specific CPU cores. This helps improve cache locality, 
reduce scheduler overhead, and provide more predictable application performance.

## What is CPU Affinity?

By default, the Linux scheduler can move a process between any available CPU core.

Benefits:
- Fair CPU utilization
- Dynamic workload balancing

Potential Drawbacks:
- Cache invalidation
- Increased context switching
- Higher latency
- Reduced performance consistency

CPU affinity instructs Linux to execute a process only on specific CPU cores.

## Without CPU Affinity

Characteristics:

- Process moves across multiple CPUs
- L1/L2/L3 CPU cache becomes less effective
- Increased context switching
- Higher latency
- Unpredictable performance


## With CPU Affinity

Benefits:

- Improved CPU cache utilization
- Better performance consistency
- Lower latency
- Reduced scheduler overhead
- Predictable application behavior


## Common Use Cases

CPU affinity is commonly used for:

- Database servers
- Java JVM applications
- Real-time applications
- Low-latency workloads
- High CPU batch jobs
- NUMA-based systems
- Performance-sensitive services

## Taskset Utility

`taskset` is a Linux utility used to:

- Set CPU affinity
- View CPU affinity
- Modify CPU affinity of running processes

## Start a Process with CPU Affinity

### Run on CPU 0

taskset -c 0 ./app.sh

### Run on CPUs 2 and 3

taskset -c 2,3 java -jar app.jar

### Run on CPU Range

taskset -c 4-7 python heavy_job.py

## Modify Affinity of a Running Process

Bind PID 2456 to CPUs 1 and 2:

taskset -cp 1,2 2456

## View Current CPU Affinity

taskset -cp <PID>

Example:
taskset -cp 2456

## Check Current Executing CPU

ps -o pid,psr,comm -p <PID>

Example:
ps -o pid,psr,comm -p 2456

### Output Fields

| Field | Description                               |
| ----- | ----------------------------------------- |
| PID   | Process ID                                |
| PSR   | Processor currently executing the process |
| COMM  | Process name                              |

---

## Thread-Level Analysis

Display all threads for a process: ps -T -p <PID>

Example: ps -T -p 2456

## Important Note

When CPU affinity is configured:

* All threads inherit the assigned CPU affinity
* Threads execute only within the assigned CPU set
* Threads compete for CPU time within those allocated cores

## Benefits of CPU Affinity

* Improved cache locality
* Reduced CPU migration
* Lower context switching
* Better application responsiveness
* More predictable performance
* Enhanced NUMA awareness

## Best Practices

* Use CPU affinity for performance-critical workloads
* Avoid excessive CPU pinning
* Monitor CPU utilization after affinity changes
* Leave CPUs available for operating system processes
* Test application performance before and after implementation

## Validation Commands

Check CPU information: lscpu

View process affinity: taskset -cp <PID>

View running CPU: ps -o pid,psr,comm -p <PID>

View threads: ps -T -p <PID>


## Key Learning

### Major Insights

* CPU affinity improves cache efficiency and reduces latency.
* Linux scheduler normally moves processes between CPUs for fairness.
* Taskset provides a simple mechanism for CPU pinning.
* CPU affinity is particularly useful for databases, JVMs, and latency-sensitive applications.
* Proper CPU allocation can significantly improve workload consistency.


## Skills Demonstrated

* Linux performance tuning
* CPU affinity management
* Taskset administration
* Process scheduling analysis
* Thread-level diagnostics
* NUMA awareness
* System performance optimization
* Production workload tuning
