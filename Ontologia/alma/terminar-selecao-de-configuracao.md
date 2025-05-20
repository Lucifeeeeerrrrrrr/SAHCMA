# Terminar - Seleção de Configuração

```

determine_policy_key() {
    local cpu_usage temp power_source temp_critical_flag key fallback_key best_match_key key_usage diff min_diff k
    cpu_usage=$(get_cpu_usage)
    temp=$(get_cpu_temp)
    power_source=$(get_power_source)

    faz_o_urro "$cpu_usage" # Atualiza a média móvel (EMA)

    (( temp >= CRITICAL_TEMP_THRESHOLD )) && temp_critical_flag=1 || temp_critical_flag=0

    local usage_key
    printf -v usage_key "%03d" "$CURRENT_EMA" # Formata EMA para 3 dígitos

    key="${usage_key}${temp_critical_flag}${power_source}" # Monta a chave: EMA(000-100) + TempFlag(0/1) + Power(0/1)

    # Verifica se a chave exata existe na tabela
    if [[ -v HOLISTIC_POLICIES["$key"] ]]; then
        echo "$key"
        return
    fi

    # Lógica de fallback (procura a chave mais próxima se a exata não existir)
    fallback_key=""
    if [[ "$temp_critical_flag" -eq 1 ]]; then # Se temp crítica, procura chaves com flag de temp crítica
        for k in "${!HOLISTIC_POLICIES[@]}"; do
            if [[ "${k:3:1}" == "1" ]] && [[ "${k:4:1}" == "$power_source" ]]; then
                fallback_key="$k"; break
            fi
        done
    else # Se temp OK, procura a chave com EMA mais próxima na mesma condição de energia
        best_match_key="" min_diff=999
        for k in "${!HOLISTIC_POLICIES[@]}"; do
            if [[ "${k:3:1}" == "0" ]] && [[ "${k:4:1}" == "$power_source" ]]; then
                key_usage=$((10#${k:0:3})) # Pega o uso da chave K
                diff=$(( CURRENT_EMA - key_usage )) # Calcula diferença
                (( diff < 0 )) && diff=$(( -diff )) # Valor absoluto da diferença
                if (( diff < min_diff )); then # Se a diferença for menor que a mínima encontrada até agora
                    min_diff=$diff
                    best_match_key="$k" # Atualiza a melhor chave encontrada
                fi
            fi
        done
        fallback_key="$best_match_key"
    fi

    if [[ -n "$fallback_key" ]]; then
        warn "Chave exata '$key' não encontrada. Usando fallback mais próximo: '$fallback_key'"
        echo "$fallback_key"
    else
        warn "Nenhuma política encontrada para o estado atual (Chave: $key). Mantendo estado anterior."
        echo "$CURRENT_POLICY_KEY" # Retorna a chave atual se nenhum fallback for encontrado
    fi
}
```
