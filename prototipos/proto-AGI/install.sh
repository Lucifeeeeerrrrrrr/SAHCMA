#!/bin/bash

echo "🚀 Instalando daemon bayesiano fodástico..."

BIN_PATH="/usr/local/bin/bayes_opt.sh"
SERVICE_PATH="/etc/systemd/system/bayes_opt.service"

# 1. Script principal (o bicho feio todo)
cat <<'EOF' > "$BIN_PATH"
#!/bin/bash
# Script ainda esta meio cagado, caso queira contribuir, que deus te abençoe, ou algum orixa aleatorio por ai
BASE_DIR="/etc/bayes_mem"
LOG_DIR="/var/log/bayes_mem"
TREND_LOG="$BASE_DIR/cpu_trend.log"
HISTORY_FILE="$BASE_DIR/cpu_history"
MAX_HISTORY=5
MAX_TDP=15
CORES_TOTAL=$(nproc --all)

initialize_directories() {
    mkdir -p "$BASE_DIR" "$LOG_DIR"
    [[ -f "$HISTORY_FILE" ]] || touch "$HISTORY_FILE"
    [[ -f "$TREND_LOG" ]] || touch "$TREND_LOG"
}

get_temp() {
    local temp_raw
    temp_raw=$(sensors 2>/dev/null | awk '
        /[0-9]+\.[0-9]+°C/ {
            for (i = 1; i <= NF; i++) {
                if ($i ~ /\+?[0-9]+\.[0-9]+°C/) {
                    gsub(/[^0-9.]/, "", $i);
                    print $i;
                    exit
                }
            }
        }' | cut -d'.' -f1)

    echo "${temp_raw:-40}"
}

get_loadavg() {
    uptime | awk -F'load average: ' '{print $2}' | awk -F', ' '{print $1, $2, $3}'
}

get_load_variance() {
    read l1 l5 _ < <(get_loadavg)
    local delta=$(echo "$l1 - $l5" | bc -l)
    delta=$(echo "$delta" | sed 's/-//')
    echo "$delta"
}

calc_dynamic_cooldown() {
    local delta_load=$(get_load_variance)
    local temp=$(get_temp)
    local cd=7
    if [[ "$temp" -ge 75 ]]; then
        cd=$((cd + 5))
    elif [[ "$temp" -ge 60 ]]; then
        cd=$((cd + 3))
    fi
    awk -v delta="$delta_load" -v cd="$cd" 'BEGIN {
        if (delta > 1.5) cd += 4;
        else if (delta > 0.8) cd += 2;
        else if (delta < 0.3) cd -= 2;
        if (cd < 3) cd = 3;
        print int(cd);
    }'
}

calc_impact_cooldown() {
    local base_cd=$(calc_dynamic_cooldown)
    local factor="$1"
    awk -v cd="$base_cd" -v f="$factor" 'BEGIN { print int(cd * f) }'
}

