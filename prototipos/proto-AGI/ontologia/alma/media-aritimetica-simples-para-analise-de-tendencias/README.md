# Média Aritimética Simples Para Análise de Tendências

A função `faz_o_urro` é crucial para evitar que o sistema tenha reações espasmódicas a cada pequena flutuação no uso da CPU. Aqui improvisei uma espécie de ML rudimentar calculando uma média que dá mais peso aos dados mais recentes sem descartar completamente o histórico passado, agindo como um filtro passa-baixa que suaviza os picos e vales momentâneos.&#x20;

> Os críticos podem até falar que isso é só média basica, mas falador só sabe falar mané!

A lógica é simples: em vez de confiar cegamente no último valor de uso de CPU medido, que pode ser um pico isolado causado por abrir um programa ou uma queda súbita por um processo ter terminado, a EMA nos dá um valor que representa melhor a _tendência_ de carga do sistema, é como olhar para a maré subindo ou descendo em vez de se distrair com cada onda individual que quebra na praia, permitindo decisões mais ponderadas e estáveis.

> Usei essa tecnica para evitar os falsos positivos que quebram a expectativa, onde ao abrir um app pode haver um consumo gigantesto de CPU para abrir, mas se estabiliza aopos três medições, mesmo não tendo mudado de uso.
>
> Esse flip-flop pode ser desgastante para o computador, e essa suavização evita um sistema reativo que sobreescreve configurações desnecessária.

Ao receber um novo valor de uso da CPU como entrada, ela mantém um histórico dos valores recentes, limitado por uma constante `MAX_HISTORY`, meio que improvisando uma memória de curto prazo. Essa manutenção de um histórico permite que o sistema não reaja apenas ao pico momentâneo de atividade, mas sim à tendência geral de uso, evitando assim flutuações bruscas nas configurações baseadas em leituras isoladas que podem não representar a carga de trabalho real sustentada.

> O objetivo é a garantia da inercia temporal nas expectativas bayesiana, evitando uma reação desnecessária a cada mudança, voltando mais na estabilidade inercial do que uma adaptação caótica.

{% code overflow="wrap" %}
```bash
#!/bin/bash
faz_o_urro() {
    local cpu="$1"
    local -a history=()
    local sum=0 avg

    [[ -f "$HISTORY_FILE" ]] && mapfile -t history < "$HISTORY_FILE"
    history+=("$cpu")

    if (( ${#history[@]} > MAX_HISTORY )); then
        history=("${history[@]: -$MAX_HISTORY}")
    fi

    for n in "${history[@]}"; do
        sum=$((sum + n))
    done

    avg=$((sum / ${#history[@]}))
    printf "%s\n" "${history[@]}" > "$HISTORY_FILE"
    echo "$avg"
}
```
{% endcode %}

Do ponto de vista eletrônico, essa função espelha a necessidade de analisar o comportamento do processador em uma janela de tempo, em vez de apenas um instante. A utilização da CPU é um reflexo direto da quantidade de ciclos de clock que os núcleos do processador estão dedicando à execução de instruções. Ao armazenar uma série desses valores, o script consegue ter uma visão mais estável da demanda computacional, como se estivesse observando a frequência com que os transistores dentro do chip estão mudando de estado para realizar cálculos, permitindo uma decisão de política mais informada e menos suscetível a ruídos ou picos transitórios de atividade.

***
