# Coleta de Dados

No caso, aqui pensei em deixar modulado em duas funções dentro do módulo(redundânica me deu uma pontada no cérebro, mas vamos lá), onde foco em carregar uma função especifica para estabelecer os válores de referências no sistema e outra ppara estabelecer o uso da CPU.

A função `load_intel_specs` tem como objetivo inicializar informações cruciais sobre as capacidades de hardware do sistema, focando especificamente no meu hardware~~, dado que sou que nem puta, quer gemindo me paga e adapto para isso rodar em qualquer carroça~~. Ela tenta extrair o Thermal Design Power (TDP) máximo do processador (em Watts), a frequência máxima do clock da GPU integrada (em MHz) e o número total de núcleos de processamento para manter coerência com a coluna de streams.

Essa coleta de informações é feita através da leitura de arquivos específicos localizados no sistema de arquivos virtual `/sys`, uma interface fornecida pelo kernel Linux que expõe informações sobre o hardware e os drivers de dispositivo, permitindo que o software interaja com o hardware de maneira padronizada.

> Aqui eu pensei em meio que improvisar um eixo talâmico no meu notebook, e se estiver errado, me corrija quando você sozinho bater de frente com universidades inteiras kkkkk

Do ponto de vista eletrônico, o TDP representa o consumo máximo de energia que o sistema de resfriamento do processador deve ser capaz de dissipar sob carga máxima, um limite físico ditado pelo projeto e pela microarquitetura do chip, onde ao forçar um valor percentual holisto em relação ao sistema, eu garando que não consuma nada além do necessário.&#x20;

> Esse hash de estado `` `["010"]="ondemand $((MAX_TDP * 25 / 100)) $((MAX_TDP * 18 / 100)) $((MAX_GPU_CLOCK * 35 / 100))` ``  é um bom exemplo.
>
> Tipo, se o máximo que minha CPU consegue lidar é 15 Watts, se eu estiver no uso de só 10%, não faz sentido deixar ela consumindo 15 Watts cagando a vida util, consumo energético e outras caralhadas de coisas, então ajusto ela para operar em só 25% dos 15, ou seja 3.5 W é o suficiente
>
> Repare que a economia é quase de 5 vezes mais vantajosa!

A frequência máxima do clock da GPU indica a velocidade operacional máxima dos núcleos gráficos, influenciando diretamente o desempenho gráfico e o consumo de energia correspondente, e não detalhei muito pq essa carroça é onboard e já tô uma semana nesse projeto.&#x20;

O número total de núcleos reflete a quantidade de unidades de processamento independentes disponíveis na CPU, impactando a capacidade de realizar tarefas paralelas e, consequentemente, o uso geral de energia, mas espeficicamente para swapiness.

> No começo pensei em deixar limitado o numero de CPUs, mas se o TDP já consegue limitar bem a frequência e essa carroça não é um Fukaku ou um pc médio da Apple, acaba ficando meio complexo mexer nisso

{% code overflow="wrap" %}
```bash
#!/bin/bash

load_intel_specs() {
    MAX_TDP=$(cat /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_max_power_uw 2>/dev/null | awk '{print $1/1000000}')
    MAX_GPU_CLOCK=$(cat /sys/class/drm/card0/gt_max_freq_mhz 2>/dev/null)
    CORES_TOTAL=$(nproc --all 2>/dev/null)

    MAX_TDP=${MAX_TDP:-15}
    MAX_GPU_CLOCK=${MAX_GPU_CLOCK:-1000}
    CORES_TOTAL=${CORES_TOTAL:-4}
}

get_cpu_usage() {
    local stat_hist_file="${HISTORY_FILE}.stat"
    local cpu_line=$(grep -E '^cpu ' /proc/stat)

    read -r _ last_user last_nice last_system last_idle last_iowait last_irq last_softirq _ _ < <(grep '^cpu ' "$stat_hist_file" 2> /dev/null || echo "cpu 0 0 0 0 0 0 0 0 0 0")
    read -r _ curr_user curr_nice curr_system curr_idle curr_iowait curr_irq curr_softirq _ _ < <(echo "$cpu_line")

    echo "$cpu_line" > "$stat_hist_file"

    local last_total=$((last_user + last_nice + last_system + last_idle + last_iowait + last_irq + last_softirq))
    local curr_total=$((curr_user + curr_nice + curr_system + curr_idle + curr_iowait + curr_irq + curr_softirq))

    local diff_idle=$((curr_idle - last_idle))
    local diff_total=$((curr_total - last_total))

    if (( diff_total > 0 )); then
        echo $(( (1000 * (diff_total - diff_idle) / diff_total + 5) / 10 ))
    else
        echo 0
    fi
}
```
{% endcode %}
