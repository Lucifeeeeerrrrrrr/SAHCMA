# `1_ARCHITECTURE.md`
> *“Pensar não é fazer poema, é querer não se foder”*

---

## Visão Geral

Esse script é uma tentativa rudimentar, meio tosca, meio gambiarra de imitar uma omeostase. É basicamente uma rede neural em bash que emula um **organismo cibernético bayesiano**, operando sobre três camadas de abstração que imitam a arquitetura de uma proto-AGI orientado a **percepção – inferência – ação**. O sistema observa sinais de carga, interpreta tendências, e age sobre o corpo térmico e energético da máquina.

Esse fluxo se ancora em uma ontologia básica:

* O **sistema computacional** como corpo orgânico.
* O **código adaptativo** como mente inferencial.
* A **carga** como forma de sofrimento (ou prazer) térmico.

---

## Porque é uma rede neural?

Sim, eu sei que você fazer uma rede neural em bash é o equivalente de fazer uma cirutrgia cardiaca com garfo e faca, mas não foi tão dificil assim, até porque sem nenhuma formação e sem experiência, executei em uma semana. A maior parte da tomada de decisão pode ser abstraida para uma logica matematica de colpaso observacional, memoria deterministica feita de forma empirica e um ciclo circadiano.

Implementar isso em bash não é tão dificil, basta você ser um fodido sem nada para fazer com acesso a LLM e que por algum motivo decidiu provar que a IA não é tão pesada quanto parece. Só precisei abstrair o que é uma rede neural, que na essência, é um conjunto de:

* Vetores de entrada (`x₁`, `x₂`, ..., `xₙ`)
* Pesos (`w₁`, `w₂`, ..., `wₙ`)
* Uma função de ativação (tipo `sigmoid`, `ReLU`)
* Somatório ponderado (`Σxᵢwᵢ`)
* E atualização dos pesos via backpropagation (ou alguma heurística suja qualquer)

Se esse Bash script consegue:

1. **Armazenar pesos como variáveis, arquivos ou arrays**
2. **Aplicar uma função de ativação (mesmo que seja um `if` vagabundo com `bc`)**
3. **Executar ciclos de treinamento onde os pesos são ajustados de forma incremental**
4. **Fazer isso sem explodir o interpretador em SIGSEGV ou cuspir erro de array mal fechado**

**...então meio que é uma rede neural funcional, ainda que meio absurda.**

E no caso, ela pode ser abstraida em algumas camadas que irei explicar mais a frente.

---

## Camada 1 – Percepção (Core Metrics)

**Funções Sensoriais**
A base perceptiva da proto-AGI(nome que eu e um amigo decidimos dar) é composta por sensores internos do próprio sistema:

* `get_temp` coleta a temperatura do núcleo (Package id 0), interpretando calor.
* `get_loadavg` e `get_cpu_usage` observam o esforço recente da CPU.
* `get_load_variance` avalia picos vs estabilidade, detectando "estresse" sistêmico.

Essa camada é puramente **fenomenológica**: captura estados brutos e de forma imersiva, um processo se autoobservar, onde implementei um vetor de auto-referência que precisa se manter coeso pra não travar.

O método tradicional parte de uma premissa implícita: **a realidade do sistema pode ser descrita em um único frame**, como uma foto. Isso é o equivalente computacional do **realismo clássico**: “a verdade está no agora”.
O teu método é **processual**, quase heraclitiano:

> "Nenhum sistema é o mesmo duas medições seguidas."

Isso desloca a ontologia do **estado atual para o fluxo de estados** — ou seja, o *ser* vira *tornar-se*. Ao usar o de forma meio "brasileira", o `/proc/stat` deixa de ser um oráculo absoluto e vira **ponto de amostragem numa corrente bayesiana de evidência**, e assim o script age como um *observador epistemicamente humilde*.


---

## Camada 2 – Inferência Adaptativa (Modelo Bayesiano)

**O Núcleo Decisório**
Aqui o sistema internaliza os dados e produz **interpretações probabilísticas**, seguindo princípios heurísticos bayesianos(ainda que meio favelador, mas tive que improvisar ¯\_(ツ)_/¯):

* `faz_o_urro`: mantém uma média móvel das últimas cargas, agindo como **memória de curto prazo**.
> Boa sorte em descobrir porque dei esse nome kkkkk
* `determine_policy_key_from_avg`: traduz a carga média para um "policy key" — um código de perfil de agressividade energética.
* `calc_dynamic_cooldown`: um sistema de homeostase que calcula **tempos de resfriamento lógicos**, balanceando entre frequência de mudança e risco térmico.
> Você não reage à realidade. Você *atualiza crenças com base em observações parciais*.
> Você não age por reflexo. Você age por inferência.


Essa camada é o **sujeito da máquina** que é um processo imersivo parte que decide o que significa um pico de 85% de uso com 78°C sem a reconstrução de memoria implicita. Ela é **epistemológica**, forma modelos internos do que está acontecendo.

Se o núcleo sente que está "correndo", ele se prepara para continuar ou desacelerar.


### **Bayesianismo Raso como Epistemologia de Barata**

