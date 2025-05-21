#!/bin/bash
# Script ainda meio zuado, mas vou arrumar, mas fique a vontade para fazer um pull Request!
echo "🚀 Instalando daemon bayesiano fodástico..."

BIN_PATH="/usr/local/bin/bayes_opt.sh"
SERVICE_PATH="/etc/systemd/system/bayes_opt.service"

# 1. Script principal (o bicho feio todo)
cat <<'EOF' > "$BIN_PATH"
#!/bin/bash

BASE_DIR="/etc/bayes_mem"
mkdir -p "$BASE_DIR"
LOG_DIR="/var/log/bayes_mem"
mkdir -p "$LOG_DIR"
TREND_LOG="$BASE_DIR/cpu_trend.log"
HISTORY_FILE="$BASE_DIR/cpu_history"
MAX_HISTORY=5
MAX_TDP=15
CORES_TOTAL=$(nproc --all)

get_temp() {  
        local temp_raw  
        temp_raw=$(sensors 2>/dev/null | grep -m1 'Package id 0' | awk '{print $4}' | tr -d '+°C' 2>/dev/null)  
        echo "${temp_raw:-40}"  
    }  

    # Subfunção: Média de carga (1m, 5m, 15m)  
    get_loadavg() {  
        uptime | awk -F'load average: ' '{print $2}' | awk -F', ' '{print $1, $2, $3}'  
    }  

    # Subfunção: Cálculo de variância entre 1m e 5m  
    get_load_variance() {  
        local l1 l5 delta  
        read l1 l5 _ < <(get_loadavg)  
        delta=$(echo "$l1 - $l5" | bc -l)  
        echo "${delta#-}"  
    }  

    # Subfunção: Cooldown dinâmico baseado em carga e temperatura  
    calc_dynamic_cooldown() {  
        local delta_load=$(get_load_variance)  
        local temp=$(get_temp)  
        local cd=7  

        # Regras térmicas  
        if (( temp >= 75 )); then  
            cd=$((cd + 5))  
        elif (( temp >= 60 )); then  
            cd=$((cd + 3))  
        fi  

        # Regras de variância de carga  
        if (( $(echo "$delta_load > 1.5" | bc -l) )); then  
            cd=$((cd + 4))  
        elif (( $(echo "$delta_load > 0.8" | bc -l) )); then  
            cd=$((cd + 2))  
        elif (( $(echo "$delta_load < 0.3" | bc -l) )); then  
            cd=$((cd - 2))  
        fi  

        (( cd < 3 )) && cd=3  
        echo "$cd"  
    }  

