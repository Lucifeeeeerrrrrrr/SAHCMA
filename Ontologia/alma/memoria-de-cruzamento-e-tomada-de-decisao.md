# Memoria de Cruzamento e Tomada de Decisão

A alma desse sistema reside na tabela `HOLISTIC_POLICIES`, um mapa pré-definido que conecta o estado atual da máquina a um conjunto completo de configurações otimizadas, funcionando como um cérebro reptiliano que já sabe a melhor resposta para certos estímulos sem precisar pensar muito, apenas reagir com base no que já foi mapeado como eficiente para aquela situação específica, essa abordagem bayesiana simplificada permite uma adaptação rápida e determinística.

> Ou seja, ao invés de ser simplesmente reativa entre, onde espera sobre-aquecer para tomar decisão, o objetivo é fazer um tunig inteligente, onde cada consfiguração é pré-mapeada e a maquina se ajusta com base naquela configuração.

A chave de acesso a essa tabela é basicamente o uso da CPU representando a tendência de carga recente através de um cálculo de média simples, em que os ultimos 5 valores são armazenados numa lista FiFo, e a média entre eles é o indicador de estado(por exemplo, em repouco, o notebook usa 30% da CPU, mas em uma tarefa mais pparruda, ele vai para 70% e o sistema detecta isso), criando assim ;um código único que reflete uma fotografia multifacetada do estado operacional do sistema naquele instante.

> Aqui a configuração funciona maios ou menos seguindo o padrão de adaptação humano, e como exemplo, posso citar o resfriamento termico, onde ao invés do corpo esperar a hiportemia, ele simplemente contrai ou dilata a circulação sanguínea, assim garantindo um controle inteligente sobre a temperatura corporal

A beleza está em não precisar de uma IA complexa ou machine learning pesado para decidir, mas sim usar esses indicadores físicos diretos para escolher uma receita de bolo já testada e aprovada na `HOLISTIC_POLICIES`, garantindo uma resposta previsível e eficiente baseada nas condições reais do hardware sem sobrecarregar o próprio sistema com cálculos complexos de otimização.

> [O software de teste aqui](https://github.com/Pedro-02931/LaplaceDemon/blob/prototypes/Rede/autoconf.sh) já está funcinou aqui nesse repositório, onde fiz com base em protencia de sinal em roteador, extendendo a distancia util de trabalho sem perda de pacotes.

{% code overflow="wrap" %}
```bash
declare -A HOLISTIC_POLICIES=(
    # Formato: "CPU Gov | Power Limit (%TDP) | TDP Limit (%TDP) | GPU Clock (%GPU_MAX) | | Algoritmo ZRAM | Streams | Swappiness"
    ["000"]="ondemand    $((MAX_TDP * 20 / 100)) $((MAX_TDP * 15 / 100)) $((MAX_GPU_CLOCK * 30 / 100)) zstd $((CORES_TOTAL * 25 / 100)) 10"
    ["010"]="ondemand    $((MAX_TDP * 25 / 100)) $((MAX_TDP * 18 / 100)) $((MAX_GPU_CLOCK * 35 / 100)) zstd $((CORES_TOTAL * 30 / 100)) 15"
    ["020"]="ondemand    $((MAX_TDP * 30 / 100)) $((MAX_TDP * 20 / 100)) $((MAX_GPU_CLOCK * 40 / 100)) lz4  $((CORES_TOTAL * 40 / 100)) 20"
    ["030"]="ondemand    $((MAX_TDP * 35 / 100)) $((MAX_TDP * 22 / 100)) $((MAX_GPU_CLOCK * 45 / 100)) lz4  $((CORES_TOTAL * 50 / 100)) 25"
    ["040"]="ondemand    $((MAX_TDP * 40 / 100)) $((MAX_TDP * 25 / 100)) $((MAX_GPU_CLOCK * 50 / 100)) lzo  $((CORES_TOTAL * 60 / 100)) 30"
    ["050"]="userspace   $((MAX_TDP * 50 / 100)) $((MAX_TDP * 30 / 100)) $((MAX_GPU_CLOCK * 60 / 100)) lz4  $((CORES_TOTAL * 70 / 100)) 35"
    ["060"]="userspace   $((MAX_TDP * 60 / 100)) $((MAX_TDP * 35 / 100)) $((MAX_GPU_CLOCK * 70 / 100)) lzo  $((CORES_TOTAL * 80 / 100)) 40"
    ["070"]="performance $((MAX_TDP * 70 / 100)) $((MAX_TDP * 40 / 100)) $((MAX_GPU_CLOCK * 80 / 100)) zstd $((CORES_TOTAL * 90 / 100)) 50"
    ["080"]="performance $((MAX_TDP * 90 / 100)) $((MAX_TDP * 50 / 100)) $((MAX_GPU_CLOCK * 90 / 100)) lz4  $((CORES_TOTAL)) 55"
    ["090"]="performance $((MAX_TDP * 95 / 100)) $((MAX_TDP * 55 / 100)) $((MAX_GPU_CLOCK * 95 / 100)) lz4  $((CORES_TOTAL)) 60"
    ["100"]="performance $((MAX_TDP))           $((MAX_TDP))           $((MAX_GPU_CLOCK))           zstd $((CORES_TOTAL)) 65"
)
```
{% endcode %}

***