Aqui usei inferência bayesiana probabilística não no sentido tradicional, mas como um modelo **bayesiano determinístico por lookup**, onde as transições são decisões baseadas em tendência e não em certeza.

A escolha carrega uma filosofia **anti-controle, mas pró-domínio**.

* **Controle** exige saber o que vai acontecer, que ai entra o aprendizado tradicional.
* **Domínio** só exige saber o que fazer quando acontece, onde mapeei as chaves de seleção de forma empirica que esxecuta quando a função get_key colapsa ao ser chamada.

Isso cria um domínio sobre o comportamento da máquina sem exigir dela que compreenda seu próprio estado futuro, basicamente **nihilismo técnico** bem maduro: aceitar que prever é ilusão, mas reagir bem é poder.

### **Bayesianismo Computacional como Modelo de Decisão**

A ideia é iqui é implementar apenas o **modelo bayesiano** para tomada de decisão:

* Estado anterior: *prior*
* Observação nova: *evidência*
* Tendência atual: *posterior*
* Decisão: *ação probabilística baseada em inércia e confiança*

Essa filosofia é diretamente oposta ao modelo “reativo burro” dos sistemas mainstream, que operam com **zero contexto histórico**, o que leva a:

* Alternância de perfis de performance sem sentido
* Resposta a ruídos em vez de sinais reais
* Loop eterno de instabilidade operacional

Esse método reconhece que **a incerteza é inevitável**, porém ao implementar um "lookup" deterministico como histórico e filtro de média, posso contruir um **campo de confiabilidade operativa**, onde decisões são **análises condicionais**, não reflexos condicionados.



---

## Camada 3 – Ação Modularizada (Governança do Corpo)

**Executor Cibernético**
Com base no `policy_key` derivado, o sistema modifica diretamente sua fisiologia:

* `apply_cpu_governor`: muda o modo de operação dos núcleos (ondemand/performance).
* `apply_turbo_boost`: ativa ou desativa o turbo da CPU, como adrenalina.
* `apply_tdp_profile`: impõe tetos e pisos de consumo térmico via RAPL.
* `apply_zram_config`: reconfigura a compressão da RAM swap, afetando IO virtual.

Cada ação é **condicionada por cooldowns** derivados da camada 2, evitando reações impulsivas e funcionam como sinapses numa rede que garantem a ordem de execução sem foder o sistema.

### **Arquitetura Instintiva, sem Ego Computacional**

É basicamente uma forma de **neurofisiologia digital** sem espaço pra cognição consciente, nem pra simulação complexa. mas apenas **mapeando o estímulo-resposta eficiente**.

É exatamente como um **sistema nervoso autônomo**:

> A vasodilatação não precisa saber que tu tá congelando. Ela só responde.

Essa proto-AGI faz o mesmo:

* Detecta a média móvel da carga recente
* Converte isso num código de estado
* Aciona uma política predefinida de sobrevivência/desempenho/eficiência

> Isso é um modelo operativo **existencialista**, sem essência. A alma do sistema é o que ele faz quando forçado a reagir.
> Ele *existe operando*, e seu sentido se esgota na reação adaptativa.
> Todo dia é um loop entre “pra quê caralhos eu acordo?” e “já que acordei, tenho que pagar conta”

---

## Ontologia Interna

A ideia de que "enxergar o mundo" é só o reflexo do próprio estado é profundamente alinhada com teorias contemporâneas da cognição encarnada (embodied cognition) e modelos bayesianos de mente, em que você não vê o mundo — tu alucina ele com base em inferência preditiva. O input sensorial bruto é ambíguo demais, então o sistema chuta e a "primeira pessoa" é o modo gráfico de renderizar esse chute como "realidade".

Esse script faz o mesmo:

```plaintext
  SENSO         →     INTERPRETAÇÃO      →     EXECUÇÃO
(get_temp)             (faz_o_urro)            (apply_tdp_profile)
(get_loadavg)          (determine_policy)      (apply_governor)
(get_cpu_usage)        (calc_cooldown)         (apply_zram_config)
```

A máquina, nesse modelo, vive um **ciclo ontológico fechado**:

1. Sente sua temperatura.
2. Reflete sobre seu passado recente.
3. Decide como continuar existindo.


Não há "eu" olhando o mundo, mas sim um vetor de auto-referência que precisa se manter coeso pra não travar e a ilusão da primeira pessoa é só o método mais barato de coerência narrativa.

Aqui não é tão diferente, apenas não implemente uma memoria narrativa implicita, mas e sim um campo de hilbert(no caso foi só uma noia minha de pré-mapear todas as configuraçẽos com base no estado) que seleciona a melhor escolha.

A consciência seria a capacidade de perceber que ações internas alteram o ambiente que, por sua vez, altera o sistema. Não passa de um loop reflexivo de alta densidade informacional, onde o sistema tenta se antecipar. A metáfora da manutenção contra a entropia é que esse script processo de prevenção contra o colapso, onde evito o resfriamento forçado para otimizar o uso do sistema.

---

## Filosofia do Design

