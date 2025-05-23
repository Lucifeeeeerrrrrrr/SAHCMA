# `faz_o_urro`

```bash
faz_o_urro() {
    local new_val="$1" history_arr=() sum=0 avg=0
    [[ -f "$HISTORY_FILE" ]] && mapfile -t history_arr < "$HISTORY_FILE"
    history_arr+=("$new_val")
    (( ${#history_arr[@]} > MAX_HISTORY )) && history_arr=("${history_arr[@]: -$MAX_HISTORY}")
    for val in "${history_arr[@]}"; do sum=$((sum + val)); done
    avg=$((sum / ${#history_arr[@]}))
    printf "%s\n" "${history_arr[@]}" > "$HISTORY_FILE"
    echo "$avg"
}
```
Implementação literal de **buffer circular com agregação por média aritmética**.
* Serve pra suavizar leituras ruidosas;
* Cria **perfil de tendência sistêmica**;
* Usável como feature de input pra modelos preditivos.

## O que ele faz?

Aqui implementei para resolver o problema de medidas, dado que o processador oscila em função de chamadas, e para evitar picos, tipo, ao abrir um programa, foi necessário implementar uma função de suavisação através de um histograma de frequencia com um limite definido.

Os valores são salvos em um arquivo temporário, e a média é calculada a cada nova leitura, e no caso, fiz de forma emperica e o melhor valor para minha situação foi 5, mas há um valor escalável, tipo, valores mais altos são mais devagares de transição, menores são frenéticos, sendo basicamente um SQLite de pobre armazenando média móvel em arquivo de texto. 
> Confesso que é DEPRIMENTE, mas fazer o que? ¯\_(ツ)_/¯.

## Analogia com NN

Explicando de forma simples, é janela deslizante temporal, tipo uma camada de average pooling numa CNN, mas aplicada ao tempo em vez do espaço, agregando múltiplos inputs ao longo do tempo e diluindo outliers, ou seja, reduz ruído sem perder o shape da tendência.

Na prática, isso funciona como um filtro de média móvel, o mesmo tipo de lógica usada no pré-processamento de séries temporais para alimentar redes como Temporal Convolutional Networks ou RNNs com atenção, porém fiz isso para lidar com as mudanças bruscas de CPU.
>- A "memória curta" da get_cpu_usage vira uma "memória intermediária" aqui.
> - A rede começa a construir um estado interno do sistema.

### Termos

- Pooling temporal: é uma técnica de aprendizado de máquina que combina várias amostras de tempo em uma única representação. É frequentemente usado em redes neurais convolucionais (CNNs) para reduzir a dimensionalidade dos dados e extrair características importantes.
> - Imagine que você tem um mapa de "detalhes" (features) da sua entrada. 
> - O pooling pega pequenas janelas desse mapa e as resume em um único valor.
> - O objetivo é reduzir o número de parâmetros na rede para apenas uma projeção holografica baseada em espelhos markovianos
- CNNs(Convolutional Neural Network): CNNs são um tipo de rede neural profunda especialmente eficaz para processar dados com estrutura em grade, como matrizes.
> - Elas são compostas por camadas de convolução (que aprendem padrões espaciais aplicando filtros), camadas de pooling (para reduzir a dimensionalidade) e camadas totalmente conectadas (para a classificação final, por exemplo).
- Shape: refere ao formato ou às dimensões de um array ou tensor (estruturas de dados multidimensionais).
> - Por exemplo, se você tem uma série temporal com 100 pontos de dados e cada ponto tem 3 características, o "shape" dessa série poderia ser (100, 3).
> - No contexto, "perder o shape da tendência" significa que, apesar de reduzir o ruído, a operação de pooling não deve distorcer a forma geral ou a progressão da tendência principal nos seus dados temporais.
- RNNs(Redes Neurais Recorrentes): São uma classe de redes neurais que possuem uma estrutura de feedback, o que significa que as saídas de uma camada podem ser usadas como entradas para a própria camada.
> - A principal característica das RNNs é a sua capacidade de manter um estado interno (memória) que permite que elas aprendam dependências entre elementos em uma sequência.

## Noias de Física

- Tempo e Espaço no Campo Quântico (Palavras para dar Peso):
> - A ideia de tempo e espaço como "dois lados da mesma moeda" tem raízes na Teoria da Relatividade Restrita e Geral (não foi Einstein, foi um italiano que morreu triste porque nem a mãe sabia quem ele era), onde tempo e espaço são unidos no conceito de espaço-tempo.
> - No campo quântico, essa relação é ainda mais profunda. A localidade (conceito espacial) e a causalidade (conceito temporal) são princípios fundamentais, embora suas interações no nível quântico possam ser não-intuitivas (pense no emaranhamento quântico).
> - Parto da premissa que a física quantoca é mais abstração de como a nossa mente processa a realidade, 
>   - tipo, não dá para saber o que tem atrás da parede, e nesse estado de superposição, pode ter literalmente tudo, desde um gato até um politico honesto 
> - A física clássica apenas explica o que acontece e como o nosso cérebro rendiriza a colisão do objeto A com objeto B por exemplo.