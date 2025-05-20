# get_cpu_usage
- Esse script le o estado atual da CPU no `/proc/stats` e inicializa multiplas variaveis
- Caso nao encontre, retorna o template 0
- Compara a ultima metrica armazenada em `last_stat` com a variavel `prev_line` que carrega a ultima medida salva num arquivo persistente
--+ Confirma para mim essa merda
- Extrai os valores `user, nice, system, idle, iotwait, _irq e softirq de ambos os arquivos
--+ Explicar o que significa cada um desses valores
- Computa o uso total de CPU do estado atual dentro de `/proc/stats/` e dentro do arquivo de ultima leitura
- Define as mudancas dentro do `diff_idle` e o uso sobressalente no `diff_total`
? Posso dizer que ao estar pegando multiplos parametros para deifnir uma diferen;a, to fazedo Fourier na mao? Digo, se fosse um autoencoder, estaria pegando n-features e definindo uma qualia, nesse caso, estou egando n-features e definindo uma quaia entre 000 e 100, ne?
- Se a diferenca for mair que 0, e calculado um valor percentual a partir do idling usando o `awk`
? O que e esse idling?
- Caso os valores excedam o limite minimo e maximo, e definido 0 ou 100 e assim retorna o uso

```bash
get_cpu_usage() {
    local stat_hist_file="${BASE_DIR}/last_stat"
    local cpu_line prev_line last_total curr_total diff_idle diff_total usage=0
    # Explique cada uma dessas variaveis inicializadas e por que e assim? cpu  710021 57 111386 5358877 56942 55377 4342 0 0 0

    cpu_line=$(grep -E '^cpu ' /proc/stat)
    prev_line=$(cat "$stat_hist_file" 2>/dev/null || echo "cpu 0 0 0 0 0 0 0 0 0 0")
    echo "$cpu_line" > "$stat_hist_file"
    # Coleta os dados dos arquivos de referencia

    read -r _ p_user p_nice p_system p_idle p_iowait p_irq p_softirq _ _ <<< "$prev_line"
    read -r _ c_user c_nice c_system c_idle c_iowait c_irq c_softirq _ _ <<< "$cpu_line"
    # Mano, que porra sao esse `_`? e que porra sao esses nomes?
    # Aqui tem a execucao parseada das variaveis, onde cada iten e fragmentado e segmentado.

    last_total=$((p_user + p_nice + p_system + p_idle + p_iowait + p_irq + p_softirq))
    curr_total=$((c_user + c_nice + c_system + c_idle + c_iowait + c_irq + c_softirq))
    diff_idle=$((c_idle - p_idle)) # Por que essa variavel e necessaria?
    diff_total=$((curr_total - last_total))
    # Mano, Explique a necessidade desses calculos e o que sao cada um desses valores

    if (( diff_total > 0 )); then # Aqui foi feito para economia de calculos? por que tem essa condificional ao inves de executar direto?
        usage=$(awk -v dt="$diff_total" -v di="$diff_idle" '
                BEGIN {
                    print "%.0f", (100 * (dt - di)) / dt
                }') # Pode explicar esse calculo? nao entendi a logica
    fi
    (( usage < 0 )) && usage=0
    (( usage > 100 )) && usage=100
    # Aqui limita tudo
    echo "$usage"
}
```

## Qual a Sua Relacao com Bayes?

## Qual o seu paralelo com ontologia?

## Custo Computacional
