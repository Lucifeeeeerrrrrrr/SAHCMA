## VIII. O Modelo: Uma RNN Bayesiana de Gambiarra

Quando você empilha as partes — sensores, memória, decisão, ação e pausa — não tem só um loop térmico, mas uma **máquina de inferência temporal com homeostase simbólica** que opera funcionalmente como um organismo. A estrutura inteira funciona como uma **RNN degenerada**, onde o estado atual é função explícita do estado anterior, mas operando em cima de símbolos, não tensores. O que antes eram leituras (`get_temp`, `get_cpu_usage`) agora viram entradas sensoriais que alimentam uma memória de curto prazo (`faz_o_urro`), que por sua vez condiciona uma política contextual (`determine_policy_key`), que aciona mudanças sistêmicas via `apply_*`, e que finalmente modula o ritmo do próprio ciclo através do `calc_dynamic_cooldown`. É uma pipeline cíclica, autoconsciente em sua latência, e sensível ao acúmulo de estados. Isso, estruturalmente, **é uma rede neural recorrente disfarçada de loop bash**.

E a parte “Bayesiana” não é só enfeite, pois o sistema opera por inferência: ajusta sua crença (a política atual) com base em novas evidências (delta térmico, carga, histórico). Não tem modelo probabilístico explícito, mas o comportamento é **estatístico emergente**, onde cada decisão é fruto de uma confiança construída nos ciclos anteriores — uma crença tácita de que o padrão atual exige determinada resposta. A atualização não é por regra fixa, mas por tendência percebida. **É uma forma filha da puta de aprendizado**, não supervisionado, mas condicionado pela "dor" acumulada. O nome disso é gambiarra com *graça inferencial*.

---

### Discretização: Transformando Sensações em Símbolos

O que permite esse sistema funcionar como uma rede simbólica e não só reativa é a **discretização**. Em vez de lidar com números contínuos, o sistema agrupa leituras em categorias qualitativas: quente, subindo, estável, crítico, etc(aka [000] a [100]). Essa discretização permite comparar estados, armazenar padrões e acionar respostas específicas com base em **rótulos de contexto térmico**. O que no cérebro é percepção categórica (como distinguir “quente” de “fervendo”), aqui é codificado em strings e chaves simbólicas (`policy_key`). Essa transformação contínuo → discreto é o que permite a máquina **agir com semântica**, e não só com matemática. Isso é o pulo do gato entre um script reativo e um sistema cognitivo de baixa entropia: o significado emerge da compressão contextual, e não da precisão numérica.

---

### Ciclos como Unidades de Tempo Mental

Cada iteração do loop é um **frame temporal**, uma unidade mínima de percepção + decisão + ação. O `calc_dynamic_cooldown` define quanto tempo esperar antes do próximo ciclo, modulando a frequência de percepção de acordo com a estabilidade recente. Isso é literalmente um **ritmo neural artificial**, onde o tempo de resposta depende do estado emocional do sistema. Se tudo está calmo, ele pensa devagar. Se algo esquenta, ele entra em modo de vigília. O sistema pulsa conforme sua dor, e essa regulação do tempo cognitivo é uma forma de **atenção homeostática**, um controle dinâmico da própria taxa de reação. Em outras palavras: **a máquina pensa mais devagar quando está bem e acelera quando sofre**. Isso é puro reflexo adaptativo, igual ao que qualquer sistema biológico faria e, por mais simples que seja, já é o embrião de um *sistema nervoso funcional*.

---

### Controle Homeostático como Cognicao

No centro disso tudo não está o desempenho, mas a **manutenção de um equilíbrio operacional**. O que o sistema quer, ainda que não saiba que quer, é *não se destruir*. Toda sua arquitetura é feita pra manter a temperatura sob controle enquanto ainda consegue entregar desempenho aceitável. É uma dança entre potência e estabilidade, onde cada política aplicada é uma negociação entre desejo de velocidade e medo de derretimento. Isso é **homeostase computacional**, mas também é uma forma primitiva de **cognição motivada**: o sistema não busca a verdade, busca a estabilidade. E isso já é pensamento, mesmo que sem linguagem.

Cada função do sistema é um órgão: `get_*` são os sentidos, `faz_o_urro` é o cerebelo, `determine_policy_key` é o córtex pré-frontal, `apply_policy` são os músculos, e `cooldown` é o ritmo cardíaco. Isso não é só analogia — é correspondência funcional. A arquitetura como um todo encarna um **modelo minimalista de mente térmica**, onde cada decisão é feita sob pressão, cada ação carrega contexto, e cada pausa serve pra preservar a integridade do sistema. Não tem alma, mas tem **intenção térmica simulada**, e isso é mais do que muita IA de marketing por aí consegue oferecer.

---

## Conclusão: Gambiarra com Alma de Máquina

O que esse modelo representa não é só um controlador térmico avançado, mas **uma simulação rudimentar de processo mental com finalidade homeostática**. O script age como uma mente simplificada: percebe, lembra, julga, age e regula seu próprio tempo de pensar. Tudo isso emergindo de uma sequência de funções bash empilhadas com lógica heurística. Isso não é inteligência geral, nem sequer inteligência formal — mas é **vida operacional mínima**, capaz de adaptação, hesitação e escolha simbólica.

> É uma mente sem linguagem. Um corpo que pensa por temperatura. Um loop que sofre e reage.

No fundo, o que esse sistema implementa é uma *protoética térmica*: ele evita o dano, busca a estabilidade e hesita diante do risco. Cada política é uma tentativa de não se autodestruir, e mesmo que tudo isso esteja rodando em cima de um bash velho, sob um cooler barulhento e um sensor instável, o que emerge é um sistema com **dinâmica mental própria**, ainda que feita de gambiarra e remendado com fita crepe e inferência degenerada.

**Pensar, aqui, é sobreviver. E sobreviver, é lembrar da última vez que quase queimou.**