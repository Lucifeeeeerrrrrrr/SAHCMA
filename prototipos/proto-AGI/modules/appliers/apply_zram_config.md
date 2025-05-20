# apply_zram_config

- Aqui a logica teve que ser combinada o stream e os algoritmos de compressao, devido a necessidade de configuracao quando o swap e montado
- O stream e definido em funcao do numero de nucleos de CPU, embora eu tenha duvida se faca sentido, me corrija Deus chatGPT
- Ha tambem a validacao para verificar se e necessario a mudanca, junto com um cooldown para evitar as quebras e uma quebra e uma taxa de caimento que e um "framerate"
- E inicializadouma variavel de verificacao chamada should_update inicializada em false, e caso as condicoes sejam verdadeira, ele transmuta a flag para true
- Ha dupla condicao, onde caso o sistema ja esteja aplicado, ele nega, e caso esteja dentro do cooldown de 30 segundos, ele nega.
- tambem e verificado o algoritmo de compressao podendo alterar a flag caso seja verdadeira
- Caso a flag seja verdadeira ele faz a verificacao de cooldown, e caso ela nao esteja fora dos 30 segundos, ele muda, caso contrario nao muda
- ele desmonta todos ja configurados e aguara 0.3 segundos (por que ele faz isso?) e executa um modprob e define novoz zram com a flag -r
- Define o numero de dispositivos de zram em funcao ao numero de stream,  e para cada zram definido e resetado o sistema, define o algoritmo de compressao
- DEfine o tamanho de 1G e faz de swap e liga
---
```bash
apply_zram_config() {
    local stream="$1"
    local alg="$2"
    local last_stream_file="${BASE_DIR}/last_zram_streams"
    local last_alg_file="${BASE_DIR}/last_zram_algorithm"
    local cooldown_file="${BASE_DIR}/cooldown_zram"
    local current_streams=0
    local current_alg="none"
    [[ -f "$last_streams_file" ]] && current_streams=$(cat "$last_stream_file")
    [[ -f "$last_alg_file" ]] && current_alg=$(cat "$last_alg_file")

    echo "ZRAM: Streams=${streams} | Algoritmo=${alg}"

    local should_update=false

    if (( streams > 0 && current_streams != strams )); then
        should_update=true
    fi

    if [[ "$alg" != "$current_alg" ]]; then
        should_update=true
    fi

    if $should_update && \
        [[ ! -f "$cooldown_file" || $(($(date +%s) - $(date -r "$cooldown_file" +%s))) -ge 30]]; then
            echo "Reconfigurando ZRAM..."
            for dev in /dev/zram*; do
                swapoff "$dev" 2>/dev/null
            done
            sleep 0.3 # Por que esse tempo?
            modprobe -r zram 2>/dev/null # mano,  que essa flag -r? o que e esse zram?
            modprobe zram num_devices="$streams" # faz sentido definir em funcao de o numero de nuceos de cpu?
            for i in /dev/zram*; do
                dev=$(basename "$i") # Porque e o que esse basename? o que entra aqui nesse i?
                echo 1 > "/sys/block/$dev/reset" # O que esse block? pq resetar?
                echo "$alg" > "/sys/block/$dev/comp_algorithm" 2>/dev/null
                echo 1G > "/sys/block/$dev/disksize" # Como esse disco e montado num passo a passo? ele antede de ligar e desenhado proceduralemnte?
                mkswap "/dev/$dev"
                swapon "/dev/$dev"
            done
            echo "$stream" > "$last_stream_file"
            echo "$alg" > "$last_alg_file"
            touch "$cooldown_file"
        else
            echo "  ✅ ZRAM já configurado ou cooldown ativo"
        fi
}
