# Terminar - Coletas

```

# --- Funções de Coleta de Estado (mantidas da versão anterior) ---
get_cpu_usage() {
    local usage avg_idle last_idle current_idle diff_idle
    local last_total current_total diff_total last_usage cpu_line
    
    cpu_line=$(grep '^cpu ' /proc/stat)
    read -r _ last_user last_nice last_system last_idle last_iowait last_irq last_softirq _ _ < <(grep '^cpu ' "$HISTORY_FILE.stat" 2>/dev/null || echo "cpu 0 0 0 0 0 0 0 0 0")
    read -r _ current_user current_nice current_system current_idle current_iowait current_irq current_softirq _ _ < <(echo "$cpu_line")
    
    echo "$cpu_line" > "$HISTORY_FILE.stat" # Salva estado atual para próximo ciclo

    last_total=$((last_user + last_nice + last_system + last_idle + last_iowait + last_irq + last_softirq))
    current_total=$((current_user + current_nice + current_system + current_idle + current_iowait + current_irq + current_softirq))
    
    diff_idle=$((current_idle - last_idle))
    diff_total=$((current_total - last_total))

    if (( diff_total > 0 )); then
        usage=$(( (1000 * (diff_total - diff_idle) / diff_total + 5) / 10 )) # Calcula % e arredonda
    else
        usage=0 # Evita divisão por zero no primeiro ciclo ou se stat não mudar
    fi
    
    echo "$usage"
}

get_cpu_temp() {
    local temp temp_file max_temp=0
    for temp_file in /sys/class/thermal/thermal_zone*/temp; do
        if [[ -r "$temp_file" ]]; then
            temp=$(<"$temp_file")
            if [[ "$temp" =~ ^[0-9]+$ ]] && (( temp > 0 && temp < 120000 )); then
               (( temp > SAFE_LIMITS[CPU_TEMP] )) && warn "Temperatura da CPU ($((temp/1000))C) excedeu limite seguro (${SAFE_LIMITS[CPU_TEMP]/1000}C)!"
               (( temp > max_temp )) && max_temp=$temp
            fi
        fi
    done
    [[ "$max_temp" -eq 0 ]] && warn "Não foi possível ler nenhuma temperatura válida da CPU."
    echo "$max_temp"
}

get_power_source() {
    # (Função mantida igual)
    if compgen -G "/sys/class/power_supply/AC*/online" > /dev/null; then
       for ac_file in /sys/class/power_supply/AC*/online; do
           if [[ -r "$ac_file" ]] && [[ $(<"$ac_file") == "1" ]]; then echo "1"; return; fi # 1 para AC
       done
    elif compgen -G "/sys/class/power_supply/ADP*/online" > /dev/null; then
       for adp_file in /sys/class/power_supply/ADP*/online; do
           if [[ -r "$adp_file" ]] && [[ $(<"$adp_file") == "1" ]]; then echo "1"; return; fi # 1 para AC
       done
    fi
    echo "0" # 0 para Bateria
}

get_current_governor() { # (Função mantida igual)
    local gov_file="/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
    [[ -r "$gov_file" ]] && cat "$gov_file" || echo "unknown"
}
get_current_swappiness() { # (Função mantida igual)
    sysctl -n vm.swappiness 2>/dev/null || echo "-1"
}
get_current_epb() { # (Função mantida igual)
    local epb_hex
    if command -v rdmsr &>/dev/null; then
       epb_hex=$(rdmsr -f 3:0 0x1b0 2>/dev/null) || epb_hex="00"
       printf "%02X" "$((16#$epb_hex))"
    else echo "00"; fi # Retorna 00 se não puder ler
}

```
