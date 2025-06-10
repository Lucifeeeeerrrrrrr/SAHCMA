#ifndef BAYES_MEM_H
#define BAYES_MEM_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <errno.h>

#define BASE_DIR "/etc/bayes_mem_c"
#define LOG_DIR "/var/log/bayes_mem_c"
#define TREND_LOG BASE_DIR "/cpu_trend_c.log"
#define HISTORY_FILE BASE_DIR "/cpu_history_c"
#define MAX_HISTORY 20
#define MAX_TDP 15

// Structure to hold CPU statistics
typedef struct {
    unsigned long user;
    unsigned long nice;
    unsigned long system;
    unsigned long idle;
} CPUStats;

// Function declarations
void initialize_directories(void);
int get_cpu_usage(void);
int calculate_average(int new_value);
char* determine_policy_key(int avg_load);
void apply_policy(void);
void log_status(int current_usage, int avg_usage, const char* policy_key);

#endif // BAYES_MEM_H 