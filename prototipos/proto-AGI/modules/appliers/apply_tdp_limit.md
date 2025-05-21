# apply_tdp_limit

- O objetivo dessa funcao é limitar o processamento de CPU de forma autonoma em função do percentual aplicado na chave selecionada
- O TDP (Thermal Design Power) é definidido dinamicamente com base no uso de CPU.
- Aqui deixei a escolha de forma empirica baseado no meu uso, mas é necessário adaptar e personalizar conforme suas necessidade
- Aqui o sistema, para evitar escritas desnecessaria e preverificado se a configuracao foi aplicada
```
Crie uma tabela casando a chave e o uso de TDP minimo e maximo
---
init_policies() {
    HOLISTIC_POLICIES["000"]="ondemand $((MAX_TDP * 0)) $((MAX_TDP * 0)) $((CORES_TOTAL * 0)) none" # I can keep everything 0 when the base status is less then 5%
    HOLISTIC_POLICIES["005"]="ondemand $((MAX_TDP * 15 / 100)) $((MAX_TDP * 0)) $((CORES_TOTAL * 15 / 100)) lzo-rle"
    HOLISTIC_POLICIES["020"]="ondemand $((MAX_TDP * 30 / 100)) $((MAX_TDP * 10 / 100)) $((CORES_TOTAL * 30 / 100)) lzo"
    HOLISTIC_POLICIES["040"]="userspace $((MAX_TDP * 45 / 100)) $((MAX_TDP * 20 / 100)) $((CORES_TOTAL * 45 / 100)) lz4"
    HOLISTIC_POLICIES["060"]="userspace $((MAX_TDP * 60 / 100)) $((MAX_TDP * 30 / 100)) $((CORES_TOTAL * 60 / 100)) lz4hc"
    HOLISTIC_POLICIES["080"]="performance $((MAX_TDP * 75 / 100)) $((MAX_TDP * 40 / 100)) $((CORES_TOTAL * 50 / 100)) zstd"
    HOLISTIC_POLICIES["100"]="performance $((MAX_TDP)) $((MAX_TDP * 50 / 100)) $CORES_TOTAL deflate"
}
```

---
```bash
apply_tdp_limit() {
    local target_max="$1"
    local target_min="$2"

    local base_dir="${BASE_DIR:-/tmp}"
    local last_power_file="${base_dir}/last_power"
    local cooldown_file="${base_dir}/power_cooldown"
    local now=$(date +%s)

    # Subfunção: Pega temperatura atual do pacote de CPU
    get_temp() {
        local temp_raw
        temp_raw=$(sensors 2>/dev/null | grep -m1 'Package id 0' | awk '{print $4}' | tr -d '+°C')
        echo "${temp_raw:-40}"  # fallback
    }

    # Subfunção: Média de carga dos últimos minutos
    get_loadavg() {
        uptime | awk -F'load average: ' '{print $2}' | awk -F', ' '{print $1, $2, $3}'
    }

    # Subfunção: Variância simples da carga (1m vs 5m)
    get_load_variance() {
        local l1 l5 delta
        read l1 l5 _ < <(get_loadavg)
        delta=$(echo "$l1 - $l5" | bc -l)
        echo "${delta#-}"  # valor absoluto
    }

    # Subfunção: Calcula cooldown dinâmico
    calc_dynamic_cooldown() {
        local delta_load=$(get_load_variance)
        local temp=$(get_temp)
        local cd=7

        (( temp >= 75 )) && cd=$((cd + 5))
        (( temp >= 60 && temp < 75 )) && cd=$((cd + 3))

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

    # Estado atual
    local current_power="${target_min} ${target_max}"
    local last_power="none"
    [[ -f "$last_power_file" ]] && last_power=$(cat "$last_power_file")

    # Cooldown
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
            echo "⏳ Cooldown ativo: ${delta}s/${dynamic_cd}s – aguarde para reconfigurar TDP."
        fi
    else
        echo "✅ TDP já está aplicado (MIN=${target_min}, MAX=${target_max}) – nada a fazer."
    fi
}


```

```plaintext
Mano, que porra siginificam esse caminho e esses diretorios? Como eles funcionam na arquitetura da intel?

ls /sys/class/powercap/intel-rapl/intel-rapl\:0
constraint_0_max_power_uw    constraint_0_time_window_us  constraint_1_power_limit_uw  enabled         intel-rapl:0:1       name       uevent
constraint_0_name            constraint_1_max_power_uw    constraint_1_time_window_us  energy_uj       intel-rapl:0:2       power
constraint_0_power_limit_uw  constraint_1_name            device                       intel-rapl:0:0  max_energy_range_uj  subsystem
```