faz_o_urro() {
    local new_val="$1" history_arr=() sum=0 avg=0
    [[ -f "$HISTORY_FILE" ]] && mapfile -t history_arr < "$HISTORY_FILE"
    history_arr+=("$new_val")
    (( ${#history_arr[@]} > MAX_HISTORY )) && history_arr=("${history_arr[@]: -$MAX_HISTORY}")
    for val in "${history_arr[@]}"; do sum=$((sum + val)); done
    avg=$((sum / ${#history_arr[@]}))
    printf "%s\n" "${history_arr[@]}" > "$HISTORY_FILE"
    echo "$avg"
}

get_cpu_usage() {
    local stat_hist_file="${BASE_DIR}/last_stat"
    local cpu_line prev_line usage=0
    cpu_line=$(grep -E '^cpu ' /proc/stat)
    prev_line=$(cat "$stat_hist_file" 2>/dev/null || echo "$cpu_line")
    echo "$cpu_line" > "$stat_hist_file"
    read -r _ pu pn ps pi _ _ _ _ _ <<< "$prev_line"
    read -r _ cu cn cs ci _ _ _ _ _ <<< "$cpu_line"
    local prev_total=$((pu + pn + ps + pi))
    local curr_total=$((cu + cn + cs + ci))
    local diff_idle=$((ci - pi))
    local diff_total=$((curr_total - prev_total))
    if (( diff_total > 0 )); then
        usage=$(( (100 * (diff_total - diff_idle)) / diff_total ))
    fi
    echo "$usage"
}

determine_policy_key_from_avg() {
    local avg_load=$1 key="000"
    if (( avg_load >= 90 )); then key="100"
    elif (( avg_load >= 80 )); then key="080"
    elif (( avg_load >= 60 )); then key="060"
    elif (( avg_load >= 40 )); then key="040"
    elif (( avg_load >= 20 )); then key="020"
    elif (( avg_load >= 5 )); then key="005"
    elif (( avg_load >= 0 )); then key="000"
    fi
    echo "$key"
}

apply_cpu_governor() {  
    local key="$1"  
    declare -A MAP=(  
        ["000"]="ondemand"  
        ["005"]="ondemand"  
        ["020"]="ondemand"  
        ["040"]="ondemand"  
        ["060"]="performance"  
        ["080"]="performance"  
        ["100"]="performance"  
    )  
    local cpu_gov="${MAP[$key]:-ondemand}"  
    local base_dir="${BASE_DIR:-/tmp}"  
    local last_gov_file="${base_dir}/last_gov"  
    local cooldown_file="${base_dir}/gov_cooldown"  
    local available_govs_file="/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors"  
    local now=$(date +%s)  

    # Subfunção: Valida governor  
    is_valid_governor() {  
        grep -qw "$cpu_gov" "$available_govs_file" || {  
            echo "✖ Governor '$cpu_gov' não suportado. Disponíveis: $(cat "$available_govs_file")" >&2  
            return 1  
        }  
    }  

    # Subfunção: Aplica governor em todos os CPUs  
    set_governor_all_cpus() {  
        local gov="$1"  
        for cpu_dir in /sys/devices/system/cpu/cpu[0-9]*; do  
            if [[ -w "$cpu_dir/cpufreq/scaling_governor" ]]; then  
                if ! echo "$gov" > "$cpu_dir/cpufreq/scaling_governor" 2>/dev/null; then  
                    echo "  ‼ Falha ao aplicar '$gov' em $cpu_dir" >&2  
                fi  
            else  
                echo "  ‼ Permissão negada em $cpu_dir" >&2  
            fi  
        done  
    }  

    # Valida governor  
    if ! is_valid_governor "$cpu_gov"; then  
        return 1  
    fi  

    # Estado atual  
    local last_gov="none"  
    [[ -f "$last_gov_file" ]] && last_gov=$(cat "$last_gov_file")  

    # Cálculo de cooldown  
    local last_change=0  
    [[ -f "$cooldown_file" ]] && last_change=$(date -r "$cooldown_file" +%s)  
    local delta=$((now - last_change))  
    local dynamic_cd=$(calc_dynamic_cooldown)  

    echo "⚙ Governor: Key=${key} | Mapeado=${cpu_gov} | Último=${last_gov} | CD=${dynamic_cd}s"  

    # Aplicação condicional  
    if [[ "$cpu_gov" != "$last_gov" ]] && [[ "$delta" -ge "$dynamic_cd" ]]; then  
        echo "  🔄 Aplicando governor..."  
        set_governor_all_cpus "$cpu_gov"  
        echo "$cpu_gov" > "$last_gov_file"  
        touch "$cooldown_file"  
    else  
        echo "  ⚠ Inação: "  
        echo "    - Governor igual? $( [[ "$cpu_gov" == "$last_gov" ]] && echo "SIM" || echo "NÃO" )"  
        echo "    - Delta cooldown: ${delta}s/${dynamic_cd}s"  
    fi  
}  

apply_turbo_boost() {
    local key="$1"
    declare -A MAP
    MAP["000"]="ondemand"
    MAP["005"]="ondemand"
    MAP["020"]="ondemand"
    MAP["040"]="ondemand"
    MAP["060"]="performance"
    MAP["080"]="performance"
    MAP["100"]="performance"
    local gov="${MAP[$key]}"
    local boost_path="/sys/devices/system/cpu/cpufreq/boost"
    local boost_file="${BASE_DIR}/last_turbo"
    local last="none"
    [[ -f "$boost_file" ]] && last=$(cat "$boost_file")
    if [[ -f "$boost_path" ]]; then
        if [[ "$gov" == "performance" && "$last" != "1" ]]; then
            echo 1 > "$boost_path"
            echo "1" > "$boost_file"
            echo "🚀 Turbo Boost ativado"
        elif [[ "$gov" != "performance" && "$last" != "0" ]]; then
            echo 0 > "$boost_path"
            echo "0" > "$boost_file"
            echo "💤 Turbo Boost desativado"
        fi
    fi
}


apply_tdp_profile() {
    local key="$1"
    declare -A MAP
    MAP["000"]="0 0"
    MAP["005"]="$((MAX_TDP * 15 / 100)) $((MAX_TDP * 0))"
    MAP["020"]="$((MAX_TDP * 30 / 100)) $((MAX_TDP * 10 / 100))"
    MAP["040"]="$((MAX_TDP * 45 / 100)) $((MAX_TDP * 20 / 100))"
    MAP["060"]="$((MAX_TDP * 60 / 100)) $((MAX_TDP * 30 / 100))"
    MAP["080"]="$((MAX_TDP * 75 / 100)) $((MAX_TDP * 40 / 100))"
    MAP["100"]="$((MAX_TDP)) $((MAX_TDP * 50 / 100))"
    local tdp_pair="${MAP[$key]}"
    [[ -z "$tdp_pair" ]] && { echo "❌ Perfil TDP inválido"; return 1; }
    read target_max target_min <<< "$tdp_pair"
    
    local now=$(date +%s)
    local current_power="${target_min} ${target_max}"
    local last_power_file="${BASE_DIR}/last_power"
    local cooldown_file="${BASE_DIR}/power_cooldown"
    local last_power="none"
    [[ -f "$last_power_file" ]] && last_power=$(cat "$last_power_file")
    local last_change=0
    [[ -f "$cooldown_file" ]] && last_change=$(date -r "$cooldown_file" +%s)
    local delta=$((now - last_change))
    local dynamic_cd=$(calc_dynamic_cooldown)
    echo "🌡  Temp=$(get_temp)°C | ΔCarga=$(get_load_variance) | Cooldown=${dynamic_cd}s"
    if [[ "$current_power" != "$last_power" ]]; then
        if (( delta >= dynamic_cd )); then
            echo "⚡ Aplicando TDP: MIN=${target_min}W | MAX=${target_max}W"
            echo $((target_min * 1000000)) > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_1_power_limit_uw 2>/dev/null
            echo $((target_max * 1000000)) > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw 2>/dev/null
            echo "$current_power" > "$last_power_file"
            touch "$cooldown_file"
        else
            echo "⏳ Cooldown ativo: ${delta}s/${dynamic_cd}s"
        fi
    else
        echo "✅ TDP já aplicado (MIN=${target_min}, MAX=${target_max})"
    fi
}

apply_zram_config() {
    local key="$1"
    local key="$1"  
    declare -A MAP=(  
        ["000"]="0 0"  
        ["005"]="$((CORES_TOTAL * 15 / 100)) zstd"  
        ["020"]="$((CORES_TOTAL * 30 / 100)) lz4hc"  
        ["040"]="$((CORES_TOTAL * 45 / 100)) lz4"  
        ["060"]="$((CORES_TOTAL * 60 / 100)) lzo"  
        ["080"]="$((CORES_TOTAL * 50 / 100)) lzo"  
        ["100"]="$CORES_TOTAL lzo-rle"  
    )  
    local streams_alg="${MAP[$key]}" && local streams="${streams_alg% *}" local alg="${streams_alg#* }"  
    local last_streams_file="${BASE_DIR}/last_zram_streams"
    local last_alg_file="${BASE_DIR}/last_zram_algorithm"
    local cooldown_file="${BASE_DIR}/cooldown_zram"
    local current_streams=0
    local current_alg="none"
    [[ -f "$last_streams_file" ]] && current_streams=$(cat "$last_streams_file")
    [[ -f "$last_alg_file" ]] && current_alg=$(cat "$last_alg_file")
    if (( streams != current_streams || alg != current_alg )); then
        if [[ ! -f "$cooldown_file" || $(($(date +%s) - $(date -r "$cooldown_file" +%s))) -ge 30 ]]; then
            echo "🔧 Reconfigurando ZRAM: Streams=$streams Alg=$alg"
            for dev in /dev/zram*; do swapoff "$dev" 2>/dev/null; done
            sleep 0.3
            modprobe -r zram 2>/dev/null
            modprobe zram num_devices="$streams"
            for i in /dev/zram*; do
                dev=$(basename "$i")
                echo 1 > "/sys/block/$dev/reset"
                echo "$alg" > "/sys/block/$dev/comp_algorithm"
                echo 1G > "/sys/block/$dev/disksize"
                mkswap "/dev/$dev"
                swapon "/dev/$dev"
            done
            echo "$streams" > "$last_streams_file"
            echo "$alg" > "$last_alg_file"
            touch "$cooldown_file"
        else
            echo "⏳ Cooldown ZRAM ativo"
        fi
    else
        echo "✅ ZRAM já configurado"
    fi
}

apply_all() {
    local current_usage=$(get_cpu_usage)
    local avg_usage=$(faz_o_urro "$current_usage")
    local policy_key=$(determine_policy_key_from_avg "$avg_usage")
    echo -e "\n🔄 $(date) | Uso: ${current_usage}% | Média: ${avg_usage}% | Perfil: ${policy_key}%"
    apply_cpu_governor "$policy_key"
    apply_turbo_boost "$policy_key"
    apply_tdp_profile "$policy_key"
    apply_zram_config "$policy_key"
}

[[ ! -f "$HISTORY_FILE" ]] && touch "$HISTORY_FILE"
[[ ! -f "$TREND_LOG" ]] && touch "$TREND_LOG"
echo "🟢 Iniciando OTIMIZADOR BAYESIANO"
while true; do
    {
        echo "🧾 Último perfil aplicado: $(date)"
        apply_all
    } >> "$LOG_DIR/bayes.log"
    sleep 5
done

EOF

chmod +x "$BIN_PATH"

# 2. Service systemd
cat <<EOF > "$SERVICE_PATH"
[Unit]
Description=Daemon Bayesiano de Otimização de CPU e ZRAM
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
ExecStart=$BIN_PATH
Restart=always
RestartSec=3
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "🔧 Recarregando systemd..."
systemctl daemon-reexec
systemctl daemon-reload

echo "✅ Habilitando serviço no boot..."
systemctl enable --now bayes_opt.service

echo "📡 Status do serviço:"
systemctl status bayes_opt.service --no-pager
