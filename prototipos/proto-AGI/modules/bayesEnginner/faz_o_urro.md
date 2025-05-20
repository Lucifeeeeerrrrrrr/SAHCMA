# `faz_o_urro`
- Média para analise de tendencias que usa espelhos markovianos das ultimas medias
- Aqui as projeções das ultimas n-medidas é o que importa para definir a tendencia atual
> O passado não importa pois ele é constantemente sobreescrito por uma nova versão, e boa sorte de entender por que esse nome
```bash
faz_o_urro() {
    local new_val="$1" history_arr=() sum=0 avg=0 count=0
    # Recebe a medida da CPU, inicia a lista para armazenar as projeções holográficas e inicializa os parametros para média

    if [[ -f "$HISTORY_FILE"]]; then
        mapfile -t history_arr < "$HISTORY_FILE"
    fi
    # Essa variavel foi definida globalmente, e persiste na memoria.

    history_arr+=("$new_val")
    count=${#history_arr[@]}

    if (( count > MAX_HISTORY )); then
        history_arr=("${history_arr[@]:$((count - MAX_HISTORY))}")
    fi
    # Aqui mantem o limite de projeções holográficas

    for val in "${history_arr[@]}"; do
        sum=$((sum + val))
    done

    (( ${#history_arr[@]} > 0 )) && avg=$(( sum / ${history_arr[@]}))
    # Aqui executo a operação de média

    printf "%s\n" "${history_arr[@]}" > "$HISTORY_FILE"
    echo "$avg"
}
```

## Qual a Sua Relacao com Bayes?

## Qual o seu paralelo com ontologia?

## Custo Computacional
