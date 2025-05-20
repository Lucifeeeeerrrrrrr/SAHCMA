# apply_cpu_governor

+ Aqui o objetivo e aplicar o governor de forma inteligente baseado em tendencia e heuristicas
+ Ha a validacao apra saber se o governor ja foi aplicado, e se sim, impplementa ele
+ cria um arquivo que permanece na memoria mesmo se o sistema cair, funcionando como rastro semantico para um LLM, podendo posteriormente ser debugado ou analisado por um humano
+ Ha aplicacao de cooldown para evitar mudancas bruscas no sistema, seguindo a logica de
    - Se a ultima mudanca foi feita a pelo menos de 7(frequencia do while + 2) segundos, altere, caso contrario retornar "governor ja ativo"

---

```bash
apply_cpu_governor() {
    local cpu_gov="$1"
    local last_gov_file="${BASE_DIR}/last_gov"
    local cooldown_file="${BASE_DIR}/gov_cooldown"
    local last_gov="none"

    [[ -f "$last_gov_file" ]] && last_gov=$(cat "$last_gov_file")

    echo "🎛  Governor: Atual=${last_gov} | Novo=${cpu_gov}"

    if [[ "$cpu_gov" != "$last_gov" ]] && \
       [[ ! -f "$cooldown_file" || $(($(date +%s) - $(date -r "$cooldown_file" +%s))) -ge 7 ]]; then
        echo "  🔧 Alterando governor..."
        echo "$cpu_gov" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
        echo "$cpu_gov" > "$last_gov_file"
        touch "$cooldown_file"
    else
        echo "  ⏳ Cooldown governor ativo"
    fi
}
```

PS, dado que estou usando o Liquorix, so tenho dois governos habilitados(performance, ondemand e sou meio boiola para configurar o userspace(e tbm to sem internt)), entao caso voce queira adaptar perfeitamente para o seu sistema, execute:
```
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
```
E cole os governos disponiveis no sistema e solicite para o LLM:
```
Tenho esses governos no meu kernel, arrume a tabela distruibuindo pela chave, e caso haja mais, adicione mais chaves, mas nao altere os valores ja definido

governors = # Cole aqui


init_policies() {
    HOLISTIC_POLICIES["000"]="ondemand $((MAX_TDP * 0)) $((MAX_TDP * 0)) $((CORES_TOTAL * 0)) none" # I can keep everything 0 when the base status is less then 5%
    HOLISTIC_POLICIES["005"]="ondemand $((MAX_TDP * 15 / 100)) $((MAX_TDP * 0)) $((CORES_TOTAL * 15 / 100)) lzo-rle"
    HOLISTIC_POLICIES["020"]="ondemand $((MAX_TDP * 30 / 100)) $((MAX_TDP * 10 / 100)) $((CORES_TOTAL * 30 / 100)) lzo"
    HOLISTIC_POLICIES["040"]="userspace $((MAX_TDP * 45 / 100)) $((MAX_TDP * 20 / 100)) $((CORES_TOTAL * 45 / 100)) lz4"
    HOLISTIC_POLICIES["060"]="userspace $((MAX_TDP * 60 / 100)) $((MAX_TDP * 30 / 100)) $((CORES_TOTAL * 60 / 100)) lz4hc"
    HOLISTIC_POLICIES["080"]="performance $((MAX_TDP * 75 / 100)) $((MAX_TDP * 40 / 100)) $((CORES_TOTAL * 50 / 100)) zstd"
    HOLISTIC_POLICIES["100"]="performance $((MAX_TDP)) $((MAX_TDP * 50 / 100)) $CORES_TOTAL deflate"
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
```
