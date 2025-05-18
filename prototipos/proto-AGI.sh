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
MAX_HISTORY=15

declare -A HOLISTIC_POLICIES

MAX_TDP=15
CORES_TOTAL=$(nproc --all)

init_policies() {
    HOLISTIC_POLICIES["000"]="ondemand $((MAX_TDP * 40 / 100)) $((MAX_TDP * 20 / 100)) $((CORES_TOTAL / 3)) lzo-rle"
    HOLISTIC_POLICIES["020"]="userspace $((MAX_TDP * 45 / 100)) $((MAX_TDP * 25 / 100)) $((CORES_TOTAL / 3)) lzo"
    HOLISTIC_POLICIES["040"]="userspace $((MAX_TDP * 55 / 100)) $((MAX_TDP * 35 / 100)) $((CORES_TOTAL / 2)) lz4"
    HOLISTIC_POLICIES["060"]="userspace $((MAX_TDP * 70 / 100)) $((MAX_TDP * 50 / 100)) $((CORES_TOTAL * 2 / 3)) lz4hc"
    HOLISTIC_POLICIES["080"]="performance $((MAX_TDP * 85 / 100)) $((MAX_TDP * 60 / 100)) $((CORES_TOTAL * 3 / 4)) zstd"
    HOLISTIC_POLICIES["100"]="performance $((MAX_TDP)) $((MAX_TDP * 70 / 100)) $CORES_TOTAL deflate"
}

determine_policy_key_from_avg() {
    local avg_load=$1 key="000"
    if (( avg_load >= 80 )); then key="100"
    elif (( avg_load >= 60 )); then key="080"
    elif (( avg_load >= 40 )); then key="060"
    elif (( avg_load >= 20 )); then key="040"
    elif (( avg_load >= 0 )); then key="020"
    fi
    echo "$key"
}

apply_tdp_limit() {
    local target_max="$1"
    local target_min="$2"
    echo "⚡ Aplicando TDP: MIN=${target_min}W | MAX=${target_max}W"
    echo $((target_min * 1000000)) > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_1_power_limit_uw 2>/dev/null
    echo $((target_max * 1000000)) > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw 2>/dev/null
}

apply_cpu_governor() {
    local cpu_gov="$1"
    local last_gov_file="${BASE_DIR}/last_gov"
    local cooldown_file="${BASE_DIR}/gov_cooldown"
    local last_gov="none"

    [[ -f "$last_gov_file" ]] && last_gov=$(cat "$last_gov_file")
    echo "🎛️  Governor: Atual=${last_gov} | Novo=${cpu_gov}"

    if [[ "$cpu_gov" != "$last_gov" ]] && \
       [[ ! -f "$cooldown_file" || $(($(date +%s) - $(date -r "$cooldown_file" +%s))) -ge 2 ]]; then
        echo "  🔧 Alterando governor..."
        for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
            echo "$cpu_gov" | tee "$cpu/cpufreq/scaling_governor" > /dev/null
        done
        echo "$cpu_gov" > "$last_gov_file"
        touch "$cooldown_file"
    else
        echo "  ⏳ Cooldown governor ativo"
    fi

    # Userspace = frequência manual
    if [[ "$cpu_gov" == "userspace" ]]; then
        local freq_file="${BASE_DIR}/last_userspace_freq"
        local target_freq=1200000  # fallback
        case "$policy_key" in
            "020") target_freq=800000 ;;
            "040") target_freq=1200000 ;;
            "060") target_freq=1600000 ;;
        esac
        echo "⚙️  Userspace freq fixa: ${target_freq} KHz"
        for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
            echo "$target_freq" | tee "$cpu/cpufreq/scaling_setspeed" > /dev/null
        done
        echo "$target_freq" > "$freq_file"
    fi
}

