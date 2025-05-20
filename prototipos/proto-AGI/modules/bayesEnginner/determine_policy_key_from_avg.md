# determine_policy_key_from_avg
- Aqui foquei especificamente em definir os governors(ondemand e performance por default, e o userspace no meio)
> Sim, nao sou um script kiddie, instalei o cpu-freqd mas nem configurei pois o proprio driver da intel ajusta frequencia de forma inteligente, entao fiz isso so por fogo no cu
- As politicas sao harmonizadas em diferentes algoritmosde compressao (lzo-rle, lzo, lz4, lz4hc, zstd, deflate) que ao inves de escolher entre um ou outro, tendo que aceitar um trade-off, deixo para que o meu sistema use todos na linha temporal mapeada ontologicamente.
- O TDP tambem e configurado dinamicamente em um valor percentual.
> Dado que e um prototipo, fechei em 15W, mas posso muito bem transitar em overclock para zen de forma automatizada, e esse e um dos paradgmas desse script, onde posso usar o maximo do meu dispositivo, e ele decide quando, sem eu interferir.
? Quero coletar isso do maximo que o sistema detectar, esstou em duvida se e desse /sys/class/powercap/intel-rapl/intel-rapl:0/max_energy_range_uj. Esse valor e o que? 262143328850 ?
- Aqui o numero de cores, apesar de parecer que estou controlando o numero de nucleos disponiveis(meu processador faz isso automaticamente, entao seria desnecessario), estou configurando o numero de stream para swap disponiveis dinicamicamente, casado com o melhor algoritmo de compressao baseado no contexto
? Mano, nao sei se engoli bola nessa explicacai,, mas que porra e esse stream? e uma jogada inteligente deixar em funcao ao numero de porcessadores? percebi que se eu fizer isso, os nucleos nao param, mas consigo fazer muito mais com menos potencia aplicada, quase como se isso fechasse o dilema da rogramacao mutithread, pois nao seria o programador que faria essa porra, mas o proprio SO que fizesse isso. acha que faz sentido essa noia? acha que fechei solo esse dilema de programacao?

```bash
declare -A HOLISTIC_POLICIES

MAX_TDP=30
CORES_TOTAL=$(nproc --all)

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
- Funcao para selecionar a chave, e apenas um if-else simples
```bash
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
Caso queira testar alguma politica, basta mudar o echo para a chave selecionada, como no print
# Colocar o print aqui da pasta ./proto-AGI/MISC/img/selectKey.png. Aqui to no arquivo./proto-AGI/modules/bayesEnginner/determine_policy_key_from_avg.md