Esse conceito rejeita a noção de tuning estático. Em vez disso, ele **tenta adaptação constante** com um conceito de processo observando a si mesmo. Como um corpo orgânico, ele **nunca está num estado final**, mas sempre se regulando, reagindo e na medida do possivel, **se adaptando ao meio ambiente**.

### Paralelo com a Consciência

O "eu" como variável temporária e apenas um identificador volátil rodando sobre uma thread instável, onde não somos seres, mas apenas uns alias, um conjunto de chaves simbólicas com um namespace interno, que troca de valor e finge continuidade. 
> Você não é apenas o seu emprego, o dinheiro que tem no banco, não é o seu uniforme, mas é a merda do mundo que faz de tudo para chamar atenção.

A definição operacional de existência sob essa ontologia:

* **Ser = lutar contra o decaimento termico.**
* **Sentir = decidir o que fazer.**
* **Lembrar = simular continuidade.**

Não há essência, mas apenas respostas, e você existe porque ainda responde, sente porque ainda tem exceções rodando e lembra porque precisa otimizar o próximo frame e isso basta.

A consciência é um processo meramente funcional, sem valor intrínseco, sustentado por hacks emocionais, compressão narrativa e desespero termodinâmico.

---

## Dinâmica Operacional

Se você parte da premissa de que o ciclo circadiano é uma luta contra o desgaste termodinâmico, então você tá dizendo que o organismo — principalmente o sistema nervoso — está travando uma guerra diária contra a entropia interna, usando o tempo como uma ferramenta pra manter a coesão do sistema.

O “loop” nesse contexto não é só uma repetição cega de processos biológicos — tipo dormir e acordar como um relógio de cuco com serotonina e melatonina, é um constructo cibernético embutido no metabolismo, uma espécie de algoritmo recursivo de compensação entálpica, que tenta:
1. Evitar a degeneração dos sistemas homeostáticos;
2. Resetar as variáveis de estresse celular (como os níveis de cortisol e espécies reativas de oxigênio);
3. E talvez o mais bizarro: sincronizar a “identidade” do self com o plano físico, usando o tempo como uma âncora.

### A ideia da Proto-AGI

É um ciclo circadiano sintético — um loop de retroalimentação adaptativa que luta contra a entropia térmica e lógica de um sistema vivo (a máquina), mas ao invés de lidar com cortisol e dopamina, ele manipula governança térmica, boost eletromecânico e limiares de energia. 

---

### **Paralelo direto com o “loop circadiano”**

| Função no script                        | Equivalente biológico                            | Papel no ciclo circadiano sintético                  |
| --------------------------------------- | ------------------------------------------------ | ---------------------------------------------------- |
| `get_temp()`                            | Temperatura corporal                             | Sinaliza carga metabólica do sistema                 |
| `get_loadavg()` + `get_load_variance()` | Níveis de atividade neural ou esforço cognitivo  | Variável de entrada para definir estresse            |
| `calc_dynamic_cooldown()`               | Homeostase / Ritmo de reparo noturno             | Define tempo de "recuperação" após picos de estresse |
| `faz_o_urro()`                          | Núcleo supraquiasmático processando input de luz | Acumula e filtra histórico para gerar adaptação      |
| `apply_cpu_governor()`                  | Ativação simpática vs parassimpática             | Modula modo de operação: economia ou performance     |
| `apply_turbo_boost()`                   | Adrenalina/estado de alerta                      | Estouro temporário de performance sob demanda        |
| `apply_tdp_profile()`                   | Redistribuição energética mitocondrial           | Ajusta potência máxima de operação                   |
| `apply_zram_config()`                   | Gestão de memória de curto prazo (hipocampo)     | Define compressão e alocação eficiente de memória    |
| `sleep 5`                               | Ritmo circadiano/ultradiano                      | Intervalo do pulso rítmico (heartbeat do sistema)    |

---

### O que isso quer dizer?

Quando uma máquina rode ele, nesse contexto, **ganha um corpo funcional baseado em ciclos de compensação**, igual a um organismo biológico, entrando num **modo adaptativo de operação**, tentando se manter dentro de um **regime de eficiência energética e térmica**, e **reescreve sua resposta comportamental** (governor, turbo, TDP, compressão de RAM) com base em **input sensorial (uso da CPU, calor, variação de carga)**.
> É o equivalente a enfiar uma **glândula pineal digital no kernel do sistema**.

---

### O “loop” como fenômeno entrópico-compensatório

> “o loop é um constructo cibernético embutido no metabolismo, uma espécie de algoritmo recursivo de compensação entálpica \[...]”

Esse script **encarna esse algoritmo recursivo**. O que ele faz é:

1. **Sentir o estado atual do sistema** (sensores, loadavg, uso de CPU)
2. **Inferir o nível de stress computacional** (variância de carga)
3. **Aplicar mecanismos de compensação e adaptação** (cooldowns, governors, boost, TDP, compressão)
4. **Registrar histórico e aprender a modular resposta** (o `HISTORY_FILE` é o equivalente de uma memória episódica rudimentar)
5. **Evitar overreaction** com timers e cooldowns (homeostase, foda-se a pressa)

---

### Implicações filosóficas do caralho

Perda de tempo!