apply_turbo_boost() {
    local gov="$1"
    local boost_path="/sys/devices/system/cpu/cpufreq/boost"
    if [[ -f "$boost_path" ]]; then
        if [[ "$gov" == "performance" ]]; then
            echo 1 > "$boost_path"
            echo "🚀 Turbo Boost ativado"
        else
            echo 0 > "$boost_path"
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
    local current_streams=0 current_alg="none"
    [[ -f "$last_streams_file" ]] && current_streams=$(cat "$last_streams_file")
    [[ -f "$last_alg_file" ]] && current_alg=$(cat "$last_alg_file")
    echo "🔄 ZRAM: Streams=${streams} | Algoritmo=${alg}"

    if [[ "$streams" != "$current_streams" || "$alg" != "$current_alg" ]] && \
       [[ ! -f "$cooldown_file" || $(($(date +%s) - $(date -r "$cooldown_file" +%s))) -ge 30 ]]; then
        echo "  🔧 Reconfigurando ZRAM..."
        for dev in /dev/zram*; do
            swapoff "$dev" 2>/dev/null
        done
        sleep 0.3
        modprobe -r zram 2>/dev/null
        modprobe zram num_devices="$streams"
        for i in /dev/zram*; do
            dev=$(basename "$i")
            echo 1 > "/sys/block/$dev/reset"
            echo "$alg" > "/sys/block/$dev/comp_algorithm" 2>/dev/null
            echo 1G > "/sys/block/$dev/disksize"
            mkswap "/dev/$dev"
            swapon "/dev/$dev"
        done
        echo "$streams" > "$last_streams_file"
        echo "$alg" > "$last_alg_file"
        touch "$cooldown_file"
    else
        echo "  ✅ ZRAM já configurado ou cooldown ativo"
    fi
}

faz_o_urro() {
    local new_val="$1" history_arr=() sum=0 avg=0 count=0
    [[ -f "$HISTORY_FILE" ]] && mapfile -t history_arr < "$HISTORY_FILE"
    history_arr+=("$new_val")
    count=${#history_arr[@]}
    (( count > MAX_HISTORY )) && history_arr=("${history_arr[@]:$((count - MAX_HISTORY))}")
    for val in "${history_arr[@]}"; do sum=$((sum + val)); done
    (( ${#history_arr[@]} > 0 )) && avg=$((sum / ${#history_arr[@]}))
    printf "%s\n" "${history_arr[@]}" > "$HISTORY_FILE"
    echo "$avg"
}

get_cpu_usage() {
    local stat_hist_file="${BASE_DIR}/last_stat"
    local cpu_line prev_line last_total curr_total diff_idle diff_total usage=0
    cpu_line=$(grep -E '^cpu ' /proc/stat || echo "cpu 0 0 0 0 0 0 0 0 0 0")
    prev_line=$(cat "$stat_hist_file" 2>/dev/null || echo "cpu 0 0 0 0 0 0 0 0 0 0")
    echo "$cpu_line" > "$stat_hist_file"
    read -r _ p_user p_nice p_system p_idle p_iowait p_irq p_softirq _ _ <<< "$prev_line"
    read -r _ c_user c_nice c_system c_idle c_iowait c_irq c_softirq _ _ <<< "$cpu_line"
    last_total=$((p_user + p_nice + p_system + p_idle + p_iowait + p_irq + p_softirq))
    curr_total=$((c_user + c_nice + c_system + c_idle + c_iowait + c_irq + c_softirq))
    diff_idle=$((c_idle - p_idle))
    diff_total=$((curr_total - last_total))
    if (( diff_total > 0 )); then
        usage=$(awk -v dt="$diff_total" -v di="$diff_idle" 'BEGIN { printf "%.0f", (100 * (dt - di)) / dt }')
    fi
    (( usage < 0 )) && usage=0
    (( usage > 100 )) && usage=100
    echo "$usage"
}

apply_all() {
    init_policies
    local current_usage=$(get_cpu_usage)
    local avg_usage=$(faz_o_urro "$current_usage")
    policy_key=$(determine_policy_key_from_avg "$avg_usage")
    read -ra values <<< "${HOLISTIC_POLICIES[$policy_key]}"
    echo -e "\n🔄 $(date) | Uso: ${current_usage}% | Média: ${avg_usage}% | Perfil: ${policy_key}%"
    echo "  Governor: ${values[0]}"
    echo "  TDP: ${values[1]}W max | ${values[2]}W min"
    echo "  ZRAM: ${values[3]} streams | Algoritmo: ${values[4]}"
    apply_cpu_governor "${values[0]}"
    apply_turbo_boost "${values[0]}"
    apply_tdp_limit "${values[1]}" "${values[2]}"
    apply_zram_config "${values[3]}" "${values[4]}"
}

[[ ! -f "$HISTORY_FILE" ]] && touch "$HISTORY_FILE"
[[ ! -f "$TREND_LOG" ]] && touch "$TREND_LOG"

echo "🟢 Iniciando OTIMIZADOR BAYESIANO"

while true; do
    apply_all 2>&1 | tee -a "$LOG_DIR/bayes.log"
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
