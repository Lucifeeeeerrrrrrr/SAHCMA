#include "bayes_mem.h"

static int history[MAX_HISTORY];
static int history_count = 0;
static CPUStats prev_stats = {0};
static int first_read = 1;

void initialize_directories(void) {
    printf("Inicializando diretórios...\n");
    if (mkdir(BASE_DIR, 0755) != 0 && errno != EEXIST) {
        perror("Erro ao criar BASE_DIR");
        exit(1);
    }
    if (mkdir(LOG_DIR, 0755) != 0 && errno != EEXIST) {
        perror("Erro ao criar LOG_DIR");
        exit(1);
    }
    
    // Create files if they don't exist
    FILE *fp;
    fp = fopen(HISTORY_FILE, "a");
    if (!fp) {
        perror("Erro ao criar HISTORY_FILE");
        exit(1);
    }
    fclose(fp);
    
    fp = fopen(TREND_LOG, "a");
    if (!fp) {
        perror("Erro ao criar TREND_LOG");
        exit(1);
    }
    fclose(fp);
    printf("Diretórios inicializados com sucesso\n");
}

int get_cpu_usage(void) {
    CPUStats curr_stats;
    FILE *fp;
    char line[256];
    
    fp = fopen("/proc/stat", "r");
    if (!fp) {
        perror("Erro ao abrir /proc/stat");
        return -1;
    }
    
    if (!fgets(line, sizeof(line), fp)) {
        perror("Erro ao ler /proc/stat");
        fclose(fp);
        return -1;
    }
    
    if (sscanf(line, "cpu %lu %lu %lu %lu",
               &curr_stats.user,
               &curr_stats.nice,
               &curr_stats.system,
               &curr_stats.idle) != 4) {
        printf("Erro ao parsear estatísticas da CPU\n");
        fclose(fp);
        return -1;
    }
    fclose(fp);
    
    // Skip first reading to establish baseline
    if (first_read) {
        prev_stats = curr_stats;
        first_read = 0;
        return 0;
    }
    
    unsigned long prev_total = prev_stats.user + prev_stats.nice + 
                             prev_stats.system + prev_stats.idle;
    unsigned long curr_total = curr_stats.user + curr_stats.nice + 
                             curr_stats.system + curr_stats.idle;
    
    unsigned long diff_idle = curr_stats.idle - prev_stats.idle;
    unsigned long diff_total = curr_total - prev_total;
    
    prev_stats = curr_stats;
    
    if (diff_total > 0) {
        int usage = (int)((100 * (diff_total - diff_idle)) / diff_total);
        // Ajuste para leituras mais frequentes
        if (usage > 100) usage = 100;
        if (usage < 0) usage = 0;
        printf("Uso da CPU: %d%%\n", usage);
        return usage;
    }
    return 0;
}

int calculate_average(int new_value) {
    // Shift history array
    for (int i = MAX_HISTORY - 1; i > 0; i--) {
        history[i] = history[i-1];
    }
    history[0] = new_value;
    
    if (history_count < MAX_HISTORY) {
        history_count++;
    }
    
    // Calculate average
    int sum = 0;
    int valid_readings = 0;
    
    for (int i = 0; i < history_count; i++) {
        if (history[i] > 0) {  // Ignore readings of 0
            sum += history[i];
            valid_readings++;
        }
    }
    
    if (valid_readings == 0) return 0;
    return sum / valid_readings;
}

char* determine_policy_key(int avg_load) {
    static char key[4];
    
    if (avg_load >= 90) strcpy(key, "100");
    else if (avg_load >= 80) strcpy(key, "080");
    else if (avg_load >= 60) strcpy(key, "060");
    else if (avg_load >= 40) strcpy(key, "040");
    else if (avg_load >= 20) strcpy(key, "020");
    else if (avg_load >= 5) strcpy(key, "005");
    else strcpy(key, "000");
    
    return key;
}

void log_status(int current_usage, int avg_usage, const char* policy_key) {
    FILE *fp = fopen(LOG_DIR "/bayes.log", "a");
    if (!fp) {
        perror("Erro ao abrir arquivo de log");
        return;
    }
    
    time_t now = time(NULL);
    char *date = ctime(&now);
    date[strlen(date)-1] = '\0'; // Remove newline
    
    fprintf(fp, "\n🔄 %s | Uso: %d%% | Média: %d%% | Perfil: %s%%\n",
            date, current_usage, avg_usage, policy_key);
    fclose(fp);
    
    // Also print to stdout for debugging
    printf("🔄 %s | Uso: %d%% | Média: %d%% | Perfil: %s%%\n",
           date, current_usage, avg_usage, policy_key);
}

void apply_policy(void) {
    int current_usage = get_cpu_usage();
    if (current_usage < 0) {
        printf("Erro ao obter uso da CPU\n");
        return;
    }
    
    int avg_usage = calculate_average(current_usage);
    char *policy_key = determine_policy_key(avg_usage);
    
    log_status(current_usage, avg_usage, policy_key);
}

int main(void) {
    printf("Iniciando OTIMIZADOR BAYESIANO...\n");
    initialize_directories();
    printf("🟢 OTIMIZADOR BAYESIANO iniciado\n");
    
    while (1) {
        apply_policy();
        sleep(1);
    }
    
    return 0;
} 