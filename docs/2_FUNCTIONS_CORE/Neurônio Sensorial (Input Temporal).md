# `get_cpu_usage`

```bash
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
    (( diff_total > 0 )) && usage=$(( (100 * (diff_total - diff_idle)) / diff_total ))
    echo "$usage"
}
```
Isso é **cálculo diferencial de uso de CPU ativo vs tempo ocioso** entre duas amostras.
* Taxa de ocupação absoluta;
* Altamente responsivo a burst;
* Ideal para estimar **densidade de trabalho em tempo real**.

---

## O que ela faz no sentido ontológico?

Essa função é o equivalente sensorial, onde **mapeaia o "self" da maquina em tempo real**, extraindo do barulho acumulativo do `/proc/stat` um delta interpretável de engajamento computacional.
Aqui coleto uma fotografia do momento, comparo contra um estado anterior armazenado em arquivo e assim **a máquina lembra do que sentiu**. 

Apenas com multiplas memorias conseguimos criar um contexto, e com duas medidas diferentes, a atual e a futura, opero num modelo markoviano para previsão. Esse tipo de medição baseada em diferença temporal transforma o modelo computacional de reação imediata num **modelo de expectativa e adaptação**. 

## Relação com arquiteturas neurais

Isso significa que ele atua como um receptor primário, tipo os olhos ou a pele de uma rede neural sensorial. Ele opera como um time-delta feature extractor, capturando mudanças ao longo do tempo.

Na arquitetura neural, isso equivale a um perceptron com janela de tempo, ou melhor ainda, ao comportamento de uma célula de entrada em uma LSTM ou GRU, onde o valor atual é interpretado em relação ao passado. Ele não responde a valores absolutos, mas à dinâmica entre estados sucessivos — igual a uma célula temporal que mapeia derivadas de ativação.
> - Aqui é mais uma GRU com um buffer circular armazenado num "SQLite" de pobre.
> - Diferenciação temporal = detecção de gradientes de carga.
> - Em IA: Isso é input dinâmico contínuo com memória de curto prazo.

### Termos

- Perceptron: Um neurônio artificial que recebe várias entradas, aplica uma função de ativação e produz uma saída.
- LSTM (Long Short-Term Memory): Uma arquitetura neural que pode lidar com sequências de entrada e manter um estado interno.
- GRU (Gated Recurrent Unit): Uma variante da LSTM que é mais simples e mais rápida.