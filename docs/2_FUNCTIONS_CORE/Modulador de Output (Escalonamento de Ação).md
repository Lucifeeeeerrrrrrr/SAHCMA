## 🔄 `calc_dynamic_cooldown`- Modulação Escalonada por Severidade

```bash
calc_impact_cooldown() {
    local base_cd=$(calc_dynamic_cooldown)
    local impact_factor="$1"
    echo $(awk -v cd="$base_cd" -v factor="$impact_factor" 'BEGIN {print int(cd * factor)}')
}
```
Essa é uma **multiplicação da latência base pelo fator de impacto da ação proposta**.
* Ações mais agressivas → cooldown mais longo;
* Ações triviais → quase imediato.

Serve como **mecanismo de mitigação de efeitos colaterais**.

Esse comportamento é o embrião de uma forma de **autorregulação homeostática computacional**. O que, filosoficamente falando, é o caralho do **deslocamento da reatividade para a intencionalidade**, onde o sistema apresenta uma especie de escolha rudimentar.

## Como Funciona

Bom, aqui é basicamente para garantir que o sistema não fique se autoajustando de forma agressiva, e como entrada extra para a aplicação de multicanais. Assim evito transições brúscas além de suavizar o Shape de métricas coletadas, além de usar como refencia o calc_dynamic_cooldown para garantir a qualidade e precisão da chave selecionada.

Foi uma função meio tosca, mas ela mede o impacto de cada mudança antes de aplica-la(troca de zswap pesa muito mais do que troca de governor, por exemplo), assim tenho um sistema homeostático que, ao ser chamada pelo micro-hivermind, o sistema não crasheia.

## Analogia com Redes Neurais

Isso é post-processing adaptativo, em que, num sistema com attention mechanism, onde o grau de certeza ou urgência da inferência afeta a intensidade da resposta. Isso é comum em agentes de reforço (RL), onde a exploração vs. explotação é ajustada com base na entropia do modelo.

Na prática, é uma função de ativação modulada — um tipo de saída onde o resultado não é só “o que fazer”, mas quão intensamente fazer. Tipo um soft thresholding com delay adaptativo.MAS, sem todo esse role e explicando de forma tosca, essa porra é o sistema ponderando se vale a pena reagir rápido ou com calma, baseado no impacto.

## Termos

- RL(Reinforcement Learning): é um paradigma de aprendizado de máquina onde um agente (um programa de computador) aprende a tomar decisões em um ambiente para maximizar uma recompensa cumulativa.
> - O agente interage com o ambiente, realiza ações e recebe feedback na forma de recompensas ou penalidades.
>   - Aqui, se o sistema acertou, não hove variacões bruscas, caso tenha errado, houve variações e é penalizado levando mais tempo para se reativar
- Exploração vs. Explotação: é um dilema fundamental em RL que se refere à decisão que o agente deve tomar em um determinado momento: 
    - Exploração (Exploration): O agente experimenta novas ações ou explora partes desconhecidas do ambiente na esperança de descobrir ações que levem a recompensas maiores no futuro. É como tentar caminhos diferentes em um labirinto.
    - Explotação (Exploitation): O agente usa o conhecimento que já possui para tomar as ações que ele acredita serem as melhores para obter a maior recompensa imediata. É como seguir o caminho que você já sabe que leva à saída do labirinto.
> - Dado que as configurações são bem documentadas e seguem logica solida(varios threads e algortimos extremamente levez para ZRAM fazem sentidos quando a CPU está sobrecarregada, mas ociosa algoritmos pesados para reduzir trabalho da RAM), não é necessário exploração
- Entropia: é uma medida da incerteza ou aleatoriedade de um sistema. Em RL, a entropia do modelo pode ser usada para medir a incerteza sobre a melhor ação a ser tomada.
> - Alta entropia: Significa que o modelo tem uma grande probabilidade de escolher ações diferentes, mesmo que não sejam as consideradas ótimas com base no conhecimento atual. Isso geralmente está associado a uma maior exploração. O agente está "mais aberto" a tentar coisas novas.
> - Baixa entropia: Significa que o modelo tende a escolher as ações que ele acredita serem as melhores com base no seu aprendizado prévio. Isso está mais ligado à explotação. O agente está mais "confiante" nas suas escolhas, que é o caso das lookups que deixei pré-definidas.