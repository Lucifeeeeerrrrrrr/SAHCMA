#!/bin/bash

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

declare -A HOLISTIC_POLICIES

MAX_TDP=15
CORES_TOTAL=$(nproc --all)

init_policies() {
    HOLISTIC_POLICIES["000"]="ondemand 0 none"
    HOLISTIC_POLICIES["005"]="ondemand $((CORES_TOTAL * 15 / 100)) lzo-rle"
    HOLISTIC_POLICIES["020"]="ondemand $((CORES_TOTAL * 30 / 100)) lzo"
    HOLISTIC_POLICIES["040"]="ondemand $((CORES_TOTAL * 45 / 100)) lz4"
    HOLISTIC_POLICIES["060"]="performance $((CORES_TOTAL * 60 / 100)) lz4hc"
    HOLISTIC_POLICIES["080"]="performance $((CORES_TOTAL * 50 / 100)) zstd"
    HOLISTIC_POLICIES["100"]="performance $CORES_TOTAL deflate"
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

apply_tdp_profile() {
    local usage="$1"
    local last_power_file="${BASE_DIR}/last_power"
    local cooldown_file="${BASE_DIR}/power_cooldown"
    local now=$(date +%s)

    declare -A HOLISTIC_POLICIES
    HOLISTIC_POLICIES["000"]="0 0"
    HOLISTIC_POLICIES["005"]="$((MAX_TDP * 15 / 100)) $((MAX_TDP * 0))"
    HOLISTIC_POLICIES["020"]="$((MAX_TDP * 30 / 100)) $((MAX_TDP * 10 / 100))"
    HOLISTIC_POLICIES["040"]="$((MAX_TDP * 45 / 100)) $((MAX_TDP * 20 / 100))"
    HOLISTIC_POLICIES["060"]="$((MAX_TDP * 60 / 100)) $((MAX_TDP * 30 / 100))"
    HOLISTIC_POLICIES["080"]="$((MAX_TDP * 75 / 100)) $((MAX_TDP * 40 / 100))"
    HOLISTIC_POLICIES["100"]="$((MAX_TDP)) $((MAX_TDP * 50 / 100))"

    local tdp_pair="${HOLISTIC_POLICIES[$usage]}"
    if [[ -z "$tdp_pair" ]]; then
        echo "❌ Perfil TDP '$usage' inválido ou não definido."
        return 1
    fi

    local target_max target_min
    read target_max target_min <<< "$tdp_pair"

    get_temp() {
        sensors 2>/dev/null | grep -m1 'Package id 0' | awk '{print int($4)}'
    }

    get_loadavg() {
        uptime | awk -F'load average: ' '{print $2}' | awk -F', ' '{print $1, $2, $3}'
    }

    get_load_variance() {
        local l1 l5 delta
        read l1 l5 _ < <(get_loadavg)
        delta=$(echo "$l1 - $l5" | bc -l)
        echo "$delta"
    }

    calc_dynamic_cooldown() {
        local delta_load=$(get_load_variance)
        local temp=$(get_temp)
        local cd=7

        local temp_int=$(printf "%.0f" "$temp")
        local delta_int=$(printf "%.0f" "$delta_load")

        (( temp_int >= 75 )) && cd=$((cd + 5))
        (( temp_int >= 60 && temp_int < 75 )) && cd=$((cd + 3))

        if (( delta_int > 1 )); then
            cd=$((cd + 4))
        elif (( delta_int > 0 )); then
            cd=$((cd + 2))
        elif (( delta_int < 1 )); then
            cd=$((cd - 2))
        fi

        (( cd < 3 )) && cd=3
        echo "$cd"
    }

    local current_power="${target_min} ${target_max}"
    local last_power="none"
    [[ -f "$last_power_file" ]] && last_power=$(cat "$last_power_file")

    local last_change=0
    [[ -f "$cooldown_file" ]] && last_change=$(date -r "$cooldown_file" +%s)
    local delta=$((now - last_change))
    local dynamic_cd=$(calc_dynamic_cooldown)

    echo "🌡️  Temp=$(get_temp)°C | ΔCarga=$(get_load_variance) | Cooldown=${dynamic_cd}s"

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

apply_cpu_governor() {
    local cpu_gov="$1"
    local last_gov_file="${BASE_DIR}/last_gov"
    local cooldown_file="${BASE_DIR}/gov_cooldown"
    local now=$(date +%s)

    grep -qw "$cpu_gov" /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors || {
        echo "✖ Governor '$cpu_gov' não suportado."
        return 1
    }

    local last_gov="none"
    [[ -f "$last_gov_file" ]] && last_gov=$(cat "$last_gov_file")

    local last_change=0
    [[ -f "$cooldown_file" ]] && last_change=$(date -r "$cooldown_file" +%s)
    local delta=$((now - last_change))

    if [[ "$cpu_gov" != "$last_gov" && "$delta" -ge 5 ]]; then
        for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
            echo "$cpu_gov" > "$cpu/cpufreq/scaling_governor" 2>/dev/null
        done
        echo "$cpu_gov" > "$last_gov_file"
        touch "$cooldown_file"
        echo "🎛 Governor alterado para $cpu_gov"
    else
        echo "⏳ Cooldown ativo ou governor já setado"
    fi
}

apply_turbo_boost() {
    local gov="$1"
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

apply_zram_config() {
    local streams="$1"
    local alg="$2"
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
    init_policies
    local current_usage=$(get_cpu_usage)
    local avg_usage=$(faz_o_urro "$current_usage")
    local policy_key=$(determine_policy_key_from_avg "$avg_usage")
    read -ra values <<< "${HOLISTIC_POLICIES[$policy_key]}"

    echo -e "\n🔄 $(date) | Uso: ${current_usage}% | Média: ${avg_usage}% | Perfil: ${policy_key}%"
    echo "  Governor: ${values[0]}"
    echo "  ZRAM: ${values[1]} cores | Algoritmo: ${values[2]}"

    apply_cpu_governor "${values[0]}"
    apply_turbo_boost "${values[0]}"
    apply_tdp_profile "$policy_key"
    apply_zram_config "${values[1]}" "${values[2]}"
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
