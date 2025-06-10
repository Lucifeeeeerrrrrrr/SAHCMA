# Bayesian Memory Optimizer

A C implementation of a Bayesian memory optimizer that monitors CPU usage and applies different policy keys based on the usage patterns.

## Features

- Monitors CPU usage in real-time
- Maintains a history of CPU usage for trend analysis
- Applies different policy keys based on CPU usage thresholds
- Logs all activities to `/var/log/bayes_mem/bayes.log`

## Building

To build the project, simply run:

```bash
make
```

To clean the build files:

```bash
make clean
```

## Usage

The program needs to be run with root privileges since it needs to access system directories:

```bash
sudo ./bayes_mem
```

## Policy Keys

The system uses the following policy keys based on CPU usage:

- 100%: CPU usage ≥ 90%
- 080%: CPU usage ≥ 80%
- 060%: CPU usage ≥ 60%
- 040%: CPU usage ≥ 40%
- 020%: CPU usage ≥ 20%
- 005%: CPU usage ≥ 5%
- 000%: CPU usage < 5%

## Directory Structure

- `/etc/bayes_mem/`: Configuration and history files
- `/var/log/bayes_mem/`: Log files

## Requirements

- Linux operating system
- GCC compiler
- Root privileges for running the program 