faz_o_urro() {
    local new_val="$1"
    local history_arr=()
    local sum=0 avg=0
    [[ -f "$HISTORY_FILE" ]] && mapfile -t history_arr < "$HISTORY_FILE"
    history_arr+=("$new_val")
    (( ${#history_arr[@]} > MAX_HISTORY )) && history_arr=("${history_arr[@]: -$MAX_HISTORY}")
    for val in "${history_arr[@]}"; do sum=$((sum + val)); done
    avg=$((sum / ${#history_arr[@]}))
    printf "%s\n" "${history_arr[@]}" | sudo tee "$HISTORY_FILE" >/dev/null
    echo "$avg"
}

get_cpu_usage() {
    local stat_hist_file="${BASE_DIR}/last_stat"
    local cpu_line prev_line usage=0
    cpu_line=$(grep -E '^cpu ' /proc/stat)
    prev_line=$(cat "$stat_hist_file" 2>/dev/null || echo "$cpu_line")
    echo "$cpu_line" | sudo tee "$stat_hist_file" >/dev/null
    read -r _ pu pn ps pi _ <<< "$prev_line"
    read -r _ cu cn cs ci _ <<< "$cpu_line"
    local prev_total=$((pu + pn + ps + pi))
    local curr_total=$((cu + cn + cs + ci))
    local diff_idle=$((ci - pi))
    local diff_total=$((curr_total - prev_total))
    (( diff_total > 0 )) && usage=$(( (100 * (diff_total - diff_idle)) / diff_total ))
    echo "$usage"
}

determine_policy_key_from_avg() {
    local avg_load=$1 key="000"
    (( avg_load >= 90 )) && key="100"
    (( avg_load >= 80 )) && key="080"
    (( avg_load >= 60 )) && key="060"
    (( avg_load >= 40 )) && key="040"
    (( avg_load >= 20 )) && key="020"
    (( avg_load >= 5 )) && key="005"
    echo "$key"
}

apply_cpu_governor() {
    local key="$1"
    declare -A MAP=(
        ["000"]="powersave"
        ["005"]="powersave"
        ["020"]="powersave"
        ["040"]="powersave"
        ["060"]="performance"
        ["080"]="performance"
        ["100"]="performance"
    )
    local cpu_gov="${MAP[$key]:-powersave}"
    local last_gov_file="${BASE_DIR}/last_gov"
    local cooldown_file="${BASE_DIR}/gov_cooldown"
    local now=$(date +%s)

    local last_gov="none"
    [[ -f "$last_gov_file" ]] && last_gov=$(cat "$last_gov_file")

    local last_change=0
    [[ -f "$cooldown_file" ]] && last_change=$(date -r "$cooldown_file" +%s)
    local delta=$((now - last_change))
    local dynamic_cd=$(calc_impact_cooldown 1.0)

    if [[ "$cpu_gov" != "$last_gov" && "$delta" -ge "$dynamic_cd" ]]; then
        echo "🔄 Aplicando governor $cpu_gov"
        for policy in /sys/devices/system/cpu/cpufreq/policy*; do
            echo "$cpu_gov" | sudo tee "$policy/scaling_governor" >/dev/null
        done
        echo "$cpu_gov" | sudo tee "$last_gov_file" >/dev/null
        sudo touch "$cooldown_file"
    else
        echo "⚠ Governor atual ou cooldown ativo: $cpu_gov (${delta}s/${dynamic_cd}s)"
    fi
}

apply_turbo_boost() {
    local key="$1"
    declare -A MAP=(
        ["000"]="ondemand" ["005"]="ondemand" ["020"]="ondemand" ["040"]="ondemand" 
        ["060"]="performance" ["080"]="performance" ["100"]="performance"
    )
    local gov="${MAP[$key]}" boost_path="/sys/devices/system/cpu/cpufreq/boost"
    local boost_file="${BASE_DIR}/last_turbo" cooldown_file="${BASE_DIR}/turbo_cooldown"
    local last="none" now=$(date +%s) last_change=0 delta dynamic_cd=$(calc_impact_cooldown 1.2)  # Fator 1.2 para turbo boost

    [[ -f "$boost_file" ]] && last=$(cat "$boost_file")
    [[ -f "$cooldown_file" ]] && last_change=$(date -r "$cooldown_file" +%s)
    delta=$((now - last_change))

    if [[ -f "$boost_path" ]]; then
        if [[ "$gov" == "performance" && "$last" != "1" && "$delta" -ge "$dynamic_cd" ]]; then
            echo 1 > "$boost_path" && echo "1" > "$boost_file"
            touch "$cooldown_file"
            echo "🚀 Turbo Boost ativado"
        elif [[ "$gov" != "performance" && "$last" != "0" && "$delta" -ge "$dynamic_cd" ]]; then
            echo 0 > "$boost_path" && echo "0" > "$boost_file"
            touch "$cooldown_file"
            echo "💤 Turbo Boost desativado"
        fi
    fi
}

apply_tdp_profile() {
    local key="$1" tdp_pair
    declare -A MAP=(
        ["000"]="0 0" ["005"]="$((MAX_TDP * 15 / 100)) $((MAX_TDP * 0))" 
        ["020"]="$((MAX_TDP * 30 / 100)) $((MAX_TDP * 10 / 100))" 
        ["040"]="$((MAX_TDP * 45 / 100)) $((MAX_TDP * 20 / 100))" 
        ["060"]="$((MAX_TDP * 60 / 100)) $((MAX_TDP * 30 / 100))" 
        ["080"]="$((MAX_TDP * 75 / 100)) $((MAX_TDP * 40 / 100))" 
        ["100"]="$MAX_TDP $((MAX_TDP * 50 / 100))"
    )
    tdp_pair="${MAP[$key]}"
    [[ -z "$tdp_pair" ]] && { echo "❌ Perfil TDP inválido"; return 1; }
    read target_max target_min <<< "$tdp_pair"
    
    local now=$(date +%s) current_power="${target_min} ${target_max}"
    local last_power_file="${BASE_DIR}/last_power" cooldown_file="${BASE_DIR}/power_cooldown"
    local last_power="none" last_change=0 delta dynamic_cd=$(calc_impact_cooldown 1.5)  # Fator 1.5 para TDP

    [[ -f "$last_power_file" ]] && last_power=$(cat "$last_power_file")
    [[ -f "$cooldown_file" ]] && last_change=$(date -r "$cooldown_file" +%s)
    delta=$((now - last_change))

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
    local key="$1" streams_alg streams alg
    declare -A MAP=(
        ["000"]="0 0" ["005"]="$((CORES_TOTAL * 15 / 100)) zstd" 
        ["020"]="$((CORES_TOTAL * 30 / 100)) lz4hc" 
        ["040"]="$((CORES_TOTAL * 45 / 100)) lz4" 
        ["060"]="$((CORES_TOTAL * 60 / 100)) lzo" 
        ["080"]="$((CORES_TOTAL * 50 / 100)) lzo" 
        ["100"]="$CORES_TOTAL lzo-rle"
    )
    streams_alg="${MAP[$key]}" && streams="${streams_alg% *}" alg="${streams_alg#* }"
    local last_streams_file="${BASE_DIR}/last_zram_streams" last_alg_file="${BASE_DIR}/last_zram_algorithm"
    local cooldown_file="${BASE_DIR}/cooldown_zram" current_streams=0 current_alg="none"
    [[ -f "$last_streams_file" ]] && current_streams=$(cat "$last_streams_file")
    [[ -f "$last_alg_file" ]] && current_alg=$(cat "$last_alg_file")

    if (( streams != current_streams || alg != current_alg )); then
        local now=$(date +%s) last_change=0 delta dynamic_cd=$(calc_impact_cooldown 2.0)  # Fator 2.0 para ZRAM
        [[ -f "$cooldown_file" ]] && last_change=$(date -r "$cooldown_file" +%s)
        delta=$((now - last_change))

        if (( delta >= dynamic_cd )); then
            echo "🔧 Reconfigurando ZRAM: Streams=$streams Alg=$alg"
            for dev in /dev/zram*; do swapoff "$dev" 2>/dev/null; done
            sleep 0.3
            modprobe -r zram 2>/dev/null
            modprobe zram num_devices="$streams"
            for i in /dev/zram*; do
                echo 1 > "/sys/block/$(basename "$i")/reset"
                echo "$alg" > "/sys/block/$(basename "$i")/comp_algorithm"
                echo 1G > "/sys/block/$(basename "$i")/disksize"
                mkswap "$i" && swapon "$i"
            done
            echo "$streams" > "$last_streams_file"
            echo "$alg" > "$last_alg_file"
            touch "$cooldown_file"
        else
            echo "⏳ Cooldown ZRAM ativo: ${delta}s/${dynamic_cd}s"
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

main() {
    initialize_directories
    echo "🟢 Iniciando OTIMIZADOR BAYESIANO"
    while true; do
        {
            echo "🧾 Último perfil aplicado: $(date)"
            apply_all
        } >> "$LOG_DIR/bayes.log"
        sleep 5
    done
}

main
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

