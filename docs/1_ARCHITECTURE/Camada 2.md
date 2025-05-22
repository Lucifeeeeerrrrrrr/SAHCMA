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

