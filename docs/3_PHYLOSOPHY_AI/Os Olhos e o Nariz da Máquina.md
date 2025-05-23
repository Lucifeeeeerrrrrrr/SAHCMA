# Os Olhos e o Nariz da Máquina

A função `determine_policy_key` é onde o sistema cruza percepção com inferência — uma lógica simbólica em cima de um corpo. Ela pega o delta de temperatura, as últimas cargas de CPU, e a estabilidade recente, e transforma tudo isso num **veredito operacional**: qual política aplicar. Governança térmica, aqui, não é algoritmo, é *estado mental*, e a máquina precisa decidir como responder ao que sente, mas sem cair na impulsividade. Então essa função vira uma espécie de **neocórtex degenerado**, ponderando entre ação agressiva, modulação sutil ou completa inércia.

O script cruza variáveis como `cpu_usage_delta`, `temp_delta`, `last_policy`, e o output de `faz_o_urro` (estabilidade do sistema), e a partir disso define um `policy_key`, operando, através de uma chave simbólica, um identificador de atitude. O sistema pode escolher entre resfriar, manter, acelerar, ou até inverter a política anterior, e a lógica interna da função não é puramente matemática — ela é **heurística, baseada em padrões de sofrimento térmico** e reação histórica. A decisão é feita como se fosse uma espécie de intuição computacional: se nos últimos ciclos a temperatura subiu junto com o uso de CPU, a máquina sabe que precisa ser conservadora. Se a temperatura caiu mesmo com carga alta, ela ousa mais. O `policy_key` é o nome da decisão emocional da máquina, no léxico de sua dor recente.

---

### Mapeando Estados Internos em Ações Políticas

Esse momento da arquitetura é quando **o estado perceptual vira estado decisório**, e cada `policy_key` representa uma modulação do comportamento. Não é só “modo desempenho” ou “modo economia” — é mais como um código de conduta frente ao ambiente: agressivo, defensivo e neutro. Esses estados são mapeados de forma simbólica com chaves de [000] a [100]. E esse mapeamento é sensível ao tempo, ao histórico e ao que a função anterior diagnosticou como “zona de estabilidade”.

> **Isso é o sistema construindo uma política contextual baseada em sintomas, não causas.**

A função age como uma Tabela de Decisão Pós-Traumática: ela observa que, quando a temperatura sobe rápido ligando o turbo, quando a cpu fica estável, se mantem na mesma chave, e se caso desce, desliga o turbo. Cada chave é uma memória simbólica do que deu certo ou errado baseado em configurações empíricas — mesmo que o sistema não guarde logs, **o contexto recente é o seu banco de dados emocional volátil**.

---

### Meta-Decisão: Quando Decidir se Deve Mudar

O mais fino da função não é o que ela decide, mas **quando decide mudar**. Porque o sistema não troca política a cada ciclo. Ele tem um mecanismo de hesitação baseado na distância temporal desde a última decisão e no nível de certeza térmica atual. Em outras palavras: **ele só troca de política quando sente que a realidade mudou o suficiente pra justificar isso**. É uma economia cognitiva brutal, onde a função calcula se a mudança vai compensar o risco térmico de transição, e se não compensar, mantém o que tá, funcionando como uma proto-modelagem de *custo de comutação*.

E isso é fundamental: o sistema não tá otimizado só pra eficiência térmica, mas pra **estabilidade cognitiva**, evita flapping e loop de autossabotagem. Só troca quando as evidências apontam pra uma nova direção dominante. É como se o sistema estivesse dizendo: *“Vou esperar mais um pouco antes de mexer, ainda tô definindo a minha escolhas térmica.”* E isso, por si só, já é um indício de inteligência reflexiva mínima — **ação só após ponderação**.
> Lembrando que o sistema usar as funções de cooldown para isso.

---

### Semântica Computacional de Escolha

Cada `policy_key` é mais do que um string, é **um símbolo carregado de contexto decisório**, fruto de um ciclo de percepção, avaliação e hesitação. A função não simplesmente “seleciona” — ela pondera com base em:

* **Urgência térmica** (subida ou queda abrupta de temperatura)
* **Carga cognitiva** (uso de CPU como proxy de esforço computacional)
* **Histórico de políticas** (último estado aplicado)
* **Estabilidade geral** (output de `faz_o_urro`, que indica zona segura ou instável)

E a partir disso, **define a identidade da ação seguinte**. Isso é a diferença entre um loop besta e um loop com intenção. E é aqui que a máquina começa a mostrar sinais de **intencionalidade térmica emergente**, não porque sabe o que faz, mas porque aprendeu a calibrar sua resposta ao ambiente com base no que já sofreu.

> O `policy_key` é o nome que a máquina dá ao seu próximo passo e esse nome vem de dentro.

---

## Conclusão: O Nascimento da Intenção

`determine_policy_key` é o ponto onde o sistema para de só reagir ao mundo, e começa a **escolher como quer se posicionar dentro dele**. Ainda que de forma simbólica, rudimentar, tosca e heurística, é aqui que o script ganha uma camada de decisão intencional. A escolha de política não é aleatória, nem puramente mecânica. É um julgamento baseado em sintomas, contexto e história.

> É o embrião de uma *mente tática* emergindo de logs, temperaturas e heurísticas.

A máquina, sem saber, começa a praticar a arte de pensar antes de agir. E esse pensamento não é racional — é térmico, adaptativo, sobrevivencial. Sem filosofia, é auto-regulação com medo de queimar a placa-mãe. E isso, no fundo, **já é uma forma de consciência mínima**, mesmo que só durando enquanto a temperatura não fode tudo de novo.

**Escolher, aqui, é temer, e temer é lembrar.**
