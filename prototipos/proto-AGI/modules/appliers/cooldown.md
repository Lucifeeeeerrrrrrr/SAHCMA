```bash
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
``